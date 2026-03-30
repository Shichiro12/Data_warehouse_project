/*
============================================================================
DDL scripts: create Silver tables
============================================================================
Script purpose:
  this script creates tables in the 'silver' schema,dropping existing tables
  if they already exists.
  run this script to re-define the DDL structure of 'bronze' tables
============================================================================
*/
if object_id('silver.crm_cust_info','u') is not null
	drop table silver.crm_cust_info;
go
  
create table silver.crm_cust_info (
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_material_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date,
dwh_create_date datetime2 default getdate()
);
go
  
if object_id('silver.crm_prd_info','u') is not null
	drop table silver.crm_prd_info;
go
  
create table silver.crm_prd_info (
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost nvarchar(50),
prd_line nvarchar(50),
prd_start_dt date,
prd_end_dt date,
dwh_create_date datetime2 default getdate()
);
go
  
if object_id('silver.crm_sales_details','u') is not null
	drop table silver.crm_sales_details;
go
  
create table silver.crm_sales_details (
sls_ord_num varchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt varchar(50),
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date datetime2 default getdate()

);
go
  
if object_id('silver.erp_CUST_AZ12','u') is not null
	drop table silver.erp_CUST_AZ12;
go
  
create table silver.erp_cust_az12 (
cid varchar(50),
bdate date,
gen nvarchar(50),
dwh_create_date datetime2 default getdate()
);
go 
  
if object_id('silver.erp_LOC_A101','u') is not null
	drop table silver.erp_LOC_A101;
create table silver.erp_loc_a101 (
cid varchar(50),
cntry nvarchar(50),
dwh_create_date datetime2 default getdate()
);
go 
  
if object_id('silver.erp_PX_CAT_G1V2 ','u') is not null
	drop table silver.erp_PX_CAT_G1V2 ;
go
  
create table silver.erp_px_cat_g1v2 (
id varchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50),
dwh_create_date datetime2 default getdate()
);
