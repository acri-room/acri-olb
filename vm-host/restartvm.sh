#!/bin/bash

echo "restart vm" > restart.log
servers=(vs001 vs002 vs003 vs004 vs005 vs006 vs007 vs008 vs009 vs010 vs011 vs012 vs013 vs014 vs015)
for s in ${servers[@]}
do
VBoxManage controlvm $s acpipowerbutton
done

for s in ${servers[@]}
do
while [ -n "$(VBoxManage list runningvms | grep $s)" ]
do
	echo "wait for stop $s"
        sleep 5
done
echo "start $s"
VBoxManage startvm $s --type headless
done

echo "restart vm...done" >> restart.log
