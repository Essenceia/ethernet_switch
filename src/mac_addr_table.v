/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

module mac_addr_table #(
	parameter N = 4, // number of entries
	parameter MAC_W = 48,
	parameter PORT_CNT = 3,
	localparam PORT_IDX_W = $clog2(PORT_CNT)
)(
	input wire clk, 
	input wire rst_n, 

	input wire rd_v_i, 
	input wire [MAC_W-1:0] rd_mac_i, 

	input wire wr_v_i, 
	input wire [MAC_W-1:0] wr_mac_i, 
	input wire [PORT_CNT-1:0] wr_port_i, 
	
	output wire                hit_v_o, 
	output wire [PORT_CNT-1:0] hit_port_o
);

endmodule 
