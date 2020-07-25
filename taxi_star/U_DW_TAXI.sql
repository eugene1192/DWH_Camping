--alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
--alter session set nls_date_format = 'dd-mm-yyyy';
--SELECT * FROM U_DW_EXT_APP.SA_TRIP where driver_first_name ='Ada' and driver_last_name = 'Fitzgerald'
--order by date_id;
--SELECT * FROM U_DW_EXT_APP.sa_customer;
--SELECT * FROM U_DW_EXT_APP.sa_driver;
--SELECT * FROM U_DW_EXT_APP.sa_vehicle;


/*
CREATE OR REPLACE PROCEDURE load_sa_trip_pr (loop_cnt_in IN NUMBER)
    IS
        cnt NUMBER;
        
    BEGIN
        
        cnt:=loop_cnt_in;
        while cnt>0
            loop
                 insert into u_dw_ext_app.sa_trip
SELECT * FROM (
  SELECT CAST(
                           (TO_CHAR(date_id, 'DD')
                           ||TO_CHAR(date_id , 'MM')
                           ||TO_CHAR(date_id , 'YYYY')
                           ||TO_CHAR(date_id , 'HH24')
                           ||TO_CHAR(date_id , 'MI')
                           ||TO_CHAR(date_id , 'SS') 
                           ) AS INTEGER) trip_id
                           , trunc(date_id)
                    from (
                        SELECT TO_TIMESTAMP ('01-JAN-2019 00:00:00',  'DD-Mon-YYYY HH24:MI:SS'
                              ) +dbms_random.value(0,1825) date_id
                        from dual) a 
                 ),            
                (SELECT * from (SELECT FIRST_NAME, last_name, drive_licen from u_dw_ext_app.sa_driver order by (dbms_random.random)) where rownum<2) b,
                (SELECT * from (SELECT FIRST_NAME, last_name  from u_dw_ext_app.sa_customer order by (dbms_random.random)) where rownum<2) c,
                (SELECT * from (SELECT MANUFACTURER ,  MODEL_VHL   , LICENCE_PLATE from u_dw_ext_app.sa_vehicle order by (dbms_random.random)) where rownum<2) d,
                (SELECT COUNTRY_DESC from u_dw_references.lc_countries  where COUNTRY_ID =56) e,
                (SELECT trunc( dbms_random.value(0,200)) distance from dual) f,
                ( select 'mil'   distance_measure FROM dual) q,
                (SELECT trunc( dbms_random.value(1,5)) raiting from dual) w,
                (SELECT 'Y' status from dual) p,
                (SELECT trunc( dbms_random.value(10,1000)) coast from dual) g ,
                (select 'EUR' cyrrency from dual) j;
        cnt:=cnt-1;
        end loop;
END load_sa_trip_pr;
exec load_sa_trip_pr(1);
*/

select * from nls_database_parameters
where parameter in ('NLS_DATE_FORMAT','NLS_DATE_LANGUAGE'); 
alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';

alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
select  count(trip_id) from ( select distinct trip_id from u_dw_ext_app.sa_trip); 

/*
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
*/