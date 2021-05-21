-- User-defined Function stats
-- ------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(object_id) AS [Function Name],
	execution_count,
	total_worker_time,
	total_logical_reads,
	total_physical_reads,
	total_elapsed_time,
	total_elapsed_time / execution_count AS avg_elapsed_time,
	FORMAT(cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS [Plan Cached Time]
FROM sys.dm_exec_function_stats WITH (NOLOCK)
WHERE database_id = DB_ID()
ORDER BY total_worker_time DESC
OPTION (RECOMPILE);
GO

-- User-defined Function stats by Database
-- ------------------------------------------------------------------------------------------------
SELECT TOP (25) DB_NAME(database_id) AS [Database Name],
	OBJECT_NAME(object_id, database_id) AS [Function Name],
	total_worker_time,
	execution_count,
	total_elapsed_time,
	total_elapsed_time / execution_count AS avg_elapsed_time,
	last_elapsed_time,
	last_execution_time,
	cached_time,
	type_desc
FROM sys.dm_exec_function_stats WITH (NOLOCK)
ORDER BY total_worker_time DESC
OPTION (RECOMPILE);
GO


