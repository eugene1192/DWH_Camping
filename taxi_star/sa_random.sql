

insert into u_dw_ext_app.sa_trip
WITH cte_rnd AS (
    SELECT /* +MATERIALIZE*/                                        
                        floor(dbms_random.value(1, 314000))                                     AS driver_rn,
        floor(dbms_random.value(1, 314000))                                                     AS customer_rn,
        floor(dbms_random.value(1, 500))                                                        AS vehicle_rn,
        country_desc,
        TO_DATE('02-JAN-2019', 'DD-MM-YYYY HH24:MI:SS') + dbms_random.value(0, 1825)            date_id,
        trunc(dbms_random.value(0, 200))                                                        distance,
        trunc(dbms_random.value(1, 5))                                                          raiting,
        CASE
            WHEN floor(dbms_random.value(1, 3)) > 1 THEN
                'Y'
            ELSE
                'N'
        END                                                                                     status,
        'mil'                                                                                   distance_measure,
        round(dbms_random.value(10, 1000), 2)                                                   coast,
        'EUR'                                                                                   cyrrency
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
        LEVEL < 10
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
                drive_licen
            FROM
                u_dw_ext_app.sa_driver
        ) a
), cte_cust AS (
    SELECT /* +MATERIALIZE*/
                                        a.*,
        ROW_NUMBER()
        OVER(PARTITION BY 1
             ORDER BY first_name, last_name
        ) AS rn
    FROM
        (
            SELECT
                first_name,
                last_name
            FROM
                u_dw_ext_app.sa_customer
        ) a
), cte_vehcl AS (
    SELECT /* +MATERIALIZE*/
                                        a.*,
        ROW_NUMBER()
        OVER(PARTITION BY 1
             ORDER BY manufacturer, model_vhl, licence_plate
        ) AS rn
    FROM
        (
            SELECT
                manufacturer,
                model_vhl,
                licence_plate
            FROM
                u_dw_ext_app.sa_vehicle
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

commit;
alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
select * from u_dw_ext_app.sa_trip;


select TO_DATE('02-JAN-2015', 'DD-MM-YYYY HH24:MI:SS') +  1825 from dual