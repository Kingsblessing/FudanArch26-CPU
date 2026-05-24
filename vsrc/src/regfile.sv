`ifndef __REGFILE_SV
`define __REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module regfile import common::*;( 
    input  logic       clk, reset, 
    input  u5          raddr1, raddr2, 
    input  logic       wen, 
    input  u5          waddr, 
    input  word_t      wdata, 
    output word_t      rdata1, rdata2 
);
    word_t REG[31:0];
    word_t next_reg[31:0];
    
    // 读取操作：组合逻辑内部前向机制，解决 WB 到 ID 的数据冒险
    always_comb begin
        if (raddr1 == 5'b0) rdata1 = 64'b0;
        else if (wen && (raddr1 == waddr)) rdata1 = wdata; // WB 阶段前向
        else rdata1 = REG[raddr1];

        if (raddr2 == 5'b0) rdata2 = 64'b0;
        else if (wen && (raddr2 == waddr)) rdata2 = wdata;
        else rdata2 = REG[raddr2];
    end
    
    // 为 Difftest 计算 next_reg 时，强制 next_reg[0] 为 0
    always_comb begin
        next_reg[0] = 64'b0;
        for (int i = 1; i < 32; i++) begin
            if (wen && (u5'(i) == waddr)) next_reg[i] = wdata;
            else next_reg[i] = REG[i];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) REG[i] <= 64'b0;
        end else if (wen && (waddr != 5'b0)) begin // 禁止写入 x0
            REG[waddr] <= wdata;
        end
    end
endmodule

`endif