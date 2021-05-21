/*****************************************************************************
*   FileName:  Create Enlarged AdventureWorks Tables.sql
*
*   Summary: Creates an enlarged version of the AdventureWorks database
*            for use in demonstrating SQL Server performance tuning and
*            execution plan issues.
*
*   Date: November 14, 2011 
*
*   SQL Server Versions:
*         2008, 2008R2, 2012
*         
******************************************************************************
*   Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlskills.com/blogs/jonathan
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
*****************************************************************************/

use AdventureWorks;
go

if OBJECT_ID('Sales.SalesOrderHeaderEnlarged') is not null
	drop table Sales.SalesOrderHeaderEnlarged;
go

create table Sales.SalesOrderHeaderEnlarged
(
	SalesOrderID           int not null identity(1, 1) not for replication, 
	RevisionNumber         tinyint not null, 
	OrderDate              datetime not null, 
	DueDate                datetime not null, 
	ShipDate               datetime null, 
	status                 tinyint not null, 
	OnlineOrderFlag        dbo.Flag not null, 
	SalesOrderNumber as ISNULL(N'SO' + CONVERT(nvarchar(23), SalesOrderID, 0), N'*** ERROR ***'), 
	PurchaseOrderNumber    dbo.OrderNumber null, 
	AccountNumber          dbo.AccountNumber null, 
	CustomerID             int not null, 
	SalesPersonID          int null, 
	TerritoryID            int null, 
	BillToAddressID        int not null, 
	ShipToAddressID        int not null, 
	ShipMethodID           int not null, 
	CreditCardID           int null, 
	CreditCardApprovalCode varchar(15) null, 
	CurrencyRateID         int null, 
	SubTotal               money not null, 
	TaxAmt                 money not null, 
	Freight                money not null, 
	TotalDue as ISNULL(SubTotal + TaxAmt + [Freight], 0), 
	Comment                nvarchar(128) null, 
	rowguid                uniqueidentifier not null
											rowguidcol, 
	ModifiedDate           datetime not null) 
on [PRIMARY];
go

set identity_insert Sales.SalesOrderHeaderEnlarged on;
go

insert into Sales.SalesOrderHeaderEnlarged (SalesOrderID, 
											RevisionNumber, 
											OrderDate, 
											DueDate, 
											ShipDate, 
											status, 
											OnlineOrderFlag, 
											PurchaseOrderNumber, 
											AccountNumber, 
											CustomerID, 
											SalesPersonID, 
											TerritoryID, 
											BillToAddressID, 
											ShipToAddressID, 
											ShipMethodID, 
											CreditCardID, 
											CreditCardApprovalCode, 
											CurrencyRateID, 
											SubTotal, 
											TaxAmt, 
											Freight, 
											Comment, 
											rowguid, 
											ModifiedDate) 
select SalesOrderID, 
	   RevisionNumber, 
	   OrderDate, 
	   DueDate, 
	   ShipDate, 
	   status, 
	   OnlineOrderFlag, 
	   PurchaseOrderNumber, 
	   AccountNumber, 
	   CustomerID, 
	   SalesPersonID, 
	   TerritoryID, 
	   BillToAddressID, 
	   ShipToAddressID, 
	   ShipMethodID, 
	   CreditCardID, 
	   CreditCardApprovalCode, 
	   CurrencyRateID, 
	   SubTotal, 
	   TaxAmt, 
	   Freight, 
	   Comment, 
	   rowguid, 
	   ModifiedDate
from Sales.SalesOrderHeader with (holdlock tablockx);
go

set identity_insert Sales.SalesOrderHeaderEnlarged off;

go

alter table Sales.SalesOrderHeaderEnlarged
add constraint PK_SalesOrderHeaderEnlarged_SalesOrderID primary key clustered(SalesOrderID)
	with(statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];

go

create unique nonclustered index AK_SalesOrderHeaderEnlarged_rowguid on Sales.SalesOrderHeaderEnlarged
(rowguid) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

create unique nonclustered index AK_SalesOrderHeaderEnlarged_SalesOrderNumber on Sales.SalesOrderHeaderEnlarged
(SalesOrderNumber) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

create nonclustered index IX_SalesOrderHeaderEnlarged_CustomerID on Sales.SalesOrderHeaderEnlarged
(CustomerID) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

create nonclustered index IX_SalesOrderHeaderEnlarged_SalesPersonID on Sales.SalesOrderHeaderEnlarged
(SalesPersonID) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

if OBJECT_ID('Sales.SalesOrderDetailEnlarged') is not null
	drop table Sales.SalesOrderDetailEnlarged;
go

