`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module execute import common::*;(
    input  logic       clk, reset,
    input  logic       step,
    output logic       execute_ok,
    input  REG_ID_EX   id_ex_reg,
    input  forward_ctrl_t forward_ctrl,
    input  word_t      wb_data,
    input  word_t      mem_forward_data,
    input  word_t      csr_rdata,
    input  word_t      csr_mtvec,
    input  word_t      csr_mepc,
    input  u2          priv_mode_q,
    input  u2          priv_mode,
    output logic       redirect_valid,
    output u64         redirect_pc,
    output logic       trap_fire,
    output logic       trap_is_mret,
    output u12         trap_ecall_imm,
    input  logic       interrupt_fire,
    input  u64         interrupt_pc,
    input  logic [5:0] interrupt_cause_code,
    output REG_EX_MEM  ex_mem_reg
);
    localparam logic [4:0] ALU_MUL   = 5'd16;
    localparam logic [4:0] ALU_DIV   = 5'd17;
    localparam logic [4:0] ALU_DIVU  = 5'd18;
    localparam logic [4:0] ALU_REM   = 5'd19;
    localparam logic [4:0] ALU_REMU  = 5'd20;
    localparam logic [4:0] ALU_MULW  = 5'd21;
    localparam logic [4:0] ALU_DIVW  = 5'd22;
    localparam logic [4:0] ALU_DIVUW = 5'd23;
    localparam logic [4:0] ALU_REMW  = 5'd24;
    localparam logic [4:0] ALU_REMUW = 5'd25;

    word_t alu_a, alu_b;
    word_t rs2_val;
    word_t alu_result;
    word_t add_res, sub_res;
    logic [31:0] addw_res, subw_res, sllw_res, srlw_res, sraw_res;
    logic [31:0] mulw_res, divw_res, divuw_res, remw_res, remuw_res;
    logic branch_taken;
    u64 branch_target;
    logic md_busy, md_finishing;
    logic md_result_ready;
    logic [6:0] md_count;
    logic id_is_muldiv;
    logic md_start;
    logic [63:0] iter_acc, iter_quo, iter_divisor, iter_op_a, iter_op_b;
    logic iter_sign_q, iter_sign_r, iter_is_mul;
    logic [63:0] iter_mul_final, iter_quo_final, iter_rem_final;

    assign id_is_muldiv = (id_ex_reg.alu_op >= ALU_MUL);
    assign md_start = id_ex_reg.valid && id_is_muldiv && !md_busy && !md_result_ready;
    assign execute_ok = !md_busy && (!id_is_muldiv || md_result_ready);

    logic csr_do_write;
    word_t csr_wval_c;
    logic is_ecall, is_mret;
    logic except_instr_misaligned, except_load_misaligned, except_store_misaligned;
    logic [63:0] jalr_raw_addr;
    logic [5:0] trap_code_val;

    always_comb begin
        case (forward_ctrl.forward_a)
            2'b00: alu_a = id_ex_reg.rs1_data;
            2'b01: alu_a = ex_mem_reg.is_load ? mem_forward_data : ex_mem_reg.alu_result;
            2'b10: alu_a = wb_data;
            default: alu_a = id_ex_reg.rs1_data;
        endcase
        if (id_ex_reg.is_lui) alu_a = 64'b0;
        case (forward_ctrl.forward_b)
            2'b00: rs2_val = id_ex_reg.rs2_data;
            2'b01: rs2_val = ex_mem_reg.is_load ? mem_forward_data : ex_mem_reg.alu_result;
            2'b10: rs2_val = wb_data;
            default: rs2_val = id_ex_reg.rs2_data;
        endcase
        if (id_ex_reg.alu_src) alu_b = id_ex_reg.imm; else alu_b = rs2_val;
        if (id_ex_reg.is_auipc) alu_a = id_ex_reg.pc;

        add_res = alu_a + alu_b; sub_res = alu_a - alu_b;
        addw_res = add_res[31:0]; subw_res = sub_res[31:0];
        sllw_res = alu_a[31:0] << alu_b[4:0];
        srlw_res = alu_a[31:0] >> alu_b[4:0];
        sraw_res = $signed(alu_a[31:0]) >>> alu_b[4:0];
        mulw_res = iter_mul_final[31:0]; divw_res = iter_quo_final[31:0];
        divuw_res = iter_quo_final[31:0]; remw_res = iter_rem_final[31:0]; remuw_res = iter_rem_final[31:0];

        csr_do_write = 1'b0; csr_wval_c = 64'b0;
        if (id_ex_reg.is_csr) begin
            unique case (id_ex_reg.funct3)
                3'b001: begin csr_wval_c = alu_a; csr_do_write = 1'b1; end
                3'b010: begin csr_wval_c = csr_rdata | alu_a; csr_do_write = (id_ex_reg.rs1 != 5'b0); end
                3'b011: begin csr_wval_c = csr_rdata & ~alu_a; csr_do_write = (id_ex_reg.rs1 != 5'b0); end
                3'b101: begin csr_wval_c = {59'b0, id_ex_reg.rs1}; csr_do_write = 1'b1; end
                3'b110: begin csr_wval_c = csr_rdata | {59'b0, id_ex_reg.rs1}; csr_do_write = (id_ex_reg.rs1 != 5'b0); end
                3'b111: begin csr_wval_c = csr_rdata & ~{59'b0, id_ex_reg.rs1}; csr_do_write = (id_ex_reg.rs1 != 5'b0); end
                default: ;
            endcase
        end

        case (id_ex_reg.alu_op)
            5'd0: alu_result = alu_a + alu_b;
            5'd1: alu_result = alu_a - alu_b;
            5'd2: alu_result = {{32{addw_res[31]}}, addw_res};
            5'd3: alu_result = {{32{subw_res[31]}}, subw_res};
            5'd4: alu_result = alu_a << alu_b[5:0];
            5'd6: alu_result = alu_a >> alu_b[5:0];
            5'd7: alu_result = $signed(alu_a) >>> alu_b[5:0];
            5'd8: alu_result = ($signed(alu_a) < $signed(alu_b)) ? 64'd1 : 64'd0;
            5'd9: alu_result = (alu_a < alu_b) ? 64'd1 : 64'd0;
            5'd10: alu_result = alu_a & alu_b;
            5'd11: alu_result = alu_a | alu_b;
            5'd12: alu_result = alu_a ^ alu_b;
            5'd13: alu_result = {{32{sllw_res[31]}}, sllw_res};
            5'd14: alu_result = {{32{srlw_res[31]}}, srlw_res};
            5'd15: alu_result = {{32{sraw_res[31]}}, sraw_res};
            5'd16: alu_result = iter_mul_final;
            5'd17: alu_result = (alu_b == 64'd0) ? 64'hffff_ffff_ffff_ffff : ((alu_a == 64'h8000_0000_0000_0000 && alu_b == 64'hffff_ffff_ffff_ffff) ? alu_a : iter_quo_final);
            5'd18: alu_result = (alu_b == 64'd0) ? 64'hffff_ffff_ffff_ffff : iter_quo_final;
            5'd19: alu_result = (alu_b == 64'd0) ? alu_a : ((alu_a == 64'h8000_0000_0000_0000 && alu_b == 64'hffff_ffff_ffff_ffff) ? 64'd0 : iter_rem_final);
            5'd20: alu_result = (alu_b == 64'd0) ? alu_a : iter_rem_final;
            5'd21: alu_result = {{32{mulw_res[31]}}, mulw_res};
            5'd22: begin if (alu_b[31:0] == 32'd0) divw_res = 32'hffff_ffff; else if (alu_a[31:0] == 32'h8000_0000 && alu_b[31:0] == 32'hffff_ffff) divw_res = 32'h8000_0000; alu_result = {{32{divw_res[31]}}, divw_res}; end
            5'd23: begin if (alu_b[31:0] == 32'd0) divuw_res = 32'hffff_ffff; alu_result = {{32{divuw_res[31]}}, divuw_res}; end
            5'd24: begin if (alu_b[31:0] == 32'd0) remw_res = alu_a[31:0]; else if (alu_a[31:0] == 32'h8000_0000 && alu_b[31:0] == 32'hffff_ffff) remw_res = 32'd0; alu_result = {{32{remw_res[31]}}, remw_res}; end
            5'd25: begin if (alu_b[31:0] == 32'd0) remuw_res = alu_a[31:0]; alu_result = {{32{remuw_res[31]}}, remuw_res}; end
            default: alu_result = 64'b0;
        endcase

        branch_taken = 1'b0; branch_target = id_ex_reg.pc + id_ex_reg.imm;
        if (id_ex_reg.is_branch) begin
            case (id_ex_reg.funct3)
                3'b000: branch_taken = (alu_a == rs2_val);
                3'b001: branch_taken = (alu_a != rs2_val);
                3'b100: branch_taken = ($signed(alu_a) < $signed(rs2_val));
                3'b101: branch_taken = ($signed(alu_a) >= $signed(rs2_val));
                3'b110: branch_taken = (alu_a < rs2_val);
                3'b111: branch_taken = (alu_a >= rs2_val);
                default: branch_taken = 1'b0;
            endcase
        end
        if (id_ex_reg.is_jump) begin
            branch_taken = 1'b1;
            if (id_ex_reg.opcode == 7'b1100111) branch_target = (alu_a + id_ex_reg.imm) & ~64'd1;
            alu_result = id_ex_reg.pc + 64'd4;
        end
        if (id_ex_reg.is_csr) alu_result = csr_rdata;
        is_ecall = id_ex_reg.is_system && !id_ex_reg.is_csr && (id_ex_reg.instr == 32'h00000073);
        is_mret  = id_ex_reg.is_system && (id_ex_reg.instr == 32'h30200073);

        // Exception detection
        except_instr_misaligned = 1'b0;
        if (id_ex_reg.is_branch && branch_taken && (branch_target[1:0] != 2'b00)) except_instr_misaligned = 1'b1;
        if (id_ex_reg.is_jump && id_ex_reg.opcode == 7'b1100111) begin
            jalr_raw_addr = alu_a + id_ex_reg.imm;
            if (jalr_raw_addr[1:0] != 2'b00) except_instr_misaligned = 1'b1;
        end
        except_load_misaligned = 1'b0;
        if (id_ex_reg.is_load) begin
            unique case (id_ex_reg.funct3)
                3'b001, 3'b101: if (alu_result[0]) except_load_misaligned = 1'b1;
                3'b010, 3'b110: if (alu_result[1:0] != 2'b00) except_load_misaligned = 1'b1;
                3'b011: if (alu_result[2:0] != 3'b000) except_load_misaligned = 1'b1;
                default: ;
            endcase
        end
        except_store_misaligned = 1'b0;
        if (id_ex_reg.is_store) begin
            unique case (id_ex_reg.funct3)
                3'b001: if (alu_result[0]) except_store_misaligned = 1'b1;
                3'b010: if (alu_result[1:0] != 2'b00) except_store_misaligned = 1'b1;
                3'b011: if (alu_result[2:0] != 3'b000) except_store_misaligned = 1'b1;
                default: ;
            endcase
        end
        trap_code_val = 6'd0;
        if (except_instr_misaligned) trap_code_val = 6'd0;
        else if (id_ex_reg.except_illegal_instr) trap_code_val = 6'd2;
        else if (except_load_misaligned) trap_code_val = 6'd4;
        else if (except_store_misaligned) trap_code_val = 6'd6;
        else if (is_ecall) begin
            unique case (priv_mode_q) 2'b00: trap_code_val = 6'd8; 2'b01: trap_code_val = 6'd9; default: trap_code_val = 6'd11; endcase
        end
    end

    logic except_fire;
    assign except_fire = step & id_ex_reg.valid & (except_instr_misaligned | id_ex_reg.except_illegal_instr | except_load_misaligned | except_store_misaligned);
    assign redirect_valid = step & id_ex_reg.valid & (branch_taken | id_ex_reg.is_csr | is_ecall | is_mret | except_fire);
    assign redirect_pc    = is_mret ? csr_mepc : (is_ecall | except_fire) ? csr_mtvec : id_ex_reg.is_csr ? (id_ex_reg.pc + 64'd4) : branch_target;
    assign trap_fire       = step & id_ex_reg.valid & (is_ecall | is_mret | except_fire);
    assign trap_is_mret    = is_mret;
    assign trap_ecall_imm  = id_ex_reg.imm[11:0];

    logic [63:0] init_op_a, init_op_b, init_abs_a, init_abs_b;
    logic init_is_signed;
    logic [63:0] div_shifted, div_trial, rem_corrected;

    always_ff @(posedge clk) begin
        if (reset) begin
            md_busy <= 1'b0; md_finishing <= 1'b0; md_result_ready <= 1'b0; md_count <= 7'd0;
            ex_mem_reg.valid <= 1'b0; ex_mem_reg.pc <= 64'b0; ex_mem_reg.instr <= 32'b0;
            ex_mem_reg.alu_result <= 64'b0; ex_mem_reg.rs2_data <= 64'b0; ex_mem_reg.imm <= 64'b0;
            ex_mem_reg.rd <= 5'b0; ex_mem_reg.is_load <= 1'b0; ex_mem_reg.is_store <= 1'b0;
            ex_mem_reg.mem_write <= 1'b0; ex_mem_reg.mem_read <= 1'b0;
            ex_mem_reg.reg_write <= 1'b0; ex_mem_reg.mem_to_reg <= 2'b0;
            ex_mem_reg.csr_pending <= 1'b0; ex_mem_reg.csr_paddr <= 12'b0; ex_mem_reg.csr_pwdata <= 64'b0;
            ex_mem_reg.trap_pending <= 1'b0; ex_mem_reg.trap_is_mret <= 1'b0; ex_mem_reg.trap_priv <= 2'b11;
            ex_mem_reg.trap_is_interrupt <= 1'b0; ex_mem_reg.trap_code <= 6'd0;
            iter_acc <= 64'd0; iter_quo <= 64'd0; iter_divisor <= 64'd0; iter_op_a <= 64'd0; iter_op_b <= 64'd0;
            iter_sign_q <= 1'b0; iter_sign_r <= 1'b0; iter_is_mul <= 1'b0;
            iter_mul_final <= 64'd0; iter_quo_final <= 64'd0; iter_rem_final <= 64'd0;
        end else begin
            md_finishing <= 1'b0;
            if (trap_fire) begin
                ex_mem_reg.valid <= 1'b1; ex_mem_reg.pc <= id_ex_reg.pc; ex_mem_reg.instr <= id_ex_reg.instr;
                ex_mem_reg.trap_pending <= 1'b1; ex_mem_reg.trap_is_mret <= trap_is_mret;
                ex_mem_reg.trap_priv <= priv_mode_q; // privilege at instruction execution
                ex_mem_reg.trap_is_interrupt <= 1'b0; ex_mem_reg.trap_code <= trap_code_val;
                ex_mem_reg.reg_write <= 1'b0; ex_mem_reg.csr_pending <= 1'b0;
                ex_mem_reg.is_load <= 1'b0; ex_mem_reg.is_store <= 1'b0;
                ex_mem_reg.mem_write <= 1'b0; ex_mem_reg.mem_read <= 1'b0;
            end else if (interrupt_fire) begin
                ex_mem_reg.valid <= 1'b1; ex_mem_reg.pc <= interrupt_pc; ex_mem_reg.instr <= 32'b0;
                ex_mem_reg.trap_pending <= 1'b1; ex_mem_reg.trap_is_mret <= 1'b0;
                ex_mem_reg.trap_priv <= priv_mode_q; // privilege at interrupt time (combinational)
                ex_mem_reg.trap_is_interrupt <= 1'b1; ex_mem_reg.trap_code <= interrupt_cause_code;
                ex_mem_reg.reg_write <= 1'b0; ex_mem_reg.csr_pending <= 1'b0;
                ex_mem_reg.is_load <= 1'b0; ex_mem_reg.is_store <= 1'b0;
                ex_mem_reg.mem_write <= 1'b0; ex_mem_reg.mem_read <= 1'b0;
            end else if (md_start) begin
                // ... (multiply/divide state machine unchanged)
                md_busy <= 1'b1; md_result_ready <= 1'b0;
                iter_is_mul <= (id_ex_reg.alu_op == ALU_MUL) || (id_ex_reg.alu_op == ALU_MULW);
                init_op_a = alu_a; init_op_b = alu_b;
                if (id_ex_reg.alu_op == ALU_MULW || id_ex_reg.alu_op == ALU_DIVW || id_ex_reg.alu_op == ALU_REMW) begin
                    init_op_a = {{32{alu_a[31]}}, alu_a[31:0]}; init_op_b = {{32{alu_b[31]}}, alu_b[31:0]};
                end else if (id_ex_reg.alu_op == ALU_DIVUW || id_ex_reg.alu_op == ALU_REMUW) begin
                    init_op_a = {32'b0, alu_a[31:0]}; init_op_b = {32'b0, alu_b[31:0]};
                end
                if ((id_ex_reg.alu_op == ALU_MUL) || (id_ex_reg.alu_op == ALU_MULW)) begin
                    init_abs_a = init_op_a[63] ? (~init_op_a + 64'd1) : init_op_a; init_abs_b = init_op_b[63] ? (~init_op_b + 64'd1) : init_op_b;
                    iter_acc <= 64'd0; iter_op_a <= init_abs_a; iter_op_b <= init_abs_b;
                    iter_sign_q <= init_op_a[63] ^ init_op_b[63]; md_count <= (id_ex_reg.alu_op == ALU_MULW) ? 7'd32 : 7'd64;
                end else begin
                    init_is_signed = (id_ex_reg.alu_op == ALU_DIV) || (id_ex_reg.alu_op == ALU_DIVW) || (id_ex_reg.alu_op == ALU_REM) || (id_ex_reg.alu_op == ALU_REMW);
                    init_abs_a = (init_is_signed && init_op_a[63]) ? (~init_op_a + 64'd1) : init_op_a; init_abs_b = (init_is_signed && init_op_b[63]) ? (~init_op_b + 64'd1) : init_op_b;
                    iter_acc <= 64'd0; iter_quo <= 64'd0; iter_divisor <= init_abs_b; iter_op_a <= init_abs_a;
                    iter_sign_q <= init_is_signed ? (init_op_a[63] ^ init_op_b[63]) : 1'b0; iter_sign_r <= init_is_signed ? init_op_a[63] : 1'b0;
                    md_count <= 7'd64;
                end
            end else if (md_busy) begin
                md_count <= md_count - 7'd1;
                if (iter_is_mul) begin
                    if (iter_op_b[0]) iter_acc <= iter_acc + iter_op_a; iter_op_a <= iter_op_a << 1; iter_op_b <= iter_op_b >> 1;
                end else begin
                    div_shifted = {iter_acc[62:0], iter_op_a[63]}; div_trial = div_shifted - iter_divisor;
                    if (!div_trial[63]) begin iter_acc <= div_trial; iter_quo <= {iter_quo[62:0], 1'b1}; end
                    else begin iter_acc <= div_shifted; iter_quo <= {iter_quo[62:0], 1'b0}; end
                    iter_op_a <= {iter_op_a[62:0], 1'b0};
                end
                if (md_count == 7'd1) begin
                    md_busy <= 1'b0; md_finishing <= 1'b1; md_result_ready <= 1'b1;
                    if (iter_is_mul) begin
                        iter_mul_final <= iter_sign_q ? (~(iter_acc + (iter_op_b[0] ? iter_op_a : 64'd0)) + 64'd1) : (iter_acc + (iter_op_b[0] ? iter_op_a : 64'd0));
                    end else begin
                        div_shifted = {iter_acc[62:0], iter_op_a[63]}; div_trial = div_shifted - iter_divisor;
                        if (!div_trial[63]) begin rem_corrected = div_trial; iter_quo_final <= iter_sign_q ? (~{iter_quo[62:0], 1'b1} + 64'd1) : {iter_quo[62:0], 1'b1}; end
                        else begin rem_corrected = div_shifted; iter_quo_final <= iter_sign_q ? (~{iter_quo[62:0], 1'b0} + 64'd1) : {iter_quo[62:0], 1'b0}; end
                        if (rem_corrected[63]) rem_corrected = rem_corrected + iter_divisor;
                        iter_rem_final <= iter_sign_r ? (~rem_corrected + 64'd1) : rem_corrected;
                    end
                end
            end
            if (step && (!id_is_muldiv || md_result_ready) && !trap_fire && !interrupt_fire) begin
                ex_mem_reg.valid <= id_ex_reg.valid; ex_mem_reg.pc <= id_ex_reg.pc; ex_mem_reg.instr <= id_ex_reg.instr;
                ex_mem_reg.rd <= id_ex_reg.rd; ex_mem_reg.reg_write <= id_ex_reg.reg_write; ex_mem_reg.alu_result <= alu_result;
                ex_mem_reg.rs2_data <= rs2_val; ex_mem_reg.imm <= id_ex_reg.imm;
                ex_mem_reg.is_load <= id_ex_reg.is_load; ex_mem_reg.is_store <= id_ex_reg.is_store;
                ex_mem_reg.mem_write <= id_ex_reg.mem_write; ex_mem_reg.mem_read <= id_ex_reg.mem_read;
                ex_mem_reg.mem_to_reg <= id_ex_reg.mem_to_reg;
                ex_mem_reg.trap_pending <= 1'b0; ex_mem_reg.trap_is_mret <= 1'b0; ex_mem_reg.trap_priv <= 2'b11;
                ex_mem_reg.trap_is_interrupt <= 1'b0; ex_mem_reg.trap_code <= 6'd0;
                ex_mem_reg.csr_pending <= id_ex_reg.valid & id_ex_reg.is_csr & csr_do_write;
                ex_mem_reg.csr_paddr <= id_ex_reg.imm[11:0]; ex_mem_reg.csr_pwdata <= csr_wval_c;
                if (id_is_muldiv) md_result_ready <= 1'b0;
            end
        end
    end
endmodule

`endif
