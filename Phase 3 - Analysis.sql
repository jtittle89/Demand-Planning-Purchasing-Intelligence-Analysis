-- Phase 3 - Analysis

-- Inventory Levels by Warehouse
-- Shows inventory distribution across warehouses
SELECT
    w.warehouse_name,
    p.category,
    SUM(i.on_hand_qty) AS inventory_units
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
JOIN warehouses w
    ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name, p.category;

-- Purchase Volume by Vendor
-- Identifies top suppliers by purchasing spend
SELECT
    v.vendor_name,
    ROUND(SUM(pol.order_qty * pol.unit_cost)) AS total_spend
FROM purchase_order_lines pol
JOIN purchase_orders po
    ON pol.po_id = po.po_id
JOIN vendors v
    ON po.vendor_id = v.vendor_id
GROUP BY v.vendor_name
ORDER BY total_spend DESC;

-- Late Vendor Deliveries
-- Shows supplier performance tracking
SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(*) AS late_orders
FROM vendors v
	JOIN purchase_orders po ON v.vendor_id = po.vendor_id
    JOIN receipts r ON r.po_line_id = po.po_id
WHERE actual_delivery > expected_delivery
GROUP BY vendor_id, vendor_name
ORDER BY late_orders DESC;

-- Demand vs Inventory GAP Analysis
-- Used to identify products that will run out based on forecast demand.
-- Negative Gap = Excess Inventory
-- Positive Gap = Inventory Shortage
WITH demand AS (
    SELECT 
        product_id,
        SUM(forecast_qty) AS forecast_demand
    FROM forecast
    GROUP BY product_id
),
inventory AS (
    SELECT
        product_id,
        SUM(on_hand_qty) AS inventory_available
    FROM inventory
    GROUP BY product_id
)
SELECT
    d.product_id,
    d.forecast_demand,
    i.inventory_available,
    d.forecast_demand - i.inventory_available AS demand_gap
FROM demand d
LEFT JOIN inventory i
ON d.product_id = i.product_id
ORDER BY demand_gap DESC;

-- Supplier On-Time Delivery Rate
-- Used to evaluate supplier reliability
SELECT
    v.vendor_name,
    COUNT(po.po_id) AS total_orders,
    SUM(
        CASE 
            WHEN r.actual_delivery <= r.expected_delivery
            THEN 1 
            ELSE 0 
        END
    ) AS on_time_orders,
    ROUND(
        SUM(
            CASE 
                WHEN r.actual_delivery <= r.expected_delivery
                THEN 1 ELSE 0 
            END
        ) / COUNT(po.po_id) * 100, 2
    ) AS on_time_delivery_rate
FROM vendors v 
	JOIN purchase_orders po ON po.vendor_id = v.vendor_id
    JOIN purchase_order_lines pol ON po.po_id = pol.po_id
    JOIN receipts r on pol.po_line_id = r.po_line_id
GROUP BY v.vendor_name
ORDER BY on_time_delivery_rate DESC;

-- Supplier Lead Time Performance
-- Identifies slow vendors affecting supply chain
SELECT
    v.vendor_name,
    ROUND(AVG(
        DATEDIFF(
            STR_TO_DATE(r.actual_delivery, '%m/%d/%Y'),
            STR_TO_DATE(po.order_date, '%m/%d/%Y')
        )
    ),2) AS avg_lead_time
FROM vendors v
	JOIN purchase_orders po ON v.vendor_id = po.vendor_id
	JOIN purchase_order_lines pol ON po.po_id = pol.po_id
    JOIN receipts r ON pol.po_line_id = r.po_line_id
GROUP BY v.vendor_name;

-- Supplier Lead Time Variability
-- Identify vendors with inconsistent delivery performance
SELECT
    v.vendor_name,
    ROUND(
        AVG(
            DATEDIFF(
                STR_TO_DATE(r.actual_delivery, '%m/%d/%Y'),
                STR_TO_DATE(po.order_date, '%m/%d/%Y')
            )
        ), 2
    ) AS avg_lead_time,
    ROUND(STDDEV(
        DATEDIFF(
            STR_TO_DATE(r.actual_delivery, '%m/%d/%Y'),
            STR_TO_DATE(po.order_date, '%m/%d/%Y')
        )
    ),2) AS lead_time_variability
FROM vendors v
JOIN purchase_orders po 
    ON v.vendor_id = po.vendor_id
JOIN purchase_order_lines pol 
    ON po.po_id = pol.po_id
