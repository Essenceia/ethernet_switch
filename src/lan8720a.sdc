# LAN8720A RMII interface timing constraints in 100BASE-TX mode using REF_CLK IN MODE
# timing signal names will be following the LAN8720A datasheet naming, and so will be 
# expressed from the perspective of the PHY chip and not the ASIC 

set ref_clk [get_clocks $::env(CLOCK_PORT)] 

# output direction (input to the ASIC) RXD[1:0], RXER, CRS_DV (RXV)
set rx_pins {uio_in[0] uio_in[1] uio_in[2] uio_in[3]}
# valid from rising edge of refclk
set toval 14
# hold from rising edge of refclk
set tohold 3

set_input_delay -clock ${ref_clk} -max ${toval} ${rx_pins}
set_input_delay -clock ${ref_clk} -min ${tohold} ${rx_pins} 

# input direction (output from the ASIC) TXD[1:0] TXEN (TXV)  
set tx_pins {uo_out[0] uo_out[1] uo_out[2]}
# setup time to rising edge for the refclk
set tsu 4
# input hold time after rising edge of refclk
set tihold 1.5

set_output_delay -clock ${ref_clk} -max ${tsu} ${tx_pins} 
set_output_delay -clock ${ref_clk} -min ${tihold} ${tx_pins} 


