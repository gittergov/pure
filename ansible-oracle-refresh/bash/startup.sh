#!/bin/bash

. ./env_oracle.sh


sqlplus -s / as sysdba << !
startup;
exit;
!
