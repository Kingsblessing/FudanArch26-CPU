`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module fetch import common::*;( 
    input  logic       clk, reset, 
    input  logic       step, 
    output logic       fetch_ok, 
    output ibus_req_t  ireq, 
    input  ibus_resp_t iresp, 
    input  logic       redirect_valid,
    input  u64         redirect_pc,
    input  logic       trap_fire,
    output REG_IF_ID   if_id_reg 
);
    u64 pc;
    u32 instr;
    u64 req_pc;
    logic fetch_in_progress;
    logic redirect_pending;
    u64 pending_redirect_pc;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= PCINIT;
            fetch_ok <= 1'b1;
            fetch_in_progress <= 1'b0;
            redirect_pending <= 1'b0;
            pending_redirect_pc <= 64'b0;
            req_pc <= 64'b0;
            ireq.valid <= 1'b0;
            ireq.addr <= 64'b0;
            if_id_reg.valid <= 1'b0;
            if_id_reg.pc <= 64'b0;
            if_id_reg.instr <= 32'b0;
        end else if (trap_fire) begin
            fetch_ok            <= 1'b1;
            fetch_in_progress   <= 1'b0;
            redirect_pending    <= 1'b0;
            ireq.valid          <= 1'b0;
            if_id_reg.valid     <= 1'b0;
            pc                  <= redirect_pc;
        end else if (redirect_valid) begin
            if_id_reg.valid <= 1'b0;
            if (fetch_in_progress) begin
                redirect_pending <= 1'b1;
                pending_redirect_pc <= redirect_pc;
            end else begin
                pc <= redirect_pc;
            end
        end else if (step && fetch_ok) begin
            // 开始取指令
            fetch_ok <= 1'b0;
            fetch_in_progress <= 1'b1;
            ireq.valid <= 1'b1;
            ireq.addr <= pc;
            req_pc <= pc;
        end else if (!fetch_ok && fetch_in_progress && iresp.data_ok && iresp.addr_ok) begin
            // 取到指令
            fetch_ok <= 1'b1;
            fetch_in_progress <= 1'b0;
            ireq.valid <= 1'b0;
            
            if (redirect_pending) begin
                if_id_reg.valid <= 1'b0;
                pc <= pending_redirect_pc;
                redirect_pending <= 1'b0;
            end else begin
                // 更新流水线寄存器
                if_id_reg.valid <= 1'b1;
                if_id_reg.instr <= iresp.data;
                // 这里必须是 pc，即发起请求时的地址
                if_id_reg.pc    <= req_pc;
                // pc 寄存器更新为下一条，但不能把这个值传给 if_id_reg.pc
                pc <= req_pc + 4;
            end
        end
    end
endmodule

`endif