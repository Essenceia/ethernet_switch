# Basys3 rev D xdc

# Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {switch_i[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {switch_i[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {switch_i[2]}]

# LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[7]}]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[8]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[9]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[10]}]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[11]}]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[12]}]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[13]}]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[14]}]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[15]}]

#Pmod Header JA
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {phy_tx_o[0]}];
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {phy_tx_o[1]}];
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {phy_tx_v_o}];

# set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {res_o[3]}];
# set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {res_o[4]}];
# set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {res_o[5]}];
# set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {res_o[6]}];
set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {clk_phy_o}];

#Pmod Header JB
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {pin_io[0]}];
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {pin_io[1]}];
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {pin_io[2]}];
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {pin_io[3]}];
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {pin_io[4]}];
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {pin_io[5]}];
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {pin_io[6]}];
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {pin_io[7]}];

# Pmod Header JC
# jtag
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33  } [get_ports {tdi_i}];
set_property -dict { PACKAGE_PIN M18  IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {tck_i}];
create_clock -add -name tck_i -period 500.00 [get_ports tck_i]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33  } [get_ports {tms_i}];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33  } [get_ports {tdo_o}];

# tie unused pins
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {unused_o[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {unused_o[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {unused_o[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {unused_o[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {unused_o[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[6]}]
set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[7]}]
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {unused_o[8]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[9]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[10]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[11]}]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

# refclk 
set ::env(OUTPUT_CLOCK) "clk_phy_o"
create_generated_clock -name $::env(OUTPUT_CLOCK) -source [get_pins -hier -regexp ".*m_oddr_refclk/C"]  -divide_by 1 [get_ports $::env(OUTPUT_CLOCK)]

# oscillator
set osc_clk "clk_osc_i"
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports $osc_clk]
create_clock -add -name $osc_clk -period 10.00 -waveform {0 5} [get_ports $osc_clk]
# pll
set ::env(CLOCK_PORT) "clk"
# clock creation infered by tools and pll params


# set data delays
set ::env(PHY_RX_PINS) {m_top/uio_in[0] m_top/uio_in[1] m_top/uio_in[2] m_top/uio_in[3]}
set ::env(PHY_TX_PINS) {m_top/uo_out[0] m_top/uo_out[1] m_top/uo_out[2]}

read_sdc ../src/lan8720a.sdc
