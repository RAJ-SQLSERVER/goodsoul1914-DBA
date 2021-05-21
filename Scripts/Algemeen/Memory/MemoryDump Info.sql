-- Get information on location, time and size of any memory dumps from SQL Server
--
-- This will not return any rows if you have 
-- not had any memory dumps (which is a good thing)
-- sys.dm_server_memory_dumps (Transact-SQL)
-- https://bit.ly/2elwWll
--------------------------------------------------------------------------------------------------
SELECT filename,
	creation_time,
	size_in_bytes / 1048576.0 AS [Size (MB)]
FROM sys.dm_server_memory_dumps WITH (NOLOCK)
ORDER BY creation_time DESC
OPTION (RECOMPILE);
GO
