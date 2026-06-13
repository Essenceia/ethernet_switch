`default_nettype none

module emulator #(
	parameter SWITCH_W = 3,
	parameter PMOD_W = 8,
	parameter LED_W = 16
)
(
   	input wire clk_phy_i, /* RMII ref clk 50MHz */
 
	// PmodC	
	inout  wire [1:0]  phy_rx_i,
	inout  wire        phy_rx_v_i,
	inout  wire        phy_rx_err_i,
	output  wire [1:0] phy_tx_o,
	output  wire       phy_tx_v_o,

	// Misc
	input wire [SWITCH_W-1:0] switch_i,
	output wire [LED_W-1:0]   led_o,

	output wire [11:0]        unused_o
);
wire [4:0] uo_out_unused; 

wire clk_ibuf, clk_pll, clk_pll_feedback, clk;
wire pll_lock;
reg  pll_lock_q;
wire ena;
wire rst_async;
 
wire [7:0] ui_in;
wire [7:0] uio_in; 

wire [7:0] uo_out; 
wire [7:0] uio_out;
wire [7:0] uio_oe;

wire tx_phase_async;

/* clk */
IBUF m_ibuf_clk(
	.I(clk_phy_i),
	.O(clk_ibuf)
);

PLLE2_BASE #(
   .CLKFBOUT_MULT(20),        
   .CLKIN1_PERIOD(20.0),      
   .CLKOUT0_DIVIDE(20),
   .DIVCLK_DIVIDE(1)
) m_global_clk_pll (
   .CLKFBIN(clk_pll_feedback),
   .CLKFBOUT(clk_pll_feedback),
   .CLKIN1(clk_ibuf),    
   .CLKOUT0(clk_pll),
/* verilator lint_off PINCONNECTEMPTY */
   .CLKOUT1(),
   .CLKOUT2(),
   .CLKOUT3(),
   .CLKOUT4(),
   .CLKOUT5(),
/* verilator lint_on PINCONNECTEMPTY */
   .LOCKED(pll_lock),
   .PWRDWN(1'b0),
   .RST(rst_async) 
);

BUFG m_bufg_clk(
	.I(clk_pll),
	.O(clk)
);

/* debug leds */
assign led_o[0] = rst_async;
assign led_o[1] = tx_phase_async;
assign led_o[2] = ena;
assign led_o[3] = clk;

assign led_o[5:4] = phy_rx_i;
assign led_o[6]   = phy_rx_v_i;
assign led_o[7]   = phy_rx_err_i;
assign led_o[9:8] = phy_tx_o;
assign led_o[10]  = phy_tx_v_o;
assign led_o[11]  = pll_lock_q; 
assign led_o[15:12] = 4'd0;

assign unused_o = {4'h0, 1'b1, {7{1'b1}}}; // an, dp, seg

/* switch, okay with bounce */
assign rst_async      = switch_i[0];
assign tx_phase_async = switch_i[1];

debounce m_switch_debounce(
	.clk(clk),
	.rst_async(rst_async),
	.switch_i(switch_i[2]),
	.switch_o(ena)
);

always @(posedge clk or posedge rst_async) begin
	if (rst_async) begin
		pll_lock_q <= 1'b0;
	end else begin
		pll_lock_q <= pll_lock;
	end
end



/* deisgn top level */ 
(* MARK_DEBUG = "true" *) wire [1:0] debug_phy_tx;
(* MARK_DEBUG = "true" *) wire       debug_phy_tx_v;
assign debug_phy_tx_v = phy_tx_v_o;
assign debug_phy_tx   = phy_tx_o;

// IN
assign ui_in[1:0] = phy_rx_i;
assign ui_in[2]   = phy_rx_v_i;
assign ui_in[3]   = phy_rx_err_i;
assign ui_in[6:4] = {3{1'bx}};
assign ui_in[7]    = tx_phase_async;

// OUT
assign phy_tx_o      = uo_out[1:0];
assign phy_tx_v_o    = uo_out[2];
assign uo_out_unused = uo_out[7:3];

// IO
wire [7:0] uio_oe_unused, uio_out_unused;

assign uio_in = {8{1'bx}};
assign uio_oe_unused = uio_oe;
assign uio_out_unused = uio_out; 

tt_um_teapot m_top(
	.ui_in(ui_in),
	.uo_out(uo_out),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(ena),
	.clk(clk),
	.rst_n(~rst_async)
);

endmodule
