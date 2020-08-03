/* --alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
insert into u_dw_fct_tax.fct_driv_month  
(
    dim_month_id      
  ,  dim_drv_id        
  ,  tot_distane      
  ,  distance_measure  
  ,  cnt_finish_orders 
  ,  cnt_cancel_orders  
  ,  total_orders      
  ,  avg_raiting       
  ,  percent_finished   
  ,  percent_canceled   
  ,  total_coast       
  ,  currency          
  ,  dim_geo_id         
) */
with fct_drv_month as
(
SELECT 
    dat.date_id,
    dat.month_id,
  --  drv.dim_drv_id,
  --  drv.driver_id,
    vh.vehicle_id,
    DECODE(t.status, 'Y', 1, 0) finished ,  -- finished order
    DECODE(t.status, 'N', 1, 0) canceled ,  -- canceled odrers
    t.raiting,
    geo.dim_geo_id,
    t.distance,
    t.distance_measure,
    t.coast,
    t.currency 
    FROM
         u_dw_data.t_trip t
    left join  U_DW_DIM_TAX.dim_vehicle_scd vh
        on t.VEHICLE_ID=vh.vehicle_id
   left join (select * from u_dw_dim_tax.dim_driver_scd2
    where is_active=1)   drv
        on t.driver_id=drv.driver_id
   --     and t.date_id=drv.valid_from        
    left join u_dw_dim_tax.dim_date dat
        on trunc (t.date_id, 'day')= dat.day_vchar_id 
    left join ( select * from u_dw_dim_tax.dim_geo_obj_scd 
    where geo_code='geo_group'
    )    geo
        on t.country_id = geo.country_id
      )
select  
    month_id dim_month_id,
    vehicle_id dim_vehcl_id,
    SUM(distance)       tot_distane,
    distance_measure,
    sum(finished) cnt_finish_orders,
    sum(canceled) cnt_cancel_orders,
    sum(finished)+sum(canceled) total_orders,
    round(AVG(raiting), 1)  avg_raiting,
    to_char(round(SUM(finished)/(SUM(finished)+SUM(canceled))*100,2)) 
        || ' %' percent_finished,
    to_char(round(SUM(canceled)/(SUM(finished)+SUM(canceled))*100,2)) 
        || ' %' percent_canceled,
    sum(coast) total_coast,
    currency,
    dim_geo_id
FROM    
     fct_drv_month
Group by 
     month_id
    , vehicle_id
    , distance_measure
    , currency
    , dim_geo_id
Order by month_id;
 

--delete from  u_dw_fct_tax.fct_driv_month ;
--truncate table  u_dw_fct_tax.fct_driv_month ;
--select * from u_dw_fct_tax.fct_driv_month ;
