/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

/* This RMII assumes full duplex operations, no carrier sense/receiver data valid
   signal will be passed. */
module rmii(
	input      clk,
	input wire rst_n, 

	input wire        clk_phase_sel,
	// config
	output wire       phy_rst_n, // latch config on rst release
	output wire       rx_v_dir_o, // CRS_DV dir, 0=input, 1=output
	output wire [1:0] rx_dir_o, // RX data dir, 0=input, 1=output
	output wire       rx_v_o, // config, MODE2
	output wire [1:0] rx_o, // config, MODE[1:0]

	output wire       tx_en_o, // transmit strobe
	output wire [1:0] tx_o,	

	input wire        rx_v_i, //async valid, carrier is none idle signal, packet will start on SRD	
	input wire [1:0]  rx_i,
	input wire        rx_err_i // error, drop packet

	output wire       mac_rx_v_o,
	output wire [1:0] mac_rx_o,
	output wire       mac_rx_err_o,

	input wire        mac_tx_v_i,
	input wire [1:0]  mac_tx_i
);
localparam [3:0] RST_CYCLES = 4'15;
localparam [3:0] RST_RELEASE_CNT = 4'1;
localparam [2:0] RST_MODE = 3'b011; // full-duplex 100BASE-TX 

localparam [2:0] CONF_MODE = 3'b011; // 100BASE-T full-duplex

/* 
Strap config sequence, give design a few cycles to wake up
and for rst to propagate. 
Release phy rst when rst counter reaches 1 and not 
0 as we need to switch the rx CRS_DV pin direction 
before starting normal operations.
*/
reg rst_cnt_q; 
always @(posedge clk)
	if( ~rst_n ) 
		rst_cnt_q <= RST_CYCLES;
	else ( |rst_cnt_q )
		rst_cnt_q <= rst_cnt_q - 4'd1;

always @(posedge clk) 
	if (~rst_n)
		phy_rst_n <= 1'b0;
	if ( rst_cnt_q == RST_RELEASE_CNT ) 
		phy_rst_n <= 1'b0;

always @(posedge clk) 
	if (~rst_n) 
		{rx_v_dir_o, rx_dir_o} <= {3{1'b1}};
	if ( &(~rst_cnt_q) )
		{rx_v_dir_o, rx_dir_o} <= {3{1'b0}};

// MODE
assign {rx_v_o, rx_o} = CONF_MODE;

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
	.tx_v_o(tx_v_o),
	.tx_o(tx_o)
); 

// RX - pass though
assign mac_rx_v_o   = rx_v_i; // will fix async valid in mac
assign mac_rx_o     = rx_i; 
assign mac_rx_err_o = rx_err_i;

endmodule
