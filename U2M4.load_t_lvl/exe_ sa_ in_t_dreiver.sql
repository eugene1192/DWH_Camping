
-- create  t_driver  natural key desc *****************************************

CREATE OR REPLACE PROCEDURE ext_sa_t_driver IS
    drv u_dw_ext_app.sa_driver%rowtype;
    CURSOR c_ex_drv IS
    SELECT
        *
    FROM
        u_dw_ext_app.sa_driver;
BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.T_DRIVER';
    EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.T_DRIVER MODIFY(driver_id Generated as Identity (START WITH 1))';
    EXECUTE IMMEDIATE 'truncate table u_dw_data.t_driver_status';
    EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_driver_status MODIFY(driver_status_id Generated as Identity (START WITH 1))';
    OPEN c_ex_drv;
    LOOP
        FETCH c_ex_drv INTO drv;
        EXIT WHEN c_ex_drv%notfound;
        INSERT INTO u_dw_data.t_driver
        (
            driver_first_name,
            driver_last_name,
            birth_date,
            drive_licen
        ) VALUES (
            drv.first_name,
            drv.last_name,
            drv.birth_date,
            drv.drive_licen
        );

    END LOOP;

    COMMIT;
  END ext_sa_t_driver;

CREATE OR REPLACE PROCEDURE load_link_driv_hist IS
BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.t_driver_link';   
    INSERT INTO u_dw_data.t_driver_link
        SELECT 
            td.driver_id,
            dst.driver_status_id,
            sat.date_id    start_date
      --     LEAD(sat.date_id)
      --      OVER(
      --          ORDER BY
      --              td.driver_id
      --       )              end_date 
        FROM
                 u_dw_ext_app.sa_trip sat
            JOIN u_dw_data.t_driver  td 
                ON td.driver_first_name = sat.driver_first_name
                      AND td.driver_last_name = sat.driver_last_name
                      AND td.drive_licen = sat.drive_licen
             JOIN u_dw_data.t_driver_status  dst
                ON dst.status = sat.status     
                        ORDER BY
            td.driver_id,
            sat.date_id;

END load_link_driv_hist;

CREATE OR REPLACE PROCEDURE load_driv_stat IS

    l_rc_var1         SYS_REFCURSOR;
    l_n_cursor_id     NUMBER;
    l_n_rowcount      NUMBER;
    l_n_column_count  NUMBER;
    l_vc_status       VARCHAR2(3);
    l_vc_status_desc  VARCHAR2(50);
    l_ntt_desc_tab    dbms_sql.desc_tab;
BEGIN
    EXECUTE IMMEDIATE 'delete u_dw_data.t_driver_status';
    EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_driver_status 
        MODIFY(driver_status_id Generated as Identity (START WITH 1))';
    OPEN l_rc_var1 FOR ' SELECT DISTINCT status FROM u_dw_ext_app.sa_driver';

    l_n_cursor_id := dbms_sql.to_cursor_number(l_rc_var1);
    dbms_sql.describe_columns(l_n_cursor_id, l_n_column_count, l_ntt_desc_tab);
    FOR loop_col IN 1..l_n_column_count LOOP
        dbms_sql.define_column(l_n_cursor_id, loop_col,
              CASE l_ntt_desc_tab(loop_col).col_name
                  WHEN 'STATUS' THEN
                      l_vc_status
              END,
              5);
    END LOOP loop_col;
    LOOP
        l_n_rowcount := dbms_sql.fetch_rows(l_n_cursor_id);
        EXIT WHEN l_n_rowcount = 0;
        FOR loop_col IN 1..l_n_column_count LOOP
            CASE l_ntt_desc_tab(loop_col).col_name
                WHEN 'STATUS' THEN
                    dbms_sql.column_value(l_n_cursor_id, loop_col, l_vc_status);
            END CASE;
        END LOOP loop_col;

        INSERT INTO u_dw_data.t_driver_status (
            status,
            status_desc
        ) VALUES (
            l_vc_status,
            CASE
                WHEN upper(l_vc_status) = 'Y'     THEN
                    'Driver online. Ready to get order'
                WHEN upper(l_vc_status) = 'N'     THEN
                    'Driver not working. Orders are not valid'
                ELSE
                    'Unknown status'
             END
    );
    END LOOP;
END load_driv_stat;

EXEC ext_sa_t_driver;

EXEC load_link_driv_hist;

EXEC load_driv_stat;


select count(*) from( select driver_first_name , driver_last_name, drive_licen  FROM u_dw_data.t_driver);


SELECT * FROM u_dw_data.t_driver_link;
SELECT * FROM u_dw_data.t_driver_status;

SELECT
  distinct COUNT(*) from (
select  d.driver_id FROM
         u_dw_data.t_driver d
    JOIN u_dw_data.t_driver_link      dl 
        ON dl.driver_id = d.driver_id
    JOIN u_dw_data.t_driver_status    ds 
        ON ds.driver_status_id = dl.driver_status_id);