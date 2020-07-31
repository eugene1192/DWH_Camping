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



/* create or replace PROCEDURE ext_sa_in_t_trip
   AS
   BEGIN
      MERGE INTO u_dw_data.t_trip trp
           USING 
           (
            select 
                trip_id               
               , date_id             
               , driver_first_name     
               , driver_last_name      
               , drive_licen           
               , customer_first_name   
               , customer_last_name
               , customer_bth_date
               , vehicle_manufacturer  
               , vehicle_model         
               , vin_code              
               , country               
               , distance              
               , distance_measure      
               , raiting               
               , status                
               , coast                 
               , currency              
            from  u_dw_ext_app.sa_trip
           ) sat
              ON ( trp.sa_trip_id=sat.trip_id )
      WHEN NOT MATCHED THEN
         INSERT (                    
                    sa_trip_id      
                   , date_id         
                   , driver_id        
                   , customer_id    
                   , vehicle_id      
                   , country_id       
                   , distance        
                   , distance_measure  
                   , raiting          
                   , status           
                   , coast            
                   , currency          
                )
             VALUES ( 
                     sat.trip_id           
                   , sat.date_id             
                   , (select  distinct driver_id
                            from 
                                 u_dw_data.t_driver td 
                               -- , sat
                           where 
                                td.driver_first_name= sat.driver_first_name 
                                AND td.driver_last_name=sat.driver_last_name 
                                and td.drive_licen =sat.DRIVE_LICEN)
                   ,(select distinct customer_id
                            from 
                               u_dw_data.t_customer ct
                             --   , sat
                            where 
                                ct.FIRST_NAME = sat.customer_first_name 
                                AND ct.LAST_NAME=sat.customer_last_name 
                                and ct.birth_date= sat.customer_bth_date
                                )         
                   , (select  distinct vehicle_id
                            from 
                               u_dw_data.t_vehicle vt
                            --    , sat
                            where 
                                vt.LICENCE_PLATE = sat.vin_code
                                )  
                   , (select distinct country_id 
                            from  
                                u_dw_references.lc_countries lccnt 
                            --    , sat 
                            where sat.country=lccnt.country_desc  )
                   , sat.distance             
                   , sat.distance_measure     
                   , sat.raiting              
                   , sat.status               
                   , sat.coast                
                   , sat.currency    
                    );
--      WHEN MATCHED THEN
--         UPDATE SET trg.geo_system_desc = cls.geo_system_desc
--                  , trg.geo_system_code = cls.geo_system_code;

      --Commit Resulst
      COMMIT;
   END ext_sa_in_t_trip;

select driver_id from 
    u_dw_data.t_driver td 
    ,u_dw_ext_app.sa_trip fr
where 
    td.driver_first_name= fr.driver_first_name 
    AND td.driver_last_name=fr.driver_last_name 
    and td.drive_licen =fr.DRIVE_LICEN;

  select customer_id
        from 
           u_dw_data.t_customer ct
            ,  U_DW_EXT_APP.sa_trip sat
        where 
            ct.FIRST_NAME = sat.customer_first_name 
            AND ct.LAST_NAME=sat.customer_last_name ;
        
select vehicle_id
        from 
           u_dw_data.t_vehicle vt
            , U_DW_EXT_APP.sa_trip sat
        where 
            vt.LICENCE_PLATE = sat.vin_code
            */
*/