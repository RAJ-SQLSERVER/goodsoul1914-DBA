use Playground;
go

-- A simple table with 1 index
create table dbo.FragTest
(
	PKCol   int not null, 
	InfoCol nchar(64) not null, 
	constraint PK_FragTest_PKCol primary key nonclustered(PKCol));
go

-- #1 Randomly inserting rows
truncate table dbo.FragTest;
go
declare @limit int;
set @limit = 50000;
declare @counter int;
set @counter = 1;
declare @key int;
set nocount on;
while @counter <= @limit
begin
	set @key = CONVERT(int, RAND() * 1000000);
	begin try
		insert into dbo.FragTest
		values(
			@key, 'AAAA');
		set @counter = @counter + 1;
	end try
	begin catch
	end catch;
end;
go

select IX.name as 'Name', 
	   PS.index_level as 'Level', 
	   PS.page_count as 'Pages', 
	   PS.avg_page_space_used_in_percent as 'Page Fullness (%)', 
	   PS.avg_fragmentation_in_percent as 'External Fragmentation (%)', 
	   PS.fragment_count as 'Fragments', 
	   PS.avg_fragment_size_in_pages as 'Avg Fragment Size'
from sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), default,
default, 'DETAILED') as PS
join sys.indexes as IX on IX.OBJECT_ID = PS.OBJECT_ID
						  and IX.index_id = PS.index_id
where IX.name = 'PK_FragTest_PKCol';
go

/****************************************************************************************
The output tells us that the average leaf level page is slightly less than 75% full. 
It also tells us that the index is completely fragmented; that is, every page is its own 
fragment, meaning that no next-page pointer points to the physically following page.
****************************************************************************************/

-- #2 Inserting Rows in Ascending Sequence
truncate table dbo.FragTest;
go
declare @limit int;
set @limit = 50000;
declare @counter int;
set @counter = 1;
set nocount on;
while @counter <= @limit
begin
	begin try
		insert into dbo.FragTest
		values(
			@counter, 'AAAA');
		set @counter = @counter + 1;
	end try
	begin catch
	end catch;
end;
go

select IX.name as 'Name', 
	   PS.index_level as 'Level', 
	   PS.page_count as 'Pages', 
	   PS.avg_page_space_used_in_percent as 'Page Fullness (%)', 
	   PS.avg_fragmentation_in_percent as 'External Fragmentation (%)', 
	   PS.fragment_count as 'Fragments', 
	   PS.avg_fragment_size_in_pages as 'Avg Fragment Size'
from sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), default,
default, 'DETAILED') as PS
join sys.indexes as IX on IX.OBJECT_ID = PS.OBJECT_ID
						  and IX.index_id = PS.index_id
where IX.name = 'PK_FragTest_PKCol';
go

/*****************************************************************************************
 This time results are indicating that the pages are densely packed, and that external 
 fragmentation is near zero.  Because external fragmentation is near zero, SQL Server can 
 scan the index by reading one extent, or more, per IO; IO that can be done as read-ahead 
 reads.
*****************************************************************************************/

-- #3 Inserting Rows in Descending Sequence
truncate table dbo.FragTest;
go
declare @limit int;
set @limit = 50000;
declare @counter int;
set @counter = 1;
set nocount on;
while @counter <= @limit
begin
	begin try
		insert into dbo.FragTest
		values(
			@limit - @counter, 'AAAA');
		set @counter = @counter + 1;
	end try
	begin catch
	end catch;
end;
go

select IX.name as 'Name', 
	   PS.index_level as 'Level', 
	   PS.page_count as 'Pages', 
	   PS.avg_page_space_used_in_percent as 'Page Fullness (%)', 
	   PS.avg_fragmentation_in_percent as 'External Fragmentation (%)', 
	   PS.fragment_count as 'Fragments', 
	   PS.avg_fragment_size_in_pages as 'Avg Fragment Size'
from sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), default,
default, 'DETAILED') as PS
join sys.indexes as IX on IX.OBJECT_ID = PS.OBJECT_ID
						  and IX.index_id = PS.index_id
where IX.name = 'PK_FragTest_PKCol';
go

/****************************************************************************************
 Pages are full, but the file is totally fragmented. This latter fact is slightly 
 misleading, for the pages of the index are contiguous; but the first page in index key 
 sequence is the physically last page in the file.  Each next-page pointer points to the 
 physically previous page, thus giving the file its high external fragmentation rating.
****************************************************************************************/

-------------------------------------------------------------------------------
-- Deleting / Updating Rows
-------------------------------------------------------------------------------

/************************************************************************************
 Thus the insert sequence of rows; be it random, ascending or descending; impacts 
 fragmentation.  But most rows do not remain in a table forever, eventually they are 
 deleted; which also effects fragmentation.
************************************************************************************/

