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

 
--------------------------------------------------------------------------------
 --STAR � Level

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
 ------------------------------------------------------------------------------- 
 
 CREATE TABLESPACE ts_dim_tax_01
DATAFILE '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/ts_dim_tax_01.dat'
SIZE 500M
 AUTOEXTEND ON NEXT 200M
 SEGMENT SPACE MANAGEMENT AUTO;
 
 --CREATE USER 
 ALTER USER
 u_dw_dim_tax
  IDENTIFIED BY "1"
    DEFAULT TABLESPACE ts_dim_tax_01 QUOTA unlimited ON ts_dim_tax_01;
GRANT CONNECT,RESOURCE, CREATE VIEW TO u_dw_dim_tax;

grant CONNECT,CREATE PUBLIC SYNONYM,DROP PUBLIC SYNONYM,RESOURCE to u_dw_dim_tax;



--drop table "u_dw_dim_tax"."dim_location" cascade constraints;

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
/* Table: "dim_trip"                                            */
/*==============================================================*/
CREATE TABLE u_dw_dim_tax.dim_trip
(
    trip_id     INT NOT NULL,
    sa_trip_id  INT,
    tr_distance DECIMAL(10, 3),
    tr_time TIMESTAMP,
    tr_rating_num INT,
    status_trip VARCHAR(2),
    coast DECIMAL(10, 3),
    pay_metod VARCHAR(50),
    currency VARCHAR(50),
    incert_dt TIMESTAMP,
    update_dt TIMESTAMP 
    CONSTRAINT pk_dim_trip PRIMARY KEY(trip_id) );


--drop table "u_dw_dim_tax"."dim_driver" cascade constraints;

/*==============================================================*/
/* Table: "dim_driver"                                          */
/*==============================================================*/
create table u_dw_dim_tax.dim_driver 
(
   driver_id                 int      not null,
   first_name         VARCHAR(120),
   last_name          VARCHAR(120),
   dirth_date         DATE,
   driv_lic_num       VARCHAR(120),
   age                INT,
   driv_rating        VARCHAR(50),
   driv_rating_num    int,
   incert_dt			TIMESTAMP,
   update_dt          TIMESTAMP
   constraint PK_DIM_DRIVER primary key ("id")
);


--drop table "u_dw_dim_tax"."dim_date" cascade constraints;

/*==============================================================*/
/* Table: "dim_date"                                            */
/*==============================================================*/
create table u_dw_dim_tax.dim_date
(
   DATE_ID              NUMBER               not null,
   DAY_VCHAR_ID         DATE,
   DAY_NAME             VARCHAR2(36 BYTE),
   DAY_NUMBER_IN_WEEK   VARCHAR2(1 BYTE),
   DAY_NUMBER_IN_MONTH  VARCHAR2(2 BYTE),
   DAY_NUMBER_IN_YEAR   VARCHAR2(3 BYTE),
   WEEK_ID              NUMBER,
   CALENDAR_WEEK_NUMBER VARCHAR2(1 BYTE),
   WEEK_ENDING_DATE     DATE,
   MONTH_ID             NUMBER,
   CALENDAR_MONTH_NUMBER VARCHAR2(2 BYTE),
   DAYS_IN_CAL_MONTH    VARCHAR2(2 BYTE),
   END_OF_CAL_MONTH     DATE,
   CALENDAR_MONTH_NAME  VARCHAR2(36 BYTE),
   QUARTER_ID           NUMBER,
   DAYS_IN_CAL_QUARTER  NUMBER,
   BEG_OF_CAL_QUARTER   DATE,
   END_OF_CAL_QUARTER   DATE,
   CALENDAR_QUARTER_NUMBER VARCHAR2(1 BYTE),
   YEAR_ID              NUMBER,
   CALENDAR_YEAR        VARCHAR2(4 BYTE),
   DAYS_IN_CAL_YEAR     NUMBER,
   BEG_OF_CAL_YEAR      DATE,
   END_OF_CAL_YEAR      DATE,
   constraint PK_DIM_DATE primary key (DATE_ID)
);


--drop table "u_dw_dim_tax"."dim_vehicle" cascade constraints;

/*==============================================================*/
/* Table: "dim_vehicle"                                         */
/*==============================================================*/
create table u_dw_dim_tax.dim_vehicle 
(
   vehicle_id         int                  not null,
   licens_plate       varchar(120),
   car_model          VARCHAR(120),
   manuf_year         int,
   total_miliage      INT,
   incert_dt		  TIMESTAMP,
   update_dt          TIMESTAMP
   constraint PK_DIM_VEHICLE primary key ("id")
);

--drop table u_dw_dim_tax.dim_vehicle
/*
alter table u_dw_dim_tax.fct_taxi_trip
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_TRIP;

alter table "u_dw_dim_tax"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_CUST;

alter table "u_dw_references"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_DATE;

alter table "u_dw_references"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_DRIV;

alter table "u_dw_references"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_INVO;

alter table "u_dw_references"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_LOCA;

alter table "u_dw_references"."fct_taxi_trip"
   drop constraint FK_FCT_TAXI_REFERENCE_DIM_VEHI;

alter table "u_dw_references"."fct_taxi_trip"
   drop unique () cascade;

drop table u_dw_fct_tax.fct_taxi_trip cascade constraints;
*/
/*==============================================================*/
/* Table: "fct_taxi_trip"         u_dw_fct_tax                              */
/*=============================== ===============================*/

create table u_dw_fct_tax.fct_taxi_trip
(
   id_dim_car         int,
   id_dim_customer    int,
   id_dim_date        NUMBER,
   id_dim_driver     int,
   id_dim_invoice    INT,
   id_dim_location    int,
   id_dim_trip        int,
   fct_tot_order_ad   VARCHAR(20),
   fct_tot_mill_ad    NUMBER,
   fct_tot_cust_ad    NUMBER,
   fct_percnt_order_cancel_nad VARCHAR(20),
   fct_percnt_order_finsh_nad VARCHAR(20)
)
PARTITION BY HASH (id_dim_car, id_dim_customer,id_dim_date, id_dim_driver, 
id_dim_invoice, id_dim_location ,id_dim_trip)
   PARTITIONS 4 ;
 
 --drop table u_dw_fct_tax.fct_taxi_trip;
/*
alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_TRIP foreign key ("id_dim_car")
      references u_dw_dim_tax.dim_trip ("id") ;
      
 select * from u_dw_fct_tax.fct_taxi_trip;     

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_CUST foreign key ("id_dim_customer")
      references u_dw_dim_tax.dim_customer ("id");

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_DATE foreign key ("id_dim_date")
      references u_dw_dim_tax.dim_date (DATE_ID);

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_DRIV foreign key ("id_dim_driver")
      references u_dw_dim_tax.dim_driver ("id");

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_INVO foreign key ("id_dim_invoice")
      references u_dw_dim_tax.dim_invoice ("id");

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_LOCA foreign key ("id_dim_location")
      references "u_dw_dim_tax"."dim_location" ("id");

alter table u_dw_fct_tax.fct_taxi_trip
   add constraint FK_FCT_TAXI_REFERENCE_DIM_VEHI foreign key ("id_dim_trip")
      references u_dw_dim_tax.dim_vehicle ("id");
*/
