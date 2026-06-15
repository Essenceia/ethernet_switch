/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

`default_nettype none

module tt_um_teapot #(
	localparam PHY_W = 2,
	localparam VID_W = 12,
	localparam MAC_W = 48,
 	parameter [15:0]      APP_ETHTYPE  = 16'h88B5,
	parameter [15:0]      CONF_ETHTYPE = 16'h88B6, 
	parameter [VID_W-1:0] DEFAULT_VID = 12'hDAD,
	parameter [MAC_W-1:0] DEFAULT_MAC = 48'h0090CF00BEEF // nortel manifacturer
)(
	input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
reg rst_n_d1_q;
reg rst_n_d2_q; 

wire [VID_W-1:0] vid; 
wire [MAC_W-1:0] mac_addr;

wire        data_rx_v;
wire        data_rx_conf;
wire        data_rx_start;
wire        data_rx_err;
wire [PHY_W-1:0] data_rx;
wire [MAC_W-1:0] data_rx_src_mac; 

wire             rmii_tx_v; 
wire [PHY_W-1:0] rmii_tx;

wire        mac_tx_v;
wire        mac_tx_last;
wire        mac_tx_acc;
wire [PHY_W-1:0]  mac_tx;
wire [MAC_W-1:0] mac_tx_dst_mac;

wire       mac_rx_err;
wire       mac_rx_v;
wire [PHY_W-1:0] mac_rx;

// IO
wire [7:0] uio_in_unused;
assign uio_oe        = 8'd0;
assign uio_out       = 8'd0;
assign uio_in_unused = uio_in;

// IN
(* MARK_DEBUG = "true" *) wire             phy_rx_v;
(* MARK_DEBUG = "true" *) wire [PHY_W-1:0] phy_rx;
(* MARK_DEBUG = "true" *) wire             phy_rx_err;

wire [2:0] ui_unused;
wire default_tx_phase; 

assign phy_rx     = ui_in[1:0];
assign phy_rx_v   = ui_in[2];
assign phy_rx_err = ui_in[3];
assign ui_unused  = ui_in[6:4];
assign default_tx_phase = ui_in[7]; 

// OUT 
wire [1:0] phy_tx;
wire       phy_tx_v;

assign uo_out[1:0] = phy_tx;
assign uo_out[2]   = phy_tx_v;
assign uo_out[7:3] = 5'd0;

// misc
wire ena_unused; 
assign ena_unused = ena; 

// rst flop, only used sequentially 
always @(posedge clk) begin
	rst_n_d1_q <= rst_n;
	rst_n_d2_q <= rst_n_d1_q;
end

// rmii 
rmii m_rmii(
	.clk(clk),
	.rst_n(rst_n_d2_q),

	.clk_phase_sel_i(default_tx_phase),

	.phy_tx_v_o(phy_tx_v),
	.phy_tx_o(phy_tx),

	.phy_rx_v_i(phy_rx_v),
	.phy_rx_i(phy_rx),
	.phy_rx_err_i(phy_rx_err),

	.mac_rx_v_o(mac_rx_v),
	.mac_rx_o(mac_rx),
	.mac_rx_err_o(mac_rx_err),

	.mac_tx_v_i(rmii_tx_v),
	.mac_tx_i(rmii_tx)
);

// rx mac 
mac_rx #(
	.APP_ETHTYPE(APP_ETHTYPE),
	.CONF_ETHTYPE(CONF_ETHTYPE)
)m_mac_rx(
	.clk(clk),
	.rst_n(rst_n_d2_q),

	.phy_mac_i(mac_addr),
	.vid_i(vid),

	.rx_v_i(mac_rx_v),
	.rx_i(mac_rx),
	.rx_err_i(mac_rx_err),

	.data_v_o(data_rx_v),
	.data_conf_o(data_rx_conf),
	.data_start_o(data_rx_start),
	.data_err_o(data_rx_err),
	.data_o(data_rx),
	.data_src_mac_o(data_rx_src_mac)
);

//application
app_wrapper #(.PHY_W(PHY_W)) m_app_wrapper(
	.clk(clk),
	.rst_n(rst_n_d2_q),

	.data_v_i      (data_rx_v),
	.data_conf_i   (data_rx_conf),
	.data_start_i  (data_rx_start),
	.data_err_i    (data_rx_err),
	.data_i        (data_rx),
	.data_src_mac_i(data_rx_src_mac),

	.mac_tx_v_o      (mac_tx_v),
	.mac_tx_last_o   (mac_tx_last),
	.mac_tx_acc_i    (mac_tx_acc),
	.mac_tx_o        (mac_tx),
	.mac_tx_dst_mac_o(mac_tx_dst_mac)
);

// playpen config
mac_conf #(
	.PHY_W(PHY_W),
	.DEFAULT_VID(DEFAULT_VID),
	.DEFAULT_MAC(DEFAULT_MAC)
)m_mac_conf(
	.clk(clk),
	.rst_n(rst_n_d2_q),

	.data_v_i    (data_rx_v),
	.data_conf_i (data_rx_conf),
	.data_start_i(data_rx_start),
	.data_err_i  (data_rx_err),
	.data_i      (data_rx),

	.vid_o          (vid),
	.mac_addr_o     (mac_addr)
);

// tx mac
mac_tx #(
	.PHY_W(PHY_W),
	.APP_ETHTYPE(APP_ETHTYPE)
) m_mac_tx(
	.clk(clk),
	.rst_n(rst_n_d2_q),
	
	.phy_mac_i(mac_addr),// conf
	
	.data_v_i(mac_tx_v),
	.data_last_i(mac_tx_last),
	.data_i(mac_tx),
	.data_dst_mac_i(mac_tx_dst_mac),
	.data_acc_o(mac_tx_acc),

	.phy_v_o(rmii_tx_v),
	.phy_o(rmii_tx)
);

endmodule
