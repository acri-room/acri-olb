#!/bin/bash

PREFIX="vs0"
SKEL="vs0-skel"
NUM_VM=10

i=0
while [ $i -le ${NUM_VM} ]
do
  printf -v VMNO "%02d" $((i++))
  VBoxManage clonevm ${SKEL} --basefolder=/usr/local/vm --name=${PREFIX}${VMNO} --register
done