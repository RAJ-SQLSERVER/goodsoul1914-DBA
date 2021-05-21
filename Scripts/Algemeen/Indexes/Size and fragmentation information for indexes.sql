-- Retrieve information about all indexes on a table

exec sp_SQLSkills_helpindex 'StackOverflow2010.dbo.Posts';

-- Returns size and fragmentation information for the data and 
-- indexes of the specified table or view in SQL Server

select index_depth as D, 
	   index_level as L, 
	   record_count as Rows, 
	   page_count as Pages, 
	   avg_page_space_used_in_percent as [Page:Percent Full], 
	   min_record_size_in_bytes as [Row:MinLen], 
	   max_record_size_in_bytes as [Row:MaxLen], 
	   avg_record_size_in_bytes as [Row:AvgLen]
from sys.dm_db_index_physical_stats (DB_ID(N'StackOverflow2010') -- Database ID
, OBJECT_ID(N'StackOverflow2010.dbo.Posts') -- Object ID
, 1	 -- Index ID (1 = Clustered index)
, null -- Partition ID
, 'DETAILED'); -- Mode
go