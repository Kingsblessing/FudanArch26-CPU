`ifndef __VTOP_SV
`define __VTOP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/core.sv"
`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"
`include "src/mmu.sv"
`endif

`ifdef VIVADO
`include "include/common.sv"
`include "src/core.sv"
`include "util/IBusToCBus.sv"
`include "util/DBusToCBus.sv"
`include "util/CBusArbiter.sv"
`include "src/mmu.sv"
`endif

module VTop 
	import common::*;(
	input logic clk, reset,

	output cbus_req_t  oreq,
	input  cbus_resp_t oresp,
	input logic trint, swint, exint
);

    u2          priv_mode;
    word_t      satp;
    ibus_req_t  ireq;
    ibus_resp_t iresp;
    dbus_req_t  dreq;
    dbus_resp_t dresp;
    cbus_req_t  icreq,  dcreq;
    cbus_resp_t icresp, dcresp;
    cbus_req_t  mmu_req;
    cbus_resp_t mmu_resp;

    core core(
        .clk, .reset, .ireq, .iresp, .dreq, .dresp,
        .trint, .swint, .exint, .priv_mode_out(priv_mode), .satp_out(satp)
    );
    IBusToCBus icvt(.*);

    DBusToCBus dcvt(.*);


    CBusArbiter mux(
        .clk, .reset,
        .ireqs({icreq, dcreq}),
        .iresps({icresp, dcresp}),
        .oreq(mmu_req),
        .oresp(mmu_resp)
    );

    mmu mmu_inst(
        .clk, .reset, .priv_mode, .satp,
        .req_in(mmu_req), .req_out(oreq),
        .resp_in(oresp), .resp_out(mmu_resp)
    );

	always_ff @(posedge clk) begin
		if (~reset) begin
			// $display("icreq %x, %x", icreq.valid, icreq.addr);
			// if (oreq.valid || dcreq.addr == 64'h40600004) $display("dcreq %x, %x, oreq %x, %x, dcresp %x", dcreq.addr, dcreq.valid, oreq.valid, oreq.addr, dcresp.ready);
		end
	end
	

endmodule



`endif