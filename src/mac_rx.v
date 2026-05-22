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
localparam IDLE       = 3'd0; 
localparam DETECT_SFD = 3'd1;
localparam DST_MAC    = 3'd2;
localparam SRC_MAC    = 3'd2;
localparam PKT_TYPE   = 3'd2;
localparam VLAN       = 3'd2;
localparam HEADER     = 3'd2;
localparam BODY       = 3'd3; 
localparam FCS        = 3'd4; 
reg [2:0] fsm_q;

reg err_q; 
reg fwd_q; // forward packet to higher level, not filted out

localparam BUF_W = $max(MAC_W,SFD_W);
reg [BUF_W-1:0] buff_q;
wire frame_start;

reg  addr_cnt_q; 
wire dst_addr_match; 

// stream from PHY is expected to be gappless
always @(posedge clk) 
	if (~rst_n) 
		buff_q <= {BUF_W{1'b0}};
	else if (mac_v_i)
		buff_q <= {buff_q[BUF_W-3:2], mac_i};

// detect SFD
wire frame_start = buff_q[SFD_W-1:0] == SFD; 

// detect mac gap 

// filter out packets that don't match our MAC address (or multicast)
always @(posedge clk)
	if ((frame_start & fsm_q == DETECT_SFD) && (fsq_q == SRC_MAC & addr_cnt_q == ADDR_CNT)) 
		addr_cnt_q <= {ADDR_CNT_W{1'b0}};
	else
		addr_cnt_q <= addr_cnt_q + {{ADDR_CNT_W-1{1'b0}}, 1'b1};

wire dst_addr_match = phy_mac_i == buff_q;
// forwarding all broadcast and multicast packets
wire dst_addr_unicast = buff_q 

endmodule
