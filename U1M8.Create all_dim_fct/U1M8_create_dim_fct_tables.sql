--insert all data from .csv
--create sa_last_name like buffer table  
DROP TABLE sa_last_name;
CREATE TABLE sa_last_name (
    last_name VARCHAR(20)
);
--SELECT * from sa_last_name;
--insert all data from .csv
--drop table sa_person;
--create sa_last_name like buffer table 
CREATE TABLE sa_person (
    first_name  VARCHAR(20),
    birth_date  VARCHAR(20),
    gender      VARCHAR(20),
    zip         VARCHAR(20),
    ccnumber    NUMBER(20, 0),
    email       VARCHAR(100),
    status      VARCHAR(1),
    rating      NUMBER(10, 0)
)--drop table sa_person_v2;
--insert all data from .csv
CREATE TABLE sa_person_v2 (
    first_name  VARCHAR(20),
    birth_date  VARCHAR(20),
    gender      VARCHAR(20),
    zip         VARCHAR(20),
    ccnumber    NUMBER(20, 0),
    email       VARCHAR(100),
    status      VARCHAR(1),
    rating      NUMBER(10, 0)
)    
--drop table sa_vehicle;
--insert all data from .csv
 CREATE TABLE sa_vehicle (
    year_1        NUMBER(10, 0),
    year_2        NUMBER(10, 0),
    manufacturer  VARCHAR(20),
    model_vhl     VARCHAR(20),
    milliage      NUMBER(20, 0)
)
-- create text level tables----------------------------


--drop  TABLESPACE TS_REFERENCES_EXT_DATA_01
--INCLUDING  CONTENTS;
--Storage Level
CREATE TABLESPACE ts_sa_app_data
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/ts_sa_app_data_1.dat'
SIZE 1000M
 AUTOEXTEND ON NEXT 250M
 SEGMENT SPACE MANAGEMENT AUTO;
--drop user u_dw_ext_app
 alter USER u_dw_ext_app
  IDENTIFIED BY "1"
    DEFAULT TABLESPACE ts_sa_app_data QUOTA unlimited ON ts_sa_app_data;
GRANT CONNECT,RESOURCE, CREATE VIEW TO u_dw_ext_app;


CREATE TABLE u_dw_ext_app.sa_vehicle (
    manuf_year     NUMBER(10, 0),
    manufacturer   VARCHAR(20),
    model_vhl      VARCHAR(20),
    milliage       NUMBER(20, 0),
    licence_plate  VARCHAR(50)
);
    
--CREATE TABLE SA_CUSTOMERS IN 314000 ROWS
--drop table u_dw_ext_app.sa_customer;
CREATE TABLE u_dw_ext_app.sa_customer
    AS
        SELECT DISTINCT
            first_name,
            last_name,
            to_date(birth_date, 'MM-DD-YYYY') birth_date,
            rating 
   --into u_dw_ext_app.sa_customer
                        FROM
            sa_person_v2,
            sa_last_name;

CREATE INDEX sa_customer_idx ON
    u_dw_ext_app.sa_customer (
        first_name,
        last_name,
        birth_date
    )
        TABLESPACE ts_sa_app_data;

--CREATE TABLE SA_DRIVER IN 314000 ROWS
--DROP TABLE u_dw_ext_app.sa_driver;
CREATE TABLE u_dw_ext_app.sa_driver
AS
    SELECT DISTINCT
        first_name,
        last_name,
        to_date(birth_date, 'MM-DD-YYYY')      birth_date,
        zip                                    drive_licen,
        status 
--    into u_dw_ext_app.sa_driver
                             FROM
        sa_person_v2,
        sa_last_name;
        
--DROP TABLE  sa_trip CASCADE CONSTRAINTS;
CREATE INDEX sa_driver_idx ON
    u_dw_ext_app.sa_driver (
        first_name,
        last_name,
        birth_date,
        drive_licen
    )
        TABLESPACE ts_sa_app_data;
        
DROP TABLE u_dw_ext_app.sa_trip CASCADE CONSTRAINTS;

/*==============================================================*/
/* Table: SA_TRIP                                               */
/*==============================================================*/
drop table u_dw_ext_app.sa_trip;
CREATE TABLE u_dw_ext_app.sa_trip (
    trip_id               INT NOT NULL,
    date_id               DATE,
    driver_first_name     VARCHAR(20),
    driver_last_name      VARCHAR(20),
    drive_licen           VARCHAR(20),
    customer_first_name   VARCHAR(20),
    customer_last_name    VARCHAR(20),
    customer_bth_date     DATE,
    vehicle_manufacturer  VARCHAR(20),
    vehicle_model         VARCHAR(20),
    vin_code              VARCHAR(20),
    country               VARCHAR(20),
    distance              DECIMAL(10, 1),
    distance_measure      VARCHAR(20),
    raiting               DECIMAL(3, 1),
    status                VARCHAR(1),
    coast                 DECIMAL(10, 2),
    currency              VARCHAR(20)
    --CONSTRAINT pk_sa_trip PRIMARY KEY ( trip_id )
);
  
CREATE INDEX sa_trip_idx ON
   u_dw_ext_app.sa_trip  (
       trip_id
    )
 TABLESPACE ts_sa_app_data;
--*****************************************************************************
--------------------------------------------------------------------------------
--Level loading
select * from v$DATABASE;
drop TABLESPACE TS_DW_DATA INCLUDING CONTENTS;
CREATE TABLESPACE ts_dw_data
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/ts_dw_data_2.dat'
SIZE 1000M
 AUTOEXTEND ON NEXT 250M
 SEGMENT SPACE MANAGEMENT AUTO;

--drop USER u_dw_data;
 create USER u_dw_data
  IDENTIFIED BY "1"
   DEFAULT TABLESPACE ts_dw_data QUOTA unlimited  ON ts_dw_data;
GRANT CONNECT,RESOURCE, CREATE VIEW TO u_dw_data;

--------------------------------------------------------------------------------
--******************************************************************************
--Create table u_dw_data.t_vehicle
--Create trigger u_dw_data.insrt_vehic_trig
--Create trigger u_dw_data.update_vehic_trig
--Create index u_dw_data.t_vehicle_idx
--******************************************************************************
--DROP TABLE u_dw_data.t_vehicle;
CREATE TABLE u_dw_data.t_vehicle (
    vehicle_id     NUMBER
        GENERATED ALWAYS AS IDENTITY,
    manuf_year     NUMBER(10, 0),
    manufacturer   VARCHAR2(20 BYTE),
    model_vhl      VARCHAR2(20 BYTE),
    milliage       NUMBER(20, 1),
    licence_plate  VARCHAR2(50 BYTE),
    insert_dt      TIMESTAMP,
    update_dt      TIMESTAMP
);

--DROP TRIGGER u_dw_data.insrt_vehic_trig;
CREATE TRIGGER u_dw_data.insrt_vehic_trig BEFORE
    INSERT ON u_dw_data.t_vehicle
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

--DROP TRIGGER u_dw_data.update_vehic_trig;

CREATE TRIGGER u_dw_data.update_vehic_trig BEFORE
    UPDATE ON u_dw_data.t_vehicle
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

CREATE INDEX u_dw_data.t_vehicle_idx ON
    u_dw_data.t_vehicle (
        vehicle_id
    )
        TABLESPACE ts_dw_data;
