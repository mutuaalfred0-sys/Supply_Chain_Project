-- Step 2: DW - Loading csv data into tables


SELECT '===loading customers_dim Table===' AS info;

INSERT INTO dim_customers (customer_id, customer_name, city, currency)
SELECT customer_id, customer_name, city, currency
FROM read_csv('A:/Alfy/Desktop/Dataset/Postgres Input files/dim_customers.csv',
    AUTO_DETECT = true,
    HEADER = true);

SELECT '===loading product_dim Table===' AS info;

INSERT INTO dim_products (product_name, product_id, category, price_INR, price_USD)
SELECT product_name, product_id, category, price_INR, price_USD
FROM read_csv('A:/Alfy/Desktop/Dataset/Postgres Input files/dim_products.csv',
    AUTO_DETECT = true,
    HEADER = true);

SELECT '===loading Tartget_order_dim Table===' AS info;

INSERT INTO dim_target_orders (customer_id, ontime_target_percent, infull_target_percent, 
    otif_target_percent)
SELECT customer_id, ontime_target_percent, infull_target_percent, otif_target_percent 
FROM read_csv('A:\Alfy\Desktop\Dataset\Postgres Input files\dim_targets_orders.csv',
    AUTO_DETECT = true,
    HEADER = true); 

SELECT '===loading Fact Aggregate Table===' AS info;

INSERT INTO fact_aggregate(order_id, customer_id, order_placement_date, on_time, in_full, otif)
SELECT 
    order_id, 
    customer_id, 
    COALESCE(
        TRY_STRPTIME(order_placement_date, '%m/%d/%Y'), 
        TRY_STRPTIME(order_placement_date, '%d-%m-%Y')
    ) AS order_placement_date,
    CASE 
        WHEN in_full = 0 THEN 'no' 
        WHEN in_full = 1 THEN 'yes'
        ELSE NULL 
    END AS in_full,
    CASE 
        WHEN on_time = 0 THEN 'no' 
        WHEN on_time = 1 THEN 'yes'
        ELSE NULL 
    END AS on_time,
    CASE 
        WHEN otif = 0 THEN 'no' 
        WHEN otif = 1 THEN 'yes'
        ELSE NULL 
    END AS otif, 
FROM read_csv('A:\Alfy\Desktop\Dataset\Postgres Input files\fact_aggregate.csv',
    AUTO_DETECT = true,
    HEADER = true);

SELECT '===loading Fact Order Line Table===' AS info;

INSERT INTO fact_order_line (order_id, order_placement_date, customer_id, product_id,
        order_qty, agreed_delivery_date, actual_delivery_date, delivery_qty, in_full, 
        on_time, otif)
SELECT 
    order_id, 
    -- Cleanly handle multiple date formats
    COALESCE(
        TRY_STRPTIME(order_placement_date, '%m/%d/%Y'), 
        TRY_STRPTIME(order_placement_date, '%d-%m-%Y')
    ) AS order_placement_date, 
    customer_id, 
    product_id,
    order_qty,
    COALESCE(
        TRY_STRPTIME(agreed_delivery_date, '%m/%d/%Y'), 
        TRY_STRPTIME(agreed_delivery_date, '%d-%m-%Y')
    ) AS agreed_delivery_date, 
    COALESCE(
        TRY_STRPTIME(actual_delivery_date, '%m/%d/%Y'), 
        TRY_STRPTIME(actual_delivery_date, '%d-%m-%Y')
    ) AS actual_delivery_date,
    delivery_qty,
    CASE 
        WHEN in_full = 0 THEN 'no' 
        WHEN in_full = 1 THEN 'yes'
        ELSE NULL 
    END AS in_full,
    CASE 
        WHEN on_time = 0 THEN 'no' 
        WHEN on_time = 1 THEN 'yes'
        ELSE NULL 
    END AS on_time,
    CASE 
        WHEN otif = 0 THEN 'no' 
        WHEN otif = 1 THEN 'yes'
        ELSE NULL 
    END AS otif,
    
FROM read_csv('A:/Alfy/Desktop/Dataset/Postgres Input files/fact_order_line.csv',
    HEADER = true,
    sample_size = -1);


SELECT 'Customer Dim' AS table_name, COUNT(*) AS record_count FROM dim_customers
UNION ALL 
SELECT 'Product Dim', COUNT(*) FROM dim_products
UNION ALL 
SELECT 'Target Orders Dim', COUNT(*) FROM dim_target_orders
UNION ALL 
SELECT 'Fact Aggregate', COUNT(*) FROM fact_aggregate
UNION ALL
SELECT 'Fact Order Line', COUNT(*) FROM fact_order_line;

SELECT '===Customer DIM Sample===' AS info;
SELECT * 
FROM dim_customers
LIMIT 10;

SELECT '===Product DIM Sample===' AS info;
SELECT * 
FROM dim_products 
LIMIT 10;

SELECT '===Target Orders DIM Sample===' AS info;
SELECT * 
FROM dim_target_orders 
LIMIT 10;

SELECT '===Fact Aggregate Sample===' AS info;
SELECT * 
FROM fact_aggregate 
LIMIT 10;

SELECT '===Fact Order Line Sample===' AS info;
SELECT * 
FROM fact_order_line 
LIMIT 10;



