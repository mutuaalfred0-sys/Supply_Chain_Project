--Step 4: Creating a product supply mart 

DROP SCHEMA IF EXISTS supply_mart CASCADE;

CREATE SCHEMA supply_mart;

SELECT '=== loading products dim for dim_products table ===' AS info;

CREATE OR REPLACE TABLE supply_mart.dim_products AS
SELECT DISTINCT
    product_id,
    product_name,
    category,
    price_USD,
    price_INR
FROM flat_mart.order_delivery;


SELECT '=== Loading Product Dim Date Table==' AS info;
CREATE OR REPLACE TABLE supply_mart.product_dim_date (
    month_delivery_date    DATE,
    year                INTEGER,
    month               INTEGER,
    month_name          VARCHAR,
    quarter             VARCHAR,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
); 

INSERT INTO supply_mart.product_dim_date( 
    month_delivery_date,    
    year,                
    month,
    month_name,              
    quarter,             
    quarter_name,        
    year_quarter 
) 
SELECT 
    DATE_TRUNC ('month', actual_delivery_date) AS month_delivery_date, 
    EXTRACT(YEAR FROM actual_delivery_date) AS year,
    EXTRACT(MONTH FROM actual_delivery_date) AS month,
    MONTHNAME(actual_delivery_date) AS month_name,
    EXTRACT(QUARTER FROM actual_delivery_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM actual_delivery_date) :: VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM actual_delivery_date):: VARCHAR || '-Q' ||
    EXTRACT(QUARTER FROM actual_delivery_date) :: VARCHAR AS year_quarter
FROM flat_mart.order_delivery 
ORDER BY month_delivery_date; 


SELECT '=== Loading date_mart Fact_Product_Monthly_Supply ===' AS info;

CREATE OR REPLACE TABLE supply_mart.fact_product_monthly_supply AS 
SELECT 
    smdp.product_id,
    smdp.product_name, 
    smdp.category,
    smpdd.month_delivery_date,    
    smpdd.year,                
    smpdd.month,
    smpdd.month_name,               
    smpdd.quarter,             
    smpdd.quarter_name,        
    smpdd.year_quarter,
    COUNT(DISTINCT fmod.order_id) AS total_orders,
    SUM(fmod.order_qty) AS ordered_quantity,
    SUM(fmod.delivery_qty) AS delivered_quantity,
    SUM(fmod.order_qty * smdp.price_USD):: DECIMAl AS ordered_value_usd,
    SUM(fmod.delivery_qty * smdp.price_USD) :: DECIMAL AS delivered_value_usd,
     ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.on_time='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_on_time_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.in_full='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_in_full_percent, 
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.otif='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_otif_percent
FROM flat_mart.order_delivery AS fmod 
LEFT JOIN supply_mart.product_dim_date AS smpdd
    ON DATE_TRUNC('month', fmod.actual_delivery_date) = smpdd.month_delivery_date
LEFT JOIN supply_mart.dim_products AS smdp
    ON fmod.product_id = smdp.product_id 
GROUP BY 
    ALL
ORDER BY 
    smdp.product_id,
    smpdd.month_delivery_date;


SELECT '=== Product dim Sample==' AS info;
SELECT * 
FROM supply_mart.dim_products
LIMIT 10;


SELECT '=== Product Product Dim Date Sample ===' AS info;
SELECT * 
FROM supply_mart.product_dim_date
ORDER BY RANDOM()
LIMIT 10; 

SELECT '=== Fact_Product_Monthly_Supply Sample ===' AS info;
SELECT *
FROM supply_mart.fact_product_monthly_supply
LIMIT 10;
