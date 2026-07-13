-- Step 5: DW - Creading customer delivery mart 

DROP SCHEMA IF EXISTS customer_delivery_mart CASCADE;

CREATE SCHEMA customer_delivery_mart; 

SELECT '=== Loading customer delivery mart dim customers table ===' AS info;
CREATE OR REPLACE TABLE customer_delivery_mart.dim_customers AS
SELECT
-- fields from customer dim table
    dc.customer_id,
    dc.customer_name,
    dc.city,
    dc.currency,
-- fields from dim target orders
    dto.ontime_target_percent,
    dto.infull_target_percent,
    dto.otif_target_percent
FROM dim_customers AS dc
LEFT JOIN dim_target_orders AS dto
    ON dc.customer_id = dto.customer_id;


SELECT '=== Loading Customer Delivery Mart Date Dimension ===' AS info;

CREATE OR REPLACE TABLE customer_delivery_mart.dim_date AS

SELECT DISTINCT
    DATE_TRUNC('month', actual_delivery_date) AS exact_delivery_month,
    EXTRACT(YEAR FROM actual_delivery_date) AS year,
    EXTRACT(MONTH FROM actual_delivery_date) AS month,
    MONTHNAME(actual_delivery_date) AS month_name,
    EXTRACT(QUARTER FROM actual_delivery_date) AS quarter,
    CONCAT(
        EXTRACT(YEAR FROM actual_delivery_date),
        '-Q',
        EXTRACT(QUARTER FROM actual_delivery_date)
    ) AS year_quarter
FROM flat_mart.order_delivery
ORDER BY exact_delivery_month;

SELECT '=== Loading customer delivery mart fact_customer_monthly_delivery ===' AS info;

CREATE OR REPLACE TABLE customer_delivery_mart.fact_customer_monthly_delivery AS
SELECT
    cdmdd.exact_delivery_month,
    fmod.customer_id,
    COUNT(DISTINCT fmod.order_id) AS total_orders,
    SUM(fmod.order_qty) AS ordered_quantity,
    SUM(fmod.delivery_qty) AS delivered_quantity,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.on_time = 'yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_on_time_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.in_full = 'yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_in_full_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN fmod.otif = 'yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS actual_otif_percent
FROM flat_mart.order_delivery fmod
JOIN customer_delivery_mart.dim_date cdmdd
    ON DATE_TRUNC('month', fmod.actual_delivery_date) = cdmdd.exact_delivery_month
GROUP BY
    cdmdd.exact_delivery_month,
    fmod.customer_id
ORDER BY
    cdmdd.exact_delivery_month,
    fmod.customer_id;

SELECT '=== Loading Customer Delivery Perfomance ===' AS info;

CREATE OR REPLACE VIEW customer_delivery_mart.customer_delivery_performance AS
SELECT
    dd.year,
    dd.month_name,
    dc.customer_name,
    dc.city,
    dc.ontime_target_percent,
    f.actual_on_time_percent,
    dc.infull_target_percent,
    f.actual_in_full_percent,
    dc.otif_target_percent,
    f.actual_otif_percent
FROM customer_delivery_mart.fact_customer_monthly_delivery f
JOIN customer_delivery_mart.dim_customers dc
    ON f.customer_id = dc.customer_id
JOIN customer_delivery_mart.dim_date dd
    ON f.exact_delivery_month = dd.exact_delivery_month;


SELECT '=== Dim customers Sample ===' AS info;
SELECT *
FROM customer_delivery_mart.dim_customers
LIMIT 10;

SELECT '=== Dim Date Sample ===' AS info;
SELECT * 
FROM customer_delivery_mart.dim_customers
LIMIT 10;

SELECT '==== Fact customer Monthly Delivery Sample ===' AS info;
SELECT*
FROM customer_delivery_mart.fact_customer_monthly_delivery
ORDER BY RANDOM()
LIMIT 10; 

SELECT '=== Customer Delivery Performance ===' AS info;
SELECT * 
FROM customer_delivery_mart.customer_delivery_performance
LIMIT 10;
