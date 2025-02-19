
set_property PACKAGE_PIN L16 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property PULLTYPE PULLUP [get_ports sys_rst_n]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_false_path -from [get_ports sys_rst_n]

create_clock -period 10.000 -name sys_clk [get_ports sys_clk_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_ddr_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_ddr_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {sys_clk_clk_n[0]}]
set_property PACKAGE_PIN R4 [get_ports sys_ddr_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_ddr_clk_n]
set_property PACKAGE_PIN F10 [get_ports {sys_clk_clk_p[0]}]
set_property PACKAGE_PIN F15 [get_ports sys_rst]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets PCIe_i/clk_wiz_0/inst/clk_in1_PCIe_clk_wiz_0_0]
