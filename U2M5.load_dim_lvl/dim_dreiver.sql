--SET SERVEROUTPUT ON
--alter session set nls_date_format = 'dd-mm-yyyy HH24:MI:SS';
CREATE OR REPLACE PROCEDURE load_dim_drv IS
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
            srart_dt
      --  , Lead (srart_dt) Over(Partition by driver_id Order by driver_id , dim.srart_dt )  end_dt
            ,
            end_dt
        FROM
            dim;

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

--exec load_dim_drv;
SELECT
    *
FROM
    u_dw_dim_tax.dim_driver_scd2;

/*drop table u_dw_dim_tax.dim_driver_scd2;
ALTER TABLE u_dw_dim_tax.dim_driver_scd2 
        MODIFY(dim_drv_id Generated as Identity (START WITH 1));
CREATE TABLE u_dw_dim_tax.dim_driver_scd2 (
    dim_drv_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    driver_id          NUMBER,
    driver_first_name   VARCHAR(20),
    driver_last_name    VARCHAR(20),
    birth_date          DATE,
    drive_licen         VARCHAR(20),
    driver_status_id    NUMBER,
    status              VARCHAR(3),
    status_desc         VARCHAR(50),
    is_active           NUMBER default 1,
    valid_from          date,
    valid_to            date
);
*/
