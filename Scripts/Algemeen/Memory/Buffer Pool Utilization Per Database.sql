-- Get number of data pages in memory for a specific database
-------------------------------------------------------------------------------
SELECT COUNT(*) AS buffer_count
FROM sys.dm_os_buffer_descriptors
WHERE dm_os_buffer_descriptors.database_id = DB_ID();

-- Bufferpool utilization for each database
-------------------------------------------------------------------------------
SELECT CASE 
		WHEN database_id = 32767
			THEN N'Resource Database'
		ELSE DB_NAME(database_id)
		END AS DatabaseName,
	COUNT(*) * 8 / 1024 AS MBUsed,
	SUM(CAST(free_space_in_bytes AS BIGINT)) / (1024 * 1024) AS MBEmpty
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id;
GO

-- Get total buffer usage by database
-------------------------------------------------------------------------------
SELECT DB_NAME(database_id) AS [Database Name],
	COUNT(*) * 8 / 1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors
WHERE database_id > 4 -- exclude system databases
	AND database_id <> 32767 -- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC;
GO

-- Check Memory Consumption Report from SQL Server.
-- Analysis Plan Cache and Buffer Pages Distribution
-- Also, execute below query to get Buffer Pages Distribution Database wise
DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters
WHERE RTRIM(object_name) LIKE '%Buffer Manager'
	AND counter_name = 'Database Pages';

WITH src
AS (
	SELECT database_id,
		db_buffer_pages = COUNT_BIG(*)
	FROM sys.dm_os_buffer_descriptors
	--WHERE database_id BETWEEN 5 AND 32766
	GROUP BY database_id
	)
SELECT db_name = CASE database_id
		WHEN 32767
			THEN 'Resource DB'
		ELSE DB_NAME(database_id)
		END,
	db_buffer_pages,
	db_buffer_MB = db_buffer_pages / 128,
	db_buffer_percent = CONVERT(DECIMAL(6, 3), db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;
