SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

USE Playground;
GO

-- select * from PerformanceCounters
-- delete from PerformanceCounters
-- drop table PerformanceCounters
IF OBJECT_ID('PerformanceCounters') IS NULL
BEGIN
	CREATE TABLE dbo.PerformanceCounters (
		collection_id INT NOT NULL,
		collection_time DATETIME NOT NULL,
		counter NVARCHAR(770),
		counter_type INT,
		counter_value DECIMAL(38, 2)
		);

	INSERT INTO PerformanceCounters
	SELECT 1 AS collection_id,
		GETDATE() AS collection_time,
		RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
		cntr_type,
		cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name IN ('Page life expectancy', 'Lazy writes/sec', 'Page reads/sec', 'Page writes/sec', 'Free Pages', 'Free list stalls/sec', 'User Connections', 'Lock waits/sec', 'Number of Deadlocks/sec', 'Transactions/sec', 'Forwarded Records/sec', 'Index Searches/sec', 'Full Scans/sec', 'Batch Requests/sec', 'SQL Compilations/sec', 'SQL Recompilations/sec', 'Total Server Memory (KB)', 'Target Server Memory (KB)', 'Latch Waits/sec')
	ORDER BY object_name + N':' + counter_name + N':' + instance_name;
END;
ELSE
BEGIN
	DECLARE @maxId INT;

	SELECT @maxId = max(collection_id)
	FROM PerformanceCounters;

	INSERT INTO PerformanceCounters
	SELECT @maxId + 1 AS collection_id,
		GETDATE() AS collection_time,
		RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
		cntr_type,
		cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name IN ('Page life expectancy', 'Lazy writes/sec', 'Page reads/sec', 'Page writes/sec', 'Free Pages', 'Free list stalls/sec', 'User Connections', 'Lock waits/sec', 'Number of Deadlocks/sec', 'Transactions/sec', 'Forwarded Records/sec', 'Index Searches/sec', 'Full Scans/sec', 'Batch Requests/sec', 'SQL Compilations/sec', 'SQL Recompilations/sec', 'Total Server Memory (KB)', 'Target Server Memory (KB)', 'Latch Waits/sec')
	ORDER BY object_name + N':' + counter_name + N':' + instance_name;
END;
