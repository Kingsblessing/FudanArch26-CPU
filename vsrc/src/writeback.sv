`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module writeback import common::*;( 
    input  logic       clk, reset, 
    input  logic       step,
    input  logic       block_commit,
    output logic       writeback_ok, 
    input  REG_MEM_WB  mem_wb_reg, 
    output logic       reg_wen, 
    output u5          reg_waddr, 
    output word_t      reg_wdata, 
    output logic       commit_valid, 
    output u64         commit_pc, 
    output u32         commit_instr, 
    output logic       commit_wen, 
    output u5          commit_wdest, 
    output word_t      commit_wdata 
);
    // Writeback 永远处于 ready 状态
    assign writeback_ok = 1'b1;

    // 只有 rd != 0 时才真正写回
    assign reg_wen = mem_wb_reg.valid & mem_wb_reg.reg_write & (mem_wb_reg.rd != 5'b0) & step;
    assign reg_waddr = mem_wb_reg.rd;
    // 根据控制信号选择写回数据 (0: ALU, 1: Memory)
    assign reg_wdata = (mem_wb_reg.mem_to_reg == 2'b01) ? mem_wb_reg.mem_data : mem_wb_reg.alu_result;

    // Difftest 提交信号
    // block_commit: only suppress WB on ecall (mret still commits for difftest)
    assign commit_valid = mem_wb_reg.valid & step & ~block_commit;
    assign commit_pc    = mem_wb_reg.pc;
    assign commit_instr = mem_wb_reg.instr;
    assign commit_wen   = reg_wen; 
    assign commit_wdest = reg_waddr;
    assign commit_wdata = reg_wdata;

endmodule

`endif