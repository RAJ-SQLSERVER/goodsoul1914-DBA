select *
from sys.indexes;

select *
from sys.stats;

-- Find all objects with "stats" in the name
select *
from sys.all_objects
where name like '%stat%'
order by type_desc, 
		 name;

-- What stats were updated last 120 minutes?
select DB_NAME(), 
	   SCHEMA_NAME(obj.schema_id), 
	   obj.name, 
	   stat.name, 
	   stat.stats_id, 
	   sp.last_updated, 
	   sp.rows, 
	   sp.rows_sampled, 
	   sp.modification_counter
from sys.objects as obj
	 inner join sys.stats as stat on stat.object_id = obj.object_id
	 cross apply sys.dm_db_stats_properties(stat.object_id, stat.stats_id) as sp
where sp.last_updated > DATEADD(MI, -120, GETDATE())
	  and obj.is_ms_shipped = 0
	  and DB_NAME() <> 'tempdb';

-- Rebuild a table, updates the stats
alter table dbo.Users rebuild;

-- Create a nice formatted message
select QUOTENAME(DB_NAME()) + N'.' + QUOTENAME(SCHEMA_NAME(obj.schema_id)) + N'.' + QUOTENAME(obj.name) + N' statistic ' + QUOTENAME(stat.name) + N' was updated on ' + CONVERT(nvarchar(50), sp.last_updated, 121) + N', had ' + CAST(sp.rows as nvarchar(50)) + N' rows, with ' + CAST(sp.rows_sampled as nvarchar(50)) + N' rows sampled, producing ' + CAST(sp.steps as nvarchar(50)) + N' steps in the histogram.'
from sys.objects as obj
	 inner join sys.stats as stat on stat.object_id = obj.object_id
	 cross apply sys.dm_db_stats_properties(stat.object_id, stat.stats_id) as sp
where sp.last_updated > DATEADD(MI, -120, GETDATE())
	  and obj.is_ms_shipped = 0;

--
select DB_NAME();
exec sp_MSforeachdb N'USE [?]; SELECT DB_NAME();';

-- Loop through all databases
exec sp_MSforeachdb N'USE [?];
select QUOTENAME(DB_NAME()) + N''.'' + 
	   QUOTENAME(SCHEMA_NAME(obj.schema_id)) + N''.'' + 
	   QUOTENAME(obj.name) + 
	   N'' statistic '' + QUOTENAME(stat.name) +
	   N'' was updated on '' + CONVERT(nvarchar(50), sp.last_updated, 121) +
	   N'', had '' + CAST(sp.rows as nvarchar(50)) + N'' rows, with '' + 
	   CAST(sp.rows_sampled as nvarchar(50)) + N'' rows sampled, producing '' + 
	   CAST(sp.steps as nvarchar(50)) + N'' steps in the histogram.''
from sys.objects as obj
	 inner join sys.stats as stat on stat.object_id = obj.object_id
	 cross apply sys.dm_db_stats_properties(stat.object_id, stat.stats_id) as sp
where sp.last_updated > DATEADD(MI, -120, GETDATE()) 
	AND obj.is_ms_shipped = 0 
	AND ''[?]'' <> ''[tempdb]'';';

-- Exclude ms shipped stuff
use master;
go
select *
from sys.all_objects
where is_ms_shipped = 0

--
select *
from sys.messages