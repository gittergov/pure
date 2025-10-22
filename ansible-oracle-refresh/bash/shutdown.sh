#!/bin/bash

. ./env_oracle.sh


sqlplus -s / as sysdba << !
shutdown immediate ;
exit;
!
