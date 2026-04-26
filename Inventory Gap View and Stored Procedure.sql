-- Inventory Gap View

CREATE VIEW vw_inventory_gap AS
SELECT
    f.product_id,
    SUM(f.forecast_qty) AS forecast_demand,
    SUM(i.on_hand_qty) AS inventory_available,
    SUM(f.forecast_qty) - SUM(i.on_hand_qty) AS demand_gap
FROM forecast f
LEFT JOIN inventory i
ON f.product_id = i.product_id
GROUP BY f.product_id;

-- Inventory Gap Stored Procedure
CREATE PROCEDURE inventory_gap_report()
SELECT *
FROM vw_inventory_gap
WHERE demand_gap > 0;