# read librelane base sdc before overwritting it
read_sdc $::env(SCRIPTS_DIR)/base.sdc

proc get_first_output_pin { instance } {
  set dir "output" 
  puts "pin iter [$instance pin_iterator]"
  set iter [$instance pin_iterator]
  while {[$iter has_next]} {
    set pin [$iter next]
    set pin_dir [get_property $pin "direction"]
    if { [lsearch $dir $pin_dir] !=  -1 } {
	  puts "found pin dir $pin_dir on pin $pin"
      return $pin
    }
  }
}

proc get_all_dff_clk_port { clk } {
	set ret {}
	set cells [get_cells [all_registers -clock $clk ]]
	foreach cell $cells {
		set dff_name [get_name $cell]
		set clk_pin [get_pin ${dff_name}/CLK]
  		lappend ret $clk_pin
	}
	return $ret
}

set mux_clk_cell [get_cells -hierarchical -regexp ".*m_ref_clk_mux"]
set mux_clk_pin [get_first_output_pin $mux_clk_cell]

#can't use the combinational arg as it causes the drt to seg fault
set ::env(OUTPUT_CLOCK) "dephase_clk"
create_generated_clock -name $::env(OUTPUT_CLOCK) -source [get_ports $clock_port] -divide_by 1 -invert $mux_clk_pin

set_min_delay 9 -from [get_port $::env(CLOCK_PORT)] -to [get_all_dff_clk_port $::env(OUTPUT_CLOCK)]
set_max_delay 11 -from [get_port $::env(CLOCK_PORT)] -to [get_all_dff_clk_port $::env(OUTPUT_CLOCK)]

set_propagated_clock [all_clocks]


set ::env(PHY_RX_PINS) {uio_in[0] uio_in[1] uio_in[2] uio_in[3]}
set ::env(PHY_TX_PINS) {uo_out[0] uo_out[1] uo_out[2]}

read_sdc $::env(DESIGN_DIR)/lan8720a.sdc
