#!/bin/bash
SERV=`hostname -s`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
USER_DIR=/usr/local/home/acriuser
HOST_FILE=${USER_DIR}/new_hostname.txt
SSHD_GEN=${USER_DIR}/new_sshd_config
XRDP_GEN=${USER_DIR}/new_xrdp.ini
ALLOW_FILE=${USER_DIR}/new_allowuser.txt

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

if [ -e ${SSHD_GEN} ]; then
  cp ${SSHD_GEN} /etc/ssh/sshd_config
fi
if [ -e ${XRDP_GEN} ]; then
  cp ${XRDP_GEN} /etc/xrdp/xrdp.ini
fi
if [ -e ${ALLOW_FILE} ]; then
  usermod -aG dialout `cat ${ALLOW_FILE}`
fi

if [ -e ${SCRIPT_DIR}/sudoers ]; then
  cp ${SCRIPT_DIR}/sudoers /etc/sudoers
  chown root:root /etc/sudoers
  chmod 440 /etc/sudoers
fi
