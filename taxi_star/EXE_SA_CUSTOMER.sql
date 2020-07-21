

GRANT READ ON DIRECTORY ext_references TO u_dw_ext_app;
GRANT WRITE ON DIRECTORY ext_references TO u_dw_ext_app;
/*
create table ts_sa_app_data_01.sa_first_name
(
   FIRST_NAME      VARCHAR (20)
 , BIRTH_DATE      VARCHAR(20)
 , RATING          NUMBER(10,0)

)
organization external (
    type oracle_loader
    default directory ext_references
    access parameters 
    (RECORDS DELIMITED BY NEWLINE NOBADFILE NODISCARDFILE NOLOGFILE FIELDS TERMINATED BY ',' MISSING FIELD VALUES ARE NULL 
        ( 
            FIRST_NAME VARCHAR (20) 
            , BIRTH_DATE   VARCHAR(20)
            , RATING INTEGER EXTERNAL) 
        )
        location ('first_birthday_rating_1000.csv')
)
reject limit unlimited;

--SA_CUSTOMER_LAST_NAME
*/
create table ts_sa_app_data_01.sa_last_name
(
   LAST_NAME  VARCHAR (20)
)
organization external (
    type oracle_loader
    default directory ext_references
    access parameters 
    (RECORDS DELIMITED BY NEWLINE NOBADFILE NODISCARDFILE NOLOGFILE FIELDS TERMINATED BY ',' MISSING FIELD VALUES ARE NULL 
        ( 
            LAST_NAME VARCHAR (20) 
        ) 
    )
    location ('last_500.csv')
)
reject limit unlimited;

create table ts_sa_app_data_01.sa_person
(
   FIRST_NAME      VARCHAR(20)
 , BIRTH_DATE      VARCHAR(20)
 , GENDER          VARCHAR(20)
 , ZIP             VARCHAR(20)
 , CCNUMBER        NUMBER(10,0)
 , EMAIL           VARCHAR(100)
 , STATUS          VARCHAR(1)
 , RATING          NUMBER(10,0)

)
organization external (
    type oracle_loader
    default directory ext_references
    access parameters 
    (RECORDS DELIMITED BY NEWLINE NOBADFILE NODISCARDFILE NOLOGFILE FIELDS TERMINATED BY ',' MISSING FIELD VALUES ARE NULL 
        ( 
               FIRST_NAME      VARCHAR(20)
             , BIRTH_DATE      VARCHAR(20)
             , GENDER          VARCHAR(20)
             , ZIP             VARCHAR(20)
             , CCNUMBER        INTEGER EXTERNAL
             , EMAIL           VARCHAR(100)
             , STATUS          VARCHAR(1)
             , RATING          INTEGER EXTERNAL
        )
    )
    location ('first_birthday_gender_zip_ccnumber_email_yn_pick_1000.csv')
)
reject limit unlimited;



create table sa_customer as select 
        rownum CUSTOMER_ID
    ,   FIRST_NAME
    ,   LAST_NAME
    ,   TO_DATE(BIRTH_DATE,  'MM-DD-YYYY') BIRTH_DATE
    ,   RATING
FROM  ts_sa_app_data_01.sa_person , ts_sa_app_data_01.sa_last_name;


create table sa_driver as select 
        rownum DRIVER_ID
    ,   FIRST_NAME
    ,   LAST_NAME
    ,   TO_DATE(BIRTH_DATE,  'MM-DD-YYYY') BIRTH_DATE
    ,   ZIP DRIVE_LICEN
    ,   STATUS WORKING
FROM  ts_sa_app_data_01.sa_person , ts_sa_app_data_01.sa_last_name;