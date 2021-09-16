USE DBA;
GO

-- Health
EXEC dbo.sp_Blitz @CheckServerInfo = 1;

-- Waits
EXEC dbo.sp_BlitzFirst @SinceStartup = 1;

-- Databases
SELECT *
FROM sys.databases;

-- Indexes
EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1;
EXEC dbo.sp_BlitzIndex @Mode = 2, @GetAllDatabases = 1;
EXEC dbo.sp_BlitzIndex @Mode = 4, @GetAllDatabases = 1;

-- Plans
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'cpu';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'reads';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'duration';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'executions';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'writes';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'memory grant';
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'recent compilations', @Top = 50;
EXEC dbo.sp_BlitzCache @ExpertMode = 1, @SortOrder = 'spills';

-- Plans by query hash
SELECT TOP (10) query_hash
FROM sys.dm_exec_query_stats
GROUP BY query_hash
ORDER BY COUNT (*) DESC;

-- Plans now
EXEC dbo.sp_BlitzWho @ExpertMode = 1;

-- Waits now, PerfMon now
EXEC dbo.sp_BlitzFirst @ExpertMode = 1, @Seconds = 30;
