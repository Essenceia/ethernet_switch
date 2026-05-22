/*
Copyright (c) 2026 Julia Desmazes, all rights reserved.  

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* 
Parsing mac headers, will filter out all packets that 
are not IPv4/6 to be handeled by the CPU 
*/ 
module mac_rx(
	input clk, 
	input wire rst_n, 

	input [47:0] phy_mac_i, 
 
	input        mac_v_i, 
	input [1:0]  mac_i, 
	input        mac_err_i,

	output       data_v_o,
	output       data_start_o,
	output [1:0] data_o,
	output       data_err_o // drop ongoing packet on error
); 
`include eth_defines.vh

// fsm 
localparam IDLE = 0; 
localparam DETECT_SFD = 1;
localparam HEADER = 2;
localparam BODY = 3; 
localparam FCS = 4;
localparam DROP = 
localparam BUF_W = $max(MAC_W,SFD_W);

reg [BUF_W-1:0] buff_q;
wire frame_start;

// stream from PHY is expected to be gappless
always @(posedge clk) 
	if (~rst_n) 
		buff_q <= {BUF_W{1'b0}};
	else if (mac_v_i)
		buff_q <= {buff_q[BUF_W-3:2], mac_i};

// detect SFD

// detect mac gap 

// filter out packets that don't match our MAC address (or multicast)


endmodule
