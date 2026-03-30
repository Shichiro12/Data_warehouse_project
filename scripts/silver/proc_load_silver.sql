/*
===========================================================================
Stored procedure: load silver layer (bronze -> silver)
===========================================================================
Script procedure:
  this stored procedure performes the ETL (Extract,Transfers,Load) process
  to populate the 'silver' schema tables from the 'bronze' schema.
Action performed:
  - Truncate silver table.
  - Inserts transformed and cleaned data from Bronze into silver tables.

Parameters:
  none
  this stored procedure does not accept any parameters or return any values.

Usage Example:
  exec silver.load_silver;
==========================================================================
*/
create or alter procedure silver.load_silver as
begin 
declare @start_time datetime,@end_time datetime,@batch_start_time  datetime, @batch_end_time datetime;
	begin try
	set @batch_start_time = GETDATE();
		print'=================================';
		print'loading silver layer';
		print'=================================';

		print'---------------------------------';
		print'loading CRM tables';
		print'---------------------------------';

    set @start_time =GETDATE();
	print'>> truncating table: silver.crm_cust_info';
	truncate table silver.crm_cust_info;
	print'>> inserting data into: silver.crm_cust_info';
	insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)


	select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case when upper(trim(cst_material_status)) = 's' then 'Single'
		 when upper(trim(cst_material_status)) ='M' then 'Married'
		 else 'n/a'
	end cst_material_status, --normalize  marital status values to readable format

	case when upper(trim(cst_gndr)) = 'F' then 'Female'
		 when upper(trim(cst_gndr)) ='M' then 'Male'
		 else 'n/a'
	end cst_gndr,  --normalize gender values to readable format
	cst_create_date
	from(
		select
		*,
		row_number() over ( partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t
	where flag_last = 1; -- select the most recent record per customer
	set @end_time = getdate();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
	print'-------------------------------------'

	set @start_time = getdate();
	print'>> truncating table: silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	print'>> inserting data into: silver.crm_prd_info';

	insert into silver.crm_prd_info(
		prd_id,
		cat_id,  
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)

	select
	prd_id,
	replace(substring(prd_key,1 ,5),'-','_') as cat_id,  --extract category id
	substring(prd_key,7,len(prd_key)) as prd_key, --extract product key
	prd_nm,
	isnull(prd_cost,0) as prd_cost,
	case upper(trim(prd_line))
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other sales'
		when 'T' then 'Touring'
		else 'n/a'
	end as prd_line,  -- map product line codes to descriptive values
	cast(prd_start_dt as date) as prd_start_dt,
	cast(dateadd(day,-1,lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) )as date) 
	as prd_end_dt -- calculate end date as one day before the next stage date 
	from bronze.crm_prd_info
	set @end_time = getdate();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
    print'-------------------------------------'

	set @start_time = getdate();
	print'>> truncating table: silver.crm_sales_details';
	truncate table silver.crm_sales_details;
	print'>> inserting data into: silver.crm_sales_details';

	insert into silver.crm_sales_details(
	sls_ord_num ,
	sls_prd_key ,
	sls_cust_id ,
	sls_order_dt,
	sls_ship_dt ,
	sls_due_dt ,
	sls_sales ,
	sls_quantity ,
	sls_price 
	)                                                                                                                      
	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when cast(sls_order_dt as varchar) = '0' or len(cast(sls_order_dt as varchar)) != 8 then null
		else cast(cast(sls_order_dt as varchar)as date)
	end as sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price <= 0
			then sls_sales / nullif(sls_quantity,0)
		else sls_price
	end as sls_price
	from bronze.crm_sales_details
	set @end_time = getdate();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
	print'-------------------------------------'

	print'---------------------------------';
	print'loading ERP tables';
	print'---------------------------------';

	set @start_time=getdate();
	print'>> truncating table: silver.erp_cust_az12';
	truncate table silver.erp_cust_az12;
	print'>> inserting data into: silver.erp_cust_az12';

	insert into silver.erp_cust_az12(
	cid,
	bdate,
	gen)

	select 
	case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
		else cid
	end as cid,
	case when bdate > getdate() then null
		else bdate
	end as bdate,
	case  
		when upper(trim(gen)) in ('F','Female') then 'Female'
		when upper(trim(gen)) in ('M','Male') then 'Male'
		else 'n/a'
	end as gen
	from bronze.erp_cust_az12
	set @end_time = getdate();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
	print'-------------------------------------'

	set @start_time =getdate();
	print'>> truncating table: silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	print'>> inserting data into: silver.erp_loc_a101';

	insert into silver.erp_loc_a101(
	cid,
	cntry)
	select
	replace(cid,'-','') cid,
	case when trim(cntry) ='DE' then 'Germany'
		when trim(cntry) in ('US','USA') then 'United States'
		when trim(cntry) = '' or cntry is null then 'n/a'
		else trim(cntry)
	end as cntry  -- normalize and handle ,issing or blank country codes
	from bronze.erp_loc_a101 
	set @end_time = GETDATE();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
	print'-------------------------------------'

	set @start_time = getdate();
	print'>> truncating table:  silver.erp_px_cat_g1v2';
	truncate table silver.erp_px_cat_g1v2;
	print'>> inserting data into:  silver.erp_px_cat_g1v2';

	insert into silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
	)
	select 
	id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2
	set @end_time = getdate();
	print'>> load duration : '+ cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
	print'-------------------------------------'

	set @batch_end_time = getdate();
		print'============================================='
		print'loading silver layer is completed';
		print'   - total load duration: '+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds';
		print'============================================='
	end try
	begin catch
	print'==========================================='
		print'ERROR OCCURED DURING LOADING SILVER LAYER'
		print'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		print'==========================================='
	end catch
end
