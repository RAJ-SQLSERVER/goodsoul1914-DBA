/******************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course Pluralsight.

Description: Shows the effect of Duplicate Indexes with SQL Server.
******************************************************************/

use [AdventureWorks];
go

set nocount on;

-- Create New Table Empty Table

select *
into Sales.DupSalesOrderDetail
from Sales.SalesOrderDetail
where 1 = 2;
go

-- Measure Time

set statistics time on;

set statistics io on;
go

-- Measure the Insert time in New Table

insert into Sales.DupSalesOrderDetail (SalesOrderID, 
									   CarrierTrackingNumber, 
									   OrderQty, 
									   ProductID, 
									   SpecialOfferID, 
									   UnitPrice, 
									   UnitPriceDiscount, 
									   LineTotal, 
									   rowguid, 
									   ModifiedDate) 
select SalesOrderID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   SpecialOfferID, 
	   UnitPrice, 
	   UnitPriceDiscount, 
	   LineTotal, 
	   rowguid, 
	   ModifiedDate
from Sales.SalesOrderDetail; 
go 5

-- Truncate Table

truncate table Sales.DupSalesOrderDetail;
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber1 on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber2 on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber3 on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber4 on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_NewSalesOrderDetail_CarrierTrackingNumber5 on Sales.DupSalesOrderDetail
(CarrierTrackingNumber asc) 
	on [PRIMARY];
go

-- Measure the Insert time in New Table

insert into Sales.DupSalesOrderDetail (SalesOrderID, 
									   CarrierTrackingNumber, 
									   OrderQty, 
									   ProductID, 
									   SpecialOfferID, 
									   UnitPrice, 
									   UnitPriceDiscount, 
									   LineTotal, 
									   rowguid, 
									   ModifiedDate) 
select SalesOrderID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   SpecialOfferID, 
	   UnitPrice, 
	   UnitPriceDiscount, 
	   LineTotal, 
	   rowguid, 
	   ModifiedDate
from Sales.SalesOrderDetail; 
go 5

-- Clean up

drop table Sales.DupSalesOrderDetail;
go