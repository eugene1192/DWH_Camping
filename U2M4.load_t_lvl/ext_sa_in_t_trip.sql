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
 --   status            VARCHAR(1),
    coast             DECIMAL(10, 2),
    currency          VARCHAR(20),
    insert_dt    TIMESTAMP default sysdate ,
    update_dt    TIMESTAMP
    --CONSTRAINT pk_sa_trip PRIMARY KEY ( trip_id )
);
-- BEFORE INSERT TRIGGER NOT USED
/*
drop TRIGGER u_dw_data.insrt_trip_trig;
create trigger u_dw_data.insrt_trip_trig
    before insert 
    on  u_dw_data.t_trip 
    for each row
    begin 
        :new.insert_dt:=sysdate;
        end;
 */
 
drop TRIGGER u_dw_data.update_trip_trig;        
create trigger u_dw_data.update_trip_trig
    before update 
    on  u_dw_data.t_trip 
    for each row
    begin 
        :new.update_dt:=sysdate;
        end;



CREATE OR REPLACE PROCEDURE ext_sa_t_trip IS
BEGIN

     delete from u_dw_data.t_trip trp 
        where  trp.sa_trip_id in (select trip_id  from u_dw_ext_app.sa_trip );
      --   EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.T_DRIVER MODIFY(driver_id Generated as Identity (START WITH 1))';            
  
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
          --  status            ,
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
          --  sat.status,
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

exec ext_sa_t_trip;


--test consistency 
SELECT
    *
FROM
         u_dw_data.t_trip t
    JOIN (
        SELECT
            d.driver_id,
            d.driver_first_name,
            d.driver_last_name,
            d.drive_licen,
            dl.driver_status_id,
            dl.srart_dt,
            dl.end_date,
            ds.status,
            ds.status_desc
        FROM
                 u_dw_data.t_driver d
            JOIN u_dw_data.t_driver_link      dl ON dl.driver_id = d.driver_id
            JOIN u_dw_data.t_driver_status    ds ON ds.driver_status_id = dl.driver_status_id
    ) dr ON t.driver_id = dr.driver_id
            AND t.date_id = dr.srart_dt;
