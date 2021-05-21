SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

USE Playground;
GO

-- select * from dbo.PerformanceCounters
-- delete from dbo.PerformanceCounters
-- drop table dbo.PerformanceCounters

IF OBJECT_ID('PerformanceCounters') IS NULL
BEGIN

    CREATE TABLE dbo.PerformanceCounters
    (
        collection_id INT NOT NULL,
        collection_time DATETIME NOT NULL,
        Counter NVARCHAR(770),
        CounterType INT,
        CounterValue DECIMAL(38, 2)
    );

    INSERT dbo.PerformanceCounters
    SELECT 1 AS collection_id,
           GETDATE() AS collection_time,
           RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
           cntr_type,
           cntr_value
    FROM sys.dm_os_performance_counters
    WHERE counter_name IN ( 'Page life expectancy', 'Lazy writes/sec', 'Page reads/sec', 'Page writes/sec',
                            'Free Pages', 'Free list stalls/sec', 'User Connections', 'Lock Waits/sec',
                            'Number of Deadlocks/sec', 'Transactions/sec', 'Forwarded Records/sec',
                            'Index Searches/sec', 'Full Scans/sec', 'Batch Requests/sec', 'SQL Compilations/sec',
                            'SQL Re-Compilations/sec', 'Total Server Memory (KB)', 'Target Server Memory (KB)',
                            'Latch Waits/sec'
                          )
    ORDER BY object_name + N':' + counter_name + N':' + instance_name;
END
ELSE
BEGIN
	INSERT dbo.PerformanceCounters
    SELECT (SELECT MAX(collection_id) FROM dbo.PerformanceCounters) + 1 AS collection_id,
           GETDATE() AS collection_time,
           RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
           cntr_type,
           cntr_value
    FROM sys.dm_os_performance_counters
    WHERE counter_name IN ( 'Page life expectancy', 'Lazy writes/sec', 'Page reads/sec', 'Page writes/sec',
                            'Free Pages', 'Free list stalls/sec', 'User Connections', 'Lock Waits/sec',
                            'Number of Deadlocks/sec', 'Transactions/sec', 'Forwarded Records/sec',
                            'Index Searches/sec', 'Full Scans/sec', 'Batch Requests/sec', 'SQL Compilations/sec',
                            'SQL Re-Compilations/sec', 'Total Server Memory (KB)', 'Target Server Memory (KB)',
                            'Latch Waits/sec'
                          )
    ORDER BY object_name + N':' + counter_name + N':' + instance_name;
END
GO


SELECT collection_id,
       collection_time,
       Counter,
       CounterType,
       CounterValue,
	   --ROW_NUMBER() OVER(PARTITION BY Counter ORDER BY collection_time),
	   (CounterValue - LAG(CounterValue) OVER(PARTITION BY Counter ORDER BY collection_time)) AS [Difference]
FROM dbo.PerformanceCounters
GO
