-- Phase 2 - Data Modeling

-- Creating Dimension Tables and Fact Tables for each dataset

-- Dimension Tables

CREATE TABLE dim_product AS
SELECT
    product_id,
    product_name,
    category,
    standard_cost
FROM products;

CREATE TABLE dim_vendor AS
SELECT
    vendor_id,
    vendor_name,
    vendor_region,
    lead_time_days
FROM vendors;

CREATE TABLE dim_warehouse AS
SELECT
    warehouse_id,
    warehouse_name,
    region
FROM warehouses;

CREATE TABLE dim_date AS
SELECT DISTINCT
    order_date AS date_value,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    QUARTER(order_date) AS quarter
FROM purchase_orders;

-- Fact Tables

CREATE TABLE fact_purchase_orders AS
SELECT
   po_id,
   vendor_id,
   order_date,
   warehouse_id,
   buyer
FROM purchase_orders;

CREATE TABLE fact_purchase_order_lines AS
SELECT
   po_line_id,
   po_id,
   product_id,
   order_qty,
   unit_cost
FROM purchase_order_lines;
    
CREATE TABLE fact_inventory AS
SELECT
    warehouse_id,
    product_id,
    on_hand_qty,
    reorder_point
FROM inventory;

CREATE TABLE fact_forecast AS
SELECT
    product_id,
    forecast_month,
    forecast_qty
FROM forecast;

CREATE TABLE fact_receipts AS
SELECT
    po_line_id,
    expected_delivery,
    actual_delivery
FROM receipts;




