SET SERVEROUTPUT ON;

drop table U_DW_EXT_APP.t_vehicle;
create table U_DW_EXT_APP.t_vehicle 
(
     vehicle_id  number GENERATED ALWAYS AS IDENTITY
    , MANUF_YEAR NUMBER(10,0)
    , MANUFACTURER VARCHAR2(20 BYTE)
    , MODEL_VHL VARCHAR2(20 BYTE)
    , MILLIAGE NUMBER(20,0)
    , LICENCE_PLATE VARCHAR2(50 BYTE)
);

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
    EXECUTE IMMEDIATE 'delete from U_DW_EXT_APP.t_vehicle';
    OPEN cur_sa_veh;
    FETCH cur_sa_veh BULK COLLECT INTO var_t_sa_vehcl;
    CLOSE cur_sa_veh;
    FORALL i IN var_t_sa_vehcl.first..var_t_sa_vehcl.last
        INSERT INTO u_dw_ext_app.t_vehicle (
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

SELECT
    *
FROM
    u_dw_ext_app.t_vehicle;