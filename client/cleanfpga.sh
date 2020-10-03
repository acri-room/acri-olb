#!/bin/sh

HOME=/root
VIVADO=/tools/Xilinx/Vivado/2019.2/bin/vivado

while [ ! -e ${VIVADO} ]
do
  sleep 5
done

cd ../vs_default
key=`hostname -s | cut -c 4-`

echo $key
case ${key} in
	"01" ) ${VIVADO} -mode batch -source config_board_1.tcl ;;
	"02" ) ${VIVADO} -mode batch -source config_board_2.tcl ;;
	"03" ) ${VIVADO} -mode batch -source config_board_3.tcl ;;
	"04" ) ${VIVADO} -mode batch -source config_board_4.tcl ;;
	"05" ) ${VIVADO} -mode batch -source config_board_5.tcl ;;
	"06" ) ${VIVADO} -mode batch -source config_board_6.tcl ;;
	"07" ) ${VIVADO} -mode batch -source config_board_7.tcl ;;
	"08" ) ${VIVADO} -mode batch -source config_board_8.tcl ;;
	"09" ) ${VIVADO} -mode batch -source config_board_9.tcl ;;
	"10" ) ${VIVADO} -mode batch -source config_board_A.tcl ;;
	"11" ) ${VIVADO} -mode batch -source config_board_B.tcl ;;
	"12" ) ${VIVADO} -mode batch -source config_board_C.tcl ;;
	"13" ) ${VIVADO} -mode batch -source config_board_D.tcl ;;
	"14" ) ${VIVADO} -mode batch -source config_board_E.tcl ;;
	"15" ) ${VIVADO} -mode batch -source config_board_F.tcl ;;
esac

killall -9 hw_server

