set bitstream_file "./num_munge.bit"
open_hw
connect_hw_server
open_hw_target
current_hw_target [get_hw_targets *]
set fpga_device [lindex [get_hw_devices] 0]
current_hw_device $fpga_device
refresh_hw_device $fpga_device
set_property PROGRAM.FILE $bitstream_file $fpga_device
program_hw_devices $fpga_device
close_hw_target
disconnect_hw_server
close_hw_manager