JOIN receipts r 
    ON pol.po_line_id = r.po_line_id
WHERE r.actual_delivery IS NOT NULL
GROUP BY v.vendor_name
ORDER BY lead_time_variability DESC;

-- Purchase Price Variance
-- Compare the standard cost vs actual cost
-- Shows vendor price increases or purchasing inefficiencies
SELECT
    p.product_name,
    p.standard_cost,
    ROUND(AVG(pol.unit_cost),2) AS avg_purchase_price,
    ROUND(AVG(pol.unit_cost) - p.standard_cost,2) AS cost_variance
FROM purchase_order_lines pol
JOIN products p
    ON pol.product_id = p.product_id
GROUP BY p.product_name, p.standard_cost;

-- Vendor Spend Ranking (Window Function)
-- Ranks the vendors to determine which have the most and least spending
SELECT
    RANK() OVER (ORDER BY total_spend DESC) AS vendor_rank,
    vendor_name,
    total_spend
FROM (
    SELECT
        v.vendor_name,
        ROUND(SUM(pol.order_qty * pol.unit_cost)) AS total_spend
    FROM purchase_order_lines pol
    JOIN purchase_orders po
        ON pol.po_id = po.po_id
    JOIN vendors v
        ON po.vendor_id = v.vendor_id
    GROUP BY v.vendor_name
) t;

-- Inventory Days of Supply
-- Determine how long current inventory will last
WITH avg_demand AS (
    SELECT
        product_id,
        ROUND(AVG(forecast_qty),2) AS avg_monthly_demand
    FROM forecast
    GROUP BY product_id
)
SELECT
    i.product_id,
    SUM(i.on_hand_qty) AS inventory_units,
    a.avg_monthly_demand,
    ROUND(SUM(i.on_hand_qty) / a.avg_monthly_demand, 2) AS months_of_supply
FROM inventory i
JOIN avg_demand a
ON i.product_id = a.product_id
GROUP BY i.product_id, a.avg_monthly_demand
ORDER BY months_of_supply;

-- Warehouse Inventory Concentration
-- Identify warehouses holding the majority of inventory
SELECT
    w.warehouse_name,
    SUM(i.on_hand_qty) AS inventory_units,
    ROUND(
        SUM(i.on_hand_qty) /
        SUM(SUM(i.on_hand_qty)) OVER () * 100, 2
    ) AS inventory_percentage
FROM inventory i
JOIN warehouses w
ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name
ORDER BY inventory_percentage DESC;

-- Backorder Risk Detection
-- Identify products where open purchase orders cannot meet forecast demand
WITH open_po AS (
    SELECT
        product_id,
        SUM(order_qty) AS open_po_qty
    FROM purchase_order_lines
    GROUP BY product_id
)
SELECT
    f.product_id,
    SUM(f.forecast_qty) AS forecast_demand,
    o.open_po_qty,
    SUM(f.forecast_qty) - o.open_po_qty AS supply_gap
FROM forecast f
LEFT JOIN open_po o
ON f.product_id = o.product_id
GROUP BY f.product_id, o.open_po_qty
ORDER BY supply_gap DESC;

-- Vendor Fill Rate
-- Measures supplier fulfillment performance
SELECT
    v.vendor_name,
    SUM(pol.order_qty) AS qty_ordered,
    SUM(r.quantity_received) AS qty_received,
    ROUND(
        SUM(r.quantity_received) /
        SUM(pol.quantity_ordered) * 100, 2
    ) AS fill_rate_percent
FROM purchase_order_lines pol
JOIN purchase_orders po
ON pol.po_id = po.po_id
JOIN vendors v
ON po.vendor_id = v.vendor_id
LEFT JOIN receipts r
ON pol.po_line_id = r.po_line_id
GROUP BY v.vendor_name
ORDER BY fill_rate_percent;

-- Inventory Shortage Forecast by Warehouse
-- Identify which warehouses will face shortages
SELECT
    w.warehouse_name,
    p.product_name,
    SUM(f.forecast_qty) AS forecast_demand,
    SUM(i.on_hand_qty) AS inventory_available,
    SUM(f.forecast_qty) - SUM(i.on_hand_qty) AS shortage
FROM forecast f
JOIN products p
ON f.product_id = p.product_id
LEFT JOIN inventory i
ON f.product_id = i.product_id
LEFT JOIN warehouses w
ON i.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name, p.product_name
HAVING shortage > 0
ORDER BY shortage DESC;