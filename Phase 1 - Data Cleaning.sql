-- Phase 1 - Data Cleaning

-- Step 1: Null or Missing Values

SELECT *
FROM forecast
WHERE
	product_id is null or product_id = '' or
    forecast_month is null or forecast_month = '' or
    forecast_qty is null or forecast_qty = '';

SELECT *
FROM inventory
WHERE
	product_id is null or product_id = '' or
    warehouse_id is null or warehouse_id = '' or
    on_hand_qty is null or on_hand_qty = '' or
    reorder_point is null or reorder_point = '';

SELECT *
FROM products
WHERE
	product_id is null or product_id = '' or
    product_name is null or product_name = '' or
    category is null or category = '' or
    standard_cost is null or standard_cost = '';

SELECT *
FROM purchase_order_lines
WHERE
	po_line_id is null or po_line_id = '' or
    po_id is null or po_id = '' or
    product_id is null or product_id = '' or
    order_qty is null or order_qty = '' or
    unit_cost is null or unit_cost = '';

SELECT *
FROM purchase_orders
WHERE
	po_id is null or po_id = '' or
    vendor_id is null or vendor_id = '' or
    order_date is null or order_date = '' or
    warehouse_id is null or warehouse_id = '' or
    buyer is null or buyer = '';
    
-- Assuming that vendor_id 7 was missing from some purchase orders. Used the Update function to update missing vendor_id valuse to 7
UPDATE purchase_orders
SET vendor_id = '7'
WHERE vendor_id = '';

SELECT *
FROM receipts
WHERE
	po_line_id is null or po_line_id = '' or
    expected_delivery is null or expected_delivery = '' or
    actual_delivery is null or actual_delivery = '';

SELECT *
FROM vendors
WHERE
	vendor_id is null or vendor_id = '' or
    vendor_name is null or vendor_name = '' or
    vendor_region is null or vendor_region = '' or
    lead_time_days is null or lead_time_days = '';

-- Region column was missing East. Used the Update function to replace missing values with East

UPDATE vendors
SET vendor_region = 'East'
WHERE vendor_region = '';

SELECT *
FROM warehouses
WHERE
	warehouse_id is null or warehouse_id = '' or
    warehouse_name is null or warehouse_name = '' or
    region is null or region = '';

-- Step 2: Standarize Text Fields
-- Created the function ProperCase to convert the text fields into proper case format (Upper first letter of each word and lower following letters)

SELECT product_name, category FROM products LIMIT 20;
SELECT buyer FROM purchase_orders LIMIT 20;
SELECT vendor_name, vendor_region FROM vendors LIMIT 20;

UPDATE products
SET category = ProperCase(category), product_name = ProperCase(product_name);

UPDATE purchase_orders
SET buyer = ProperCase(buyer);

UPDATE vendors
SET vendor_name = ProperCase(vendor_name), vendor_region = ProperCase(vendor_region);

-- Step 3: Check for Negative or Invalid numeric data
SELECT * FROM forecast WHERE forecast_qty < 0;
SELECT * FROM inventory WHERE on_hand_qty < 0 or reorder_point < 0;
SELECT * FROM products WHERE standard_cost < 0;
SELECT * FROM purchase_order_lines WHERE order_qty < 0 or unit_cost < 0;
SELECT * FROM vendors WHERE lead_time_days < 0;

-- Step 4: Check for Duplicate Primary Keys for Product_ID, Vendor_ID, PO_ID, and Warehouse_ID
SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM inventory
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT 
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT 
    po_id,
    COUNT(*) AS duplicate_count
FROM purchase_orders
GROUP BY po_id
HAVING COUNT(*) > 1;

SELECT 
    vendor_id,
    COUNT(*) AS duplicate_count
FROM vendors
GROUP BY vendor_id
HAVING COUNT(*) > 1;

SELECT 
    warehouse_id,
    COUNT(*) AS duplicate_count
FROM warehouses
GROUP BY warehouse_id
HAVING COUNT(*) > 1;

