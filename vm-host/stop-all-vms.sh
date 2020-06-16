#!/bin/bash

tmpfile=$(mktemp)

VBoxManage list runningvms > $tmpfile
while read name id
do
    n=${name#\"}
    n=${n%\"}
    echo "stop ${n}"
    VBoxManage controlvm ${n} acpipowerbutton
done < $tmpfile

while read name id
do
    n=${name#\"}
    n=${n%\"}
    while [ -n "$(VBoxManage list runningvms | grep ${n})" ]
    do
        echo "wait for stop ${n}"
        sleep 5
    done
done < $tmpfile

rm $tmpfile
