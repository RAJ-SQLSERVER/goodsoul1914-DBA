use Playground;
go

select 
	COUNT(*)
from dbo.LargeTable;
go

/*******
option 1
*******/

exec ('select COUNT(*) TotalRows from dbo.LargeTable;');
go

/*******
option 2
*******/

declare @SchemaName nvarchar(20) = 'dbo';
declare @TableName nvarchar(50) = 'LargeTable';
exec ('select COUNT(*) TotalRows from '+@SchemaName+'.'+@TableName);
go

/*******
option 3
*******/

declare @SchemaName nvarchar(20) = QUOTENAME('dbo');
declare @TableName nvarchar(50) = QUOTENAME('LargeTable');
declare @ObjectName nvarchar(75) = @SchemaName + '.' + @TableName;
print 'select COUNT(*) TotalRows from ' + @ObjectName;
exec ('select COUNT(*) TotalRows from '+@ObjectName);
go

/*******
option 4
*******/

declare @SchemaName nvarchar(20) = QUOTENAME('dbo');
declare @TableName nvarchar(50) = QUOTENAME('LargeTable');
declare @ObjectName nvarchar(75) = @SchemaName + '.' + @TableName;
declare @SQL nvarchar(255) = 'select COUNT(*) TotalRows from ' + @ObjectName;
exec (@SQL);
go

/*******
option 5
*******/

declare @SchemaName nvarchar(20) = QUOTENAME('dbo');
declare @TableName nvarchar(50) = QUOTENAME('LargeTable');
declare @ObjectName nvarchar(75) = @SchemaName + '.' + @TableName;
declare @SQL nvarchar(255) = 'select COUNT(*) TotalRows from ' + @ObjectName;
exec sp_executesql @SQL;
go

/**************************************************************************************************************
 option 6: Execute the following statement(s) to understand the effect of dynamic SQL on Environmental settings
**************************************************************************************************************/

-- Query 1: Changes don't affect outer batch
use Playground;
declare @db as nvarchar(30);
set @db = QUOTENAME(N'master');
exec (N'use '+@db+';');
select 
	DB_NAME();
go

-- Query 2: Changes affect inner batch
use Playground;
declare @db as nvarchar(30);
set @db = QUOTENAME(N'master');
exec (N'use '+@db+';'+N'select DB_NAME()');
go

/*********************************************************
option 7: plan will not be parameterized when you use EXEC
*********************************************************/

dbcc freeproccache;
go

declare @i int;
set @i = 570005;

declare @sql varchar(52);
set @sql = 'select * from dbo.LargeTable where Number = ' + CAST(@i as varchar(10)) + N';';
exec (@sql);
go

declare @i int;
set @i = 570015;

declare @sql varchar(52);
set @sql = 'select * from dbo.LargeTable where Number = ' + CAST(@i as varchar(10)) + N';';
exec (@sql);
go

declare @i int;
set @i = 570025;

declare @sql varchar(52);
set @sql = 'select * from dbo.LargeTable where Number = ' + CAST(@i as varchar(10)) + N';';
exec (@sql);
go

select 
	cacheobjtype, 
	objtype, 
	usecounts, 
	sql
from sys.syscacheobjects
where sql not like '%cache%'
	  and sql not like '%sys.%';
go

/***************************************************************
 option 8: plan will be parameterized when you use sp_executesql
***************************************************************/

dbcc freeproccache;
go

declare @i int = 570005;
declare @sql nvarchar(100);
set @sql = N'select * from dbo.LargeTable where Number = @Number;';
exec sp_executesql @stmt = @sql, @params = N'@Number int', @Number = @i;
go

declare @i int = 570015;
declare @sql nvarchar(100);
set @sql = N'select * from dbo.LargeTable where Number = @Number;';
exec sp_executesql @stmt = @sql, @params = N'@Number int', @Number = @i;
go

declare @i int = 570025;
declare @sql nvarchar(100);
set @sql = N'select * from dbo.LargeTable where Number = @Number;';
exec sp_executesql @stmt = @sql, @params = N'@Number int', @Number = @i;
go

select 
	cacheobjtype, 
	objtype, 
	usecounts, 
	sql
from sys.syscacheobjects
where sql not like '%cache%'
	  and sql not like '%sys.%';
go

/****************************
option 9: Dynamic Pivot Query
****************************/

use AdventureWorks2014;
go

declare @DynamicPivotQuery nvarchar(max);
declare @ColumnName nvarchar(max);

select 
	@ColumnName = ISNULL(@ColumnName + ',', '') + QUOTENAME([YEAR])
