CREATE OR REPLACE PACKAGE BODY load_all_driver 
AS 
    PROCEDURE ext_sa_t_driver IS
            drv u_dw_ext_app.sa_driver%rowtype;
            CURSOR c_ex_drv IS
            SELECT
                *
            FROM
                u_dw_ext_app.sa_driver;
        
            BEGIN
            EXECUTE IMMEDIATE 'delete from u_dw_data.T_DRIVER';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.T_DRIVER MODIFY
                (driver_id Generated as Identity (START WITH 1))';
            EXECUTE IMMEDIATE 'truncate table u_dw_data.t_driver_status';
            EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_driver_status MODIFY
                (driver_status_id Generated as Identity (START WITH 1))';
            OPEN c_ex_drv;
            LOOP
                FETCH c_ex_drv INTO drv;
                EXIT WHEN c_ex_drv%notfound;
                INSERT INTO u_dw_data.t_driver (
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
    
    PROCEDURE load_link_driv_list IS
    BEGIN
        EXECUTE IMMEDIATE 'delete from u_dw_data.t_driver_link';   
        INSERT INTO u_dw_data.t_driver_link
            SELECT
                td.driver_id,
                dst.driver_status_id,
                sat.date_id    start_date
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
    COMMIT;
    END load_link_driv_list;        

    PROCEDURE load_driv_stat IS

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
        COMMIT;
    END load_driv_stat;
    
    PROCEDURE load_dim_drv IS
    BEGIN
    INSERT INTO u_dw_dim_tax.dim_driver_scd2 (
    --   dim_drv_id   
        driver_id,
        driver_first_name,
        driver_last_name,
        birth_date,
        drive_licen,
        driver_status_id,
        status,
        status_desc,
        is_active,
        valid_from,
        valid_to
    )
        WITH dim AS (
            SELECT
                d.driver_id,
                d.driver_first_name,
                d.driver_last_name,
                d.birth_date,
                d.drive_licen,
                ds.driver_status_id,
                ds.status,
                ds.status_desc
    --    , 0 is_active
                ,
                dl.srart_dt,
                LEAD(dl.srart_dt)
                OVER(PARTITION BY d.driver_id
                     ORDER BY
                         d.driver_id, dl.srart_dt
                ) end_dt
            FROM
                     u_dw_data.t_driver d
                JOIN u_dw_data.t_driver_link      dl 
                    ON dl.driver_id = d.driver_id
                JOIN u_dw_data.t_driver_status    ds 
                    ON ds.driver_status_id = dl.driver_status_id
          --  where rownum <10000
            MINUS
            SELECT 
    --   dim_drv_id   
                driver_id,
                driver_first_name,
                driver_last_name,
                birth_date,
                drive_licen,
                driver_status_id,
                status,
                status_desc ,       
 --     is_active,          
                
                valid_from srart_dt,
                valid_to
            FROM
                u_dw_dim_tax.dim_driver_scd2
            ORDER BY
                driver_id,
                srart_dt
        )
        SELECT
            driver_id,
            driver_first_name,
            driver_last_name,
            birth_date,
            drive_licen,
            driver_status_id,
            status,
            status_desc,
            CASE
                WHEN end_dt IS NULL THEN
                    1
                ELSE
                    0
            END is_active,
            srart_dt ,
            end_dt
        FROM
            dim
        ;

    COMMIT;
    DELETE FROM u_dw_dim_tax.dim_driver_scd2 a
    WHERE
        EXISTS (
            SELECT
                *
            FROM
                u_dw_dim_tax.dim_driver_scd2
            WHERE
                    is_active = 1
                AND a.driver_id = driver_id
                AND a.valid_from < valid_from
        )
        AND a.is_active = 1;

    COMMIT;
    END load_dim_drv;

END load_all_driver;