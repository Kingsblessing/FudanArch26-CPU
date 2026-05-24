`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module memory import common::*;( 
    input  logic       clk, reset, 
    input  logic       step, 
    output logic       mem_ok, 
    input  REG_EX_MEM  ex_mem_reg,
    input  logic       flush,
    output dbus_req_t  dreq, 
    input  dbus_resp_t dresp, 
    output REG_MEM_WB  mem_wb_reg,
    output word_t      mem_forward_data // 组合逻辑前向输出
);
    logic mem_in_progress;
    logic req_completed; // 标记当前 ex_mem_reg 中的请求已处理完成
    word_t saved_rdata;  // 新增：用于暂存从总线读回的数据
    
    // 组合逻辑提取子字段
    u3 funct3;
    u3 offset;
    u6 shift_amt;
    word_t rdata_shifted;
    word_t final_rdata;

    assign funct3 = ex_mem_reg.instr[14:12];
    assign offset = ex_mem_reg.alu_result[2:0];
    assign shift_amt = {offset, 3'b000};
    assign mem_forward_data = saved_rdata;
    
    // 对读上来的数据统一做对齐和符号截断操作
    assign rdata_shifted = dresp.data >> shift_amt;
    always_comb begin
        case (funct3)
            3'b000: final_rdata = {{56{rdata_shifted[7]}}, rdata_shifted[7:0]};   // lb
            3'b001: final_rdata = {{48{rdata_shifted[15]}}, rdata_shifted[15:0]}; // lh
            3'b010: final_rdata = {{32{rdata_shifted[31]}}, rdata_shifted[31:0]}; // lw
            3'b011: final_rdata = rdata_shifted;                                  // ld
            3'b100: final_rdata = {56'b0, rdata_shifted[7:0]};                    // lbu
            3'b101: final_rdata = {48'b0, rdata_shifted[15:0]};                   // lhu
            3'b110: final_rdata = {32'b0, rdata_shifted[31:0]};                   // lwu
            default: final_rdata = 64'b0;
        endcase
    end

    // 只要 EX_MEM 中有未完成的访存指令，立刻（0 延迟）拉低阻塞全局 step
    assign mem_ok = ~(ex_mem_reg.valid && (ex_mem_reg.is_load || ex_mem_reg.is_store) && !req_completed);

    always_ff @(posedge clk) begin
        if (reset) begin
            mem_in_progress <= 1'b0;
            req_completed <= 1'b0;
            saved_rdata <= 64'b0;
            dreq.valid <= 1'b0;
            dreq.addr <= 64'b0;
            dreq.size <= MSIZE4;
            dreq.strobe <= 8'b0;
            dreq.data <= 64'b0;
            mem_wb_reg.valid <= 1'b0;
            mem_wb_reg.pc <= 64'b0;
            mem_wb_reg.instr <= 32'b0;
            mem_wb_reg.alu_result <= 64'b0;
            mem_wb_reg.mem_data <= 64'b0;
            mem_wb_reg.rd <= 5'b0;
            mem_wb_reg.reg_write <= 1'b0;
            mem_wb_reg.mem_to_reg <= 2'b0;
            mem_wb_reg.csr_pending <= 1'b0;
            mem_wb_reg.csr_paddr <= 12'b0;
            mem_wb_reg.csr_pwdata <= 64'b0;
            mem_wb_reg.trap_pending <= 1'b0;
            mem_wb_reg.trap_is_mret <= 1'b0;
            mem_wb_reg.trap_priv     <= 2'b11;
            
        end else begin
            if (flush && mem_in_progress) begin
                // Lab5/6: trap 时取消未完成的访存，但保留 EX/MEM 中可提交的指令
                mem_in_progress <= 1'b0;
                dreq.valid      <= 1'b0;
            end
            if (step) begin
                // 当 step 为 1 时，意味着流水线推进。将 EX_MEM 正式送入 MEM_WB
                req_completed <= 1'b0;
                mem_wb_reg.valid <= ex_mem_reg.valid;
                mem_wb_reg.pc <= ex_mem_reg.pc;
                mem_wb_reg.instr <= ex_mem_reg.instr;
                mem_wb_reg.rd <= ex_mem_reg.rd;
                mem_wb_reg.reg_write <= ex_mem_reg.reg_write;
                mem_wb_reg.alu_result <= ex_mem_reg.alu_result;
                mem_wb_reg.mem_data <= ex_mem_reg.is_load ? saved_rdata : ex_mem_reg.alu_result;
                mem_wb_reg.mem_to_reg <= ex_mem_reg.mem_to_reg;
                mem_wb_reg.csr_pending <= ex_mem_reg.csr_pending;
                mem_wb_reg.csr_paddr <= ex_mem_reg.csr_paddr;
                mem_wb_reg.csr_pwdata <= ex_mem_reg.csr_pwdata;
                mem_wb_reg.trap_pending <= ex_mem_reg.trap_pending;
                mem_wb_reg.trap_is_mret <= ex_mem_reg.trap_is_mret;
                mem_wb_reg.trap_priv     <= ex_mem_reg.trap_priv;
            end
            if (!mem_in_progress && ex_mem_reg.valid && (ex_mem_reg.is_load || ex_mem_reg.is_store) && !req_completed) begin
            // 发现需要访存的指令，发起内存总线请求（此时 step 为 0，前序指令安全停留在 mem_wb_reg）
            mem_in_progress <= 1'b1;
            dreq.valid <= 1'b1;
            dreq.addr <= ex_mem_reg.alu_result; 
            
            if (ex_mem_reg.is_store) begin
                case (funct3)
                    3'b000: begin dreq.strobe <= 8'b0000_0001 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE1; end
                    3'b001: begin dreq.strobe <= 8'b0000_0011 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE2; end
                    3'b010: begin dreq.strobe <= 8'b0000_1111 << offset; dreq.data <= ex_mem_reg.rs2_data << shift_amt; dreq.size <= MSIZE4; end
                    3'b011: begin dreq.strobe <= 8'hFF;                  dreq.data <= ex_mem_reg.rs2_data;              dreq.size <= MSIZE8; end
                    default:begin dreq.strobe <= 8'b0;                   dreq.data <= 64'b0;                            dreq.size <= MSIZE8; end
                endcase
            end else begin // Load
                dreq.strobe <= 8'b0;
                dreq.data <= 64'b0;
                case (funct3)
                    3'b000, 3'b100: dreq.size <= MSIZE1;
                    3'b001, 3'b101: dreq.size <= MSIZE2;
                    3'b010, 3'b110: dreq.size <= MSIZE4;
                    3'b011:         dreq.size <= MSIZE8;
                    default:        dreq.size <= MSIZE8;
                endcase
            end
            
            end
            if (mem_in_progress && dresp.data_ok && dresp.addr_ok) begin
                mem_in_progress <= 1'b0;
                dreq.valid <= 1'b0;
                req_completed <= 1'b1;
                saved_rdata <= final_rdata;
            end
        end
    end
endmodule

`endif