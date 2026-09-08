/*
=============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=============================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load)
    process to populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

=============================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time=GETDATE();
			PRINT '=======================';
			PRINT 'Loading SILVER Layer'
			PRINT '=======================';

			 PRINT '---------------------------';
			 PRINT 'Loading CRM Tables'
			 PRINT '---------------------------';
			 SET @start_time=GETDATE();
			
 

			PRINT '>> Truncating Table: silver.crm_cust_info';
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT '>> Inserting Data into silver.crm_cust_info';
			INSERT INTO silver.crm_cust_info(
			cst_id,
			csk_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_crete_date
			)
			SELECT 
				cst_id,
				csk_key,
				TRIM(cst_first_name) as cst_firstname,
				TRIM(cst_last_name) as cst_lastname,
				CASE
					WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'MARRIED'
					WHEN UPPER(TRIM(cst_marital_status)) ='S' THEN 'SINGLE'
					ELSE 'n/a'
				END cst_marital_status,

				CASE
					WHEN UPPER(TRIM(cst_gndr)) ='M' THEN 'MALE'
					WHEN UPPER(TRIM(cst_gndr)) ='F' THEN 'FEMALE'
					ELSE 'n/a'
				END cst_gndr,
				cst_create_date
			FROM(
				SELECT 
				*,
				ROW_NUMBER() OVER( PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
				)t
			WHERE flag=1

			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';

			PRINT '>> Truncating Table: silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT '>> Inserting Data into silver.crm_prd_info';

			INSERT INTO silver.crm_prd_info(
			prd_id ,
			cat_id,
			prd_key ,
			prd_nm,
			prd_cost ,
			prd_line ,
			prd_start_dt,
			prd_end_dt 
			)
			SELECT 
			prd_id,

			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key, 
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
				 WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
				 WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
				 WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
				 ELSE 'n/a'
			END prd_line,
			prd_start_dt,
			LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)  AS prd_end_dt
			FROM bronze.crm_prd_info

			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';

			PRINT '>> Truncating Table: silver.crm_sales_details'
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT '>> Inserting Data into silver.crm_sales_details'

			INSERT INTO silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity,
			sls_price 

			)
			SELECT 
			sls_ord_num ,
			sls_prd_key,
			sls_cust_id ,

			CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
			END AS sls_ship_dt ,
			CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
			END AS sls_due_dt,

			CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!=sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
				 ELSE sls_sales
			END sls_sales,
			sls_quantity ,
			CASE WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales/NULLIF(sls_quantity,0)
				 ELSE sls_price
			END sls_price

			FROM bronze.crm_sales_details

			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			PRINT '>> Truncating Table: silver.erp_CPX_CAT_G1V2';
			TRUNCATE TABLE silver.erp_CPX_CAT_G1V2;
			PRINT '>> Inserting Data into silver.erp_CPX_CAT_G1V2';

			INSERT INTO silver.erp_CPX_CAT_G1V2(
			ID ,
			CAT,
			SUBCAT,
			MAINTENANCE

			)

			SELECT
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
			FROM bronze.erp_CPX_CAT_G1V2

			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			PRINT '>> Truncating Table: silver.erp_CUST_AZ12';
			TRUNCATE TABLE silver.erp_CUST_AZ12;
			PRINT '>> Inserting Data into silver.erp_CUST_AZ12';

			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			INSERT INTO silver.erp_CUST_AZ12(
			CID ,
			BDATE ,
			GEN 

			)
			SELECT
			CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
				 ELSE CID
			END cid,

			CASE WHEN BDATE>GETDATE() THEN NULL
				 ELSE BDATE
			END AS bdate,
			CASE WHEN UPPER(TRIM(GEN)) IN ('F','Female') THEN 'Female'
				 WHEN UPPER(TRIM(GEN)) IN ('M','Male') THEN 'Male'
				 ELSE 'n/a'
			END gen
			FROM bronze.erp_CUST_AZ12

			PRINT '>> Truncating Table: silver.erp_LOC_A101';
			TRUNCATE TABLE silver.erp_LOC_A101;
			PRINT '>> Inserting Data into silver.erp_LOC_A101';


			INSERT INTO silver.erp_LOC_A101(
			cid,
			cntry)
			SELECT
			REPLACE(CID,'-','') cid,

			CASE WHEN TRIM(cntry)='DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				 WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(CNTRY)
			END cntry
			FROM bronze.erp_LOC_A101
	
				SET @end_time=GETDATE();
				PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';
				PRINT '------------------'
		SET @batch_end_time=GETDATE();
		PRINT '---------------------';
		PRINT '>>TOTAL Load Duration ' +CAST(DATEDIFF(SECOND, @batch_start_time,@batch_end_time )AS NVARCHAR) + 'seconds';
		PRINT '---------------------';

 END TRY
 BEGIN CATCH
	PRINT '==================================';
	PRINT 'ERROR OCCURED DURING BRONZE LAYER'
	PRINT '==================================';
 END CATCH
END
