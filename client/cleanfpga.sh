#!/bin/sh

VIVADO=/tools/Xilinx/Vivado/2019.2/bin/vivado

while [ ! -e ${VIVADO} ]
do
  sleep 5
done

cd ../vs_default
key=`hostname -s | cut -c 4-`

echo $key
case ${key} in
	"01" ) HOME=/root ${VIVADO} -mode batch -source config_board_1.tcl ;;
	"02" ) HOME=/root ${VIVADO} -mode batch -source config_board_2.tcl ;;
	"03" ) HOME=/root ${VIVADO} -mode batch -source config_board_3.tcl ;;
	"04" ) HOME=/root ${VIVADO} -mode batch -source config_board_4.tcl ;;
	"05" ) HOME=/root ${VIVADO} -mode batch -source config_board_5.tcl ;;
	"06" ) HOME=/root ${VIVADO} -mode batch -source config_board_6.tcl ;;
	"07" ) HOME=/root ${VIVADO} -mode batch -source config_board_7.tcl ;;
	"08" ) HOME=/root ${VIVADO} -mode batch -source config_board_8.tcl ;;
	"09" ) HOME=/root ${VIVADO} -mode batch -source config_board_9.tcl ;;
	"10" ) HOME=/root ${VIVADO} -mode batch -source config_board_A.tcl ;;
	"11" ) HOME=/root ${VIVADO} -mode batch -source config_board_B.tcl ;;
	"12" ) HOME=/root ${VIVADO} -mode batch -source config_board_C.tcl ;;
	"13" ) HOME=/root ${VIVADO} -mode batch -source config_board_D.tcl ;;
	"14" ) HOME=/root ${VIVADO} -mode batch -source config_board_E.tcl ;;
	"15" ) HOME=/root ${VIVADO} -mode batch -source config_board_F.tcl ;;
esac

killall -9 hw_server

