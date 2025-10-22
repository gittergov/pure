#!/bin/bash
# stop_start_oracle.sh

export ORACLE_SID=orcl
export ORAENV_ASK=NO
. /u01/app/oracle/product/19c/dbhome_1/bin/oraenv >/dev/null 2>&1

LOGFILE=/tmp/oracle_refresh.log
ACTION=$1

stop_db() {
  echo "[$(date)] Stopping Oracle instance $ORACLE_SID..." | tee -a $LOGFILE
  sqlplus -s / as sysdba <<EOF
  shutdown immediate;
  exit;
EOF
}

start_db() {
  echo "[$(date)] Starting Oracle instance $ORACLE_SID..." | tee -a $LOGFILE
  sqlplus -s / as sysdba <<EOF
  startup;
  exit;
EOF
}

case "$ACTION" in
  stop) stop_db ;;
  start) start_db ;;
  *) echo "Usage: $0 {start|stop}" ;;
esac

