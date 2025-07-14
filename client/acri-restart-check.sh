#!/bin/bash
SERV=`hostname -s`
RESTART=$( ../vm-host/check-reservation.rb ${SERV} )
if [ "${SERV}" != "${RESTART}" ]; then
  exit 1
fi
exit 0