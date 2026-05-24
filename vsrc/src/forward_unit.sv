`ifndef __FORWARD_UNIT_SV
`define __FORWARD_UNIT_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module forward_unit import common::*;( 
    input  u5          id_ex_rs1, id_ex_rs2, 
    input  u5          ex_mem_rd, 
    input  logic       ex_mem_reg_write,
    input  u5          mem_wb_rd, 
    input  logic       mem_wb_reg_write, 
    output forward_ctrl_t forward_ctrl 
);
    always_comb begin
        // 处理 rs1 的前向 (注意：我去掉了对 Load 的屏蔽)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_ctrl.forward_a = 2'b01;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_ctrl.forward_a = 2'b10;
        end else begin
            forward_ctrl.forward_a = 2'b00;
        end
        
        // 处理 rs2 的前向 (注意：我去掉了对 Load 的屏蔽)
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_ctrl.forward_b = 2'b01;
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_ctrl.forward_b = 2'b10;
        end else begin
            forward_ctrl.forward_b = 2'b00;
        end
    end
endmodule

`endif