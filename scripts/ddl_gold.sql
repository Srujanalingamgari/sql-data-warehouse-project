/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id as customer_id,
ci.csk_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
CASE WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr
	 ELSE COALESCE(ca.gen,'n/a')
END gender, 
ca.bdate as birthdate,
ci.cst_crete_date as create_date
  GO
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO


FROM silver.crm_cust_info as ci
LEFT JOIN silver.erp_CUST_AZ12 as ca
ON		  ci.csk_key=ca.cid
LEFT JOIN silver.erp_LOC_A101 as la
ON		  ci.csk_key=la.CID


CREATE VIEW gold.dim_products as
SELECT 
	ROW_NUMBER() OVER(ORDER BY pd.prd_start_dt,pd.prd_key) as product_key,
	pd.prd_id  AS product_id,
	pd.prd_key as product_number,
	pd.prd_nm AS product_name,
	pd.cat_id AS category_id,
	pc.CAT AS category,
	pc.SUBCAT AS subcategory,
	pc.MAINTENANCE AS maintenance,
	pd.prd_cost AS cost,
	pd.prd_line AS product_line,
	pd.prd_start_dt AS start_date
FROM silver.crm_prd_info as pd
LEFT JOIN silver.erp_CPX_CAT_G1V2 as pc
ON pd.cat_id=pc.ID
WHERE prd_end_dt IS NULL
  GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS

	SELECT
			sd.sls_ord_num AS order_number,
			pr.product_key ,
			cu.customer_key,
			
			sd.sls_order_dt as order_date ,
			sd.sls_ship_dt as ship_date ,
			sd.sls_due_dt as due_date ,
			sd.sls_sales as sales_amount,
			sd.sls_quantity as quantity,
			sd.sls_price as price 
FROM silver.crm_sales_details as sd
LEFT JOIN  gold.dim_products pr
on sd.sls_prd_key=pr.product_number
LEFT JOIN  gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id
GO

