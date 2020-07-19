

CREATE TABLESPACE ts_dw_taxi_01
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/db_qpt_dw_taxi_01.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 CREATE USER u_dw_taxi
  IDENTIFIED BY "1"
    DEFAULT TABLESPACE ts_dw_taxi_01;

grant all  PRIVILEGES TO u_dw_taxi;
GRANT CONNECT,RESOURCE, CREATE VIEW TO u_dw_taxi;