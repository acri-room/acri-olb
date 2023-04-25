#!/bin/bash
SERV=`hostname -s`
cp /tools/acri-olb/client/setting/sshd_config.${SERV} /etc/ssh/sshd_config
cp /tools/acri-olb/client/setting/xrdp.ini.${SERV} /etc/xrdp/xrdp.ini
/usr/bin/systemctl restart ssh xrdp
