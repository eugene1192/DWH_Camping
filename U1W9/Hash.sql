--HASH
CREATE TABLESPACE gear1
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/gear1.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 150M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE TABLESPACE gear2
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/gear2.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 150M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE TABLESPACE gear3
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/gear3.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 150M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE TABLESPACE gear4
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/gear4.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 150M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE TABLESPACE gear5
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/gear5.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 150M
 SEGMENT SPACE MANAGEMENT AUTO;
 
CREATE TABLE scubagear
     (id NUMBER,
      name VARCHAR2 (60))
   PARTITION BY HASH (id)
   PARTITIONS 4 
   STORE IN (gear1, gear2, gear3, gear4);
   
ALTER TABLE scubagear
      ADD PARTITION p_named TABLESPACE gear5;
      
ALTER TABLE scubagear COALESCE PARTITION;

ALTER TABLE scubagear MOVE PARTITION p_named
     TABLESPACE gear5 ;
     
      SELECT * FROM ALL_TAB_PARTITIONS where TABLE_NAME = 'SCUBAGEAR';
 alter table scubagear drop partition SYS_P396;
