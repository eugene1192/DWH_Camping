/* not used
CREATE SEQUENCE u_dw_data.t_driver_seq
  MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  CACHE 20;
*/
-- create  t_driver  natural key desc *****************************************
DROP TABLE u_dw_data.t_driver;
CREATE TABLE u_dw_data.t_driver (
        --driver_id number DEFAULT U_DW_EXT_APP.t_driver_seq.nextval,
    driver_id NUMBER GENERATED AS IDENTITY,
    driver_first_name  VARCHAR(20),
    driver_last_name   VARCHAR(20),
    birth_date         DATE,
    drive_licen        VARCHAR(20),
    insert_dt      TIMESTAMP,
    update_dt      TIMESTAMP
);

drop TRIGGER u_dw_data.insrt_driver_trig;
create trigger u_dw_data.insrt_driver_trig
    before insert 
    on  u_dw_data.t_driver 
    for each row
    begin 
        :new.insert_dt:=sysdate;
        end;
        
drop TRIGGER u_dw_data.update_driver_trig;        
create trigger u_dw_data.update_driver_trig
    before update 
    on  u_dw_data.t_driver 
    for each row
    begin 
        :new.update_dt:=sysdate;
        end;

CREATE INDEX t_driver_idx ON
   u_dw_data.t_driver  (
       driver_id
    )
 TABLESPACE ts_dw_data;
 
--select* from u_dw_data.t_driver

-- create t_driver status  table**********************************************
drop table u_dw_data.t_driver_status;
CREATE TABLE u_dw_data.t_driver_status (
    driver_status_id  NUMBER
        GENERATED AS IDENTITY,
    status            VARCHAR(3),
    status_desc       VARCHAR(50)
);



-- create t_driver_link table  *************************************************
drop table u_dw_data.t_driver_link ;
CREATE TABLE u_dw_data.t_driver_link (
    driver_id         NUMBER,
    driver_status_id  NUMBER,
    srart_dt          DATE
);




CREATE OR REPLACE PROCEDURE ext_sa_t_driver IS
    drv u_dw_ext_app.sa_driver%rowtype;
    CURSOR c_ex_drv IS
    SELECT * FROM u_dw_ext_app.sa_driver;
    
  --  CURSOR c_driv_link
  --  select driver_id
BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.T_DRIVER';
    EXECUTE IMMEDIATE 'truncate table u_dw_data.t_driver_status';
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
    
    
    INSERT INTO u_dw_data.t_driver_STATUS ( status , status_desc )
        SELECT DISTINCT
            status,
            CASE
                WHEN upper(status) = 'Y'       THEN
                    'Driver online. Ready to get order'
                WHEN upper(status) = 'N'       THEN
                    'Driver not working. Orders are not valid'
                ELSE
                    'Unknown status'
            END
        FROM
            u_dw_ext_app.sa_driver;
END ext_sa_t_driver;

CREATE OR REPLACE PROCEDURE load_link_driv_hist IS
BEGIN
    INSERT INTO u_dw_data.t_driver_link
        SELECT
            td.driver_id,
           dst.driver_status_id,
             --sat.status,
                sat.date_id
   -- max(sat.date_id)
   -- rank() Over(PARTITION BY sat.status order by sat.date_id ) max 
            FROM
                 u_dw_ext_app.sa_trip sat
            JOIN u_dw_data.t_driver  td 
            ON td.driver_first_name = sat.driver_first_name
                  AND td.driver_last_name = sat.driver_last_name
                  AND td.drive_licen = sat.drive_licen
           JOIN u_dw_data.t_driver_status dst 
           ON dst.status = sat.status     
             --   where td.driver_id=3012
        ORDER BY
            td.driver_id,
            sat.date_id;

END load_link_driv_hist;


EXEC ext_sa_t_driver;
exec load_link_driv_hist;
select * from u_dw_data.t_driver;
select * from u_dw_data.t_driver_link;
select * from u_dw_data.t_driver_STATUS ;


SELECT * FROM u_dw_data.t_driver d
    join u_dw_data.t_driver_link dl on dl.driver_id=d.driver_id
    join u_dw_data.t_driver_STATUS ds on ds.driver_status_id=dl.driver_status_id;