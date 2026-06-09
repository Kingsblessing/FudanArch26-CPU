`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

import common::*;
import csr_pkg::*;

typedef struct packed { logic [1:0] forward_a; logic [1:0] forward_b; } forward_ctrl_t;

typedef struct packed { logic valid; u64 pc; u32 instr; } REG_IF_ID;

typedef struct packed {
    logic valid; u64 pc; u32 instr; u64 rs1_data; u64 rs2_data; u64 imm;
    logic [4:0] rd, rs1, rs2; logic [2:0] funct3; logic [6:0] funct7, opcode;
    logic is_load, is_store, is_branch, is_jump, is_alu, is_aluimm, is_lui, is_auipc, is_system, is_csr;
    logic [4:0] alu_op; logic alu_src; logic mem_write, mem_read, reg_write; logic [1:0] mem_to_reg;
    logic except_illegal_instr;
} REG_ID_EX;

typedef struct packed {
    logic valid; u64 pc; u32 instr; u64 alu_result; u64 rs2_data; u64 imm; logic [4:0] rd;
    logic is_load, is_store; logic mem_write, mem_read; logic reg_write; logic [1:0] mem_to_reg;
    logic csr_pending; u12 csr_paddr; word_t csr_pwdata;
    logic trap_pending; logic trap_is_mret; u2 trap_priv;
    logic trap_is_interrupt; logic [5:0] trap_code;
} REG_EX_MEM;

typedef struct packed {
    logic valid; u64 pc; u32 instr; u64 alu_result; u64 mem_data; logic [4:0] rd;
    logic reg_write; logic [1:0] mem_to_reg;
    logic csr_pending; u12 csr_paddr; word_t csr_pwdata;
    logic trap_pending; logic trap_is_mret; u2 trap_priv;
    logic trap_is_interrupt; logic [5:0] trap_code;
} REG_MEM_WB;

`ifdef VERILATOR
`include "src/csr_regfile.sv"
`include "src/mmu.sv"
`include "src/fetch.sv"
`include "src/decode.sv"
`include "src/execute.sv"
`include "src/memory.sv"
`include "src/writeback.sv"
`include "src/regfile.sv"
`include "src/forward_unit.sv"
`endif

