use SalesDB
go

-- Backup table before deletion
select *
into dbo.Customers_backup
from dbo.Customers;
go

-- Show constraints
select tc.CONSTRAINT_TYPE, 
	   tc.CONSTRAINT_NAME, 
	   tc.TABLE_NAME
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc
where tc.TABLE_CATALOG = 'SalesDB'
	  and tc.TABLE_NAME = 'Customers'
union
select CONCAT('referenced in table: ', tc1.TABLE_NAME) as CONSTRAINT_TYPE, 
	   tc1.CONSTRAINT_NAME, 
	   tc2.TABLE_NAME
from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS as rc
inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc1 on rc.CONSTRAINT_NAME = tc1.CONSTRAINT_NAME
inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc2 on rc.UNIQUE_CONSTRAINT_NAME = tc2.CONSTRAINT_NAME
where rc.CONSTRAINT_CATALOG = 'SalesDB'
	  and tc2.TABLE_NAME = 'Customers';
go

/*
 CONSTRAINT_TYPE					CONSTRAINT_NAME		TABLE_NAME
 ----------------------------------|-------------------|-----------
 PRIMARY KEY						CustomerPK			Customers
 referenced in table: Sales	Sales	CustomersFK			Customers
*/

-- Show extended table info
sp_help 'dbo.Customers'

-- Deleting the table, will result in an error
drop table Customers
go

-- First: backup key constraints
alter table dbo.Customers
add constraint CustomerPK primary key clustered(CustomerID asc) on [PRIMARY];
go

alter table dbo.Sales
with check
add constraint SalesCustomersFK foreign key(CustomerID) references dbo.Customers(CustomerID) on update cascade;
go
alter table dbo.Sales check constraint SalesCustomersFK;
go

-- Second: delete key constraints
alter table dbo.Sales drop constraint SalesCustomersFK;
go
alter table dbo.Customers drop constraint CustomerPK;
go

-- Now try dropping the table
drop table Customers
go

-- Okay, this time it worked!
-- But wait, we didn't mean to....

-- Copy backup data into original table
select *
into dbo.Customers
from dbo.Customers_backup;
go

-- Re-apply all constraints
alter table dbo.Customers
add constraint CustomerPK primary key clustered(CustomerID asc) on [PRIMARY];
go

alter table dbo.Sales
with check
add constraint SalesCustomersFK foreign key(CustomerID) references dbo.Customers(CustomerID) on update cascade;
go
alter table dbo.Sales check constraint SalesCustomersFK;
go
