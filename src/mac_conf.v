/*
Copyright (c) 2026 Julia Desmazes, all rights reserved.  

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* store MAC configurations, updated by offload CPU
configs: 
- TX clk dephase
- VLAN ID (12 bits)
- Device MAC address (48 bits)

By default these configs will be set based 
on the module parameters and reset to default
on each sync reset.
*/
module mac_conf #(
	localparam VID_W = 12,
	localparam MAC_ADDR_W = 48,
	parameter TX_CLK_DEPHASE = 1'b1, // 180 degrees dephase from ref_clk
	parameter [VID_W-1:0]      VID = 12'h,
	parameter [MAC_ADDR_W-1:0] MAC_ADDR = 48'h
)
(
	input clk, 
	input rst_n,
	
	input wire       conf_v_i,
	input wire       conf_type_i,//0: dephase, 1: mac/vid
	input wire [1:0] conf_i,

	output wire                  clk_dephase_sel_o,
	output wire [VID_W-1:0]      vid_o,
	output wire [MAC_ADDR_W-1:0] mac_addr_o
);
localparam CONF_TYPE_DEPHASE = 1'b0;
localparam CONF_TYPE_MAC_VID = 1'b1;

/* Configuration packet types :

0 : dephase pkt type
pkt : [ x <dephase> ] 2 bits wide, single transfer

1: mac/vid pkt type 
pkt : [ mac ] [ vid ] 48+12=60 bits wide, 30 transfers
*/
reg                  dephase_sel_q;
reg [MAC_ADDR_W-1:0] mac_addr_q;
reg [VID_W-1:0]      vid_q;

always @(posedge clk) 
	if (~rst_n) 
		dephase_sel_q <= TX_CLK_DEPHASE;
	else if (conf_v_i & conf_type_i == CONF_TYPE_DEPHASE)
		dephase_sel_q <= conf_i[0];

always @(posedge clk) 
	if (~rst_n) 
		{ mac_addr_q, vid_q} <= { MAC_ADDR, VID};
	else if (conf_v_i & conf_type == CONF_TYPE_MAC_VID)
		{ mac_addr_q, vid_q} <= {mac_addr_q[MAC_ADDR_W-3:0], vid_q, conf_i};
		
assign clk_dephase_sel_o = dephase_sel_q;
assign mac_addr_o = mac_addr_q;
assign vid_o = vid_q;

endmodule