--******************************************************************************
-- Crate table u_dw_data.t_trip
-- Create trigger u_dw_data.update_trip_trig
--******************************************************************************
-- DROP TABLE u_dw_data.t_trip;
CREATE TABLE u_dw_data.t_trip (
    trip_id           NUMBER
        GENERATED ALWAYS AS IDENTITY,
    sa_trip_id        INT NOT NULL,
    date_id           DATE,
    driver_id         NUMBER,
    customer_id       NUMBER,
    vehicle_id        NUMBER,
    country_id        VARCHAR(20),
    distance          DECIMAL(10, 1),
    distance_measure  VARCHAR(20),
    raiting           DECIMAL(3, 1),
    status            VARCHAR(1),
    coast             DECIMAL(10, 2),
    currency          VARCHAR(20),
    insert_dt         TIMESTAMP DEFAULT sysdate,
    update_dt         TIMESTAMP
   
);
-- BEFORE INSERT TRIGGER NOT USED
/*
drop TRIGGER u_dw_data.insrt_trip_trig;
create trigger u_dw_data.insrt_trip_trig
    before insert 
    on  u_dw_data.t_trip 
    for each row
    begin 
        :new.insert_dt:=sysdate;
        end;
 */ 
--DROP TRIGGER u_dw_data.update_trip_trig;

CREATE TRIGGER u_dw_data.update_trip_trig BEFORE
    UPDATE ON u_dw_data.t_trip
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;
--******************************************************************************
--Create table u_dw_data.t_customer
--Create trigger u_dw_data.insrt_cust_trig
--Create trigger u_dw_data.update_cust_trig
--Create index u_dw_data.t_customer_idx
--******************************************************************************
--DROP TABLE u_dw_data.t_customer;

CREATE TABLE u_dw_data.t_customer (
    customer_id  NUMBER
        GENERATED ALWAYS AS IDENTITY,
    first_name   VARCHAR2(20 BYTE),
    last_name    VARCHAR2(20 BYTE),
    birth_date   DATE,
    rating       NUMBER(10, 0),
    insert_dt    TIMESTAMP,
    update_dt    TIMESTAMP
);

--DROP TRIGGER u_dw_data.insrt_cust_trig;

CREATE TRIGGER u_dw_data.insrt_cust_trig BEFORE
    INSERT ON u_dw_data.t_customer
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

DROP TRIGGER u_dw_data.update_cust_trig;

CREATE TRIGGER u_dw_data.update_cust_trig BEFORE
    UPDATE ON u_dw_data.t_customer
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

CREATE INDEX t_customer_idx ON
    u_dw_data.t_customer (
        customer_id
    )
        TABLESPACE ts_dw_data;
--******************************************************************************
----Create table u_dw_data.t_driver
--Create trigger u_dw_data.insrt_driver_trig
--Create trigger u_dw_data.update_driver_trig
--Create index u_dw_data.t_driver_idx
--******************************************************************************
--DROP TABLE u_dw_data.t_driver;
CREATE TABLE u_dw_data.t_driver (
        --driver_id number DEFAULT U_DW_EXT_APP.t_driver_seq.nextval,
    driver_id          NUMBER
        GENERATED AS IDENTITY,
    driver_first_name  VARCHAR(20),
    driver_last_name   VARCHAR(20),
    birth_date         DATE,
    drive_licen        VARCHAR(20),
    insert_dt          TIMESTAMP,
    update_dt          TIMESTAMP
);

--DROP TRIGGER u_dw_data.insrt_driver_trig;

CREATE TRIGGER u_dw_data.insrt_driver_trig BEFORE
    INSERT ON u_dw_data.t_driver
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

--DROP TRIGGER u_dw_data.update_driver_trig;

CREATE TRIGGER u_dw_data.update_driver_trig BEFORE
    UPDATE ON u_dw_data.t_driver
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

CREATE INDEX t_driver_idx ON
    u_dw_data.t_driver (
        driver_id
    )
        TABLESPACE ts_dw_data;
 
-- create t_driver status  table**********************************************
DROP TABLE u_dw_data.t_driver_status;

CREATE TABLE u_dw_data.t_driver_status (
    driver_status_id  NUMBER
        GENERATED AS IDENTITY,
    status            VARCHAR(3),
    status_desc       VARCHAR(50)
);


-- create t_driver_link table  *************************************************
DROP TABLE u_dw_data.t_driver_link;

