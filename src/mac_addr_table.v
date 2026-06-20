/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* Guaranties no duplicate entries */
module mac_addr_table #(
	parameter N = 4, // number of entries
	parameter MAC_W = 48,
	parameter PORT_CNT = 3
)(
	input wire clk, 
	input wire rst_n, 

	input wire                 rd_v_i, 
	input wire                 rd_early_v_i, 
	input wire [MAC_W-1:0]     rd_mac_i, 

	input wire                 wr_early_v_i, 
	input wire [MAC_W-1:0]     wr_mac_i, 
	input wire [PORT_CNT-1:0]  wr_port_i, 
	
	output wire                hit_v_o, 
	output wire [PORT_CNT-1:0] hit_port_o
);
/* memory line layout 
[ MAC 48b ][ PORT 2b ][ TTNN 4b ]

MAC  mac address
PORT compressed port index 
TTNN time to num num (ageing mechanism) 
*/
localparam PORT_IDX_W    = $clog2(PORT_CNT);
localparam TTNN_W        = 4;
localparam MAC_GROUP_IDX = 40;  

/* memory fsm : coordinate read/writes, trigger regular ttnn updates */
localparam IDLE   = 2'd0; 
localparam WRITE  = 2'd1;
localparam UPDATE = 2'd2;
reg [1:0] fsm_q; 

wire wr_v;
wire req_ttnn_update;
wire [MAC_W-1:0] rd_mac; 

always @(posedge clk) begin
	if (~rst_n) fsm_q <= IDLE; 
	else begin
		case(fsm_q) 
			IDLE:    fsm_q <= wr_early_v_i ? WRITE : req_ttnn_update ? UPDATE : IDLE; 
			WRITE:   fsm_q <= ~rd_v_i ? IDLE: WRITE; 
			UPDATE:  fsm_q <= IDLE; 
			default: fsm_q <= IDLE; 
		endcase
	end
end

// TTNN 
ttnn_timer m_ttnn_timer(
	.clk(clk), 
	.rst_n(rst_n), 
	.update_finished_i(fsm_q == UPDATE),
	.update_req_o(req_ttnn_update)
);

// in the absence of a CAM ( TODO: design an analog CAM ) 
reg [MAC_W-1:0]      mem_mac_q[N-1:0];
reg [PORT_IDX_W-1:0] mem_port_q[N-1:0];
reg [TTNN_W-1:0]     mem_ttnn_q[N-1:0];

wire [N-1:0] mac_hit; 
wire [N-1:0] alive_v; 
reg  [N-1:0] wr_sel_q;
wire         wr_mac_group; 

genvar i; 

// TODO replacement policy and look for collisions 
assign wr_mac_group = wr_mac_i[MAC_GROUP_IDX]; // don't write group addresses, should be broadcasted
assign wr_sel_q = mac_hit // collison, overwrite entry 
			   | ({N{~|mac_hit & ~wr_mac_group}} & 4'b0001);

// compress port onehot to idx
reg [PORT_IDX_W-1:0] wr_port_idx; 
always @(*) begin
	/* verilator lint_off CASEOVERLAP */
	(* parallel_case *)
	casez(wr_port_i)
		3'b??1: wr_port_idx = 2'd0;
		3'b?1?: wr_port_idx = 2'd1;
		3'b1??: wr_port_idx = 2'd2;
		default: wr_port_idx = {PORT_IDX_W{1'bx}};
	endcase
	/* verilator lint_on CASEOVERLAP */
end

// write
assign wr_v = (fsm_q == WRITE) & ~rd_v_i; 
generate
	for(i=0; i < N; i=i+1)begin: g_mem
		// TTNN
		always @(posedge clk) 
			if (~rst_n )                 mem_ttnn_q[i] <= {TTNN_W{1'b0}};
			else if (wr_v & wr_sel_q[i]) mem_ttnn_q[i] <= {TTNN_W{1'b1}};
			else if  (fsm_q == UPDATE)   mem_ttnn_q[i] <= mem_ttnn_q[i] - {{TTNN_W-1{1'b0}},alive_v[i]}; // can do sequential update for area		

		always @(posedge clk) begin
			if (wr_v & wr_sel_q[i]) begin
				mem_mac_q[i] <= wr_mac_i;
				mem_port_q[i] <= wr_port_idx;
			end
		end
	end // for
endgenerate

reg wr_lookup_mac_sel_q; 
always @(posedge clk) 
	wr_lookup_mac_sel_q <= ~rd_early_v_i;

assign rd_mac = wr_lookup_mac_sel_q ? wr_mac_i: rd_mac_i;	

// read - parallel lookup
generate
	for(i=0; i < N; i=i+1)begin: g_parallel_lookup
		assign mac_hit[i] = mem_mac_q[i] == rd_mac; 
		assign alive_v[i] = |mem_ttnn_q[i]; 
	end
endgenerate 

reg [PORT_IDX_W-1:0] port_hit; 
always @(*) begin
	/* verilator lint_off CASEOVERLAP */
	(* parallel_case *)
	casez(mac_hit)
		4'b???1: port_hit = mem_port_q[0];
		4'b??1?: port_hit = mem_port_q[1];
		4'b?1??: port_hit = mem_port_q[2];
		4'b1???: port_hit = mem_port_q[3];
		default: port_hit = {PORT_IDX_W{1'bX}};
	endcase
	/* verilator lint_on CASEOVERLAP */
end

reg [PORT_CNT-1:0] port_hit_full; 
always @(*) begin
	case(port_hit) 
		2'd0: port_hit_full = 3'b001;
		2'd1: port_hit_full = 3'b010;
		2'd3: port_hit_full = 3'b100;
		default: port_hit_full = {PORT_CNT{1'bx}};
	endcase
end

assign hit_v_o = |(mac_hit & alive_v);
assign hit_port_o = port_hit_full; 

endmodule 
