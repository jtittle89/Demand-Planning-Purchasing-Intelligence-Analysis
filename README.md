Project Overview

This project demonstrates how raw operational supply chain data can be transformed into structured analytics-ready datasets using MySQL.

The goal of this project is to simulate the responsibilities of a Business Intelligence or Data Analyst supporting Demand Planning and Purchasing teams, including:

    Cleaning messy operational datasets
    Standardizing vendor and product records
    Transforming transactional data into dimensional models
    Generating analytics queries to support purchasing and supply chain decisions

The final result is a cleaned, structured dataset optimized for reporting and dashboard development.

Business Problem

Demand planners and purchasing managers rely on accurate operational data to answer key questions:

Which vendors deliver on time?
Which products experience frequent delays?
What is the average supplier lead time?
Which warehouses are most affected by delayed shipments?

However, raw supply chain data often contains inconsistent vendor names, mixed date formats, missing delivery information, duplicate product records, and unstructured transactional data.

This project demonstrates how SQL can transform this data into reliable analytics datasets.

Tools Used

    MySQL – Data cleaning, transformation, and analytics queries
    SQL Window Functions
    Common Table Expressions (CTEs)
    Data Modeling (Fact & Dimension Tables)

Phase 1 - Data Cleaning

    Step 1 - Hanlding Missing and Null Values
    Explored each dataset for missing or null values
    For missing values assumptions were made and the Update function was used to update the datasets
    
    Step 2 - Standardizing Text Fields
    Created the function ProperCase to convert the text fields into proper case format (Upper first letter of each word and lower following letters)
    Updated all text fields using the function to ensure proper formatting
    
    Step 3 - Check for Negative or Invalid numeric data
    Checked all numeric fields for any negative numbers
    
    Step 4 - Check for Duplicate Primary Keys for Product_ID, Vendor_ID, PO_ID, and Warehouse_ID
    Checked the primary keys in the Vendor, Product, Purchase Order, and Warehouse datasets
    Any duplicates would be deleted from the datasets

Phase 2 - Data Modeling

    Created Dimension tables from the Products, Vendors, and Warehouses tables, as well as a Date table made from the Purchase Orders table
    
    Created Fact tables from the Purchase Orders, Purchase Order Lines, Inventory, Forecast, and Receipts tables
    
    These tables would be used for reporting and dashboard created using a data visualization tool

Phase 3 - Analysis

Used intermediate to advanced SQL skills to analyze:

    1. Inventory levels by warehouse - Show inventory distribution accross warehouses
    2. Purchase volume by vendor - Identifies top suppliers by purchasing spend
    3. Late Vendor Deliveries - Shows supplier performance tracking
    4. Demand vs Inventory GAP Analysis - Used to identify products that will run out based on forecast demand
    5. Supplier On-Time Delivery Rate - Used to evaluate supplier reliability
    6. Supplier Lead Time Performance - Identifies slow vendors affecting supply chain
    7. Supplier Lead Time Variability - Identify vendors with inconsistent delivery performance
    8. Purchase Price Variance - Compare the standard cost vs actual cost to show vendor price increases or purchasing inefficiencies
    9. Vendor Spend Ranking (Window Function) - Ranks the vendors to determine which have the most and least spending
    10. Inventory Days of Supply - Determine how long current inventory will last
    11. Warehouse Inventory Concentration - Identify warehouses holding the majority of inventory
    12. Backorder Risk Detection - Identify products where open purchase orders cannot meet forecast demand
    13. Vendor Fill Rate - Measures supplier fulfillment performance
    14. Inventory Shortage Forecast by Warehouse - Identify which warehouses will face shortages

Key Insights Generated

The SQL analysis can reveal insights such as:

Vendors with the longest and most variable lead times
Products with the highest delay rates
Warehouses experiencing the largest delivery gaps
Suppliers with the highest on-time performance

These insights directly support purchasing decisions and supply chain risk management.

Skills Demonstrated

This project demonstrates practical data analytics and engineering skills including:

SQL Data Engineering

    Data cleaning and transformation
    Data standardization
    Data validation

Data Modeling

    Fact and dimension table design
    Dimensional modeling for analytics

Advanced SQL

    Window functions
    CTEs
    Aggregations and KPI calculations

Business Analytics

    Supply chain metrics
    Vendor performance analysis
    Delivery reliability tracking









