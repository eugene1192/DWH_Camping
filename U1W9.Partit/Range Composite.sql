--Range-Partitioned Tables
DROP TABLE sales;

CREATE TABLE sales (
    prod_id        NUMBER(6),
    cust_id        NUMBER,
    time_id        DATE,
    channel_id     CHAR(1),
    promo_id       NUMBER(6),
    quantity_sold  NUMBER(3),
    amount_sold    NUMBER(10, 2)
)
    PARTITION BY RANGE (
        time_id
    )
    ( PARTITION sales_q1_2006
        VALUES LESS THAN ( TO_DATE('01-APR-2006', 'dd-MON-yyyy') )
    TABLESPACE system,
    PARTITION sales_q2_2006
        VALUES LESS THAN ( TO_DATE('01-JUL-2006', 'dd-MON-yyyy') )
    TABLESPACE system,
    PARTITION sales_q3_2006
        VALUES LESS THAN ( TO_DATE('01-OCT-2006', 'dd-MON-yyyy') )
    TABLESPACE system,
    PARTITION sales_q4_2006
        VALUES LESS THAN ( TO_DATE('01-JAN-2007', 'dd-MON-yyyy') )
    TABLESPACE system );

ALTER TABLE sales ADD PARTITION oct06
    VALUES LESS THAN ( '01-OCT-2008' )
TABLESPACE system;

ALTER TABLE sales DROP PARTITION oct06;

SELECT
    *
FROM
    sales; 
 --select * from v$tablespace
 
 
 
--------------------------------------------------------------------------------
CREATE TABLESPACE i_gear1 DATAFILE
    '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/i_gear1.dat' SIZE 20M
        AUTOEXTEND ON NEXT 5M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE i_gear2 DATAFILE
    '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/i_gear2.dat' SIZE 20M
        AUTOEXTEND ON NEXT 5M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE i_gear3 DATAFILE
    '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/i_gear3.dat' SIZE 20M
        AUTOEXTEND ON NEXT 5M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE i_gear4 DATAFILE
    '/oracle/u01/app/oracle/oradata/DCORCL/pdb_evrublevskiy/i_gear4.dat' SIZE 20M
        AUTOEXTEND ON NEXT 5M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLE four_seasons (
    one    DATE,
    two    VARCHAR2(60),
    three  NUMBER
)
    PARTITION BY RANGE (
        one
    )
    ( PARTITION gear1
        VALUES LESS THAN ( TO_DATE('01-apr-1998', 'dd-mon-yyyy') )
    TABLESPACE gear1,
    PARTITION gear2
        VALUES LESS THAN ( TO_DATE('01-jul-1998', 'dd-mon-yyyy') )
    TABLESPACE gear2,
    PARTITION gear3
        VALUES LESS THAN ( TO_DATE('01-oct-1998', 'dd-mon-yyyy') )
    TABLESPACE gear3,
    PARTITION gear4
        VALUES LESS THAN ( TO_DATE('01-jan-1999', 'dd-mon-yyyy') )
    TABLESPACE gear4 );

-- 
-- Create local PREFIXED index on Four_Seasons
-- Prefixed because the leftmost columns of the index match the
-- Partitioning key 
--
--drop INDEX i_four_seasons_l;
CREATE INDEX i_four_seasons_l ON
    four_seasons (
        one,
        two
    )
        LOCAL ( PARTITION gear1
        TABLESPACE i_gear1,
            PARTITION gear2
        TABLESPACE i_gear2,
            PARTITION gear3
        TABLESPACE i_gear3,
            PARTITION gear4
        TABLESPACE i_gear4 );

ALTER TABLE four_seasons MERGE PARTITIONS gear1, gear2 INTO PARTITION gear2 UPDATE INDEXES;

ALTER TABLE sales MOVE PARTITION sales_q1_2006
TABLESPACE i_gear2 NOLOGGING COMPRESS;

ALTER TABLE sales SPLIT PARTITION sales_q1_2006    VALUES LESS THAN ( TO_DATE('01-JUL-2006','dd-MON-yyyy'))
   INTO    
    ( PARTITION oct06_1, 
      PARTITION oct06_2)
--split      
      ALTER TABLE sales SPLIT PARTITION sales_q2_2006 AT ( '15-JUN-2006' ) INTO ( PARTITION sales_jun_2006
TABLESPACE system, PARTITION sales_jul__2006
TABLESPACE system );
SELECT
    *
FROM
    all_tab_partitions
WHERE
    table_name = 'SALES';

ALTER TABLE sales DROP PARTITION sales_q1_2006;

ALTER TABLE sales DROP PARTITION sales_jun_2006;

ALTER TABLE sales DROP PARTITION sales_jul__2006;

ALTER TABLE sales DROP PARTITION sales_q3_2006;

ALTER TABLE sales DROP PARTITION sales_q4_2006;