from (select distinct 
		  YEAR(TransactionDate) as [YEAR]
	  from Production.TransactionHistory
	  union
	  select distinct 
		  YEAR(TransactionDate) as [YEAR]
	  from Production.TransactionHistoryArchive) as PvtSource
order by 
	[YEAR];

--select 
--	@ColumnName;

set @DynamicPivotQuery = N'select TransactionType, ' + @ColumnName + ' 
	from (select 
				TransactionType, 
				ActualCost, 
				YEAR(TransactionDate) as [YEAR]
			from Production.TransactionHistory
			union all
			select 
				TransactionType, 
				ActualCost, 
				YEAR(TransactionDate) as [YEAR]
			from Production.TransactionHistoryArchive) as sq 
	PIVOT(SUM([ActualCost]) FOR [YEAR] IN (' + @ColumnName + ')) as pvt';

exec sp_executesql @DynamicPivotQuery;

/************************************************
option 10: Fix index fragmentation of all indexes
************************************************/

set nocount on;

use AdventureWorks2014;
go

declare @objectid int;
declare @indexid int;
declare @partitioncount bigint;
declare @partitionnum bigint;
declare @partitions bigint;
declare @schemaname nvarchar(255);
declare @objectname nvarchar(255);
declare @indexname nvarchar(255);
declare @frag float;
declare @command varchar(8000);

-- Ensure temp table does not exist
if exists (select 
			   name
		   from sys.objects
		   where name = 'work_to_do') 
	drop table work_to_do;

-- Conditionally select from the function, converting object and index IDs to names
select 
	object_id as objectid, 
	index_id as indexid, 
	partition_number as partitionnum, 
	avg_fragmentation_in_percent as frag
into 
	work_to_do
from sys.dm_db_index_physical_stats (DB_ID(), null, null, null, 'LIMITED')
where avg_fragmentation_in_percent > 10.0
	  and index_id > 0;

-- Declare the cursor for the list of partitions to be processed
declare partitions cursor
for select 
		*
	from work_to_do;

-- Open the cursor
open partitions;

-- Loop through the partitions
fetch next from partitions into @objectid, 
								@indexid, 
								@partitionnum, 
								@frag;

while @@FETCH_STATUS = 0
begin
	select 
		@objectname = QUOTENAME(o.name), 
		@schemaname = QUOTENAME(s.name)
	from sys.objects as o
		 join sys.schemas as s on s.schema_id = o.schema_id
	where o.object_id = @objectid;

	select 
		@indexname = QUOTENAME(name)
	from sys.indexes
	where object_id = @objectid
		  and index_id = @indexid;

	select 
		@partitioncount = COUNT(*)
	from sys.partitions
	where object_id = @objectid
		  and index_id = @indexid;

	if @frag < 30.0
	begin
		select 
			@command = 'ALTER INDEX ' + @indexname + ' ON ' + @schemaname + '.' + @objectname + ' REORGANIZE';

		if @partitioncount > 1
			select 
				@command = @command + ' PARTITION=' + CONVERT(char, @partitionnum);

		exec (@command);
	end;

	if @frag >= 30.0
	begin
		select 
			@command = 'ALTER INDEX ' + @indexname + ' ON ' + @schemaname + '.' + @objectname + ' REBUILD';

		if @partitioncount > 1
			select 
				@command = @command + ' PARTITION=' + CONVERT(char, @partitionnum);

		exec (@command);
	end;

	print 'Executed ' + @command;

	fetch next from partitions into @objectid, 
									@indexid, 
									@partitionnum, 
									@frag;
end;

-- Close and deallocate cursor
close partitions;
deallocate partitions;

-- Drop temp table
if exists (select 
			   name
		   from sys.objects
		   where name = 'work_to_do') 
	drop table work_to_do;
go

/***************************************
option 11
******************************/

use AdventureWorks2014;
go

if OBJECTPROPERTY(OBJECT_ID(N'dbo.ProductSalesDetails'), N'IsProcedure') = 1
	drop procedure 
		dbo.ProductSalesDetails;
go

