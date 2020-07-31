--DROP PROCEDURE load_all_sa;
-- generic some data in u_dw_ext_app.sa_vehicle
CREATE OR REPLACE PROCEDURE load_all_sa IS
BEGIN
    INSERT INTO u_dw_ext_app.sa_vehicle
        SELECT DISTINCT
            *
        FROM
            (
                SELECT
                    v.year_2 manuf_year,
                    v.manufacturer,
                    v.model_vhl,
                    v.milliage,
                    r.*
                FROM
                    sa_vehicle  v,
                    (
                        SELECT
                            trunc(dbms_random.value(0, 9))
                            || dbms_random.string('u', 4)
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9))
                            || dbms_random.string('u', 4)
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9))
                            || trunc(dbms_random.value(0, 9)) vin_code
                        FROM
                            dual
                    )  r
            );

END;

EXEC load_all_sa;






INSERT INTO u_dw_ext_app.sa_trip
    WITH cte_rnd AS (
        SELECT /* +MATERIALIZE*/                                        
            floor(dbms_random.value(1, 1000))                                                      AS driver_rn,
            floor(dbms_random.value(1, 31400))                                                     AS customer_rn,
            floor(dbms_random.value(1, 30))                                                        AS vehicle_rn,
            country_desc,
            TO_DATE('02-JUN-2019', 'DD-MM-YYYY HH24:MI:SS') + dbms_random.value(0, 200)            date_id,
            trunc(dbms_random.value(0, 200))                                                       distance,
            trunc(dbms_random.value(1, 5))                                                         raiting,
            CASE
                WHEN floor(dbms_random.value(1, 3)) > 1 THEN
                    'Y'
                ELSE
                    'N'
            END                                                                                    status,
            'mil'                                                                                  distance_measure,
            round(dbms_random.value(10, 1000), 2)                                                  coast,
            'EUR'                                                                                  cyrrency
        FROM
            dual,
            (
                SELECT
                    country_desc
                FROM
                    u_dw_references.lc_countries
                WHERE
                    country_id = 56
            )
        CONNECT BY
            level < 1000000
    ), cte_drv AS (
        SELECT /* +MATERIALIZE*/
                                    a.*,
            ROW_NUMBER()
            OVER(PARTITION BY 1
                 ORDER BY first_name, last_name, drive_licen
            ) AS rn
        FROM
            (
                SELECT
                    first_name,
                    last_name,
                    drive_licen,
                    status
                FROM
                    u_dw_ext_app.sa_driver
      
            ) a
    ), cte_cust AS (
        SELECT /* +MATERIALIZE*/
                                                    a.*,
            ROW_NUMBER()
            OVER(PARTITION BY 1
                 ORDER BY first_name, last_name, birth_date
            ) AS rn
        FROM
            (
                SELECT 
                    first_name,
                    last_name,
                    birth_date
                FROM
                    u_dw_ext_app.sa_customer
            ) a
    ), cte_vehcl AS (
        SELECT /* +MATERIALIZE*/
                                                    a.*,
            ROW_NUMBER()
            OVER(PARTITION BY 1
                 ORDER BY manufacturer, model_vhl
            ) AS rn
        FROM
            (
                SELECT
                    manufacturer,
                    model_vhl,
                    licence_plate
                FROM
                    u_dw_ext_app.sa_vehicle
                WHERE
                    manufacturer IN ( 'Volkswagen', 'Ford', 'Chevrolet' )
                    AND manuf_year = 2019
               -- and model_vhl  in('Camaro', 'Corvette', 'Cruze', 'Focus', 'Fusion' , 'Golf' , 'Passat',  'Tiguan' )
                    ) a
    )
    SELECT
        CAST((to_char(date_id, 'DD')
              || to_char(date_id, 'MM')
              || to_char(date_id, 'YYYY')
              || to_char(date_id, 'HH24')
              || to_char(date_id, 'MI')
              || to_char(date_id, 'SS')) AS INTEGER) trip_id,
        c.date_id,
        drv.first_name,
        drv.last_name,
        drv.drive_licen,
        cust.first_name,
        cust.last_name,
        cust.birth_date,
        vehcl.manufacturer,
        vehcl.model_vhl,
        vehcl.licence_plate,
        c.country_desc,
        c.distance,
        c.distance_measure,
        c.raiting,
        c.status,
        c.coast,
        c.cyrrency
   -- cust.*,
    --vehcl.*,
    --drv.*
    FROM
             cte_rnd c
        INNER JOIN cte_drv    drv ON c.driver_rn = drv.rn
        INNER JOIN cte_cust   cust ON c.customer_rn = cust.rn
        INNER JOIN cte_vehcl  vehcl ON c.vehicle_rn = vehcl.rn;

COMMIT;

SELECT
    COUNT(*)
FROM
    u_dw_ext_app.sa_trip;