CREATE TABLE u_dw_data.t_driver_link (
    driver_id         NUMBER,
    driver_status_id  NUMBER,
    srart_dt          DATE
   -- end_date          DATE
);
--******************************************************************************
--------------------------------------------------------------------------------
 

CREATE TABLESPACE ts_fct_tax_month_01
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/ts_fct_tax_month_01.dat'
SIZE 500M
 AUTOEXTEND ON NEXT 200M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 --CREATE USER 
 ALTER USER
    u_dw_fct_tax
  IDENTIFIED BY "1"
    DEFAULT TABLESPACE ts_fct_tax_month_01 QUOTA unlimited ON ts_fct_tax_month_01;
grant CONNECT,CREATE PUBLIC SYNONYM,DROP PUBLIC SYNONYM,RESOURCE to u_dw_fct_tax;


--drop table u_dw_fct_tax.fct_driv_month; 
  CREATE TABLE u_dw_fct_tax.fct_driv_month (
    dim_month_id       NUMBER(*, 0),
    dim_drv_id         NUMBER,
    tot_distane        NUMBER,
    distance_measure   VARCHAR2(20 BYTE),
    cnt_finish_orders  NUMBER,
    cnt_cancel_orders  NUMBER,
    total_orders       NUMBER,
    avg_raiting        NUMBER,
    percent_finished   VARCHAR2(42 BYTE),
    percent_canceled   VARCHAR2(42 BYTE),
    total_coast        NUMBER,
    currency           VARCHAR2(20 BYTE),
    dim_geo_id         VARCHAR2(40 BYTE),
    insert_dt      TIMESTAMP,
    update_dt      TIMESTAMP
)

TABLESPACE ts_fct_tax_month_01;

CREATE TRIGGER u_dw_fct_tax.fct_driv_month_insert_trig BEFORE
    INSERT ON u_dw_fct_tax.fct_driv_month
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

--DROP TRIGGER  u_dw_fct_tax.fct_driv_month_update_trig;

CREATE TRIGGER u_dw_fct_tax.fct_driv_month_update_trig BEFORE
    UPDATE ON u_dw_fct_tax.fct_driv_month
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

 ------------------------------------------------------------------------------- 
 
 CREATE TABLESPACE ts_dim_tax_01
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/ts_dim_tax_01.dat'
SIZE 1000M
 AUTOEXTEND ON NEXT 200M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 --CREATE USER 
 ALTER USER
 u_dw_dim_tax
  IDENTIFIED BY "1"
    DEFAULT TABLESPACE ts_dim_tax_01 QUOTA unlimited ON ts_dim_tax_01;
GRANT CONNECT,RESOURCE, CREATE VIEW TO u_dw_dim_tax;

grant CONNECT,CREATE PUBLIC SYNONYM,DROP PUBLIC SYNONYM,RESOURCE to u_dw_dim_tax;


/*==============================================================*/
/* Table: "dim_location"                                        */
/*==============================================================*/
--DROP TABLE u_dw_dim_tax.dim_geo_obj_scd;
CONNECT pdbadm_evrublevskiy / adm08#evrublevskiy

CREATE TABLE u_dw_dim_tax.dim_geo_obj_scd (
    dim_geo_id              VARCHAR2(40),
    geo_code                NVARCHAR2(10),
    obj_geo_sys_id          NUMBER,
    cnt_child_geo_sys       NUMBER,
    geo_system_id           NUMBER,
    geo_system_code         NVARCHAR2(30),
    geo_system_desc         NVARCHAR2(100),
    obj_geo_parts_id        NUMBER,
    cnt_child_geo_parts     NUMBER,
    part_id                 NUMBER,
    part_code               NVARCHAR2(20),
    part_desc               NVARCHAR2(100),
    obj_geo_regions_id      NUMBER,
    cnt_child_geo_regions   NUMBER,
    region_id               NUMBER,
    region_code             NVARCHAR2(30),
    region_desc             NVARCHAR2(100),
    obj_geo_country_id      NUMBER,
    country_id              NUMBER,
    country_desc            NVARCHAR2(100),
    country_code_a2         NVARCHAR2(10),
    country_code_a3         NVARCHAR2(20),
    obj_cntr_group_systems  NUMBER,
    grp_system_id           NUMBER,
    grp_system_code         NVARCHAR2(20),
    grp_system_desc         NVARCHAR2(100),
    obj_cntr_groups         NUMBER,
    group_id                NUMBER,
    group_code              NVARCHAR2(20),
    group_desc              NVARCHAR2(100),
    obj_cntr_sub_groups     NUMBER,
    sub_group_id            NUMBER,
    sub_group_code          NVARCHAR2(20),
    sub_group_desc          NVARCHAR2(100)
);
--drop table "u_dw_dim_tax"."dim_trip" cascade constraints;


