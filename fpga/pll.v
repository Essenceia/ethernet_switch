
`default_nettype none

module pll(
	input  wire clk_i, 
	input  wire rst_async_i, 

	output wire locked_o,
	output wire clk_o
);

wire clk_ibuf, clk_pll, clk_pll_feedback, clk;

/* clk */
IBUF m_ibuf_clk(
	.I(clk_i),
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
   .LOCKED(locked_o),
   .PWRDWN(1'b0),
   .RST(rst_async_i) 
);

BUFG m_bufg_clk(
	.I(clk_pll),
	.O(clk_o)
);


endmodule
