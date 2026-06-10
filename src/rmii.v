/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* This RMII assumes full duplex operations, no carrier sense/receiver data valid
   signal will be passed. */
module rmii(
	input wire clk,
	input wire rst_n, 

	input wire        clk_phase_sel_i,
	// config
	output wire       phy_rst_n_o, // latch config on rst release
	output wire       phy_rx_v_dir_o, // CRS_DV dir, 0=input, 1=output
	output wire [1:0] phy_rx_dir_o, // RX data dir, 0=input, 1=output
	output wire       phy_rx_v_o, // config, MODE2
	output wire [1:0] phy_rx_o, // config, MODE[1:0]

	output wire       phy_tx_v_o, // transmit strobe
	output wire [1:0] phy_tx_o,	

	input wire        phy_rx_v_i, //async valid, carrier is none idle signal, packet will start on SRD	
	input wire [1:0]  phy_rx_i,
	input wire        phy_rx_err_i, // error, drop packet

	output wire       mac_rx_v_o,
	output wire [1:0] mac_rx_o,
	output wire       mac_rx_err_o,

	input wire        mac_tx_v_i,
	input wire [1:0]  mac_tx_i
);
localparam  T_RST_IA = (100000 / 50); // rst input assert time: 100 us 
localparam       RST_CNT_W = $clog2(T_RST_IA);
localparam [RST_CNT_W-1:0] RST_CYCLES = {RST_CNT_W{1'b1}};
localparam [RST_CNT_W-1:0] RST_RELEASE_CNT = {{RST_CNT_W-1{1'b0}}, 1'b1};

localparam [2:0] CONF_MODE = 3'b011; // 100BASE-T full-duplex

/* 
Strap config sequence, give design a few cycles to wake up
and for rst to propagate. 
Release phy rst when rst counter reaches 1 and not 
0 as we need to switch the rx CRS_DV pin direction 
before starting normal operations.
*/
reg [RST_CNT_W-1:0] rst_cnt_q; 
always @(posedge clk)
	if( ~rst_n ) 
		rst_cnt_q <= RST_CYCLES;
	else if ( |rst_cnt_q )
		rst_cnt_q <= rst_cnt_q - {{RST_CNT_W-1{1'b0}}, 1'b1};

reg phy_rst_n_q;
always @(posedge clk) 
	if (~rst_n)
		phy_rst_n_q <= 1'b0;
	else if ( rst_cnt_q == RST_RELEASE_CNT ) 
		phy_rst_n_q <= 1'b1;
assign phy_rst_n_o = phy_rst_n_q;

reg       phy_rx_v_dir_q;
reg [1:0] phy_rx_dir_q;
always @(posedge clk) 
	if (~rst_n) 
		{phy_rx_v_dir_q, phy_rx_dir_q} <= {3{1'b1}}; // outputs for config
	else if ( phy_rst_n_q ) // hold config after rst deasserted, this is safe since conf sets valid = 0
		{phy_rx_v_dir_q, phy_rx_dir_q} <= {3{1'b0}}; // configure as inputs
assign phy_rx_v_dir_o = phy_rx_v_dir_q;
assign phy_rx_dir_o   = phy_rx_dir_q;

// MODE
assign {phy_rx_v_o, phy_rx_o} = CONF_MODE;

// implictly already set by wiring : 
// PHYADDR0 = 0 
// REGOFF = 0 (enabled) 
// nINTSET = 1 (REF_CLK In mode) 

// TX - adjust clk phase
reg       mac_tx_v_q;
reg [1:0] mac_tx_q;

always @(posedge clk) begin
	mac_tx_v_q <= mac_tx_v_i; 
	mac_tx_q   <= mac_tx_i;
end

tx_tt_buffer m_tx_delay(
	.ref_clk(clk),
	.rst_n(rst_n), 

	.clk_phase_sel_i(clk_phase_sel_i),

	.tx_v_i(mac_tx_v_q),
	.tx_i(mac_tx_q),

	.tx_v_o(phy_tx_v_o),
	.tx_o(phy_tx_o)
); 

// RX - pass though, flop for timing
reg       mac_rx_v_q;
reg       mac_rx_err_q;
reg [1:0] mac_rx_q;

always @(posedge clk) begin
	if (~rst_n) begin
		mac_rx_v_q   <= 1'b0;
		mac_rx_err_q <= 1'b0;
		mac_rx_q     <= 2'b00;
	end else begin
		mac_rx_v_q   <= phy_rx_v_i;
		mac_rx_err_q <= phy_rx_err_i;
		mac_rx_q     <= phy_rx_i;
	end
end

assign mac_rx_v_o   = mac_rx_v_q; // will fix async valid in mac
assign mac_rx_o     = mac_rx_q; 
assign mac_rx_err_o = mac_rx_err_q;

endmodule
