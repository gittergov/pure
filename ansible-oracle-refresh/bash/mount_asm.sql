-- set echo on
-- set termout on
-- set time off
-- set timing off
-- set feedback off
 
-- SELECT  name, state FROM    v$asm_diskgroup ORDER BY name;

alter diskgroup data mount;
alter diskgroup fra mount;
alter diskgroup redo mount;

SELECT  name, state FROM    v$asm_diskgroup ORDER BY name;

exit

