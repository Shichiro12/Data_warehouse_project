/*
=======================================================================================
Stored Procedure: load bronze layer (source -> bronze)
=======================================================================================
Script purpose:
  this stored procedure loads into the   'bronze' schema from external csv files.
  it performs the following actions:
  - Truncates the  bronze tables before loading data.
  - uses the 'BULK INSERT' command to load data from csv files to bronzxe table.

parameters:
   none.
  this stored procedure does not accept any parameters or return any values.

usage example:
  exec bronze.load_bronze;
=======================================================================================
*/


create or alter procedure bronze.load_bronze as
begin
	declare @start_time datetime,@end_time datetime,@batch_start_time  datetime, @batch_end_time datetime;
	begin try
	set @batch_start_time = GETDATE();
		print'=================================';
		print'loading bronze layer';
		print'=================================';

		print'---------------------------------';
		print'loading CRM tables';
		print'---------------------------------';


		set @start_time =GETDATE();
		truncate table bronze.crm_cust_info;
		bulk insert bronze.crm_cust_info
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'

		set @start_time =GETDATE();
		truncate table bronze.crm_prd_info;
		bulk insert bronze.crm_prd_info
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'

		set @start_time =GETDATE();
		truncate table bronze.crm_sales_details;
		bulk insert bronze.crm_sales_details
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'
	    
		print'---------------------------------';
		print'loading ERP tables';
		print'---------------------------------';

		set @start_time =GETDATE();
		truncate table bronze.erp_cust_az12;
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'

		set @start_time =GETDATE();
		truncate table bronze.erp_loc_a101;
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'

		set @start_time =GETDATE();
		truncate table bronze.erp_px_cat_g1v2;
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\smscs\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =GETDATE();
		print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		print'-------------------------------------'

		set @batch_end_time = getdate();
		print'============================================='
		print'loading bronze layer is completed';
		print'   - total load duration: '+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds';
		print'============================================='
	end try
	begin catch
		print'==========================================='
		print'ERROR OCCURED DURING LOADING BRONZE LAYER'
		print'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		print'==========================================='
	end catch
end