`ifdef VIVADO
`include "csr_regfile.sv"
`include "fetch.sv"
`include "decode.sv"
`include "execute.sv"
`include "memory.sv"
`include "writeback.sv"
`include "regfile.sv"
`include "forward_unit.sv"
`include "mmu.sv"
`endif

module core import common::*;(
    input logic clk, reset,
    output ibus_req_t ireq, input ibus_resp_t iresp,
    output dbus_req_t dreq, input dbus_resp_t dresp,
    input logic trint, swint, exint,
    output u2 priv_mode_out, output word_t satp_out
);
    assign priv_mode_out = priv_mode;
    always_ff @(posedge clk) begin if (reset) priv_mode_difftest <= 2'b11; else priv_mode_difftest <= priv_mode_q; end
    assign satp_out = csr_satp_mmu;

    word_t mem_forward_data, csr_rdata;
    word_t csr_mstatus, csr_mtvec_trap, csr_mtvec_dbg, csr_mip, csr_mie, csr_mscratch;
    word_t csr_mcause, csr_mtval, csr_mepc_trap, csr_mepc_dbg, csr_mcycle, csr_mhartid;
    word_t csr_satp_mmu, csr_satp_dbg;
    word_t csr_mie_q;
    u2 priv_mode, priv_mode_q, priv_mode_difftest;
    logic trap_fire, trap_is_mret; u12 trap_ecall_imm; u64 trap_pc; logic trap_csr_commit;
    u64 fetch_current_pc;
    /* verilator lint_off UNOPTFLAT */
    logic interrupt_fire;
    /* verilator lint_on UNOPTFLAT */
    logic [5:0] interrupt_cause_code;
    logic combined_redirect_valid; u64 combined_redirect_pc; logic combined_trap; logic trap_in_progress;

    logic fetch_ok, decode_ok, execute_ok, mem_ok, writeback_ok, step;
    logic redirect_valid; u64 redirect_pc; logic difftest_skip;
    u64 interrupt_save_pc;
    REG_IF_ID if_id_reg; REG_ID_EX id_ex_reg; REG_EX_MEM ex_mem_reg; REG_MEM_WB mem_wb_reg;
    forward_ctrl_t forward_ctrl;
    logic reg_wen; u5 reg_waddr; word_t reg_wdata, reg_rdata1, reg_rdata2;
    logic commit_valid; u64 commit_pc; u32 commit_instr; logic commit_wen; u5 commit_wdest; word_t commit_wdata;

    csr_regfile csr_regfile_inst(
        .clk(clk), .reset(reset),
        .csr_we(step & mem_wb_reg.valid & mem_wb_reg.csr_pending),
        .csr_waddr(mem_wb_reg.csr_paddr), .csr_wdata(mem_wb_reg.csr_pwdata),
        .csr_raddr(id_ex_reg.imm[11:0]), .csr_rdata(csr_rdata),
        .trap_fire_ex(trap_fire), .trap_csr_commit(trap_csr_commit),
        .trap_is_mret_ex(trap_is_mret), .trap_is_mret_wb(mem_wb_reg.trap_is_mret),
        .trap_priv_wb(mem_wb_reg.trap_priv), .trap_pc(trap_pc),
        .trint(trint), .swint(swint), .exint(exint),
        .interrupt_taken(interrupt_fire),
        .trap_is_interrupt_wb(mem_wb_reg.trap_is_interrupt), .trap_code_wb(mem_wb_reg.trap_code),
        .priv_mode(priv_mode), .priv_mode_q_out(priv_mode_q),
        .mtvec_o(csr_mtvec_trap), .mepc_o(csr_mepc_trap), .satp_o(csr_satp_mmu),
        .dbg_mstatus(csr_mstatus), .dbg_mtvec(csr_mtvec_dbg), .dbg_mip(csr_mip), .dbg_mie(csr_mie),
        .dbg_mscratch(csr_mscratch), .dbg_mcause(csr_mcause), .dbg_mtval(csr_mtval),
        .dbg_mepc(csr_mepc_dbg), .dbg_mcycle(csr_mcycle), .dbg_mhartid(csr_mhartid), .dbg_satp(csr_satp_dbg),
        .mie_q_out(csr_mie_q)
    );

    fetch fetch_module(.clk(clk), .reset(reset), .step(step), .fetch_ok(fetch_ok), .ireq(ireq), .iresp(iresp),
        .redirect_valid(combined_redirect_valid), .redirect_pc(combined_redirect_pc),
        .trap_fire(combined_trap), .if_id_reg(if_id_reg), .current_pc(fetch_current_pc));

    decode decode_module(.clk(clk), .reset(reset), .step(step), .decode_ok(decode_ok), .if_id_reg(if_id_reg),
        .reg_rdata1(reg_rdata1), .reg_rdata2(reg_rdata2),
        .flush(combined_redirect_valid | combined_trap), .id_ex_reg(id_ex_reg));

    execute execute_module(.clk(clk), .reset(reset), .step(step), .execute_ok(execute_ok), .id_ex_reg(id_ex_reg),
        .forward_ctrl(forward_ctrl), .wb_data(reg_wdata), .mem_forward_data(mem_forward_data),
        .csr_rdata(csr_rdata), .csr_mtvec(csr_mtvec_trap), .csr_mepc(csr_mepc_trap),
        .priv_mode_q(priv_mode_q),
        .redirect_valid(redirect_valid), .redirect_pc(redirect_pc),
        .trap_fire(trap_fire), .trap_is_mret(trap_is_mret), .trap_ecall_imm(trap_ecall_imm),
        .interrupt_fire(interrupt_fire), .interrupt_pc(interrupt_save_pc),
        .interrupt_cause_code(interrupt_cause_code), .ex_mem_reg(ex_mem_reg));

    memory memory_module(.clk(clk), .reset(reset), .step(step), .mem_ok(mem_ok), .ex_mem_reg(ex_mem_reg),
        .flush(combined_trap), .dreq(dreq), .dresp(dresp), .mem_wb_reg(mem_wb_reg),
        .mem_forward_data(mem_forward_data));

    forward_unit forward_unit_module(.id_ex_rs1(id_ex_reg.rs1), .id_ex_rs2(id_ex_reg.rs2),
        .ex_mem_rd(ex_mem_reg.rd), .ex_mem_reg_write(ex_mem_reg.reg_write & ex_mem_reg.valid),
        .mem_wb_rd(mem_wb_reg.rd), .mem_wb_reg_write(mem_wb_reg.reg_write & mem_wb_reg.valid),
        .forward_ctrl(forward_ctrl));

    writeback writeback_module(.clk(clk), .reset(reset), .step(step),
        .block_commit(trap_csr_commit & ~mem_wb_reg.trap_is_mret), .writeback_ok(writeback_ok),
        .mem_wb_reg(mem_wb_reg), .reg_wen(reg_wen), .reg_waddr(reg_waddr), .reg_wdata(reg_wdata),
        .commit_valid(commit_valid), .commit_pc(commit_pc), .commit_instr(commit_instr),
        .commit_wen(commit_wen), .commit_wdest(commit_wdest), .commit_wdata(commit_wdata));

    regfile regfile_module(.clk(clk), .reset(reset),
        .raddr1(if_id_reg.instr[19:15]), .raddr2(if_id_reg.instr[24:20]),
        .wen(reg_wen), .waddr(reg_waddr), .wdata(reg_wdata), .rdata1(reg_rdata1), .rdata2(reg_rdata2));

    assign step = fetch_ok & decode_ok & execute_ok & mem_ok & writeback_ok;

    always_comb begin
        interrupt_fire = 1'b0; interrupt_cause_code = 6'd0;
        if (step && fetch_ok && !trap_fire && !trap_csr_commit && !trap_in_progress) begin
            if ((priv_mode_q == 2'b11 && csr_mstatus[3]) || (priv_mode_q != 2'b11)) begin
                if (exint && csr_mie_q[11]) begin interrupt_fire = 1'b1; interrupt_cause_code = 6'd11; end
                else if (swint && csr_mie_q[3]) begin interrupt_fire = 1'b1; interrupt_cause_code = 6'd3; end
                else if (trint && csr_mie_q[7]) begin interrupt_fire = 1'b1; interrupt_cause_code = 6'd7; end
            end
        end
    end

    assign combined_redirect_valid = redirect_valid | interrupt_fire;
    assign combined_redirect_pc   = interrupt_fire ? csr_mtvec_trap : redirect_pc;
    assign combined_trap           = trap_fire | interrupt_fire;
    assign trap_in_progress        = ex_mem_reg.trap_pending || mem_wb_reg.trap_pending;
    assign trap_csr_commit         = step & mem_wb_reg.valid & mem_wb_reg.trap_pending;
    assign trap_pc                 = mem_wb_reg.pc;
    assign interrupt_save_pc       = ex_mem_reg.valid ? ex_mem_reg.pc :
                                     id_ex_reg.valid  ? id_ex_reg.pc  : fetch_current_pc;

    assign difftest_skip = commit_valid && ((commit_instr[6:0] == 7'b0000011) || (commit_instr[6:0] == 7'b0100011)) && (mem_wb_reg.alu_result[31] == 1'b0);

`ifdef VERILATOR
    DifftestInstrCommit DifftestInstrCommit(.clock(clk), .coreid(csr_mhartid[7:0]), .index(0),
        .valid(commit_valid), .pc(commit_pc), .instr(commit_instr), .skip(difftest_skip),
        .isRVC(0), .scFailed(0), .wen(commit_wen), .wdest({3'b0, commit_wdest}), .wdata(commit_wdata));

    DifftestArchIntRegState DifftestArchIntRegState(.clock(clk), .coreid(csr_mhartid[7:0]),
        .gpr_0(regfile_module.next_reg[0]), .gpr_1(regfile_module.next_reg[1]), .gpr_2(regfile_module.next_reg[2]), .gpr_3(regfile_module.next_reg[3]),
        .gpr_4(regfile_module.next_reg[4]), .gpr_5(regfile_module.next_reg[5]), .gpr_6(regfile_module.next_reg[6]), .gpr_7(regfile_module.next_reg[7]),
        .gpr_8(regfile_module.next_reg[8]), .gpr_9(regfile_module.next_reg[9]), .gpr_10(regfile_module.next_reg[10]), .gpr_11(regfile_module.next_reg[11]),
        .gpr_12(regfile_module.next_reg[12]), .gpr_13(regfile_module.next_reg[13]), .gpr_14(regfile_module.next_reg[14]), .gpr_15(regfile_module.next_reg[15]),
        .gpr_16(regfile_module.next_reg[16]), .gpr_17(regfile_module.next_reg[17]), .gpr_18(regfile_module.next_reg[18]), .gpr_19(regfile_module.next_reg[19]),
        .gpr_20(regfile_module.next_reg[20]), .gpr_21(regfile_module.next_reg[21]), .gpr_22(regfile_module.next_reg[22]), .gpr_23(regfile_module.next_reg[23]),
        .gpr_24(regfile_module.next_reg[24]), .gpr_25(regfile_module.next_reg[25]), .gpr_26(regfile_module.next_reg[26]), .gpr_27(regfile_module.next_reg[27]),
        .gpr_28(regfile_module.next_reg[28]), .gpr_29(regfile_module.next_reg[29]), .gpr_30(regfile_module.next_reg[30]), .gpr_31(regfile_module.next_reg[31]));

    logic [31:0] difftest_exc_cause;
    assign difftest_exc_cause = (trap_csr_commit && !mem_wb_reg.trap_is_mret && !mem_wb_reg.trap_is_interrupt) ? {26'b0, mem_wb_reg.trap_code} : 32'b0;

    DifftestArchEvent DifftestArchEvent(.clock(clk), .coreid(csr_mhartid[7:0]),
        .intrNO(trap_csr_commit && mem_wb_reg.trap_is_interrupt ? {26'b0, mem_wb_reg.trap_code} : 32'b0),
        .cause(difftest_exc_cause), .exceptionPC(trap_pc));

    DifftestTrapEvent DifftestTrapEvent(.clock(clk), .coreid(csr_mhartid[7:0]),
        .valid(commit_valid && (commit_instr == 32'h0005006b)),
        .code(regfile_module.next_reg[10][2:0]), .pc(commit_pc), .cycleCnt(0), .instrCnt(0));

    DifftestCSRState DifftestCSRState(.clock(clk), .coreid(csr_mhartid[7:0]),
        .priviledgeMode(priv_mode_difftest), .mstatus(csr_mstatus), .sstatus(csr_mstatus & SSTATUS_MASK),
        .mepc(csr_mepc_dbg), .sepc(64'b0), .mtval(csr_mtval), .stval(64'b0),
        .mtvec(csr_mtvec_dbg), .stvec(64'b0), .mcause(csr_mcause), .scause(64'b0),
        .satp(csr_satp_dbg), .mip(csr_mip), .mie(csr_mie), .mscratch(csr_mscratch), .sscratch(64'b0),
        .mideleg(64'b0), .medeleg(64'b0));
`endif
endmodule

`endif
