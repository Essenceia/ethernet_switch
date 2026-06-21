/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none
`timescale 1ns / 10ps

module tb ();

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
		#1;
	end

	// Wire up the inputs and outputs:
	wire clk;
	wire rst_n;
	wire ena;
	
	wire [7:0] ui_in;
	wire [7:0] uio_in;
	wire [7:0] uo_out;
	wire [7:0] uio_out;
	wire [7:0] uio_oe;

	// cocotb lacks support for verilog array indexing
	// RX0 path
	wire [1:0] phy_rx0;
	wire       phy_rx0_v;
	wire       phy_rx0_err;
	// RX1
	wire [1:0] phy_rx1;
	wire       phy_rx1_v;
	wire       phy_rx1_err;
	// RX2
	wire [1:0] phy_rx2;
	wire       phy_rx2_v;
	wire       phy_rx2_err;
		
	// TX0 
	wire [1:0] phy_tx0;
	wire       phy_tx0_v;
	// TX1
	wire [1:0] phy_tx1;
	wire       phy_tx1_v;
	// TX2 
	wire [1:0] phy_tx2;
	wire       phy_tx2_v;

	wire       tx_phase; 

	assign ui_in[1:0] = phy_rx0;
	assign ui_in[2]   = phy_rx0_v;
	assign ui_in[3]   = phy_rx0_err;

	assign ui_in[5:4] = phy_rx1;
	assign ui_in[6]   = phy_rx1_v;
	assign ui_in[7]   = phy_rx1_err;

	assign uio_in[1:0] = phy_rx2;
	assign uio_in[2]   = phy_rx2_v;
	assign uio_in[3]   = phy_rx2_err;

	assign uio_in[4]   = tx_phase;

	assign phy_tx0     = uo_out[1:0];
	assign phy_tx0_v   = uo_out[2];

	assign phy_tx1     = uo_out[6:5];
	assign phy_tx1_v   = uo_out[7];

	assign phy_tx2     = uio_out[6:5];
	assign phy_tx2_v   = uio_out[7];

	tt_um_coffeepot m_dut (
		  .ui_in  (ui_in),    // Dedicated inputs
		  .uo_out (uo_out),   // Dedicated outputs
		  .uio_in (uio_in),   // IOs: Input path
		  .uio_out(uio_out),  // IOs: Output path
		  .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
		  .ena    (ena),      // enable - goes high when design is selected
		  .clk    (clk),      // clock
		  .rst_n  (rst_n)     // not reset
	);


/* mac address table for increasing tech coverage */
localparam MAC_W = 48;
localparam PORT_CNT = 3;
localparam N = 4; 

wire               rd_early_v;
wire [MAC_W-1:0]   rd_early_mac;
reg                _rd_v_q;
reg  [MAC_W-1:0]   _rd_mac_q;

wire                wr_early_v; 
wire [MAC_W-1:0]    wr_early_mac; 
wire [PORT_CNT-1:0] wr_early_port;
reg  [MAC_W-1:0]    _wr_mac_q; 
reg  [PORT_CNT-1:0] _wr_port_q;

wire                hit; 
wire [PORT_CNT-1:0] hit_port;

always @(posedge clk) begin
	_rd_v_q    <= rd_early_v;
	_rd_mac_q  <= rd_early_mac;
	_wr_mac_q  <= wr_early_mac;
	_wr_port_q <= wr_early_port;
end

mac_addr_table #(.N(N), .MAC_W(MAC_W), .PORT_CNT(PORT_CNT)) m_table( 
	.clk(clk),
	.rst_n(rst_n), 
	.rd_v_i(_rd_v_q),
	.rd_early_v_i(rd_early_v),
	.rd_mac_i(_rd_mac_q),
	.wr_early_v_i(wr_early_v),
	.wr_mac_i(_wr_mac_q),
	.wr_port_i(_wr_port_q),
	.hit_v_o(hit),
	.hit_port_o(hit_port)
);

endmodule
