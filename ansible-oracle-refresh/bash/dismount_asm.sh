#!/bin/bash

. ./env_grid.sh

sqlplus -s / as sysasm @dismount_asm.sql

