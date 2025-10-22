#!/bin/bash

. ./params.sh

export SSHPASS=${DB_HOST_PASS_SRC}

echo "mounting ASM diskgroups on node ${DB_HOST_SRC}"

sshpass -e ssh -l ${ASM_HOST_USER_SRC} ${DB_HOST_SRC} "export ORAENV_ASK=NO; export ORACLE_SID=+ASM; . oraenv; asmcmd mount DATA,FRA,REDO" 

sshpass -e ssh -l ${ASM_HOST_USER_SRC} ${DB_HOST_SRC} "export ORAENV_ASK=NO; export ORACLE_SID=+ASM; . oraenv; echo 'connect / as sysasm' > /tmp/pure.sql; echo 'select name, state from v\$asm_diskgroup;' >> /tmp/pure.sql; echo 'exit;' >> /tmp/pure.sql; sqlplus -s /nolog @/tmp/pure.sql" 

echo "starting oracle orcl database on node ${DB_HOST_SRC}"

sshpass -e ssh -l ${DB_HOST_USER_SRC} ${DB_HOST_SRC} "srvctl start database -db orcl" 

echo "complete"

