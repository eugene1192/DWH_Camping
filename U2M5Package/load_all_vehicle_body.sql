CREATE OR REPLACE PACKAGE BODY load_all_vehicle 
AS
    PROCEDURE ext_sa_t_vehicke IS

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
        EXECUTE IMMEDIATE 'ALTER TABLE u_dw_data.t_vehicle MODIFY
            (vehicle_id Generated as Identity (START WITH 1))';
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
    
    PROCEDURE t_dim_vehicle IS

        cur_id         NUMBER;
        var_cur        SYS_REFCURSOR;
        row_cnt        NUMBER;
        TYPE t_vehicle IS
            TABLE OF u_dw_data.t_vehicle%rowtype;
        var_t_vehcl    t_vehicle := t_vehicle();
        var_t_vehcl_2   t_vehicle := t_vehicle();  
        var_cur_t_veh  VARCHAR(60) := '(SELECT vehicle_id FROM u_dw_dim_tax.dim_vehicle_scd )';
        
        BEGIN
            cur_id := dbms_sql.open_cursor;
            dbms_sql.parse(cur_id,
                          'SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id  in  ' || var_cur_t_veh
        -- SELECT DISTINCT vehicle_id FROM u_dw_data.t_vehicle where vehicle_id not in (SELECT vehicle_id FROM u_dw_dim_tax.dim_vehicle_scd);
                          ,
                          dbms_sql.native);
            row_cnt := dbms_sql.execute(cur_id);
            var_cur := dbms_sql.to_refcursor(cur_id);
            FETCH var_cur BULK COLLECT INTO var_t_vehcl_2;
            FORALL i IN var_t_vehcl_2.first..var_t_vehcl_2.last 
            --    DBMS_OUTPUT.PUT_LINE(var_t_vehcl_2(i).vihicle_id)      
                UPDATE u_dw_dim_tax.dim_vehicle_scd a
                SET
                    manuf_year = var_t_vehcl_2(i).manuf_year,
                    manufacturer = var_t_vehcl_2(i).manufacturer,
                    model_vhl = var_t_vehcl_2(i).model_vhl,
                    milliage = var_t_vehcl_2(i).milliage,
                    licence_plate = var_t_vehcl_2(i).licence_plate
                    where a.vehicle_id=var_t_vehcl_2(i).vehicle_id; 
            COMMIT;
            cur_id := dbms_sql.open_cursor;
            dbms_sql.parse(cur_id,
                          'SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id not in  ' || var_cur_t_veh
           -- SELECT DISTINCT * FROM u_dw_data.t_vehicle where vehicle_id not in (SELECT vehicle_id FROM u_dw_dim_tax.dim_vehicle_scd);
                          ,
                          dbms_sql.native);
         --  dbms_sql.bind_variable(cur_id, 'var_vehicle_id', var_cur_t_veh);
                row_cnt := dbms_sql.execute(cur_id);
            var_cur := dbms_sql.to_refcursor(cur_id);
            FETCH var_cur BULK COLLECT INTO var_t_vehcl;
            FORALL i IN var_t_vehcl.first..var_t_vehcl.last
                INSERT INTO u_dw_dim_tax.dim_vehicle_scd (
                    vehicle_id,
                    manuf_year,
                    manufacturer,
                    model_vhl,
                    milliage,
                    licence_plate
                ) VALUES (
                    var_t_vehcl(i).vehicle_id,
                    var_t_vehcl(i).manuf_year,
                    var_t_vehcl(i).manufacturer,
                    var_t_vehcl(i).model_vhl,
                    var_t_vehcl(i).milliage,
                    var_t_vehcl(i).licence_plate
                );
                       
        COMMIT;
    END t_dim_vehicle;

END load_all_vehicle;