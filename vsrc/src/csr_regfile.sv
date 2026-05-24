`ifndef __CSR_REGFILE_SV
`define __CSR_REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/csr.sv"
`endif

`ifdef VIVADO
`include "../include/common.sv"
`include "../include/csr.sv"
`endif

import common::*;
import csr_pkg::*;

module csr_regfile import common::*; import csr_pkg::*; (
    input  logic       clk,
    input  logic       reset,
    input  logic       csr_we,
    input  u12         csr_waddr,
    input  word_t      csr_wdata,
    input  u12         csr_raddr,
    output word_t      csr_rdata,
    input  logic       trap_fire_ex,
    input  logic       trap_csr_commit,
    input  logic       trap_is_mret_ex,
    input  logic       trap_is_mret_wb,
    input  u2          trap_priv_wb,
    input  u64         trap_pc,
    input  u12         trap_ecall_imm,
    output u2          priv_mode,
    output u2          priv_mode_q_out,
    output word_t      mtvec_o,
    output word_t      mepc_o,
    output word_t      satp_o,
    output word_t      dbg_mstatus,
    output word_t      dbg_mtvec,
    output word_t      dbg_mip,
    output word_t      dbg_mie,
    output word_t      dbg_mscratch,
    output word_t      dbg_mcause,
    output word_t      dbg_mtval,
    output word_t      dbg_mepc,
    output word_t      dbg_mcycle,
    output word_t      dbg_mhartid,
    output word_t      dbg_satp,
    output word_t      mstatus_q_out,
    output word_t      mcause_q_out,
    output word_t      mepc_q_out,
    output word_t      satp_q_out
);
    word_t mstatus_q, mtvec_q, mip_q, mie_q, mscratch_q, mcause_q, mtval_q, mepc_q, mcycle_q, satp_q;
    u2     priv_mode_q;

    word_t mstatus_d, mtvec_d, mip_d, mie_d, mscratch_d, mcause_d, mtval_d, mepc_d, mcycle_d, satp_d;
    u2     priv_mode_d;

    assign priv_mode        = priv_mode_d;
    assign priv_mode_q_out  = priv_mode_q;
    assign mtvec_o   = mtvec_q;
    assign mepc_o    = mepc_q;
    assign satp_o    = satp_q;

    // dbg_* = *_d: Lab4 CSR write commit timing; trap updates visible same cycle in EX
    assign dbg_mstatus  = mstatus_d;
    assign dbg_mtvec    = mtvec_d;
    assign dbg_mip      = mip_d;
    assign dbg_mie      = mie_d;
    assign dbg_mscratch = mscratch_d;
    assign dbg_mcause   = mcause_d;
    assign dbg_mtval    = mtval_d;
    assign dbg_mepc     = mepc_d;
    assign dbg_mcycle   = mcycle_d;
    assign dbg_mhartid  = 64'd0;
    assign dbg_satp     = satp_d;
    assign mstatus_q_out = mstatus_q;
    assign mcause_q_out  = mcause_q;
    assign mepc_q_out    = mepc_q;
    assign satp_q_out    = satp_q;

    function automatic word_t apply_wmask(word_t wdata, word_t oldv, word_t wmask);
        return (wdata & wmask) | (oldv & ~wmask);
    endfunction

    always_comb begin
        csr_rdata = 64'b0;
        unique case (csr_raddr)
            CSR_MSTATUS:  csr_rdata = mstatus_q;
            CSR_MTVEC:    csr_rdata = mtvec_q;
            CSR_MIP:      csr_rdata = mip_q;
            CSR_MIE:      csr_rdata = mie_q;
            CSR_MSCRATCH: csr_rdata = mscratch_q;
            CSR_MCAUSE:   csr_rdata = mcause_q;
            CSR_MTVAL:    csr_rdata = mtval_q;
            CSR_MEPC:     csr_rdata = mepc_q;
            CSR_MCYCLE:   csr_rdata = mcycle_q;
            CSR_MHARTID:  csr_rdata = 64'd0;
            CSR_SATP:     csr_rdata = satp_q;
            default:      csr_rdata = 64'b0;
        endcase
    end

    always_comb begin
        mstatus_t ms;

        mstatus_d  = mstatus_q;
        mtvec_d    = mtvec_q;
        mip_d      = mip_q;
        mie_d      = mie_q;
        mscratch_d = mscratch_q;
        mcause_d   = mcause_q;
        mtval_d    = mtval_q;
        mepc_d     = mepc_q;
        satp_d     = satp_q;
        mcycle_d   = mcycle_q;
        priv_mode_d = priv_mode_q;

        if (reset) begin
            mstatus_d   = 64'b0;
            mtvec_d     = 64'b0;
            mip_d       = 64'b0;
            mie_d       = 64'b0;
            mscratch_d  = 64'b0;
            mcause_d    = 64'b0;
            mtval_d     = 64'b0;
            mepc_d      = 64'b0;
            mcycle_d    = 64'b0;
            satp_d      = 64'b0;
            priv_mode_d = 2'b11;
        end else begin
            // Lab5: trap_csr_commit (WB, older) first; trap_fire_ex (EX, newer) overrides
            if (trap_csr_commit) begin
                if (trap_is_mret_wb) begin
                    priv_mode_d = mstatus_q[12:11];
                    mstatus_d   = mstatus_q;
                    mstatus_d[3]  = mstatus_q[7];
                    mstatus_d[7]  = 1'b1;
                    mstatus_d[12:11] = 2'b00;
                end else begin
                    mepc_d      = trap_pc;
                    priv_mode_d = 2'b11;
                    mstatus_d   = mstatus_q;
                    mstatus_d[12:11] = trap_priv_wb;
                    mstatus_d[7]     = mstatus_q[3];
                    mstatus_d[3]     = 1'b0;
                    if (trap_priv_wb == 2'b00)
                        mcause_d = 64'd8;
                    else if (trap_priv_wb == 2'b01)
                        mcause_d = 64'd9;
                    else
                        mcause_d = 64'd11;
                end
            end
            if (trap_fire_ex) begin
                if (trap_is_mret_ex)
                    priv_mode_d = mstatus_q[12:11];
                else
                    priv_mode_d = 2'b11;
            end

            if (csr_we && csr_waddr == CSR_MCYCLE)
                mcycle_d = csr_wdata;
            else
                mcycle_d = mcycle_q + 64'd1;

            if (csr_we && (csr_waddr != CSR_MHARTID) && (csr_waddr != CSR_MCYCLE)) begin
                unique case (csr_waddr)
                    CSR_MSTATUS:  mstatus_d  = apply_wmask(csr_wdata, mstatus_q, MSTATUS_MASK);
                    CSR_MTVEC:    mtvec_d    = apply_wmask(csr_wdata, mtvec_q, MTVEC_MASK);
                    CSR_MIP:      mip_d      = apply_wmask(csr_wdata, mip_q, MIP_MASK);
                    CSR_MIE:      mie_d      = csr_wdata;
                    CSR_MSCRATCH: mscratch_d = csr_wdata;
                    CSR_MCAUSE:   mcause_d   = csr_wdata;
                    CSR_MTVAL:    mtval_d    = csr_wdata;
                    CSR_MEPC:     mepc_d     = csr_wdata;
                    CSR_SATP:     satp_d     = csr_wdata;
                    default:      ;
                endcase
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            mstatus_q   <= 64'b0;
            mtvec_q     <= 64'b0;
            mip_q       <= 64'b0;
            mie_q       <= 64'b0;
            mscratch_q  <= 64'b0;
            mcause_q    <= 64'b0;
            mtval_q     <= 64'b0;
            mepc_q      <= 64'b0;
            mcycle_q    <= 64'b0;
            satp_q      <= 64'b0;
            priv_mode_q <= 2'b11;
        end else begin
            mstatus_q   <= mstatus_d;
            mtvec_q     <= mtvec_d;
            mip_q       <= mip_d;
            mie_q       <= mie_d;
            mscratch_q  <= mscratch_d;
            mcause_q    <= mcause_d;
            mtval_q     <= mtval_d;
            mepc_q      <= mepc_d;
            mcycle_q    <= mcycle_d;
            satp_q      <= satp_d;
            priv_mode_q <= priv_mode_d;
        end
    end
endmodule

`endif
