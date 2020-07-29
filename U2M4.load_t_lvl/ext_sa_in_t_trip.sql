drop table  u_dw_data.t_trip;
CREATE TABLE u_dw_data.t_trip (
    trip_id           NUMBER GENERATED ALWAYS AS IDENTITY,
    sa_trip_id        INT NOT NULL,
    date_id           DATE,
    driver_id         NUMBER,
    customer_id       NUMBER,
    vehicle_id        NUMBER,
    country_id        VARCHAR(20),
    distance          DECIMAL(10, 1),
    distance_measure  VARCHAR(20),
    raiting           DECIMAL(3, 1),
    status            VARCHAR(1),
    coast             DECIMAL(10, 2),
    currency          VARCHAR(20)
    --CONSTRAINT pk_sa_trip PRIMARY KEY ( trip_id )
);

CREATE OR REPLACE PROCEDURE ext_sa_t_trip IS
BEGIN

     delete from u_dw_data.t_trip trp 
        where  trp.sa_trip_id in (select trip_id  from u_dw_ext_app.sa_trip ); 
  
        INSERT INTO u_dw_data.t_trip (
            sa_trip_id        ,
            date_id           ,
            driver_id         ,
            customer_id       ,
            vehicle_id        ,
            country_id        ,
            distance          ,
            distance_measure  ,
            raiting           ,
            status            ,
            coast             ,
            currency          
        ) 
        SELECT  
            sat.trip_id,
            sat.date_id,
            td.driver_id,        
            ct.customer_id,        
            vt.vehicle_id,
            lccnt.country_id,
            sat.distance,
            sat.distance_measure,
            sat.raiting,
            sat.status,
            sat.coast,
            sat.currency
        FROM
            u_dw_ext_app.sa_trip sat
            join  u_dw_data.t_driver td  on
                        td.driver_first_name = sat.driver_first_name
                    AND td.driver_last_name = sat.driver_last_name
                    AND td.drive_licen = sat.drive_licen
            join u_dw_data.t_customer ct on
                        ct.first_name = sat.customer_first_name
                    AND ct.last_name = sat.customer_last_name
                    AND ct.birth_date = sat.customer_bth_date
            join u_dw_data.t_vehicle vt on
                    vt.licence_plate = sat.vin_code
            join  u_dw_references.lc_countries lccnt on
                    sat.country = lccnt.country_desc        
                    ;
    COMMIT;
END ext_sa_t_trip;

exec ext_sa_in_t_trip;

select count( *) from u_dw_data.t_trip;
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