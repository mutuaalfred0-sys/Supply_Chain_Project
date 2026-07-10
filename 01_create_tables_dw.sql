-- Step 1: DW- Create star schema tables
-- .read 01_create_tables_dw.sql

DROP TABLE IF EXISTS fact_order_line;
DROP TABLE IF EXISTS fact_aggregate;
DROP TABLE IF EXISTS dim_target_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;

-- Customer dimensional table
CREATE TABLE dim_customers (
    customer_id     INTEGER     PRIMARY KEY,
    customer_name   VARCHAR,
    city            VARCHAR,
    currency        VARCHAR
);

-- Product dimensional tables 
CREATE TABLE dim_products (
    product_name    VARCHAR     PRIMARY KEY,
    product_id      INTEGER,
    category        VARCHAR, 
    price_INR       INTEGER, 
    price_USD       INTEGER,
); 


-- Target Orders dimensional table
CREATE TABLE dim_target_orders (
    customer_id                 INTEGER,
    ontime_target_percent       INTEGER,
    infull_target_percent       INTEGER,
    otif_target_percent         INTEGER,
    FOREIGN KEY(customer_id) REFERENCES dim_customers(customer_id)
);


-- Fact Aggregate table
CREATE TABLE fact_aggregate (
    order_id                VARCHAR,
    customer_id             INTEGER,
    order_placement_date    DATE,
    on_time                 VARCHAR,
    in_full                 VARCHAR,
    otif                    VARCHAR,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customers (customer_id)
);

-- Fact Order Line Table
CREATE TABLE fact_order_line (
    order_id                VARCHAR,
    order_placement_date    DATE,
    customer_id             INTEGER,
    product_id              INTEGER,
    order_qty               INTEGER,
    agreed_delivery_date    DATE,
    actual_delivery_date    DATE,
    delivery_qty            INTEGER,
    in_full                 VARCHAR,
    on_time                 VARCHAR,
    otif                    VARCHAR,
    FOREIGN KEY(order_id) REFERENCES fact_aggregate(order_id),
    FOREIGN KEY(customer_id) REFERENCES dim_customers(customer_id),
    );

SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'main';