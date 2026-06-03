`ifndef USE_GATE_NL
`default_nettype none
`endif
module emulator #(
	parameter SWITCH_W = 3,
	parameter PMOD_W = 8,
	parameter LED_W = 16
)
(
	input wire clk_osc_i, /* 100 MHz on board oscillator */
   	output wire clk_phy_o, /* RMII ref clk 50MHz */
 
	// PmodC
	input wire  tck_i,
    input wire  tdi_i, 
    input wire  tms_i,
    output wire tdo_o,


	// PmodA	
	input  wire [1:0]  phy_tx_o,
	input  wire        phy_tx_v_o,
	
	// Pmod B
	inout  wire [PMOD_W-1:0] pin_io,
 
	// Misc
	input wire [SWITCH_W-1:0] switch_i,
	output wire [LED_W-1:0]   led_o,

	output wire [11:0]        unused_o
);
wire [3:0] uo_out_unused; 

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

(* MARK_DEBUG = "true" *) wire tck, tdi, tdo, tms; 

/* clk */
IBUF m_ibuf_clk(
	.I(clk_osc_i),
	.O(clk_ibuf)
);

/* Step down clock from the 100MHz to the desired 50MHz, 
PLL is totally overkill for such a trivial task */
PLLE2_BASE #(
   .CLKFBOUT_MULT(10),        
   .CLKIN1_PERIOD(10.0),      
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

/* refclk out */
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"),
	.INIT(1'b1),
	.SRCTYPE("ASYNC")
) m_oddr_refclk(
	.Q(clk_phy_o),
	.C(clk),
	.CE(1'b1),
	.D1(1'b1),
	.D2(1'b0),
	.R(rst_async),
	.S(1'b0)
);

/* debug leds */
assign led_o[0] = rst_async;
assign led_o[1] = ena;
assign led_o[2] = clk_ibuf;
assign led_o[3] = pll_lock_q; 

assign led_o[11:4] = 8'd0;

assign led_o[12]    = tck;
assign led_o[13]    = tdi;
assign led_o[14]    = tms;
assign led_o[15]    = tdo;

assign unused_o = {4'h0, 1'b1, {7{1'b1}}}; // an, dp, seg

/* switch, okay with bounce */
assign rst_async = switch_i[0];
assign tx_phase_async = switch[1];

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


/* jtag */
assign tck   = tck_i;
assign tdi   = tdi_i; 
assign tms   = tms_i; 
assign tdo_o = tdo; 

/* deisgn top level */ 
assign ui_in[0]    = tck;
assign ui_in[1]    = tms;
assign ui_in[2]    = tdi;
assign ui_in[6:3]  = 4'h0;
assign ui_in[7]    = tx_phase_async;

io_switch #(.W(8)) m_io_switch(
	.dir_sel_i(uio_oe),
	.data_out_i(uio_out),
	.data_in_o(uio_in),
	.pin_io(pin_io)
);

assign phy_tx_o      = uo_out[1:0];
assign phy_tx_v_o    = uo_out[2];
assign tdo           = uo_out[3];
assign uo_out_unused = uo_out[7:4];


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
