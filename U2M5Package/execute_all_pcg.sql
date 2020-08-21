--delete all dw 
--alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
BEGIN
   delete_all_data.delete_t_vehicle_data; --delete t_vehicle
   delete_all_data.delete_t_trip_data; --delete t_trip
   delete_all_data.delete_t_customer_data; --delete t_customer
   delete_all_data.delete_t_driver_data;  --delete t_driver 
  
--END;

--delete all dim
--BEGIN  
   delete_all_data.delete_dim_driver_data; --delete all from dim_driver
   delete_all_data.delete_dim_vehicle; --delete all from dim_vehicle
--END;

--BEGIN
    delete_all_data.delete_all_fct_data;
--END;
-- load all date tables
--BEGIN
    delete_all_data.delete_dim_date; -- delete all from dim_date
    delete_all_data.t_all_t_date; -- delete all t_time tables 
    load_t_dim_date.loat_t_day;
    load_t_dim_date.load_t_week;
    load_t_dim_date.load_t_month;  --not Use twice
    load_t_dim_date.load_t_qarter;
    load_t_dim_date.load_t_year;
    load_t_dim_date.load_dim_date;
--END;
--load geo dimension
--BEGIN
    delete_all_data.delete_dim_geo; --delete from dim_geo_obj_scd
    load_dim_geo.load_dim_geo_obg; --not Use twice because create new id  
--END;
-- load driver tables
--BEGIN 
    load_all_driver.ext_sa_t_driver;
    load_all_driver.load_driv_stat;
    load_all_driver.load_link_driv_list;

    load_all_driver.load_dim_drv; 
--END;
-- load all vehicle table
--BEGIN 
    load_all_vehicle.ext_sa_t_vehicke;
    load_all_vehicle.t_dim_vehicle;
--END;
-- load all customer
--BEGIN 
    load_all_customer.ext_sa_t_customer;
--END;
-- load all trip data
--BEGIN
    load_all_trip.ext_sa_t_trip;
--END;
-- load  fct driver month
--BEGIN
    load_fct_driv_moth.load_fct_drv;
    load_fct_vehcl_moth.load_fct_vehcl;
END;