create table Sales.SalesOrderDetailEnlarged
(
	SalesOrderID          int not null, 
	SalesOrderDetailID    int not null identity(1, 1), 
	CarrierTrackingNumber nvarchar(25) null, 
	OrderQty              smallint not null, 
	ProductID             int not null, 
	SpecialOfferID        int not null, 
	UnitPrice             money not null, 
	UnitPriceDiscount     money not null, 
	LineTotal as ISNULL(( UnitPrice * ( 1.0 - [UnitPriceDiscount] ) ) * OrderQty, 0.0), 
	rowguid               uniqueidentifier not null
										   rowguidcol, 
	ModifiedDate          datetime not null) 
on [PRIMARY];
go

set identity_insert Sales.SalesOrderDetailEnlarged on;
go

insert into Sales.SalesOrderDetailEnlarged (SalesOrderID, 
											SalesOrderDetailID, 
											CarrierTrackingNumber, 
											OrderQty, 
											ProductID, 
											SpecialOfferID, 
											UnitPrice, 
											UnitPriceDiscount, 
											rowguid, 
											ModifiedDate) 
select SalesOrderID, 
	   SalesOrderDetailID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   SpecialOfferID, 
	   UnitPrice, 
	   UnitPriceDiscount, 
	   rowguid, 
	   ModifiedDate
from Sales.SalesOrderDetail with (holdlock tablockx);
go

set identity_insert Sales.SalesOrderDetailEnlarged off;
go

alter table Sales.SalesOrderDetailEnlarged
add constraint PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID primary key clustered(SalesOrderID, SalesOrderDetailID)
	with(statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];

go

create unique nonclustered index AK_SalesOrderDetailEnlarged_rowguid on Sales.SalesOrderDetailEnlarged
(rowguid) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

create nonclustered index IX_SalesOrderDetailEnlarged_ProductID on Sales.SalesOrderDetailEnlarged
(ProductID) 
	with (statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY];
go

begin transaction;

declare @TableVar table
(
	OrigSalesOrderID int, 
	NewSalesOrderID  int);

insert into Sales.SalesOrderHeaderEnlarged (RevisionNumber, 
											OrderDate, 
											DueDate, 
											ShipDate, 
											status, 
											OnlineOrderFlag, 
											PurchaseOrderNumber, 
											AccountNumber, 
											CustomerID, 
											SalesPersonID, 
											TerritoryID, 
											BillToAddressID, 
											ShipToAddressID, 
											ShipMethodID, 
											CreditCardID, 
											CreditCardApprovalCode, 
											CurrencyRateID, 
											SubTotal, 
											TaxAmt, 
											Freight, 
											Comment, 
											rowguid, 
											ModifiedDate) 
output inserted.Comment, 
	   inserted.SalesOrderID
	   into @TableVar
select RevisionNumber, 
	   DATEADD(dd, number, OrderDate) as OrderDate, 
	   DATEADD(dd, number, DueDate), 
	   DATEADD(dd, number, ShipDate), 
	   status, 
	   OnlineOrderFlag, 
	   PurchaseOrderNumber, 
	   AccountNumber, 
	   CustomerID, 
	   SalesPersonID, 
	   TerritoryID, 
	   BillToAddressID, 
	   ShipToAddressID, 
	   ShipMethodID, 
	   CreditCardID, 
	   CreditCardApprovalCode, 
	   CurrencyRateID, 
	   SubTotal, 
	   TaxAmt, 
	   Freight, 
	   SalesOrderID, 
	   NEWID(), 
	   DATEADD(dd, number, ModifiedDate)
from Sales.SalesOrderHeader as soh with (holdlock tablockx)
	 cross join
(
	select number
	from
	(
		select top 10 number
		from master.dbo.spt_values
		where type = N'P'
			  and number < 1000
		order by NEWID() desc
		union
		select top 10 number
		from master.dbo.spt_values
		where type = N'P'
			  and number < 1000
		order by NEWID() desc
		union
		select top 10 number
		from master.dbo.spt_values
		where type = N'P'
			  and number < 1000
		order by NEWID() desc
		union
		select top 10 number
		from master.dbo.spt_values
		where type = N'P'
			  and number < 1000
		order by NEWID() desc
	) as tab
) as Randomizer
order by OrderDate, 
		 number;

insert into Sales.SalesOrderDetailEnlarged (SalesOrderID, 
											CarrierTrackingNumber, 
											OrderQty, 
											ProductID, 
											SpecialOfferID, 
											UnitPrice, 
											UnitPriceDiscount, 
											rowguid, 
											ModifiedDate) 
select tv.NewSalesOrderID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   SpecialOfferID, 
	   UnitPrice, 
	   UnitPriceDiscount, 
	   NEWID(), 
	   ModifiedDate
from Sales.SalesOrderDetail as sod
	 join @TableVar as tv on sod.SalesOrderID = tv.OrigSalesOrderID
order by sod.SalesOrderDetailID;

commit;