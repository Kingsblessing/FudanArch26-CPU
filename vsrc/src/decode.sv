`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

import common::*;

module decode import common::*;( 
	input  logic       clk, reset, 
	input  logic       step, 
	output logic       decode_ok, 
	input  REG_IF_ID   if_id_reg, 
	input  word_t      reg_rdata1, reg_rdata2, 
    input  logic       flush,
	output REG_ID_EX   id_ex_reg 
);
	// 指令字段
	u7 opcode;
	u5 rd;
	u3 funct3;
	u5 rs1;
	u5 rs2;
	u7 funct7;
	u12 imm_i;
	u12 imm_s;
	u20 imm_u;
    u13 imm_b;
    logic [20:0] imm_j;
	
	// 控制信号
	logic [4:0] alu_op;
	logic alu_src;
	logic reg_write;
	logic mem_write;
	logic mem_read;
	logic [1:0] mem_to_reg;
	word_t imm;
	logic is_load;
	logic is_store;
	logic is_branch;
	logic is_jump;
	logic is_alu;
	logic is_aluimm;
	logic is_lui;
	logic is_auipc;
	logic is_system;
	logic is_csr;
	
	// 初始化信号在reset时处理
	
	// 指令解码
	always_comb begin
		opcode = if_id_reg.instr[6:0];
		rd = if_id_reg.instr[11:7];
		funct3 = if_id_reg.instr[14:12];
		rs1 = if_id_reg.instr[19:15];
		rs2 = if_id_reg.instr[24:20];
		funct7 = if_id_reg.instr[31:25];
		imm_i = if_id_reg.instr[31:20];
		imm_s = {if_id_reg.instr[31:25], if_id_reg.instr[11:7]};
		imm_u = if_id_reg.instr[31:12];
        imm_b = {if_id_reg.instr[31], if_id_reg.instr[7], if_id_reg.instr[30:25], if_id_reg.instr[11:8], 1'b0};
        imm_j = {if_id_reg.instr[31], if_id_reg.instr[19:12], if_id_reg.instr[20], if_id_reg.instr[30:21], 1'b0};
		
		// 默认值
		alu_op = 5'd0;
		alu_src = 1'b0;
		reg_write = 1'b0;
		mem_write = 1'b0;
		mem_read = 1'b0;
		mem_to_reg = 2'b00;
		imm = 64'b0;
		is_load = 1'b0;
		is_store = 1'b0;
		is_branch = 1'b0;
		is_jump = 1'b0;
		is_alu = 1'b0;
		is_aluimm = 1'b0;
		is_lui = 1'b0;
		is_auipc = 1'b0;
		is_system = 1'b0;
		is_csr = 1'b0;
		
		case (opcode) 
			7'b0110111: begin // U-type (lui)
                reg_write = 1'b1; alu_src = 1'b1; is_lui = 1'b1;
                imm = {{32{if_id_reg.instr[31]}}, imm_u, 12'b0};
                alu_op = 5'd0;
            end
            7'b0010111: begin // auipc
                reg_write = 1'b1; alu_src = 1'b1; is_auipc = 1'b1;
                imm = {{32{if_id_reg.instr[31]}}, imm_u, 12'b0};
                alu_op = 5'd0;
            end

            7'b0000011: begin // I-type Load (ld, lw, lb, etc)
                reg_write = 1'b1; alu_src = 1'b1; is_load = 1'b1; 
                mem_read = 1'b1; mem_to_reg = 2'b01;
                imm = {{52{imm_i[11]}}, imm_i};
                alu_op = 5'd0;
            end

            7'b0100011: begin // S-type Store (sd, sw, sb, etc)
                mem_write = 1'b1; is_store = 1'b1; alu_src = 1'b1;
                imm = {{52{imm_s[11]}}, imm_s};
                alu_op = 5'd0;
            end

			7'b0010011: begin // I-type ALU
				reg_write = 1'b1;
				alu_src = 1'b1;
				imm = {{52{imm_i[11]}}, imm_i};
				is_aluimm = 1'b1;
				
				case (funct3) 
					3'b000: alu_op = 5'd0;  // addi
                    3'b001: alu_op = 5'd4;  // slli
                    3'b010: alu_op = 5'd8;  // slti
                    3'b011: alu_op = 5'd9;  // sltiu
                    3'b101: alu_op = funct7[5] ? 5'd7 : 5'd6; // srai/srli
					3'b100: alu_op = 5'd12; // xori
					3'b110: alu_op = 5'd11; // ori
					3'b111: alu_op = 5'd10; // andi
					default: alu_op = 5'd0;
				endcase
			end
			
			7'b0110011: begin // R-type
				reg_write = 1'b1; alu_src = 1'b0; is_alu = 1'b1;
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_op = 5'd16; // mul
                        3'b100: alu_op = 5'd17; // div
                        3'b101: alu_op = 5'd18; // divu
                        3'b110: alu_op = 5'd19; // rem
                        3'b111: alu_op = 5'd20; // remu
                        default: alu_op = 5'd0;
                    endcase
                end else begin
                    case (funct3)
                        3'b000: alu_op = (funct7 == 7'b0100000) ? 5'd1 : 5'd0;
                        3'b001: alu_op = 5'd4;
                        3'b010: alu_op = 5'd8;
                        3'b011: alu_op = 5'd9;
                        3'b101: alu_op = funct7[5] ? 5'd7 : 5'd6;
                        3'b110: alu_op = 5'd11;
                        3'b111: alu_op = 5'd10;
                        3'b100: alu_op = 5'd12;
                        default: alu_op = 5'd0;
                    endcase
                end
			end
			
			7'b0011011: begin // OP-IMM-32
				reg_write = 1'b1; alu_src = 1'b1; imm = {{52{imm_i[11]}}, imm_i};
                case (funct3)
                    3'b000: alu_op = 5'd2;  // addiw
                    3'b001: alu_op = 5'd13; // slliw
                    3'b101: alu_op = funct7[5] ? 5'd15 : 5'd14; // sraiw/srliw
                    default: alu_op = 5'd2;
                endcase
			end
			
			7'b0111011: begin // OP-32
				reg_write = 1'b1; alu_src = 1'b0;
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_op = 5'd21; // mulw
                        3'b100: alu_op = 5'd22; // divw
                        3'b101: alu_op = 5'd23; // divuw
                        3'b110: alu_op = 5'd24; // remw
                        3'b111: alu_op = 5'd25; // remuw
                        default: alu_op = 5'd2;
                    endcase
                end else begin
                    case (funct3)
                        3'b000: alu_op = (funct7 == 7'b0100000) ? 5'd3 : 5'd2; // subw/addw
                        3'b001: alu_op = 5'd13; // sllw
                        3'b101: alu_op = funct7[5] ? 5'd15 : 5'd14; // sraw/srlw
                        default: alu_op = 5'd2;
                    endcase
                end
			end
            7'b1100011: begin // branch
                is_branch = 1'b1;
                imm = {{51{imm_b[12]}}, imm_b};
            end
            7'b1101111: begin // jal
                is_jump = 1'b1;
                reg_write = 1'b1;
                imm = {{43{imm_j[20]}}, imm_j};
            end
            7'b1100111: begin // jalr
                is_jump = 1'b1;
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm = {{52{imm_i[11]}}, imm_i};
			end
            7'b1110011: begin // SYSTEM：CSR / ecall / mret
                is_system = 1'b1;
                if (funct3 != 3'b000) begin
                    is_csr = 1'b1;
                    reg_write = (rd != 5'b0);
                    alu_src = 1'b0;
                    imm = {52'b0, imm_i};
                end else begin
                    imm = {52'b0, imm_i};
                end
			end
			
			default: begin // 默认情况，所有控制信号设为默认值
				reg_write = 1'b0;
				alu_src = 1'b0;
				mem_write = 1'b0;
				mem_read = 1'b0;
				mem_to_reg = 2'b00;
				imm = 64'b0;
				is_load = 1'b0;
				is_store = 1'b0;
				is_branch = 1'b0;
				is_jump = 1'b0;
				is_alu = 1'b0;
				is_aluimm = 1'b0;
				is_lui = 1'b0;
				is_auipc = 1'b0;
				is_system = 1'b0;
				is_csr = 1'b0;
				alu_op = 5'd0;
			end
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			decode_ok <= 1'b1;
			id_ex_reg.valid <= 1'b0;
			id_ex_reg.pc <= 64'b0;
			id_ex_reg.instr <= 32'b0;
			id_ex_reg.rs1_data <= 64'b0;
			id_ex_reg.rs2_data <= 64'b0;
			id_ex_reg.imm <= 64'b0;
			id_ex_reg.rd <= 5'b0;
			id_ex_reg.rs1 <= 5'b0;
			id_ex_reg.rs2 <= 5'b0;
			id_ex_reg.funct3 <= 3'b0;
			id_ex_reg.funct7 <= 7'b0;
			id_ex_reg.opcode <= 7'b0;
			id_ex_reg.is_load <= 1'b0;
			id_ex_reg.is_store <= 1'b0;
			id_ex_reg.is_branch <= 1'b0;
			id_ex_reg.is_jump <= 1'b0;
			id_ex_reg.is_alu <= 1'b0;
			id_ex_reg.is_aluimm <= 1'b0;
			id_ex_reg.is_lui <= 1'b0;
			id_ex_reg.is_auipc <= 1'b0;
			id_ex_reg.is_system <= 1'b0;
			id_ex_reg.is_csr <= 1'b0;
			id_ex_reg.alu_op <= 5'b0;
			id_ex_reg.alu_src <= 1'b0;
			id_ex_reg.mem_write <= 1'b0;
			id_ex_reg.mem_read <= 1'b0;
			id_ex_reg.reg_write <= 1'b0;
			id_ex_reg.mem_to_reg <= 2'b0;
		end else if (flush) begin
            id_ex_reg.valid <= 1'b0;
        end else if (step) begin
			// 更新流水线寄存器
			id_ex_reg.valid <= if_id_reg.valid;
			id_ex_reg.pc <= if_id_reg.pc;
			id_ex_reg.instr <= if_id_reg.instr;
			id_ex_reg.rs1 <= rs1;
			id_ex_reg.rs2 <= rs2;
			id_ex_reg.rd <= rd;
			id_ex_reg.rs1_data <= reg_rdata1;
			id_ex_reg.rs2_data <= reg_rdata2;
			id_ex_reg.alu_op <= alu_op;
			id_ex_reg.alu_src <= alu_src;
			id_ex_reg.reg_write <= reg_write;
			id_ex_reg.mem_write <= mem_write;
			id_ex_reg.mem_read <= mem_read;
			id_ex_reg.mem_to_reg <= mem_to_reg;
			id_ex_reg.imm <= imm;
			id_ex_reg.is_load <= is_load;
			id_ex_reg.is_store <= is_store;
			id_ex_reg.is_branch <= is_branch;
			id_ex_reg.is_jump <= is_jump;
			id_ex_reg.is_alu <= is_alu;
			id_ex_reg.is_aluimm <= is_aluimm;
			id_ex_reg.is_lui <= is_lui;
			id_ex_reg.is_auipc <= is_auipc;
			id_ex_reg.is_system <= is_system;
			id_ex_reg.is_csr <= is_csr;
			id_ex_reg.funct3 <= funct3;
			id_ex_reg.funct7 <= funct7;
			id_ex_reg.opcode <= opcode;
		end
	end
endmodule

`endif