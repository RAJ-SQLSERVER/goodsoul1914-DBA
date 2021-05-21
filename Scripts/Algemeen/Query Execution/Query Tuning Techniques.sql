/****************
 1. Clear caches 
****************/

checkpoint;

dbcc freeproccache;

dbcc dropcleanbuffers;

dbcc sqlperf('sys.dm_os_wait_stats', CLEAR);
go

/******************
 =Set measurements 
******************/

set statistics io, time on;
go

set showplan_xml on;
go

/****************************
 2. Dynamic Management Views 
****************************/

-- System info

select *
from sys.dm_os_performance_counters;

select *
from sys.dm_os_wait_stats;

-- Query info

select *
from sys.dm_exec_requests;

-- Index info

select *
from sys.dm_db_index_usage_stats;

select *
from sys.dm_io_virtual_file_stats (6, null);

/**********************
 3. Look for red flags 
**********************/

-- Scans
-- Spools
-- Hash joins (Sorts)
-- Bookmark lookups
-- Parallelism
-- Big difference between estimated execution plan and actual execution plan
-- Physical reads
-- Missing indexes
-- Implicit data conversion
-- Cursors (incl WHILE loops) -> start using LOCAL FAST_FORWARD
-- sp_msforeachdb (uses cursor with DEFAULT options, stop using it!)
-- 

/*****************************
 4. NOT IN vs LEFT OUTER JOIN 
*****************************/

-- Dangerous if source column is NULLable
-- LEFT OUTER JOIN is not always a good alternative
-- NOT EXISTS or EXCEPT are better (but can behave differently)

declare @x table
(
	a int);

insert into @x
values (1), (1), (null);

declare @y table
(
	b int not null);

insert into @y
values (1), (1), (2), (2);

select b
from @y
where b not in
(
	select a
	from @x
);

select b
from @y as y
where not exists
(
	select 1
	from @x as x
	where x.a = y.b
);

select b
from @y
except
select a
from @x;

/****************************
 5. WHERE IN vs WHERE EXISTS 
****************************/

-- There are lots of ways to find data existing within subsets:
--	IN, EXISTS, JOIN, APPLY, SUBQUERY

/****************************
 6. SELECT vs DML operations 
****************************/

-- With DML all triggers, foreign keys, check constraints will show up in 
-- your execution plans as well
-- Rollbacks are SINGLE THREADED !!!

/***********************
 7. Unwanted Recompiles 
***********************/

-- Expected:
-- CREATE PROC ... WITH RECOMPILE or EXEC myproc ... WITH RECOMPILE
-- SP_RECOMPILE foo
-- Expected: plan was aged out of memory
-- Unexpected: interleaved DDL and DML
-- CREATE PROC testddldml AS ... ;
-- CREATE TABLE #testdml;		-- (DDL)
-- INSERT INTO #testdml;		-- (DML + RECOMPILE)
-- ALTER TABLE #testdml;		-- (DDL)
-- INSERT INTO #testdml;		-- (DML + RECOMPILE)
-- DROP TABLE #testdml;			-- (DDL)
-- Unexpected: big changes since last execution:
-- * schema changes to objects in underlying code
-- * new/updated index statistics
-- * sp_configure

/********************************
 8. The "Kitchen Sink" procedure 
********************************/

-- Many optional params to satisfy a variety of search conditions:
-- * dynamic SQL is often the beste route here
-- * especially if "Optimize For Ad Hoc Workloads" is enabled (OLTP apps + read-heavy OLAP)
-- * could also use RECOMPILE, but then you will pay compile cost every time

/******************************
 9. sp_executesql vs EXEC(...) 
******************************/

-- Can promote better plan-reuse
-- encourages strongly typed parameters instead of building up a massive string
-- Does not take care of parameter sniffing!

/*******************************
 10. Comma-delimited parameters 
*******************************/

-- example: pass a comma-separated list of OrderIDs
-- String splitting is expensive, even using the CLR
-- Table-valued parameters are typically a better approach

use AdventureWorks2014;
go

create procedure dbo.FindOrders_UsingJSON_Broken 
	@List varchar(max)
as
begin
	set nocount on;

	select SalesOrderID
	from Sales.SalesOrderHeaderEnlarged
	where SalesOrderID in (@List);
end;
go

declare @List varchar(max) = '330227,273691,1003613,1150279,1130412,414097' + ',957188,256658,869880,1297400,102222,146300' + ',1161693,1237396,134616,741849';

exec dbo.FindOrders_UsingJSON_Broken @List;
go

--Msg 245, Level 16, State 1, Procedure dbo.FindOrders_UsingJSON_Broken, Line 7 [Batch Start Line 139]
--Conversion failed when converting the varchar value '330227, 273691,1003613,1150279,1130412,414097,957188,256658,869880,1297400,102222,146300,1161693,1237396,134616,741849' to data type int.

create function dbo.SplitJSONInts
(
	@List varchar(max)) 
returns table
with schemabinding
as
	return
(
	select Item
	from
	(
		select Item = x.i.value ('(./text())[1]', 'int')
		from
		(
			select XML = CONVERT(xml, '<i>' + REPLACE(@List, ',', '</i><i>') + '<i>').query ('.')
		) as a
		cross apply XML.nodes ('i') as x(i)
	) as y
	where Item is not null
);
go

create procedure dbo.FindOrders_UsingJSON_FixedKindOf 
	@List varchar(max)
as
begin
	set nocount on;

	select SalesOrderID
	from Sales.SalesOrderHeaderEnlarged as h
	where exists
	(
		select 1
		from dbo.SplitJSONInts (@List) as l
		where l.Item = h.SalesOrderID
	);
end;
go

declare @List varchar(max) = '330227,273691,1003613,1150279,1130412,414097' + ',957188,256658,869880,1297400,102222,146300' + ',1161693,1237396,134616,741849';

exec dbo.FindOrders_UsingJSON_FixedKindOf @List;
go

create type dbo.Integers as table
(
	Item int
	primary key);
go

create procedure dbo.FindOrders_UsingTVP 
	@List dbo.Integers readonly
as
begin
	set nocount on;

	select SalesOrderID
	from Sales.SalesOrderHeaderEnlarged as h
	where exists
	(
		select 1
		from @List
		where Item = h.SalesOrderID
	);
end;
go

/*************************
 11. Implicit conversions 
*************************/

-- SQL Server has to do a lot of extra work / scans when conversion operations are assumed by the SQL programmer
-- Happens all the time with data types you'd think wouldn't need it, e.g. between date types and character types
-- Very useful data type conversion chart at http://bit.ly/15bDRRA
-- Date type precedence call also have an impact: http://bit.ly/13Zio1f

declare @LastName1 varchar(100) = 'Duffy';

select FirstName, 
	   LastName
from Person.Person
where LastName = @LastName1;

declare @LastName2 nvarchar(100) = N'Duffy';

select FirstName, 
	   LastName
from Person.Person
where LastName = @LastName2;
go