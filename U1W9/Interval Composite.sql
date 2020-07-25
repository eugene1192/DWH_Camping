CREATE TABLE interval_sales (
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
    ) INTERVAL ( numtoyminterval(1, 'MONTH') ) ( PARTITION p0
        VALUES LESS THAN ( TO_DATE('1-1-2005', 'DD-MM-YYYY') ),
    PARTITION p1
        VALUES LESS THAN ( TO_DATE('1-1-2006', 'DD-MM-YYYY') ),
    PARTITION p2
        VALUES LESS THAN ( TO_DATE('1-7-2006', 'DD-MM-YYYY') ),
    PARTITION p3
        VALUES LESS THAN ( TO_DATE('1-1-2007', 'DD-MM-YYYY') )
    );
      
    --  ALTER TABLE interval_sales
    --  split PARTITION oct08 VALUES LESS THAN ( '01-OCT-2008' )
    --  TABLESPACE SYSTEM;
      
      ALTER TABLE interval_sales SET INTERVAL ( numtoyminterval(2, 'year') );
--ALTER TABLE interval_sales DROP PARTITION FOR(TO_DATE('1-7-2006', 'DD-MM-YYYY'));
      
--------------------------------------------------------------------------------
--Merging Interval Partitions
CREATE TABLE transactions (
    id                NUMBER,
    transaction_date  DATE,
    value             NUMBER
)
    PARTITION BY RANGE (
        transaction_date
    ) INTERVAL ( numtodsinterval(1, 'DAY') ) ( PARTITION p_before_2007
        VALUES LESS THAN ( TO_DATE('01-JAN-2007', 'dd-MON-yyyy') )
    );

INSERT INTO transactions VALUES (
    1,
    TO_DATE('15-JAN-2007', 'dd-MON-yyyy'),
    100
);

INSERT INTO transactions VALUES (
    2,
    TO_DATE('16-JAN-2007', 'dd-MON-yyyy'),
    600
);

INSERT INTO transactions VALUES (
    3,
    TO_DATE('30-JAN-2007', 'dd-MON-yyyy'),
    200
);

ALTER TABLE transactions MERGE PARTITIONS for(TO_DATE('15-JAN-2007', 'dd-MON-yyyy')),
                                          for(TO_DATE('16-JAN-2007', 'dd-MON-yyyy'));

ALTER TABLE interval_sales MOVE PARTITION p0
TABLESPACE i_gear2 NOLOGGING COMPRESS;
--split   
    ALTER TABLE transactions SPLIT PARTITION FOR ( TO_DATE('12-JAN-2007', 'dd-MON-yyyy') ) AT ( TO_DATE(
'16-JAN-2007', 'dd-MON-yyyy') );

SELECT
    *
FROM
    all_tab_partitions
WHERE
    table_name = 'TRASACTIONS';

ALTER TABLE transactions DROP PARTITION p_before_2007;

