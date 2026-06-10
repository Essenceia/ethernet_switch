set checkpoint_path [lindex $argv 0]
set bit_path [lindex $argv 1]
puts "Programming script called with checkpoint path $checkpoint_path, loading bitsteam $bit_path"

puts "Opening program at $checkpoint_path"
open_checkpoint $checkpoint_path 

open_hw_manager
connect_hw_server

# autodetecting xilinx approved programmer, will fail otherwise, will used current_hw_target by default
puts "Detecting hw target [current_hw_target]"

if { [current_hw_target] ne "" } {
	open_hw_target
	current_hw_device

	set_property PROGRAM.FILE $bit_path [current_hw_device]

	set fail [program_hw_device -verbose]
	
} else {
	puts "Error : no hw target detected !"
}
disconnect_hw_server
close_hw_manager
exit 0


