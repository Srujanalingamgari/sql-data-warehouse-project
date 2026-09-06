/*
=============================================================
  Stored Procedure : Load Bronze Layer (Source --> Bronze)
=============================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
	SET @batch_start_time=GETDATE();
			PRINT '=======================';
			PRINT 'Loading BRONZE Layer'
			PRINT '=======================';

			 PRINT '---------------------------';
			 PRINT 'Loading CRM Tables'
			 PRINT '---------------------------';

			SET @start_time=GETDATE();
			TRUNCATE TABLE bronze.crm_cust_info;

			BULK INSERT bronze.crm_cust_info
			FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK

			);
			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';

			SET @start_time=GETDATE();
			TRUNCATE TABLE bronze.crm_prd_info;

			BULK INSERT bronze.crm_prd_info
			FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK

			);
			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			SET @start_time=GETDATE();
			TRUNCATE TABLE bronze.crm_sales_details;

			BULK INSERT bronze.crm_sales_details
			FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK

			);
			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			 PRINT '---------------------------';
			 PRINT 'Loading ERP Tables'
			 PRINT '---------------------------';

			 SET @start_time=GETDATE();
			TRUNCATE TABLE bronze.erp_CUST_AZ12;

			BULK INSERT bronze.erp_CUST_AZ12
			FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK

			);
			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


			SET @start_time=GETDATE();

			TRUNCATE TABLE bronze.erp_LOC_A101;

			BULK INSERT bronze.erp_LOC_A101
			FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK

			);
			SET @end_time=GETDATE();
			PRINT '>> Load Duration ' +CAST(DATEDIFF(SECOND, @start_time,@end_time )AS NVARCHAR) + 'seconds';


		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_CPX_CAT_G1V2;

		BULK INSERT bronze.erp_CPX_CAT_G1V2
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK

		);
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
