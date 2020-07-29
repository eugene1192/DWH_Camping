CREATE TABLE q1_sales_by_region (
    deptno           NUMBER,
    deptname         VARCHAR2(20),
    quarterly_sales  NUMBER(10, 2),
    state            VARCHAR2(2)
)
    PARTITION BY LIST ( state ) ( PARTITION q1_northwest VALUES ( 'OR',
    'WA' ),
        PARTITION q1_southwest VALUES ( 'AZ',
        'UT',
        'NM' ),
        PARTITION q1_northeast VALUES ( 'NY',
        'VM',
        'NJ' ),
        PARTITION q1_southeast VALUES ( 'FL',
        'GA' ),
        PARTITION q1_northcentral VALUES ( 'SD',
        'WI' ),
        PARTITION q1_southcentral VALUES ( 'OK',
        'TX' )
    );

ALTER TABLE q1_sales_by_region ADD PARTITION q1_nonmainland VALUES ( 'HI',
'PR' )
    STORAGE ( INITIAL 20K NEXT 20K )
TABLESPACE system NOLOGGING;

ALTER TABLE q1_sales_by_region DROP PARTITION q1_nonmainland;