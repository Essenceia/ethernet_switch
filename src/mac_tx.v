/*
Copyright (c) 2026 Julia Desmazes, all rights reserved.  

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* MAC TX 
Send out response packet with accelerator results encapsulated.
Packet will NOT contain a VLAN tag.
Module will be adding : 
- header
- fcs 
*/
module mac_tx #(
	parameter PHY_W = 2,
	localparam MAC_W = 48
)(
	input clk, 
	input wire rst_n, 

	input wire [MAC_W-1:0] phy_mac_i, 

	input wire             data_v_i, 
	input wire [PHY_W-1:0] data_i, 
	input wire [MAC_W-1:0] data_dst_mac_i,
	output wire            data_acc_o, // accept payload, start streaming

	output wire phy_v_o,
	output wire [PHY_W-1:0] phy_o	
);
localparam CNT_W = 6; 
localparam [CNT_W-1:0] PREAMBLE_CNT = 7 * (8/PHY); 
localparam [CNT_W-1:0] SFD_CNT      = 1 * (8/PHY); 
localparam [CNT_W-1:0] MAC_CNT      = 6 * (8/PHY); 
localparam [CNT_W-1:0] ETHTYPE_CNT  = 2 * (8/PHY); 
localparam [CNT_W-1:0] FCS_CNT      = 4 * (8/PHY); 
/* 
fsm
start streaming out header when a new request arrived (data_v_i), 
and lift the accept signal to tell application that it can start
streaming payload.
When data_v_i is deaserted this signals the end of the payload
so append the fcs */
localparam IDLE     = 3'd0;
localparam PREAMBLE = 3'd1;
localparam SFD      = 3'd2; 
localparam SRC_MAC  = 3'd3;
localparam DST_MAC  = 3'd4;
localparam ETHTYPE  = 3'd5;
localparam PAYLOAD  = 3'd6;
localparam FCS      = 3'd7;

reg [2:0] fsm_q;
reg cnt_q; 
always @(posedge clk) 
	if (~rst_n) 
		fsm_q <= IDLE; 
	else begin
		case(fsm_q) 
			IDLE    : fsm_q <= data_v_i ? PREAMBLE: IDLE; 
			PREAMBLE: fsm_q <= cnt_q == PREAMBLE_CNT ? SFD: PREAMBLE; 
			SFD     : fsm_q <= cnt_q == SFD_CNT ? SRC_MAC: SFD; 
			SRC_MAC : fsm_q <= cnt_q == MAC_CNT ? DST_MAC: SRC_MAC; 
			DST_MAC : fsm_q <= cnt_q == MAC_CNT ? SRC_MAC: ETHTYPE; 
			PAYLOAD : fsm_q <= data_last_i ? FCS : PAYLOAD;
			FCS     : fsm_q <= cnt_q == FCS_CNT ? IDLE : FCS;
		endcase
	end
end

assign data_acc_o = (fsm_q == PAYLOAD);

// mac
reg [MAC_W-1:0] mac_buff_q;
always @(posedge clk) 
	if ((fsm_q == SFD) && (cnt_q == SFD_CNT)) mac_buff_q <= phy_mac_i;
	else if ((fsm_q == SRC_MAC) && (cnt_q == MAC_CNT)) mac_buff_q <= data_dst_mac_i;
	else mac_buff_q <= {mac_buff_q[MAC_W-PHY_W-1:0], data_i};

wire [PHY_W-1:0] data;
assign data = ((fsm_q == SRC_MAC)|(fsm_q == DST_MAC))? mac_buff_q[MAC_W-1:MAC_W-3]:
endmodule	
