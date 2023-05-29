#!/bin/bash
DEVICES=`sudo -u acriuser vboxmanage list usbhost | grep Serial | wc -l`
if [ ${DEVICES} -eq 0 ]
then
  /usr/sbin/reboot
fi
