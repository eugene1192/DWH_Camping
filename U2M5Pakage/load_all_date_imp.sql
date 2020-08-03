CREATE OR REPLACE PACKAGE load_t_dim_date AS
    PROCEDURE loat_t_day;

    PROCEDURE load_t_week;

    PROCEDURE load_t_month;

    PROCEDURE load_t_qarter;

    PROCEDURE load_t_year;

    PROCEDURE load_dim_date;

END load_t_dim_date;