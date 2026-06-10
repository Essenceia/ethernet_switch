/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* IO mux FPGA replicate, assuming FPGA syn will be
infering tristate buffer.
Sel direction : 
0 - input 
1 - output */
module io_switch #(
	parameter W = 8
)(
	input  wire [W-1:0] dir_sel_i,		
	input  wire [W-1:0] data_out_i,
	output wire [W-1:0] data_in_o,
	inout  wire [W-1:0] pin_io
);

(* MARK_DEBUG = "true" *)wire [W-1:0] sel;
(* MARK_DEBUG = "true" *)wire [W-1:0] debug_data_in;
assign sel = dir_sel_i;
assign debug_data_in = data_in_o;
// tristate buff for out dir
genvar i; 
generate 
	for (i = 0; i < W; i++) begin: g_tristate
		IOBUF m_iobuf(
			.O(data_in_o[i]),
			.I(data_out_i[i]),
			.IO(pin_io[i]),
			.T(sel)
		); 
	end
endgenerate
endmodule
