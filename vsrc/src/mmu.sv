`ifndef __MMU_SV
`define __MMU_SV

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

// Sv39 MMU on CBus (after arbiter). Enabled in U/S when satp.mode == 8.
module mmu import common::*; import csr_pkg::*; (
    input  logic       clk,
    input  logic       reset,
    input  u2          priv_mode,
    input  word_t      satp,
    input  cbus_req_t  req_in,
    output cbus_req_t  req_out,
    input  cbus_resp_t resp_in,
    output cbus_resp_t resp_out
);
    satp_t satp_v;
    assign satp_v = satp_t'(satp);

    logic mmu_on;
    assign mmu_on = (priv_mode != 2'b11) && (satp_v.mode == 4'd8);

    typedef enum logic [1:0] {
        ST_IDLE  = 2'd0,
        ST_PTE   = 2'd1,
        ST_WAIT  = 2'd2
    } state_t;

    state_t state;
    cbus_req_t saved_req;
    addr_t    paddr;
    logic     pte_hold;

`ifdef VERILATOR
    logic        pte_en;
    addr_t       pte_vaddr;
    logic [63:0] pte;
    logic [7:0]  pte_level;
    logic [7:0]  pte_pf;

    assign pte_vaddr = (state == ST_IDLE) ? req_in.addr : saved_req.addr;
    assign pte_en    = (state == ST_IDLE) && req_in.valid && mmu_on;

    PTEHelper pte_helper_inst(
        .clock(clk),
        .enable(pte_en),
        .satp(satp),
        .vpn({{37'b0}, pte_vaddr[38:12]}),
        .pte(pte),
        .level(pte_level),
        .pf(pte_pf)
    );

    function automatic addr_t sv39_paddr(
        input word_t pte_val,
        input addr_t vaddr,
        input logic [7:0] level
    );
        unique case (level)
            8'd0: sv39_paddr = {{8'b0}, pte_val[53:28], vaddr[29:12], vaddr[11:0]};
            8'd1: sv39_paddr = {{8'b0}, pte_val[53:19], vaddr[20:12], vaddr[11:0]};
            default: sv39_paddr = {{8'b0}, pte_val[53:10], vaddr[11:0]};
        endcase
    endfunction
`endif

    always_ff @(posedge clk) begin
        if (reset) begin
            state     <= ST_IDLE;
            saved_req <= '0;
            paddr     <= 64'b0;
            pte_hold  <= 1'b0;
        end else if (!mmu_on) begin
            state     <= ST_IDLE;
            pte_hold  <= 1'b0;
        end else begin
            unique case (state)
                ST_IDLE: begin
                    pte_hold <= 1'b0;
                    if (req_in.valid) begin
                        saved_req <= req_in;
                        state     <= ST_PTE;
                    end
                end
                ST_PTE: begin
                    if (!pte_hold) begin
                        pte_hold <= 1'b1;
                    end else begin
`ifdef VERILATOR
                        if (pte_pf == 8'b0)
                            paddr <= sv39_paddr(pte, saved_req.addr, pte_level);
                        else
                            paddr <= 64'b0;
`else
                        paddr <= saved_req.addr;
`endif
                        pte_hold <= 1'b0;
                        state    <= ST_WAIT;
                    end
                end
                ST_WAIT: begin
                    if (resp_in.ready && resp_in.last)
                        state <= ST_IDLE;
                end
                default: state <= ST_IDLE;
            endcase
        end
    end

    always_comb begin
        req_out  = req_in;
        resp_out = resp_in;

        if (!mmu_on) begin
            // passthrough
        end else if (state == ST_WAIT) begin
            req_out       = saved_req;
            req_out.valid = 1'b1;
            req_out.addr  = paddr;
        end else begin
            req_out.valid  = 1'b0;
            resp_out.ready = 1'b0;
            resp_out.last  = 1'b0;
            resp_out.data  = 64'b0;
        end
    end

endmodule

`endif
