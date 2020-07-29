
CREATE SEQUENCE U_DW_EXT_APP.t_driver_seq
  MINVALUE 1
  START WITH 1
  INCREMENT BY 1
  CACHE 20;

drop table  U_DW_EXT_APP.t_driver ;
truncate table U_DW_EXT_APP.t_driver; 
create table U_DW_EXT_APP.t_driver
    (
        --driver_id number DEFAULT U_DW_EXT_APP.t_driver_seq.nextval,
        driver_id number GENERATED ALWAYS AS IDENTITY,
        driver_first_name Varchar(20),
        driver_last_name Varchar(20),
        birth_date DATE,
        drive_licen Varchar(20),
        status Varchar(1)
    );
    
    

create or replace procedure ext_sa_t_driver is
         drv U_DW_EXT_APP.sa_driver%ROWTYPE;      
         CURSOR c_ex_drv is select * from U_DW_EXT_APP.sa_driver;
begin
        EXECUTE IMMEDIATE 'delete from U_DW_EXT_APP.T_DRIVER';
        open c_ex_drv;
            loop
                fetch c_ex_drv into drv;
                exit when c_ex_drv%NOTFOUND;
                        insert into U_DW_EXT_APP.t_driver
                (
                        driver_first_name,
                        driver_last_name ,
                        birth_date ,
                        drive_licen ,
                        status
                )
                VALUES 
                (
                
                        drv.FIRST_NAME, 
                        drv.LAST_NAME ,
                        drv.BIRTH_DATE ,
                        drv.DRIVE_LICEN ,
                        drv.STATUS
                ); 
            end loop; 
         commit;
end ext_sa_t_driver;

exec ext_sa_t_driver;

select * from U_DW_EXT_APP.t_driver