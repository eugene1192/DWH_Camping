CREATE OR REPLACE PACKAGE BODY load_all_trip
as
    PROCEDURE ext_sa_t_trip IS
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
                status,-----------------------------------
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
                sat.status,   --------------------------------------
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
END load_all_trip;