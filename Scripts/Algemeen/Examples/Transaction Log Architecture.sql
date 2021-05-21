-----------------------------------------------
--		Transaction Log Architecture		 --
-----------------------------------------------
USE [master];
GO

IF DATABASEPROPERTYEX(N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012]

	SET SINGLE_USER
	WITH

	ROLLBACK IMMEDIATE;

	DROP DATABASE [DBMaint2012];
END
GO

-- Enable trace flags to watch zero-initialization
DBCC TRACEON (
		3605,
		3004,
		- 1
		);
GO

-- Flush the error log
EXEC sp_cycle_errorlog;
GO

-- Create a database
CREATE DATABASE [DBMaint2012] ON PRIMARY (
	NAME = N'DBMaint2012_data',
	FILENAME = N'D:\MSSQL\Data\DBMaint2012_data.mdf'
	) LOG ON (
	NAME = N'DBMaint2012_log',
	FILENAME = N'D:\MSSQL\Log\DBMaint2012_log.ldf',
	SIZE = 10 MB,
	FILEGROWTH = 10 MB
	);
GO

-- Examine the errorlog
EXEC xp_readerrorlog;
GO

-- Drop the database again
DROP DATABASE [DBMaint2012];
GO

-- Turn off the traceflags
DBCC TRACEOFF (
		3605,
		3004,
		- 1
		);
GO

-- In the other window, flush wait stats
-- Recreate the database
CREATE DATABASE [DBMaint2012] ON PRIMARY (
	NAME = N'DBMaint2012_data',
	FILENAME = N'D:\MSSQL\Data\DBMaint2012_data.mdf'
	) LOG ON (
	NAME = N'DBMaint2012_log',
	FILENAME = N'D:\MSSQL\Log\DBMaint2012_log.ldf',
	SIZE = 10 MB,
	FILEGROWTH = 10 MB
	);
GO

-- Examine waits 
WITH [Waits]
AS (
	SELECT [wait_type],
		[wait_time_ms] / 1000.0 AS [WaitS],
		([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
		[signal_wait_time_ms] / 1000.0 AS [SignalS],
		[waiting_tasks_count] AS [WaitCount],
		100.0 * [wait_time_ms] / SUM([wait_time_ms]) OVER () AS [Percentage],
		ROW_NUMBER() OVER (
			ORDER BY [wait_time_ms] DESC
			) AS [RowNum]
	FROM sys.dm_os_wait_stats
	WHERE [wait_type] NOT IN (N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE', N'SQLTRACE_BUFFER_FLUSH', N'SLEEP_TASK', N'SLEEP_SYSTEMTASK', N'WAITFOR', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT', N'XE_DISPATCHER_JOIN', N'LOGMGR_QUEUE', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT', N'DISPATCHER_QUEUE_SEMAPHORE', N'TRACEWRITE', N'XE_DISPATCHER_WAIT', N'BROKER_TO_FLUSH', N'BROKER_EVENTHANDLER', N'FT_IFTSHC_MUTEX', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'DIRTY_PAGE_POLL')
	)
SELECT [W1].[wait_type] AS [WaitType],
	CAST([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
	CAST([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
	CAST([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
	[W1].[WaitCount] AS [WaitCount],
	CAST([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
	CAST(([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL(14, 4)) AS [AvgWait_S],
	CAST(([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL(14, 4)) AS [AvgRes_S],
	CAST(([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL(14, 4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum],
	[W1].[wait_type],
	[W1].[WaitS],
	[W1].[ResourceS],
	[W1].[SignalS],
	[W1].[WaitCount],
	[W1].[Percentage]
HAVING SUM([W2].[Percentage]) - [W1].[Percentage] < 95;-- percentage
GO

-- Clear wait stats 
-- DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
USE [master];
GO

IF DATABASEPROPERTYEX(N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012]

	SET SINGLE_USER
	WITH

	ROLLBACK IMMEDIATE;

	DROP DATABASE [DBMaint2012];
END
GO

-- Create a database
CREATE DATABASE [DBMaint2012] ON PRIMARY (
	NAME = N'DBMaint2012_data',
	FILENAME = N'D:\MSSQL\Data\DBMaint2012_data.mdf'
	) LOG ON (
	NAME = N'DBMaint2012_log',
	FILENAME = N'D:\MSSQL\Log\DBMaint2012_log.ldf',
	SIZE = 10 MB,
	FILEGROWTH = 10 MB
	);
GO

-- Examine the size of the log
DBCC SQLPERF (LOGSPACE);
GO

-- Examine the VLF structure of the log
DBCC LOGINFO(N'DBMaint2012');
GO

-- Increase the log file size
ALTER DATABASE [DBMaint2012] MODIFY FILE (
	NAME = N'DBMaint2012_log',
	SIZE = 20 MB
	);
GO

-- Examine the size of the log
DBCC SQLPERF (LOGSPACE);
GO

-- Examine the VLF structure of the log
DBCC LOGINFO(N'DBMaint2012');
GO


