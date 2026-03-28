/*
=========================================================
Create database and schemas
=========================================================
Script purpose:
	this script creates a new database named 'DataWarehouse' after checking if it already exists.
	if the database exists, it is dropped and recreated. additionally, the scripts sets up three schemas
	within the database: 'bronze','silver', and 'gold'.

WARNING:
	running this scripts will drop the entire 'datawarehouse' database if it exists.
	all data in the database will be permanently deleted. proceed with caution
	

*/

use master;
go

--drop and recieve the 'Datawarehouse' database
if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin 
	alter database DataWarehouse;
	drop database DataWarehouse;
end;
go

-- Create the 'Datawarehouse' Database
Create database DataWarehouse;
go

use DataWarehouse;
go

--create schemas;
Create schema bronze;
go 


cretae schema silverl;
go


create schema gold;
go
