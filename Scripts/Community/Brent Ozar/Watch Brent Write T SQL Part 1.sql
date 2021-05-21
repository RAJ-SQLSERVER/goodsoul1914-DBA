SELECT *
FROM sys.indexes;

SELECT *
FROM sys.stats;

-- Find all objects with "stats" in the name
SELECT *
FROM sys.all_objects
WHERE name LIKE '%stat%'
ORDER BY type_desc,
         name;

-- What stats were updated last 120 minutes?
SELECT DB_NAME (),
       SCHEMA_NAME (obj.schema_id),
       obj.name,
       stat.name,
       stat.stats_id,
       sp.last_updated,
       sp.rows,
       sp.rows_sampled,
       sp.modification_counter
FROM sys.objects AS obj
INNER JOIN sys.stats AS stat
    ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties (stat.object_id, stat.stats_id) AS sp
WHERE sp.last_updated > DATEADD (MI, -120, GETDATE ());

-- Rebuild a table, updates the stats
ALTER TABLE dbo.Users REBUILD;

-- Create a nice formatted message
SELECT QUOTENAME (DB_NAME ()) + N'.' + QUOTENAME (SCHEMA_NAME (obj.schema_id)) + N'.' + QUOTENAME (obj.name)
       + N' statistic ' + QUOTENAME (stat.name) + N' was updated on ' + CONVERT (NVARCHAR(50), sp.last_updated, 121)
       + N', had ' + CAST(sp.rows AS NVARCHAR(50)) + N' rows, with ' + CAST(sp.rows_sampled AS NVARCHAR(50))
       + N' rows sampled, producing ' + CAST(sp.steps AS NVARCHAR(50)) + N' steps in the histogram.'
FROM sys.objects AS obj
INNER JOIN sys.stats AS stat
    ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties (stat.object_id, stat.stats_id) AS sp
WHERE sp.last_updated > DATEADD (MI, -120, GETDATE ());

--
SELECT DB_NAME ();
EXEC sp_MSforeachdb N'USE [?]; SELECT DB_NAME();';

-- Loop through all databases
EXEC sp_MSforeachdb N'USE [?];
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
where sp.last_updated > DATEADD(MI, -120, GETDATE()) AND obj.is_ms_shipped = 0;';

-- Exclude ms shipped stuff
USE master;
GO
SELECT *
FROM sys.all_objects
WHERE is_ms_shipped = 0;