#!/bin/bash

cp /root/acri-olb/client/rc.local /etc/rc.local
chmod 755 /etc/rc.local
cat /etc/rc.local

crontab /root/acri-olb/client/crontab
crontab -l

cp /root/acri-olb/client/sudoers /etc/
chmod chown root:root /etc/sudoers
chmod 440 /etc/sudoers

