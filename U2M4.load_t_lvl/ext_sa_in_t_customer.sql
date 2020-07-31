SET SERVEROUTPUT ON;

DROP TABLE u_dw_data.t_customer;

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

drop TRIGGER u_dw_data.insrt_cust_trig;
create trigger u_dw_data.insrt_cust_trig
    before insert 
    on  u_dw_data.t_customer 
    for each row
    begin 
        :new.insert_dt:=sysdate;
        end;
        
drop TRIGGER u_dw_data.update_cust_trig;        
create trigger u_dw_data.update_cust_trig
    before update 
    on  u_dw_data.t_customer 
    for each row
    begin 
        :new.update_dt:=sysdate;
        end;


CREATE INDEX t_customer_idx ON
   u_dw_data.t_customer  (
       customer_id
    )
 TABLESPACE ts_dw_data;

CREATE OR REPLACE PROCEDURE ext_sa_t_customer IS
    TYPE t_sa_cust IS
        TABLE OF u_dw_ext_app.sa_customer%rowtype;
    var_t_sa_cust  t_sa_cust := t_sa_cust();
    TYPE customer_t IS REF CURSOR RETURN u_dw_ext_app.sa_customer%rowtype;
    c_customer     customer_t;
BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.t_customer';
    EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_customer MODIFY(customer_id Generated as Identity (START WITH 1))';

    OPEN c_customer FOR SELECT DISTINCT
                            *
                        FROM
                            u_dw_ext_app.sa_customer;
    FETCH c_customer BULK COLLECT INTO var_t_sa_cust;
    CLOSE c_customer;
    FORALL i IN var_t_sa_cust.first..var_t_sa_cust.last
        INSERT INTO u_dw_data.t_customer (
            first_name,
            last_name,
            birth_date,
            rating
        ) VALUES (
            var_t_sa_cust(i).first_name,
            var_t_sa_cust(i).last_name,
            var_t_sa_cust(i).birth_date,
            var_t_sa_cust(i).rating
        );
    COMMIT;
END ext_sa_t_customer;

EXEC ext_sa_t_customer;

select * from u_dw_data.t_customer;
