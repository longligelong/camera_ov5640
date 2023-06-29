create_clock -period 20.000 -name clk_50M [get_ports clk_50M]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_50M]
set_property PACKAGE_PIN R4 [get_ports clk_50M]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50M]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN U2 [get_ports rst_n]


#CAMERA

#摄像头接口的时钟
create_clock -period 40.000 -name tpclk [get_ports tpclk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tpclk_IBUF]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports tpclk]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports cam_rest]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports pwdn]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[0]}]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[1]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[2]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[3]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[4]}]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[5]}]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[6]}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {data_in[7]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports vsync]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports href]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports scl]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports sda]










