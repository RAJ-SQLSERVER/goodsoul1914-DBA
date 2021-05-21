-- =================================================
-- Demonstrates the semantics of the Tipping Point
-- =================================================

use master;
go

set statistics io on;

set statistics time on;
go

create database TippingPoint;
go

use TippingPoint;
go

-- Create a table with 393 length + 7 bytes overhead = 400 bytes
-- Therefore 20 records can be stored on 1 page (8096 / 400) = 20,24

create table Customers
(
	CustomerID      int not null, 
	CustomerName    char(100) not null, 
	CustomerAddress char(100) not null, 
	Comments        char(185) not null, 
	Value           int not null);
go

-- Create a unique clustered index

create unique clustered index idx_Customers on Customers
(CustomerID);
go

-- Insert 80000 records

declare @i int = 1;

while @i <= 80000
begin
	insert into Customers
	values (@i, 'CustomerName' + CAST(@i as char), 'CustomerAddress' + CAST(@i as char), 'Comments' + CAST(@i as char), @i);

	set @i+=1;
end;
go

-- Create a new NCI

create unique nonclustered index idx_Test on Customers
(Value);
go

-- Retrieve the inserted data

select *
from Customers;
go	-- 4.016 logical reads
-- Our table has 4.000 pages, so the tipping point is somewhere between
-- 1.000 / 80000 = 1,25%
-- 1.333 / 80000 = 1,67%
-- The following query does a bookmark lookup
-- We are reading 1.061 records, which is about 1,3% of the overall table
-- The query produces 3.262 I/Os, where about 1/3 are data page reads

select *
from Customers
where Value < 1062;
go

-- The following query does a clustered index scan.
-- The query produces 4.016 I/Os

select *
from Customers
where Value < 1064;	-- not selective enough anymore
go

-- Retrieve all records through a bookmark lookup
-- The query produces 245.141 page reads!!!

select *
from Customers with (index(idx_Test))
where Value < 80001;
go