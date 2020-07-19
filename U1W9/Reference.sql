CREATE TABLE orders
    ( order_id           NUMBER(12),
      order_date         TIMESTAMP WITH LOCAL TIME ZONE,
      order_mode         VARCHAR2(8),
      customer_id        NUMBER(6),
      order_status       NUMBER(2),
      order_total        NUMBER(8,2),
      sales_rep_id       NUMBER(6),
      promotion_id       NUMBER(6),
      CONSTRAINT orders_pk PRIMARY KEY(order_id)
    )
  PARTITION BY RANGE(order_date)
    ( 
     partition Q1_2005 values less than (TIMESTAMP'2005-04-01 00:00:00 +0:00') tablespace SYSTEM,
     partition Q2_2005 values less than (TIMESTAMP'2005-07-01 00:00:00 +0:00') tablespace SYSTEM,
     partition Q3_2005 values less than (TIMESTAMP'2005-10-01 00:00:00 +0:00') tablespace SYSTEM,
     partition Q4_2005 values less than (TIMESTAMP'2006-01-01 00:00:00 +0:00') tablespace SYSTEM
    );
CREATE TABLE order_items
    ( order_id           NUMBER(12) NOT NULL,
      line_item_id       NUMBER(3)  NOT NULL,
      product_id         NUMBER(6)  NOT NULL,
      unit_price         NUMBER(8,2),
      quantity           NUMBER(8),
      CONSTRAINT order_items_fk
      FOREIGN KEY(order_id) REFERENCES orders(order_id)
    )
    PARTITION BY REFERENCE(order_items_fk);
    
    ALTER TABLE orders MOVE PARTITION Q1_2005
     TABLESPACE gear2 NOLOGGING COMPRESS;
     
         SELECT * FROM ALL_TAB_PARTITIONS where TABLE_NAME = 'ORDER_ITEMS';
 alter table order_items drop partition Q1_2005;