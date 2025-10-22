#!/bin/bash

. ./params.sh

sshpass -f <(printf '%s\n' ${DB_HOST_PASS_TGT}) ssh -l ${DB_HOST_USER_TGT} ${DB_HOST_TGT} sqlplus  -s ${DB_USER_TGT}/${DB_PASS_TGT} << !

alter session set nls_date_format='dd-Mon-yy hh24:mi:ss';
set veri off
col ih noprint new_value ih
col ht noprint new_value ht
select instance_name ih, host_name ht from v\$instance;
prompt Connected to Instance "&ih" on Host "&ht"
prompt
prompt
col inm heading 'Instance-Server' format a40
col nm heading 'Customer Name' format a15
col cdt heading 'Date created' format a17
select inm, nm,cdt from (
       select '&ih-&ht' inm, name nm, to_char(creation_date,'mm/dd/yy hh24:mi:ss') cdt,
               row_number() over (order by creation_date desc) rn
          from pure_demo )
  where rn <= 20
  order by rn desc;
exit;
!
