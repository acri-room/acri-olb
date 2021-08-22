#!/bin/sh

QUARTUS_BIN=/tools/Intel/intelFPGA_lite/20.1/quartus/bin/
SOF_DIR=/tools/acri-olb/vsa_default/

${QUARTUS_BIN}/quartus_pgm -m jtag -o "p;${SOF_DIR}/first_1.sof"
