DROP TABLE u_dw_data.t_trip;

CREATE TABLE u_dw_data.t_trip (
    trip_id           NUMBER
        GENERATED ALWAYS AS IDENTITY,
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
    insert_dt         TIMESTAMP DEFAULT sysdate,
    update_dt         TIMESTAMP
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
 
DROP TRIGGER u_dw_data.update_trip_trig;

CREATE TRIGGER u_dw_data.update_trip_trig BEFORE
    UPDATE ON u_dw_data.t_trip
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

CREATE OR REPLACE PROCEDURE ext_sa_t_trip IS
BEGIN
    DELETE FROM u_dw_data.t_trip trp
    WHERE
        trp.sa_trip_id IN (
            SELECT
                trip_id
            FROM
                u_dw_ext_app.sa_trip
        );     
  
        INSERT INTO u_dw_data.t_trip (
            sa_trip_id,
            date_id,
            driver_id,
            customer_id,
            vehicle_id,
            country_id,
            distance,
            distance_measure,
            raiting,
            coast,
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
            sat.coast,
            sat.currency
        FROM
                 u_dw_ext_app.sa_trip sat
            JOIN u_dw_data.t_driver  td 
                ON td.driver_first_name = sat.driver_first_name
                    AND td.driver_last_name = sat.driver_last_name
                    AND td.drive_licen = sat.drive_licen
            JOIN u_dw_data.t_customer ct 
                ON ct.first_name = sat.customer_first_name
                    AND ct.last_name = sat.customer_last_name
                    AND ct.birth_date = sat.customer_bth_date
            JOIN u_dw_data.t_vehicle  vt
                ON vt.licence_plate = sat.vin_code
            JOIN u_dw_references.lc_countries lccnt 
                ON sat.country = lccnt.country_desc;

    COMMIT;
END ext_sa_t_trip;

EXEC ext_sa_t_trip;

--test consistency 
SELECT * FROM
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
            JOIN u_dw_data.t_driver_link  dl
                ON dl.driver_id = d.driver_id
            JOIN u_dw_data.t_driver_status  ds
                ON ds.driver_status_id = dl.driver_status_id
    ) dr ON t.driver_id = dr.driver_id
            AND t.date_id = dr.srart_dt;