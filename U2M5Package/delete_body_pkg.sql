CREATE OR REPLACE PACKAGE BODY delete_all_data AS 
    -- delete all from u_dw_data.t_vehicle , reset the counter
    PROCEDURE delete_t_vehicle_data AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_data.t_vehicle';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_vehicle MODIFY
                    (vehicle_id Generated as Identity (START WITH 1))';            
            COMMIT;
    END delete_t_vehicle_data;       
     
     -- delete all from u_dw_data.t_trip
    PROCEDURE delete_t_trip_data AS
        BEGIN
            EXECUTE IMMEDIATE 'truncate table u_dw_data.t_trip';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_trip MODIFY
                    (trip_id Generated as Identity (START WITH 1))';   
            COMMIT;
    END delete_t_trip_data;
      
    -- delete all from delete from u_dw_data.t_customer , reset the counter
    PROCEDURE delete_t_customer_data AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_data.t_customer';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_customer MODIFY
                    (customer_id Generated as Identity (START WITH 1))';
            COMMIT;
    END delete_t_customer_data;
    
    --delete all from u_dw_data.t_driver  
    PROCEDURE delete_t_driver_data AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_data.t_driver';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_driver MODIFY
                    (driver_id Generated as Identity (START WITH 1))';
                --delete all from u_dw_data.t_driver_status   
            EXECUTE IMMEDIATE 'delete from u_dw_data.t_driver_status';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_driver_status MODIFY
                    (driver_status_id Generated as Identity (START WITH 1))';
                --delete all from u_dw_data.t_driver_link     
            EXECUTE IMMEDIATE 'delete from u_dw_data.t_driver_link';
        COMMIT;
    END delete_t_driver_data;
    -- delete al data from t_day, t_week, ,t_month, t_quarter, t_year
    PROCEDURE t_all_t_date AS
        BEGIN
            EXECUTE IMMEDIATE ' delete from    u_dw_data.t_day';
            EXECUTE IMMEDIATE ' delete from    u_dw_data.t_week';
            EXECUTE IMMEDIATE ' delete from    u_dw_data.t_month';
            EXECUTE IMMEDIATE ' delete from    u_dw_data.t_quarter';
            EXECUTE IMMEDIATE ' delete from    u_dw_data.t_year';
        COMMIT;
    END t_all_t_date;
--******************************************************************************     
       -- delete all data from dim_driver_scd2 
    PROCEDURE delete_dim_driver_data AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_dim_tax.dim_driver_scd2';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_dim_tax.dim_driver_scd2 MODIFY
                    (dim_drv_id Generated as Identity (START WITH 1))';
        COMMIT;
    END delete_dim_driver_data; 
        
        --delete all data from dim_vehicle
    PROCEDURE delete_dim_vehicle AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_dim_tax.dim_vehicle_scd';
         --   EXECUTE IMMEDIATE 'ALTER TABLE u_dw_dim_tax.dim_vehicle_scd MODIFY
         --           (vehicle_id Generated as Identity (START WITH 1))';
        COMMIT;
    END delete_dim_vehicle;
       -- delete all data from dim_date 
    PROCEDURE delete_dim_date AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_dim_tax.dim_date';
        COMMIT;
    END delete_dim_date;
        
        --delete all data from dim_geo_obj_scd
    PROCEDURE delete_dim_geo AS
        BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_dim_tax.dim_geo_obj_scd';
        COMMIT;
    END delete_dim_geo;

    PROCEDURE delete_all_fct_data
        AS
            BEGIN
                EXECUTE IMMEDIATE 'delete from u_dw_fct_tax.fct_vehcl_month';
                EXECUTE IMMEDIATE 'delete from u_dw_fct_tax.fct_driv_month';
    END delete_all_fct_data;
    
END delete_all_data;


/*
select * from u_dw_data.t_vehicle ;
select * from u_dw_data.t_trip ;
select * from u_dw_data.t_driver ;
select * from u_dw_data.t_driver_status ;
select * from u_dw_data.t_driver_link ;
*/