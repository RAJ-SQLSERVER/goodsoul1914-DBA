/****************************************************************
Course by: 	Pinal Dave  (http://blog.sqlauthority.com)
			Vinod Kumar (http://blogs.extremeExperts.com)

Scripts for SQL Server Performance: Indexing Course Pluralsight.

Description: Script to show how Defragmentation happens
****************************************************************/

use [AdventureWorks];
go

-- Create New Table Empty Table

select *
into Sales.DefragSalesOrderDetail
from Sales.SalesOrderDetail
where 1 = 2;
go

----------------------------------------------------------------------------------
-- Create Non-Clustered Index

create clustered index IX_DefragSalesOrderDetail_SalesOrderDetailID on Sales.DefragSalesOrderDetail
(SalesOrderDetailID asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_DefragSalesOrderDetail_OrderQty on Sales.DefragSalesOrderDetail
(OrderQty asc) 
	on [PRIMARY];
go

-- Create Non-Clustered Index

create nonclustered index IX_DefragSalesOrderDetail_ProductID on Sales.DefragSalesOrderDetail
(ProductID asc) 
	on [PRIMARY];
go

-- Inserting the data

insert into Sales.DefragSalesOrderDetail (SalesOrderID, 
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

----------------------------------------------------------------------------------
-- Identify Index Defragmentation

select ps.database_id, 
	   OBJECT_NAME(ps.OBJECT_ID), 
	   ps.index_id, 
	   b.name, 
	   ps.avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null) as ps
	 inner join sys.indexes as b on ps.OBJECT_ID = b.OBJECT_ID
									and ps.index_id = b.index_id
where ps.database_id = DB_ID()
	  and b.OBJECT_ID = OBJECT_ID('Sales.DefragSalesOrderDetail')
order by ps.OBJECT_ID;
go

----------------------------------------------------------------------------------
-- Rebuild and Reorganize Script
----------------------------------------------------------------------------------
-- Reorganization

alter index IX_DefragSalesOrderDetail_OrderQty on Sales.DefragSalesOrderDetail reorganize;
go

-- Rebuild

alter index IX_DefragSalesOrderDetail_ProductID on Sales.DefragSalesOrderDetail rebuild;
go

-- Rebuild

alter index all on Sales.DefragSalesOrderDetail rebuild;
go

----------------------------------------------------------------------------------
-- Index Maintenance Script http://ola.hallengren.com

execute master.dbo.IndexOptimize @Databases = 'AdventureWorks';
go

----------------------------------------------------------------------------------
-- Clean up

drop table Sales.DefragSalesOrderDetail;
go