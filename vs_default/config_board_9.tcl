set chipname xc7a35t_0
set bitfile prj_9/top_9.runs/impl_1/top.bit
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices ${chipname}]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices ${chipname}] 0]
set_property PROBES.FILE {} [get_hw_devices ${chipname}]
set_property FULL_PROBES.FILE {} [get_hw_devices ${chipname}]
set_property PROGRAM.FILE ${bitfile} [get_hw_devices ${chipname}]
program_hw_devices [get_hw_devices ${chipname}]
close_hw_manager
