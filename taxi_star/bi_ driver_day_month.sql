WITH like_fct_daily AS (
    SELECT
        trunc(a.date_id, 'MONTH')            date_id     -- group by month
        --TRUNC(a.date_id, 'YEAR') date_id     -- group by YEAR
       -- TRUNC(a.date_id, 'Q') date_id           -- group by QUARTER
      --TRUNC(a.date_id, 'MONTH') date_id     -- group by MONTH
      --TRUNC(a.date_id, 'DAY') date_id     -- group by DAY
        ,
        a.trip_id,
        a.driver_first_name
        || ' '
        || a.driver_last_name
        || ' '
        || a.drive_licen             full_driver_name,
        a.vehicle_manufacturer
        || ' '
        || a.vehicle_model
        || ' '
        || a.vin_code                vehicle
        --, a.coast
        ,
        a.raiting,
        a.distance,
        decode(a.status, 'Y', 1, 0)          finished   -- finished order
        ,
        decode(a.status, 'N', 1, 0)          canceled   -- canceled odrers
        FROM
        u_dw_ext_app.sa_trip a  
       -- where driver_first_name ='Ada' and driver_last_name = 'Fitzgerald'
            ORDER BY
        date_id
)
SELECT
    date_id,
    full_driver_name
 -- , vehicle 
    ,
    SUM(ct.distance)                         tot_distane,
    round(AVG(ct.raiting), 1)                avg_raiting,
    SUM(finished)                            cnt_finised,
    SUM(canceled)                            cnt_canceled,
    ( SUM(finished) + SUM(canceled) )            total_order,
    to_char(round(SUM(finished) /(SUM(finished) + SUM(canceled)) * 100, 2))
    || ' %'                                  percent_finished,
    to_char(round(SUM(canceled) /(SUM(finished) + SUM(canceled)) * 100, 2))
    || ' %'                                  percent_canceled,
    GROUPING(date_id)                        AS f1g_date_id,
    GROUPING(full_driver_name)               AS f1g_full_driver_name
FROM
    like_fct_daily ct
GROUP BY
    CUBE(full_driver_name,
         date_id 
 --, vehicle
         )
ORDER BY
    date_id,
    full_driver_name
    --, vehicle
    --  DESC
    ;