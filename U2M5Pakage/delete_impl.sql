CREATE OR REPLACE PACKAGE delete_all_data AS
    -- delete all dw data
    PROCEDURE delete_t_vehicle_data;

    PROCEDURE delete_t_trip_data;

    PROCEDURE delete_t_customer_data;

    PROCEDURE delete_t_driver_data;

    PROCEDURE t_all_t_date;

    PROCEDURE delete_dim_driver_data;

    PROCEDURE delete_dim_vehicle;

    PROCEDURE delete_dim_date;

    PROCEDURE delete_dim_geo;
    
    PROCEDURE delete_all_fct_data;

END delete_all_data;