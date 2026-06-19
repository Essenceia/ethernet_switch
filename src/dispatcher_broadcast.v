/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

module dispatcher_broadcast #(
	localparam PORT_CNT = 3
)(
	input wire [PORT_CNT-1:0] new_req_i, 
	input wire [PORT_CNT-1:0] free_i,

	output wire [PORT_CNT-1:0] new_dispatch_o,
	output wire [PORT_CNT*(PORT_CNT-1)-1:0] dir_o	
);
// select high priority req
wire [PORT_CNT-1:0] prio_req; 
assign prio_req[0] = new_req_i[0];
assign prio_req[1] = new_req_i[1] & ~new_req_i[0];
assign prio_req[2] = new_req_i[2] & ~|new_req_i[1:0];

wire is_req; 
assign is_req = |prio_req; 

assign new_dispatch_o = free_i & {PORT_CNT{is_req}};
assign dir_o = prio_req; 

endmodule	
