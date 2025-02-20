open_project num_munge.xpr
set_property top PCIe_wrapper [current_fileset]
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
reset_run impl_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
open_run impl_1
write_bitstream -force ./num_munge.bit
close_project