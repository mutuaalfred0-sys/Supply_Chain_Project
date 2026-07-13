-- Step 3: Creating flat mart


DROP SCHEMA IF EXISTS flat_mart CASCADE;

CREATE OR REPLACE SCHEMA flat_mart;

SELECT '===Loading Flat Mart Order Delivery Table===' AS info;

CREATE OR REPLACE TABLE flat_mart.order_delivery AS 
SELECT 
    fol.order_id, 
    fol.order_placement_date, 
    fol.customer_id, 
    fol.product_id,
    fol.order_qty, 
    fol.agreed_delivery_date, 
    fol.actual_delivery_date, 
    fol.delivery_qty, 
    fol.in_full, 
    fol.on_time, 
    fol.otif, 
    -- customer_dim fields 
    dc.customer_name,
    dc.city,
    -- product_dim fields
    dp.product_name,
    dp.category,
    dp.price_INR,
    dp.price_USD 
FROM fact_order_line AS fol
LEFT JOIN dim_customers AS dc 
    ON fol.customer_id = dc.customer_id
LEFT JOIN dim_products AS dp
    ON fol.product_id = dp.product_id; 


SELECT '=== Order Delivery Sample===' AS info;

SELECT * 
FROM flat_mart.order_delivery
LIMIT 10;

