SET SERVEROUTPUT ON;

DROP TABLE u_dw_data.t_vehicle;
CREATE TABLE u_dw_data.t_vehicle (
    vehicle_id     NUMBER
        GENERATED ALWAYS AS IDENTITY,
    manuf_year     NUMBER(10, 0),
    manufacturer   VARCHAR2(20 BYTE),
    model_vhl      VARCHAR2(20 BYTE),
    milliage       NUMBER(20, 0),
    licence_plate  VARCHAR2(50 BYTE),
    insert_dt      TIMESTAMP,
    update_dt      TIMESTAMP
);
drop TRIGGER u_dw_data.insrt_vehic_trig;
create trigger u_dw_data.insrt_vehic_trig
    before insert 
    on  u_dw_data.t_vehicle 
    for each row
    begin 
        :new.insert_dt:=sysdate;
        end;
drop TRIGGER u_dw_data.update_vehic_trig;        
create trigger u_dw_data.update_vehic_trig
    before update 
    on  u_dw_data.t_vehicle 
    for each row
    begin 
        :new.update_dt:=sysdate;
        end;

CREATE INDEX u_dw_data.t_vehicle_idx ON
   u_dw_data.t_vehicle  (
       vehicle_id
    )
 TABLESPACE ts_dw_data;

CREATE OR REPLACE PROCEDURE ext_sa_t_vehicke IS
    TYPE t_sa_vehicle IS
        TABLE OF u_dw_ext_app.sa_vehicle%rowtype;
    var_t_sa_vehcl t_sa_vehicle := t_sa_vehicle();
    CURSOR cur_sa_veh IS
    SELECT DISTINCT
        *
    FROM
        u_dw_ext_app.sa_vehicle;
BEGIN
    EXECUTE IMMEDIATE 'delete from u_dw_data.t_vehicle';
    EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_vehicle MODIFY(vehicle_id Generated as Identity (START WITH 1))';
    OPEN cur_sa_veh;
    FETCH cur_sa_veh BULK COLLECT INTO var_t_sa_vehcl;
    CLOSE cur_sa_veh;
    FORALL i IN var_t_sa_vehcl.first..var_t_sa_vehcl.last
        INSERT INTO u_dw_data.t_vehicle (
            manuf_year,
            manufacturer,
            model_vhl,
            milliage,
            licence_plate
        ) VALUES (
            var_t_sa_vehcl(i).manuf_year,
            var_t_sa_vehcl(i).manufacturer,
            var_t_sa_vehcl(i).model_vhl,
            var_t_sa_vehcl(i).milliage,
            var_t_sa_vehcl(i).licence_plate
        );
    COMMIT;
END ext_sa_t_vehicke;

EXEC ext_sa_t_vehicke;

SELECT * FROM  u_dw_data.t_vehicle;
