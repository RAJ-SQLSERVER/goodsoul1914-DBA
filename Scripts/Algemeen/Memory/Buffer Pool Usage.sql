-- source:https://www.mssqltips.com/sqlservertip/2393/determine-sql-server-memory-use-by-database-and-object/

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters
WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
      AND counter_name = 'Database Pages';

;WITH src
AS (SELECT database_id,
           db_buffer_pages = COUNT_BIG(*)
    FROM sys.dm_os_buffer_descriptors
    --WHERE database_id BETWEEN 5 AND 32766
    GROUP BY database_id)
SELECT TOP 10
       [db_name] = CASE [database_id]
                       WHEN 32767 THEN
                           'Resource DB'
                       ELSE
                           DB_NAME([database_id])
                   END,
       db_buffer_pages,
       db_buffer_MB = db_buffer_pages / 128,
       db_buffer_percent = CONVERT(DECIMAL(6, 3), db_buffer_pages * 100.0 / @total_buffer)
FROM src
--ORDER BY db_buffer_MB DESC; 
ORDER BY db_buffer_percent DESC;
GO

-- Buffer pool usage
-------------------------------------------------------------------------------
SELECT DB_NAME(database_id) AS [Database Name],
       COUNT(*) * 8 / 1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id > 4 -- system databases
      AND database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC
OPTION (RECOMPILE);
GO
