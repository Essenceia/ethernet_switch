/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

module switch #(
	localparam PORT_CNT = 3,
	localparam PHY_W = 2
)(
	input wire clk, 
	input wire rst_n, 

	input wire [PORT_CNT-1:0]       mac_rx_v_i,
	input wire [PORT_CNT*PHY_W-1:0] mac_rx_i,

	output wire [PORT_CNT-1:0]       mac_tx_v_o,
	output wire [PORT_CNT-1:0]       mac_tx_last_o,
	output wire [PORT_CNT*PHY_W-1:0] mac_tx_o,

	input  wire [PORT_CNT-1:0]       mac_tx_acc_i
);
localparam DATA_DELAY = 8 * 8; // preamble + sfd
localparam BUF_W = DATA_DELAY;
localparam BUF_V_W = DATA_DELAY / PHY_W; 

// buffer incomming data
reg [BUF_W-1:0]   buff_q[PORT_CNT-1:0];
reg [BUG_V_W-1:0] buff_v_q[PORT_CNT-1:0];
 
genvar i; 
generate 
	for(i = 0; i < PORT_CNT; i=i+1) begin: g_port_buff
		always @(posedge clk) begin
			buff_q[i]   <= {buff_q[i][BUF_W-PHY_W-1:0], mac_rx_i[i]};
			buff_v_q[i] <= {buff_v_q[i][BUF_V_W-2:0], mac_rx_v_i[i]};
		end
	end
endgenerate

// keep track of incomming requests
endmodule
