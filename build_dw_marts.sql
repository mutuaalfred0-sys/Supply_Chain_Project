-- Step 1: DW - Create star schema tables
.read 01_create_tables_dw.sql 

-- Step 2: DW - load data into tables
.read 02_load_data_into_tables.sql

-- Step 3: Creating city delivery
.read 03_customer_flat_mart.sql

-- Step 4: Creating a product supply date mart
.read 04_create_date_mart.sql