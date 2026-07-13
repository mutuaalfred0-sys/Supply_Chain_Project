-- Step 6: DW - Creating product performace mart

DROP SCHEMA IF EXISTS product_performance_mart CASCADE;

CREATE SCHEMA product_performance_mart; 

SELECT '=== Loading Product Dimension ===' AS info;

CREATE OR REPLACE TABLE product_performance_mart.dim_products AS

SELECT
    product_id,
    product_name,
    category,
    price_INR,
    price_USD
FROM dim_products; 

SELECT '=== Loading Product Date Dimension ===' AS info;

CREATE OR REPLACE TABLE product_performance_mart.dim_date AS
SELECT DISTINCT
    DATE_TRUNC('month', actual_delivery_date) AS delivery_month,
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
ORDER BY delivery_month;

SELECT '=== Loading Product Monthly Performance Fact ===' AS info;

CREATE OR REPLACE TABLE product_performance_mart.fact_product_monthly_performance AS
SELECT
    DATE_TRUNC('month', actual_delivery_date) AS delivery_month,
    product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(order_qty) AS ordered_quantity,
    SUM(delivery_qty) AS delivered_quantity,
    SUM(order_qty - delivery_qty) AS short_quantity,
    ROUND(
        100.0 * SUM(delivery_qty) / NULLIF(SUM(order_qty),0),
        2
    ) AS fill_rate_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN on_time='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS on_time_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN in_full='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS in_full_percent,
    ROUND(
        100.0 * AVG(
            CASE
                WHEN otif='yes' THEN 1
                ELSE 0
            END
        ),
        2
    ) AS otif_percent,
    ROUND(
        SUM(delivery_qty * price_USD),
        2
    ) AS revenue_usd,
    ROUND(
        SUM(delivery_qty * price_INR),
        2
    ) AS revenue_inr
FROM flat_mart.order_delivery
GROUP BY
    delivery_month,
    product_id
ORDER BY
    delivery_month,
    product_id; 


SELECT '=== Creating Product Performance View ===' AS info;

CREATE OR REPLACE VIEW product_performance_mart.product_performance AS
SELECT
    d.year,
    d.month_name,
    p.product_name,
    p.category,
    f.total_orders,
    f.ordered_quantity,
    f.delivered_quantity,
    f.short_quantity,
    f.fill_rate_percent,
    f.on_time_percent,
    f.in_full_percent,
    f.otif_percent,
    f.revenue_usd,
    f.revenue_inr
FROM product_performance_mart.fact_product_monthly_performance f
JOIN product_performance_mart.dim_products p
ON f.product_id = p.product_id
JOIN product_performance_mart.dim_date d
ON f.delivery_month = d.delivery_month;

SELECT '=== Product Perfomance Sample ===' AS info;
SELECT * 
FROM product_performance_mart.product_performance
LIMIT 10;