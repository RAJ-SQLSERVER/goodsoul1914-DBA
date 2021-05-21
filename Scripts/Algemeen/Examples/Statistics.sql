create database StatisticsExample;
go

use StatisticsExample;
go

create table Table1
(
	Column1 int identity, 
	Column2 int);
go

-- Insert 1500 records

select top 1500 IDENTITY( int, 1, 1) as n
into #Nums
from master.dbo.syscolumns as sc1;

insert into Table1 (Column2) 
select n
from #Nums;

drop table #Nums;
go

-- Retrieve the inserted records

select *
from Table1;
go

-- Create a non-clustered index on column Column2

create nonclustered index idxTable1_Column2 on Table1
(Column2);
go

-- Select a record through the previously created NCI on the table
-- SQL server retrieves the record htrough a NCI Seek op.
-- Logical reads: 3

select *
from Table1
where Column2 = 2;
go

-- Insert 799 records

select top 799 IDENTITY( int, 1, 1) as n
into #Nums
from master.dbo.syscolumns as sc1;

insert into Table1 (Column2) 
select 2
from #Nums; -- change the data distribution

drop table #Nums;
go

-- No statistics update because we had to insert at least 800 records (20% + 500)
-- Logical reads: 806

select *
from Table1
where Column2 = 2;
go

-- Insert 1 more record

select top 1 IDENTITY( int, 1, 1) as n
into #Nums
from master.dbo.syscolumns as sc1;

insert into Table1 (Column2) 
select 2
from #Nums;			-- change the data distribution

drop table #Nums;
go

-- Now the stats are automatically updated by sql server
-- and a Table scan is used
-- Logical reads: 5

select *
from Table1
where Column2 = 2;	-- query is not selective enough anymore
go