create procedure ProductSalesDetails
(
	@FirstName   varchar(50) = null, 
	@LastName    varchar(50) = null, 
	@Color       varchar(15) = null, 
	@ProductName varchar(50) = null
) 
as
begin
	set nocount on;

	select 
		PER.FirstName, 
		PER.LastName, 
		PROD.Name as ProductName, 
		ISNULL(PROD.Color, 'No Color') as Color, 
		SUM(SOD.OrderQty) as TotalOrderQty, 
		SUM(UnitPrice) as SalesAmount, 
		COUNT_BIG(*) as CountOfTotal
	from Sales.SalesOrderHeaderEnlarged as SOH
			inner join Sales.SalesOrderDetail as SOD on SOH.SalesOrderID = SOD.SalesOrderID
			inner join Production.Product as PROD on PROD.ProductID = SOD.ProductID
			inner join Sales.Customer as CUST on SOH.CustomerID = CUST.CustomerID
			inner join Person.Person as PER on PER.BusinessEntityID = CUST.PersonID
	where( PER.FirstName like @FirstName
			or @FirstName is null
			)
			and ( PER.LastName like @LastName
				or @LastName is null
				)
			and ( PROD.Color like @Color
				or @Color is null
				)
			and ( PROD.Name like @ProductName
				or @ProductName is null
				)
	group by 
		PER.FirstName, 
		PER.LastName, 
		PROD.Name, 
		PROD.Color
	order by 
		FirstName, 
		LastName;
end;
go

set statistics time on;
go

dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

exec ProductSalesDetails @FirstName = 'Kelli';

-- Now create the same Stored Proecedure but with dynamic SQL

use AdventureWorks2014;
go

if OBJECTPROPERTY(OBJECT_ID(N'dbo.ProductSalesDetails_DSE'), N'IsProcedure') = 1
	drop procedure 
		dbo.ProductSalesDetails_DSE;
go

create procedure ProductSalesDetails_DSE
(
	@FirstName   varchar(50) = null, 
	@LastName    varchar(50) = null, 
	@Color       varchar(15) = null, 
	@ProductName varchar(50) = null
) 
as
begin
	set nocount on;

	declare @DSE nvarchar(max);

	select 
		@DSE = 'select 
		PER.FirstName, 
		PER.LastName, 
		PROD.Name as ProductName, 
		ISNULL(PROD.Color, ''NoColor'') as Color, 
		SUM(SOD.OrderQty) as TotalOrderQty, 
		SUM(UnitPrice) as SalesAmount, 
		COUNT_BIG(*) as CountOfTotal
	from Sales.SalesOrderHeaderEnlarged as SOH
			inner join Sales.SalesOrderDetail as SOD on SOH.SalesOrderID = SOD.SalesOrderID
			inner join Production.Product as PROD on PROD.ProductID = SOD.ProductID
			inner join Sales.Customer as CUST on SOH.CustomerID = CUST.CustomerID
			inner join Person.Person as PER on PER.BusinessEntityID = CUST.PersonID
	where 1 = 1'; -- The following query sets up the base query for the proc. We Select that base
	-- query into the @DSE variable. The string will get executed at runtime of the proc. 
	-- This process is known as Dynamic String Execution.

	if @FirstName is not null
		select 
			@DSE = @DSE + N' AND PER.FirstName LIKE @FName';

	if @LastName is not null
		select 
			@DSE = @DSE + N' AND PER.LastName LIKE @LName';

	if @Color is not null
		select 
			@DSE = @DSE + N' AND PROD.Color LIKE @Col';

	if @ProductName is not null
		select 
			@DSE = @DSE + N' AND PROD.Name LIKE @PName';

	select 
		@DSE = @DSE + ' ' + N'group by 
		PER.FirstName, 
		PER.LastName, 
		PROD.Name, 
		PROD.Color
	order by 
		FirstName, 
		LastName';

	exec sp_executesql @DSE, N'@FName varchar(50), @LName varchar(50), @Col varchar(15), @PName varchar(50)', @FName = @FirstName, @LName = @LastName, @Col = @Color, @PName = @ProductName;
end;

dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

exec ProductSalesDetails_DSE @FirstName = 'Kelli';


dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

-- Compare them

exec ProductSalesDetails 
	@FirstName = 'Kelli', 
	@LastName = 'Anand', 
	@ProductName = 'HL Road Tire';

dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

exec ProductSalesDetails_DSE 
	@FirstName = 'Kelli', 
	@LastName = 'Anand', 
	@ProductName = 'HL Road Tire';

-- Create necessary indexes

use AdventureWorks2014
go

create nonclustered index IX_ProductID_SalesOrderId_OrderQty_UnitPrice 
on Sales.SalesOrderDetail (ProductID) 
include (SalesOrderID, OrderQty, UnitPrice);
go

create nonclustered index IX_PersonID_CustomerID 
on Sales.Customer (PersonID)
include (CustomerID)
go

dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

exec ProductSalesDetails 
	@FirstName = 'Kelli', 
	@LastName = 'Anand', 
	@ProductName = 'HL Road Tire';

dbcc dropcleanbuffers;
go

dbcc freeproccache;
go

exec ProductSalesDetails_DSE 
	@FirstName = 'Kelli', 
	@LastName = 'Anand', 
	@ProductName = 'HL Road Tire';

/***************************************
option 12: 
***************************************/

