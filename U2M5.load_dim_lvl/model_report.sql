SELECT DISTINCT
    vehicle,
    date_id,
    distance,
    round(raiting, 1)             raiting,
    finished,
    canceled,
    round(cancel_percent, 1)      cancel_percent,
    round(finish_percent, 1)      finish_percent
FROM
    test_model
GROUP BY
    vehicle,
    date_id,
    cancel_percent,
    finish_percent
MODEL
    UNIQUE SINGLE REFERENCE
--PARTITION BY (full_driver_name, date_id)
        DIMENSION BY ( date_id,
                   vehicle )
    MEASURES ( SUM(distance) distance, AVG(raiting) raiting, SUM(finished) finished, SUM(canceled) canceled,
     cancel_percent,
    finish_percent )
    RULES
    (
      --  distance ['01-SEP-19', 'Addie Massey 88789']= sum(distance)['01-SEP-19' , 'Addie Massey 88789']
     distance[ANY,
        FOR vehicle IN (
            SELECT
                vehicle
            FROM
                test_model
            GROUP BY
                vehicle
        )
    ]= SUM ( distance )[ANY,
    cv(vehicle)],
    raiting[ANY,
        FOR vehicle IN (
            SELECT
                vehicle
            FROM
                test_model
            GROUP BY
                vehicle
        )
    ]= AVG ( raiting )[ANY,
    cv(vehicle)],
    finished[ANY,
        FOR vehicle IN (
            SELECT
                vehicle
            FROM
                test_model
            GROUP BY
                vehicle
        )
    ]= SUM ( finished )[ANY,
    cv(vehicle)],
    cancel_percent[ANY,
        FOR vehicle IN (
            SELECT
                vehicle
            FROM
                test_model
            GROUP BY
                vehicle
        )
    ]= SUM ( canceled )[ANY,
    cv(vehicle)]/ ( SUM ( canceled )[ANY,
    cv(vehicle)]+ SUM ( finished )[ANY,
    cv(vehicle)]) * 100,
    finish_percent[ANY,
        FOR vehicle IN (
            SELECT
                vehicle
            FROM
                test_model
            GROUP BY
                vehicle
        )
    ]= SUM ( finished )[ANY,
    cv(vehicle)]/ ( SUM ( canceled )[ANY,
    cv(vehicle)]+ SUM ( finished )[ANY,
    cv(vehicle)]) * 100 );


SELECT DISTINCT
    full_driver_name,
    date_id,
    distance,
    round(raiting, 1)             raiting,
    finished,
    canceled,
    round(cancel_percent, 1)      cancel_percent,
    round(finish_percent, 1)      finish_percent
FROM
    test_model
GROUP BY
    full_driver_name,
    date_id,
    cancel_percent,
    finish_percent
MODEL
    UNIQUE SINGLE REFERENCE
--PARTITION BY (full_driver_name, date_id)
        DIMENSION BY ( date_id,
                   full_driver_name )
    MEASURES ( SUM(distance) distance, AVG(raiting) raiting, SUM(finished) finished, SUM(canceled) canceled,
    cancel_percent,
    finish_percent )
    RULES
    (
      --  distance ['01-SEP-19', 'Addie Massey 88789']= sum(distance)['01-SEP-19' , 'Addie Massey 88789']
     distance[ANY,
        FOR full_driver_name IN (
            SELECT
                full_driver_name
            FROM
                test_model
            GROUP BY
                full_driver_name
        )
    ]= SUM ( distance )[ANY,
    cv(full_driver_name)],
    raiting[ANY,
        FOR full_driver_name IN (
            SELECT
                full_driver_name
            FROM
                test_model
            GROUP BY
                full_driver_name
        )
    ]= AVG ( raiting )[ANY,
    cv(full_driver_name)],
    finished[ANY,
        FOR full_driver_name IN (
            SELECT
                full_driver_name
            FROM
                test_model
            GROUP BY
                full_driver_name
        )
    ]= SUM ( finished )[ANY,
    cv(full_driver_name)],
    cancel_percent[ANY,
        FOR full_driver_name IN (
            SELECT
                full_driver_name
            FROM
                test_model
            GROUP BY
                full_driver_name
        )
    ]= SUM ( canceled )[ANY,
    cv(full_driver_name)]/ ( SUM ( canceled )[ANY,
    cv(full_driver_name)]+ SUM ( finished )[ANY,
    cv(full_driver_name)]) * 100,
    finish_percent[ANY,
        FOR full_driver_name IN (
            SELECT
                full_driver_name
            FROM
                test_model
            GROUP BY
                full_driver_name
        )
    ]= SUM ( finished )[ANY,
    cv(full_driver_name)]/ ( SUM ( canceled )[ANY,
    cv(full_driver_name)]+ SUM ( finished )[ANY,
    cv(full_driver_name)]) * 100 );

 SELECT    *FROM    test_model ;
  --alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
 drop table test_model;
create table test_model 
(
    date_id date,
    trip_id number,
    full_driver_name varchar(59),
    vehicle varchar(70),
    raiting NUMBER(8,2),
    distance NUMBER(9,1),
    finished number ,
    canceled number,
 --   total_order number,
    cancel_percent NUMBER(8,2),
    finish_percent NUMBER(8,2)
    
);

INSERT INTO test_model  (
    date_id ,
    trip_id ,
    full_driver_name ,
    vehicle ,
    raiting ,
    distance ,
    finished  ,
    canceled 
) WITH like_fct_daily AS (
    SELECT
        trunc(a.date_id, 'MONTH')            date_id     -- group by month
      --TRUNC(a.date_id, 'YEAR') date_id      -- group by YEAR
      -- TRUNC(a.date_id, 'Q') date_id        -- group by QUARTER
      --TRUNC(a.date_id, 'MONTH') date_id     -- group by MONTH
      --TRUNC(a.date_id, 'DAY') date_id       -- group by DAY
        ,
        a.trip_id,
        a.driver_first_name
        || ' '
           || a.driver_last_name
              || ' '
                 || a.drive_licen      full_driver_name,
        a.vehicle_manufacturer
        || ' '
           || a.vehicle_model
              || ' '
                 || a.vin_code         vehicle
        --, a.coast
                 ,
        a.raiting,
        a.distance,
        decode(a.status, 'Y', 1, 0)          finished   -- finished order
        ,
        decode(a.status, 'N', 1, 0)          canceled   -- canceled odrers
            FROM
        u_dw_ext_app.sa_trip a
    ORDER BY
        date_id,
        full_driver_name
)
SELECT DISTINCT
    *
FROM
    like_fct_daily ct
   -- group by   date_id,
    --full_driver_name
    WHERE
    ROWNUM < 50000;
    COMMIT;
*/