/*==============================================================*/
/* Table: "dim_driver"                                          */
/*==============================================================*/
--drop table u_dw_dim_tax.dim_driver_scd2;
--ALTER TABLE u_dw_dim_tax.dim_driver_scd2 
--        MODIFY(dim_drv_id Generated as Identity (START WITH 1));
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
    valid_to            date,
    insert_dt         TIMESTAMP DEFAULT sysdate
);


/*==============================================================*/
/* Table: "dim_date"                                            */
/*==============================================================*/
  CREATE TABLE u_dw_dim_tax.dim_date 
   (	date_id NUMBER(*,0), 
	day_vchar_id DATE, 
	day_name VARCHAR2(36 BYTE), 
	day_number_in_week VARCHAR2(1 BYTE), 
	day_number_in_month VARCHAR2(2 BYTE), 
	day_number_in_year VARCHAR2(3 BYTE), 
	week_id NUMBER(*,0), 
	beg_week_date DATE, 
	end_week_date DATE, 
	calendar_week_number VARCHAR2(1 BYTE), 
	month_id NUMBER(*,0), 
	calendar_month_name VARCHAR2(36 BYTE), 
	calendar_month_number VARCHAR2(2 BYTE), 
	days_in_cal_month VARCHAR2(2 BYTE), 
	beg_of_cal_month DATE, 
	end_of_cal_month DATE, 
	quarter_id NUMBER(*,0), 
	calendar_quarter_number VARCHAR2(1 BYTE), 
	days_in_cal_quarter NUMBER, 
	beg_of_cal_quarter DATE, 
	end_of_cal_quarter DATE, 
	year_id NUMBER(*,0), 
	calendar_year VARCHAR2(4 BYTE), 
	days_in_cal_year NUMBER, 
	beg_of_cal_year DATE, 
	end_of_cal_year DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE ts_dim_tax_01 ;

/*==============================================================*/
/* Table: "dim_vehicle"                                         */
/*==============================================================*/
--DROP TABLE u_dw_dim_tax.dim_vehicle_scd;

CREATE TABLE u_dw_dim_tax.dim_vehicle_scd (
    vehicle_id     NUMBER
       ,
    manuf_year     NUMBER(10, 0),
    manufacturer   VARCHAR2(20 BYTE),
    model_vhl      VARCHAR2(20 BYTE),
    milliage       NUMBER(20, 1),
    licence_plate  VARCHAR2(50 BYTE),
    insert_dt      TIMESTAMP,
    update_dt      TIMESTAMP
);

--DROP TRIGGER u_dw_dim_tax.insrt_vehic_trig;

CREATE TRIGGER u_dw_dim_tax.insrt_vehic_trig BEFORE
    INSERT ON u_dw_dim_tax.dim_vehicle_scd
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

--DROP TRIGGER u_dw_dim_tax.update_vehic_trig;

CREATE TRIGGER u_dw_dim_tax.update_vehic_trig BEFORE
    UPDATE ON u_dw_dim_tax.dim_vehicle_scd
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;

/*==============================================================*/
/* Table: "fct_taxi_trip"         u_dw_fct_tax                              */
/*=============================== ===============================*/


 
 