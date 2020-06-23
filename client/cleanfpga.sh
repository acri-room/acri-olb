#!/bin/sh

cd /root/acri-olb/client
date > cleanfpga.log
/tools/Xilinx/Vivado/2019.2/bin/vivado -mode batch -source /tools/acri/write_dummy.tcl

