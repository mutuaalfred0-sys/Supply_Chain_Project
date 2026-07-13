-- duckdb supply_chain_dw -c ".read build_dw_marts.sql"

-- Step 1: DW - Create star schema tables
.read 01_create_tables_dw.sql 

-- Step 2: DW - load data into tables
.read 02_load_data_into_tables.sql

-- Step 3: DW - Creating city delivery
.read 03_create_order_flat_mart.sql

-- Step 4: Creating a product supply date mart
.read 04_create_product_supply_mart.sql 

-- Step 5: DW - Creading customer delivery mart 
.read 05_create_customer_delivery_mart.sql