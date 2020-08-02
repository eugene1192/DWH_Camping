 --alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
 SELECT
    date_id  
    , trip_id 
    ,full_driver_name
    --, FIRST_VALUE(trip_id) over (partition by  date_id Order by date_id) first_record
    -- , LAST_VALUE(trip_id) over (partition by  date_id Order by date_id) last_record
    -- , DENSE_RANK() over (partition by  vehicle order by full_driver_name, trip_id  ) dense_rank
    , RANK() over (partition by  vehicle order by full_driver_name, trip_id  ) rank
    ,ROWNUM 
    ,sum(distance) over (partition by full_driver_name ,date_id) sum_distance
    ,MAx(raiting)  over (partition by full_driver_name ,date_id) max_driv_rait_month
    ,MIN(raiting) over (partition by full_driver_name ,date_id) min_driv_rait_month
    , vehicle 
    , raiting 
    , distance 
  --  , finished 
   -- , canceled 
    --, cancel_percent 
   -- , finish_percent 
    from  test_model
    
    Order by full_driver_name;