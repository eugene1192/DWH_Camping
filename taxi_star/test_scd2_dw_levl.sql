--alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
SELECT
    td.driver_id,
    sat.status,
    sat.date_id    start_date,
    LEAD(sat.date_id)
    OVER(
        ORDER BY
            td.driver_id
    )              end_date
    FROM
         u_dw_ext_app.sa_trip sat
    JOIN u_dw_data.t_driver td ON td.driver_first_name = sat.driver_first_name
                                  AND td.driver_last_name = sat.driver_last_name
                                  AND td.drive_licen = sat.drive_licen
ORDER BY
    td.driver_id,
    sat.date_id