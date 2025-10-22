#!/bin/bash
# stop_start_oracle.sh
# Usage: ./stop_start_oracle.sh [start|stop]

ACTION=$1
ORACLE_SID=${ORACLE_SID:-orcl}
ORACLE_HOME=${ORACLE_HOME:-/u01/app/oracle/product/19c/dbhome_1}
export ORACLE_SID ORACLE_HOME PATH=$ORACLE_HOME/bin:$PATH

LOGFILE=/tmp/oracle_refresh.log

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
  stop)  stop_db ;;
  start) start_db ;;
  *) echo "Usage: $0 {start|stop}" ;;
esac

