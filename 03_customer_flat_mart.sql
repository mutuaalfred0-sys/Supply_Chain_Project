-- Step 3: Creating city delivery


DROP SCHEMA IF EXISTS flat_mart CASCADE;

CREATE SCHEMA flat_mart;

CREATE OR REPLACE TABLE flat_mart.city_delivery AS 
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
    dc.city 
FROM fact_order_line AS fol
JOIN dim_customers AS dc 
    ON fol.customer_id = dc.customer_id; 

SELECT * 
FROM flat_mart.city_delivery;