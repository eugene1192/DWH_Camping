SET SERVEROUTPUT ON;

drop table U_DW_EXT_APP.t_customer;
create table u_dw_data.t_customer 
(
     customer_id  number GENERATED ALWAYS AS IDENTITY
    , FIRST_NAME VARCHAR2(20 BYTE)
    , LAST_NAME VARCHAR2(20 BYTE)
    , BIRTH_DATE DATE
    , RATING NUMBER(10,0)
);


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
