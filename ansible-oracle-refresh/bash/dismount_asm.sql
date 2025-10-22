-- set echo on
-- set termout on
-- set time off
-- set timing off
-- set feedback off

-- SELECT  name, state FROM    v$asm_diskgroup ORDER BY name;

alter diskgroup data dismount;
alter diskgroup fra dismount;
alter diskgroup redo dismount;

SELECT  name, state FROM    v$asm_diskgroup ORDER BY name;

exit

