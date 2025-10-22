#!/bin/bash

. ./params.sh

export SSHPASS=${DB_HOST_PASS_SRC}

echo "shutting oracle orcl database on node ${DB_HOST_SRC}"

sshpass -e ssh -l ${DB_HOST_USER_SRC} ${DB_HOST_SRC} "srvctl stop database -db orcl" 

echo $ASM_HOST_USER_SRC
echo "dismounting ASM diskgroups on node ${DB_HOST_SRC}"

sshpass -e ssh -l ${ASM_HOST_USER_SRC} ${DB_HOST_SRC} "export ORAENV_ASK=NO; export ORACLE_SID=+ASM; . oraenv; asmcmd umount DATA,FRA,REDO" 

sshpass -e ssh -l ${ASM_HOST_USER_SRC} ${DB_HOST_SRC} "export ORAENV_ASK=NO; export ORACLE_SID=+ASM; . oraenv; echo 'connect / as sysasm' > /tmp/pure.sql; echo 'select name, state from v\$asm_diskgroup;' >> /tmp/pure.sql; echo 'exit;' >> /tmp/pure.sql; sqlplus -s /nolog @/tmp/pure.sql" 

echo "complete"

