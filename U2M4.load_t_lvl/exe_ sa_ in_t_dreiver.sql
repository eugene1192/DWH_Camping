/*
CREATE SEQUENCE u_dw_data.t_driver_seq
  MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
*/

DROP TABLE u_dw_data.t_driver;

CREATE TABLE u_dw_data.t_driver (
        --driver_id number DEFAULT U_DW_EXT_APP.t_driver_seq.nextval,
    driver_id NUMBER GENERATED ALWAYS AS IDENTITY,
    driver_first_name  VARCHAR(20),
    driver_last_name   VARCHAR(20),
    birth_date         DATE,
    drive_licen        VARCHAR(20),
    status             VARCHAR(1)
);

CREATE INDEX t_driver_idx ON
   u_dw_data.t_driver  (
       driver_id
    )
 TABLESPACE ts_dw_data;

CREATE OR REPLACE PROCEDURE ext_sa_t_driver IS
    drv u_dw_ext_app.sa_driver%rowtype;
    CURSOR c_ex_drv IS
    SELECT
        *
    FROM
        u_dw_ext_app.sa_driver;

BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.T_DRIVER';
    OPEN c_ex_drv;
    LOOP
        FETCH c_ex_drv INTO drv;
        EXIT WHEN c_ex_drv%notfound;
        INSERT INTO u_dw_data.t_driver (
            driver_first_name,
            driver_last_name,
            birth_date,
            drive_licen,
            status
        ) VALUES (
            drv.first_name,
            drv.last_name,
            drv.birth_date,
            drv.drive_licen,
            drv.status
        );

    END LOOP;
    COMMIT;
END ext_sa_t_driver;

EXEC ext_sa_t_driver;

SELECT
    *
FROM
    u_dw_data.t_driver