-- ===========================
-- Database Shrink Operations
-- ===========================

use Playground;
go

-- Create a table with 10MB of chunk data at the start of the data file

create table ChunkTable
(
	c1 int identity, 
	c2 char(8000) default 'chunk');
go

-- Insert 10MB of chunk data into the table

insert into ChunkTable
default values;
go 1280

-- Create a clustered table, that is placed after the chunk table
-- inside the data file

create table CustomersTable
(
	c1 int identity, 
	c2 char(7000) default 'Customer', 
	c3 char(200) default 'c3');
go

-- Create a unique clustered index on that table

create unique clustered index idx_c1 on CustomersTable
(c1);
go

-- Create a unique nonclustered index on that table

create nonclustered index idx_c3 on CustomersTable
(c3);
go

-- Insert 10MB of data into the table

insert into CustomersTable
default values;
go 1280

-- Check the fragmentation of the clustered table, it is < 1%

select avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (DB_ID('Playground'), OBJECT_ID('CustomersTable'), 1, null, 'LIMITED');
go	-- 0,3125 %
-- Check the fragmentation of the nonclustered table, it is < 10%

select avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (DB_ID('Playground'), OBJECT_ID('CustomersTable'), 2, null, 'LIMITED');
go	-- 2,94 %
-- Now, let's drop the ChunkTable
-- This causes some free space at the beginning of the data file

drop table ChunkTable;
go

-- Now, let's shrink our database to use the free space at the beginning
-- of our data file

dbcc shrinkdatabase(Playground);
go

/************************************************************
	DbId	FileId	CurrentSize	MinimumSize	UsedPages	EstimatedPages
	14		1		68376		1024		68360		68360
	14		2		74752		1024		74752		1024
************************************************************/

-- Check the fragmentation of the clustered table, it is > 70%

select avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (DB_ID('Playground'), OBJECT_ID('CustomersTable'), 1, null, 'LIMITED');
go	-- 73,90625 %
-- Check the fragmentation of the nonclustered table, it is > 50%

select avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (DB_ID('Playground'), OBJECT_ID('CustomersTable'), 2, null, 'LIMITED');
go	-- 58,8235294117647 %
-- Rebuild the clustered index

alter index idx_c1 on CustomersTable rebuild;
go

-- Rebuild the nonclustered index

alter index idx_c3 on CustomersTable rebuild;
go

-- The index fragmentation in the clustered index is now gone

select avg_fragmentation_in_percent
from sys.dm_db_index_physical_stats (DB_ID('Playground'), OBJECT_ID('CustomersTable'), 1, null, 'LIMITED');
go	-- 0%