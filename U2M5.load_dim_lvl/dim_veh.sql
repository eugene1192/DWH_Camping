
CREATE OR REPLACE PROCEDURE t_dim_vehicle IS

    cur_id         NUMBER;
    var_cur        SYS_REFCURSOR;
    row_cnt        NUMBER;
    TYPE t_vehicle IS
        TABLE OF u_dw_data.t_vehicle%rowtype;
    var_t_vehcl    t_vehicle := t_vehicle();
    var_cur_t_veh  VARCHAR(60) := '(SELECT vehicle_id FROM u_dw_dim_tax.dim_vehicle_scd )';
BEGIN
    cur_id := dbms_sql.open_cursor;
    dbms_sql.parse(cur_id,
                  'SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id  in  ' || var_cur_t_veh
-- SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id not in (SELECT vehicle_id FROM u_dw_data.t_vehicle_2);
                  ,
                  dbms_sql.native);
    row_cnt := dbms_sql.execute(cur_id);
    var_cur := dbms_sql.to_refcursor(cur_id);
    FETCH var_cur BULK COLLECT INTO var_t_vehcl;
    FORALL i IN var_t_vehcl.first..var_t_vehcl.last
        UPDATE u_dw_dim_tax.dim_vehicle_scd
        SET
            manuf_year = var_t_vehcl(i).manuf_year,
            manufacturer = var_t_vehcl(i).manufacturer,
            model_vhl = var_t_vehcl(i).model_vhl,
            milliage = var_t_vehcl(i).milliage,
            licence_plate = var_t_vehcl(i).licence_plate;

    COMMIT;
    cur_id := dbms_sql.open_cursor;
    dbms_sql.parse(cur_id,
                  'SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id not in  ' || var_cur_t_veh
   -- SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id not in (SELECT vehicle_id FROM u_dw_data.t_vehicle_2);
                  ,
                  dbms_sql.native);
 --  dbms_sql.bind_variable(cur_id, 'var_vehicle_id', var_cur_t_veh);
        row_cnt := dbms_sql.execute(cur_id);
    var_cur := dbms_sql.to_refcursor(cur_id);
    FETCH var_cur BULK COLLECT INTO var_t_vehcl;
    FORALL i IN var_t_vehcl.first..var_t_vehcl.last
        INSERT INTO u_dw_dim_tax.dim_vehicle_scd (
            manuf_year,
            manufacturer,
            model_vhl,
            milliage,
            licence_plate
        ) VALUES (
            var_t_vehcl(i).manuf_year,
            var_t_vehcl(i).manufacturer,
            var_t_vehcl(i).model_vhl,
            var_t_vehcl(i).milliage,
            var_t_vehcl(i).licence_plate
        );

    COMMIT;
END t_dim_vehicle;

--EXEC t_dim_vehicle;
/*
SELECT * FROM  u_dw_dim_tax.dim_vehicle_scd
order by vehicle_id;
 delete from  u_dw_dim_tax.dim_vehicle_scd;
DROP TABLE u_dw_dim_tax.dim_vehicle_scd;

CREATE TABLE u_dw_dim_tax.dim_vehicle_scd (
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

DROP TRIGGER u_dw_dim_tax.insrt_vehic_trig;

CREATE TRIGGER u_dw_dim_tax.insrt_vehic_trig BEFORE
    INSERT ON u_dw_dim_tax.dim_vehicle_scd
    FOR EACH ROW
BEGIN
    :new.insert_dt := sysdate;
END;

DROP TRIGGER u_dw_dim_tax.update_vehic_trig;

CREATE TRIGGER u_dw_dim_tax.update_vehic_trig BEFORE
    UPDATE ON u_dw_dim_tax.dim_vehicle_scd
    FOR EACH ROW
BEGIN
    :new.update_dt := sysdate;
END;
*/