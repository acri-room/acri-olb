#!/bin/bash

for i in $*
do
    VBoxManage controlvm $i acpipowerbutton
done

for i in $*
do
    while [ -n "$(VBoxManage list runningvms | grep ${i})" ]
    do
        echo "wait for stop ${i}"
        sleep 5
    done
done
