--check for unwanted spaces
--expectation: no results
select cst_lastname
from silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

--data standardization and consisitency
select  distinct cst_gndr
from silver.crm_cust_info

--check for invalid date
select * from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt
