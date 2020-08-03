CREATE OR replace PACKAGE BODY load_fct_vehcl_moth 
AS 
    PROCEDURE load_fct_vehcl 
    AS
            BEGIN 
                MERGE INTO u_dw_fct_tax.fct_vehcl_month f 
                USING ( 
                    WITH fct_drv_month
                            AS
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
                                LEFT JOIN  U_DW_DIM_TAX.dim_vehicle_scd vh
                                    ON t.VEHICLE_ID=vh.vehicle_id
                               LEFT JOIN (SELECT * FROM u_dw_dim_tax.dim_driver_scd2
                                where is_active=1)   drv
                                    ON t.driver_id=drv.driver_id
                               --     and t.date_id=drv.valid_from        
                                LEFT JOIN u_dw_dim_tax.dim_date dat
                                    ON TRUNC (t.date_id, 'DAY')= dat.day_vchar_id 
                                LEFT JOIN ( SELECT * FROM u_dw_dim_tax.dim_geo_obj_scd 
                                WHERE geo_code='geo_group'
                                )    geo
                                    ON t.country_id = geo.country_id
                                  )
                            SELECT  
                                month_id dim_month_id,
                                vehicle_id dim_vehcl_id,
                                SUM(distance)       tot_distane,
                                distance_measure,
                                SUM(finished) cnt_finish_orders,
                                SUM(canceled) cnt_cancel_orders,
                                SUM(finished)+sum(canceled) total_orders,
                                round(AVG(raiting), 1)  avg_raiting,
                                to_char(round(SUM(finished)/(SUM(finished)+SUM(canceled))*100,2)) 
                                    || ' %' percent_finished,
                                to_char(round(SUM(canceled)/(SUM(finished)+SUM(canceled))*100,2)) 
                                    || ' %' percent_canceled,
                                SUM(coast) total_coast,
                                currency,
                                dim_geo_id
                            FROM    
                                 fct_drv_month
                            GROUP BY 
                                 month_id
                                , vehicle_id
                                , distance_measure
                                , currency
                                , dim_geo_id
                           
                           ) q
                    ON(
                       f.dim_month_id = q.dim_month_id
                        AND  f.dim_vehcl_id = q.dim_vehcl_id        
                        AND  f.dim_geo_id =  q.dim_geo_id   
                    )
                     WHEN NOT MATCHED THEN INSERT
                        (
                         f.dim_month_id 
                      ,  f.dim_vehcl_id
                      ,  f.tot_distane 
                      ,  f.distance_measure 
                      ,  f.cnt_finish_orders
                      ,  f.cnt_cancel_orders  
                      ,  f.total_orders
                      ,  f.avg_raiting 
                      ,  f.percent_finished 
                      ,  f.percent_canceled 
                      ,  f.total_coast 
                      ,  f.currency 
                      ,  f.dim_geo_id 
                        )
                    VALUES
                        (
                        q.dim_month_id 
                      ,  q.dim_vehcl_id
                      ,  q.tot_distane 
                      ,  q.distance_measure 
                      ,  q.cnt_finish_orders
                      ,  q.cnt_cancel_orders  
                      ,  q.total_orders
                      ,  q.avg_raiting 
                      ,  q.percent_finished 
                      ,  q.percent_canceled 
                      ,  q.total_coast 
                      ,  q.currency 
                      ,  q.dim_geo_id 
                        )
            WHEN MATCHED THEN UPDATE SET
                        f.tot_distane = q.tot_distane      
                     ,   f.distance_measure = q.distance_measure
                     ,   f.cnt_finish_orders = q.cnt_finish_orders
                     ,   f.cnt_cancel_orders  =q.cnt_cancel_orders
                     ,   f.total_orders = q.total_orders    
                     ,   f.avg_raiting  = q.avg_raiting    
                     ,   f.percent_finished =  q.percent_finished 
                     ,   f.percent_canceled = q.percent_canceled 
                     ,   f.total_coast = q.total_coast      
                     ,   f.currency =  q.currency       
                   ;
            COMMIT;
            END load_fct_vehcl;
END load_fct_vehcl_moth;