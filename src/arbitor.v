/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

module arbitor #(
	localparam PORT_CNT = 3,
	parameter MAC_W = 48
)(
	input wire clk, 
	input wire rst_n, 

	input wire [PORT_CNT-1:0] req_next_i, 
	input wire [MAC_W*PORT_CNT-1:0] req_mac_i, 

	output wire                req_v_o,	
	output wire[PORT_CNT-1:0]  req_port_o, 
	output wire[MAC_W-1:0]     req_mac_o
);

// priority selection
wire [PORT_CNT-1:0] prio_req; 
reg  [PORT_CNT-1:0] prio_req_q; 
assign prio_req[0] = new_req_i[0];
assign prio_req[1] = new_req_i[1] & ~new_req_i[0];
assign prio_req[2] = new_req_i[2] & ~|new_req_i[1:0];

always @(posedge clk) 
	prio_req_q <= prio_req;

reg [MAC_W-1:0] req_mac;
always @(*) begin
	casex(prio_req_q)
		3'bxx1: req_mac = req_mac_i[MAC_W-1:0];
		3'bx1x: req_mac = req_mac_i[2*MAC_W-1-:MAC_W];
		3'b1xx: req_mac = req_mac_i[3*MAC_W-1-:MAC_W];
		default: req_mac = {MAC_W{1'bx}};
	endcase
end

assign req_v_o = |prio_req_q;
assign req_port_o = prio_req_q; 

endmodule
