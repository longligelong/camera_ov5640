
#----------------------摄像头接口的时钟---------------------------
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports clk_50M]
#72M


set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports rst_n]


#----------------------摄像头接口---------------------------

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports cam_rest]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports pwdn]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {data_in[0]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {data_in[1]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {data_in[2]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {data_in[3]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {data_in[4]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {data_in[5]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {data_in[6]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {data_in[7]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports href]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports tpclk]
create_clock -period 13.888 -name tpclk [get_ports tpclk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tpclk_IBUF]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tpclk_IBUF]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports vsync]
#cam_scl:
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports scl]
#cam_sda:
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports sda]

#set_property PULLUP true [get_ports {sda}]

set_property BITSTREAM.GENERAL.COMPRESS true [current_design]