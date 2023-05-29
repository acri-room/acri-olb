#!/bin/bash
SERV=`hostname -s`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HOST_FILE=/usr/local/home/acriuser/new_hostname.txt

if [ -e ${HOST_FILE} ]; then
  NEWSERV=`head -1 ${HOST_FILE}`
  NEWIP=`tail -1 ${HOST_FILE}`
  if [ ${NEWSERV} != ${SERV} ]; then
    TMPFILE=`mktemp`
    python3 ${SCRIPT_DIR}/vm-host-setup.py ${NEWSERV} ${NEWIP} > ${TMPFILE}
    chmod 644 ${TMPFILE}
    sudo -u acriuser cp ${TMPFILE} ${SCRIPT_DIR}/log/setup-${NEWSERV}.txt
    rm ${TMPFILE}
  fi
fi

if [ -e ${SCRIPT_DIR}/setting/sshd_config.${SERV} ]; then
  cp ${SCRIPT_DIR}/setting/sshd_config.${SERV} /etc/ssh/sshd_config
fi
if [ -e ${SCRIPT_DIR}/setting/xrdp.ini.${SERV} ]; then
  cp ${SCRIPT_DIR}/setting/xrdp.ini.${SERV} /etc/xrdp/xrdp.ini
fi

if [ -e ${SCRIPT_DIR}/sudoers ]; then
  cp ${SCRIPT_DIR}/sudoers /etc/sudoers
  chown root:root /etc/sudoers
  chmod 440 /etc/sudoers
fi
