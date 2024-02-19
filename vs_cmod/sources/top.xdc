set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports { CLK }];
create_clock -period 83.33 -name sys_clk_pin -waveform {0.00 41.66} -add [get_ports { CLK } ];

set_property -dict { PACKAGE_PIN A18    IOSTANDARD LVCMOS33 } [get_ports { RST } ];

set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }];
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { LED[4] }];

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports UART_RX]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports UART_TX]
