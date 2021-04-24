#!/bin/bash

mkdir -p /tools
cp /root/acri-olb/client/tools.mount /etc/systemd/system/
systemctl enable tools.mount

#cp /root/acri-olb/client/rc.local /etc/rc.local
#chmod 755 /etc/rc.local
#cat /etc/rc.local

crontab /root/acri-olb/client/crontab
crontab -l

cp /root/acri-olb/client/sudoers /etc/
chown root:root /etc/sudoers
chmod 440 /etc/sudoers

