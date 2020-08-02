--alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
 SELECT
    date_id,
    trip_id,
    full_driver_name
    , FIRST_VALUE(trip_id) 
         over (partition by  date_id Order by date_id) first_record
    , LAST_VALUE(trip_id) 
         over (partition by  date_id Order by date_id) last_record
    , DENSE_RANK() 
         over (partition by  vehicle order by full_driver_name, trip_id  ) dense_rank
    ,
    RANK()
    OVER(PARTITION BY vehicle
         ORDER BY full_driver_name, trip_id
    )                                                 rank,
    ROWNUM,
    SUM(distance)
        OVER(PARTITION BY full_driver_name, date_id)     sum_distance,
    MAX(raiting)
        OVER(PARTITION BY full_driver_name, date_id)     max_driv_rait_month,
    MIN(raiting)
        OVER(PARTITION BY full_driver_name, date_id)     min_driv_rait_month,
    vehicle,
    raiting,
    distance 
  --  , finished 
   -- , canceled 
    --, cancel_percent 
   -- , finish_percent 
    FROM
    test_model
ORDER BY
    full_driver_name;