/* 
-- create  view_test_on_dem for DBMS_MVIEW.refresh test
CREATE MATERIALIZED VIEW view_test_on_dem
REFRESH COMPLETE 
NEXT sysdate+NUMTODSINTERVAL(1 , 'MINUTE' )
AS WITH like_fct_daily AS(
    SELECT 
        trunc(a.date_id, 'MONTH') date_id     -- group by month
     -- trunc(a.date_id, 'DAY') date_id     -- group by day
        ,a.trip_id
        ,a.driver_first_name 
        || ' ' ||
        a.driver_last_name 
        || ' ' ||
        a.drive_licen full_driver_name
        , a.vehicle_manufacturer
        || ' ' ||
        a.vehicle_model
        || ' ' ||
        a.vin_code vehicle
        --, a.coast
        , a.raiting
        , a.distance
        ,DECODE(a.status, 'Y', 1, 0) finished   -- finished order
        ,DECODE(a.status, 'N', 1, 0) canceled   -- canceled odrers
    FROM 
        U_DW_EXT_APP.SA_TRIP a  
       -- where driver_first_name ='Ada' and driver_last_name = 'Fitzgerald'
        ORDER BY date_id
)
SELECT
    date_id
    ,full_driver_name
 -- , vehicle 
    ,SUM(ct.distance)                    tot_distane
    ,round(AVG(ct.raiting), 1)           avg_raiting
    ,SUM(finished)                       cnt_finised
    ,SUM(canceled)                       cnt_canceled
    ,(SUM(finished)+SUM(canceled))       total_order
    ,to_char(round(SUM(finished)/(SUM(finished)+SUM(canceled))*100,2)) 
    || ' %' percent_finished
    ,to_char(round(SUM(canceled)/(SUM(finished)+SUM(canceled))*100,2)) 
    || ' %' percent_canceled
FROM
    like_fct_daily ct
GROUP BY (
     date_id
   , full_driver_name
 --, vehicle
    )
 ORDER BY 
      date_id
    , full_driver_name
    --, vehicle
; 

select * from view_test_on_dem;
EXEC DBMS_MVIEW.refresh('view_test_model');
*/
/*
--I distributed all possible rights, created an index and PK. Reduced 
--the query to one column and got no results.

connect U_DW_EXT_APP/1;
CREATE MATERIALIZED VIEW view_test_on_commit
 refresh  on commit  
AS
SELECT     
    trip_id    
    FROM 
        U_DW_EXT_APP.SA_TRIP 
  ;
*/

SELECT
    *
FROM
    u_dw_ext_app.sa_trip;

DELETE FROM u_dw_ext_app.sa_trip
WHERE
    ROWNUM < (
        SELECT
            COUNT(*) - 1
        FROM
            u_dw_ext_app.sa_trip
    );

CREATE MATERIALIZED VIEW view_test_on_time
    REFRESH
        COMPLETE
        NEXT sysdate + numtodsinterval(1, 'MINUTE')
AS
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

SELECT
    *
FROM
    view_test_on_time;

DELETE FROM test_model
WHERE
    ROWNUM < 27;