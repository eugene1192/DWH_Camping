--insert all data from .csv
--create sa_last_name like buffer table  
DROP TABLE sa_last_name;

CREATE TABLE sa_last_name (
    last_name VARCHAR(20)
);
--SELECT * from sa_last_name;
--insert all data from .csv
--drop table sa_person;
--create sa_last_name like buffer table 
CREATE TABLE sa_person (
    first_name  VARCHAR(20),
    birth_date  VARCHAR(20),
    gender      VARCHAR(20),
    zip         VARCHAR(20),
    ccnumber    NUMBER(20, 0),
    email       VARCHAR(100),
    status      VARCHAR(1),
    rating      NUMBER(10, 0)
)--drop table sa_person_v2;
--insert all data from .csv
CREATE TABLE sa_person_v2 (
    first_name  VARCHAR(20),
    birth_date  VARCHAR(20),
    gender      VARCHAR(20),
    zip         VARCHAR(20),
    ccnumber    NUMBER(20, 0),
    email       VARCHAR(100),
    status      VARCHAR(1),
    rating      NUMBER(10, 0)
)    
--drop table sa_vehicle;
--insert all data from .csv
 CREATE TABLE sa_vehicle (
    year_1        NUMBER(10, 0),
    year_2        NUMBER(10, 0),
    manufacturer  VARCHAR(20),
    model_vhl     VARCHAR(20),
    milliage      NUMBER(20, 0)
)

CREATE TABLE u_dw_ext_app.sa_vehicle (
    manuf_year     NUMBER(10, 0),
    manufacturer   VARCHAR(20),
    model_vhl      VARCHAR(20),
    milliage       NUMBER(20, 0),
    licence_plate  VARCHAR(50)
);
    
    
    
--CREATE TABLE SA_CUSTOMERS IN 314000 ROWS
--drop table u_dw_ext_app.sa_customer;
CREATE TABLE u_dw_ext_app.sa_customer
    AS
        SELECT DISTINCT
            first_name,
            last_name,
            to_date(birth_date, 'MM-DD-YYYY') birth_date,
            rating 
   --into u_dw_ext_app.sa_customer
                        FROM
            sa_person_v2,
            sa_last_name;

CREATE INDEX sa_customer_idx ON
    u_dw_ext_app.sa_customer (
        first_name,
        last_name,
        birth_date
    )
        TABLESPACE ts_sa_app_data;

--CREATE TABLE SA_DRIVER IN 314000 ROWS
--DROP TABLE u_dw_ext_app.sa_driver;
    CREATE TABLE u_dw_ext_app.sa_driver
    AS
        SELECT DISTINCT
            first_name,
            last_name,
            to_date(birth_date, 'MM-DD-YYYY')      birth_date,
            zip                                    drive_licen,
            status 
    --    into u_dw_ext_app.sa_driver
                         FROM
            sa_person_v2,
            sa_last_name;
    --DROP TABLE  sa_trip CASCADE CONSTRAINTS;
CREATE INDEX sa_driver_idx ON
    u_dw_ext_app.sa_driver (
        first_name,
        last_name,
        birth_date,
        drive_licen
    )
        TABLESPACE ts_sa_app_data;
-- insert all data from .csv
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
                    )           r
            );

END;

EXEC load_all_sa;

SELECT
    *
FROM
    u_dw_ext_app.sa_vehicle
ORDER BY
    manufacturer;
/*==============================================================*/
/* Table: SA_TRIP                                               */
/*==============================================================*/
DROP TABLE u_dw_ext_app.sa_trip CASCADE CONSTRAINTS;

/*==============================================================*/
/* Table: SA_TRIP                                               */
/*==============================================================*/
CREATE TABLE u_dw_ext_app.sa_trip (
    trip_id               INT NOT NULL,
    date_id               DATE,
    driver_first_name     VARCHAR(20),
    driver_last_name      VARCHAR(20),
    drive_licen           VARCHAR(20),
    customer_first_name   VARCHAR(20),
    customer_last_name    VARCHAR(20),
    customer_bth_date     DATE,
    vehicle_manufacturer  VARCHAR(20),
    vehicle_model         VARCHAR(20),
    vin_code              VARCHAR(20),
    country               VARCHAR(20),
    distance              DECIMAL(10, 1),
    distance_measure      VARCHAR(20),
    raiting               DECIMAL(3, 1),
    status                VARCHAR(1),
    coast                 DECIMAL(10, 2),
    currency              VARCHAR(20)
    --CONSTRAINT pk_sa_trip PRIMARY KEY ( trip_id )
);
 


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
            level < 500000
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