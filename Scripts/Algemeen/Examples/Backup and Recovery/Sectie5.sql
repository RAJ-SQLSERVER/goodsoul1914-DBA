-- Effects of Instant File Initialization
---------------------------------------------------------------------------------------------------
-- Verify if IFI is enabled on the server
sp_cycle_errorlog;
GO

USE master;

-- Set trace flags
DBCC TRACEON (
		3004,
		- 1
		);

DBCC TRACEON (
		3605,
		- 1
		);
GO

CREATE DATABASE test;
GO

-- Read the SQL Server errorlog to see the file initialization process
xp_readerrorlog;
GO

DROP DATABASE test;
GO

--LogDate					ProcessInfo	Text
--2020-02-26 19:23:53.090	spid52		Zeroing D:\Documents\MSSQL\Log\test_log.ldf from page 0 to 1024 (0x0 to 0x800000)
--2020-02-26 19:23:53.180	spid52		Zeroing completed on D:\Documents\MSSQL\Log\test_log.ldf (elapsed = 88 ms)
--2020-02-26 19:23:53.470	spid52		Starting up database 'test'.
--2020-02-26 19:23:53.520	spid52		Parallel redo is started for database 'test' with worker pool size [4].
--2020-02-26 19:23:53.550	spid52		FixupLogTail(progress) zeroing D:\Documents\MSSQL\Log\test_log.ldf from 0x5000 to 0x6000.
--2020-02-26 19:23:53.550	spid52		Zeroing D:\Documents\MSSQL\Log\test_log.ldf from page 3 to 249 (0x6000 to 0x1f2000)
--2020-02-26 19:23:53.560	spid52		Zeroing completed on D:\Documents\MSSQL\Log\test_log.ldf (elapsed = 8 ms)
--2020-02-26 19:23:53.580	spid52		Parallel redo is shutdown for database 'test' with worker pool size [4].  
-- Now look at the effects
-----------------------------------------------------------------------------------------------
USE master;
GO

CREATE DATABASE testDB3 ON PRIMARY (
	name = N'testDB3_data',
	filename = N'D:\Documents\MSSQL\DATA\testDB3_data.mdf',
	size = 47 mb,
	filegrowth = 8 gb
	) log ON (
	name = N'testDB3_log',
	filename = N'D:\Documents\MSSQL\LOG\testDB3_log.ldf',
	size = 512 mb,
	filegrowth = 512 mb
	);
GO

USE testDB3;
GO

CREATE TABLE testTable (
	c1 INT identity,
	c2 CHAR(8000) DEFAULT 'This is a record'
	);
GO

INSERT INTO testTable DEFAULT
VALUES;GO 6000

BACKUP DATABASE testDB2 TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB3.bak'
WITH init,
	stats;
GO

xp_readerrorlog;
GO

/*********************
 Show autogrowth info 
*********************/
DECLARE @current_tracefilename VARCHAR(500);
DECLARE @0_tracefilename VARCHAR(500);
DECLARE @indx INT;

SELECT @current_tracefilename = path
FROM sys.traces
WHERE is_default = 1;

SET @current_tracefilename = REVERSE(@current_tracefilename);

SELECT @indx = PATINDEX('%\%', @current_tracefilename);

SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @0_tracefilename = LEFT(@current_tracefilename, LEN(@current_tracefilename) - @indx) + '\log.trc';

SELECT DatabaseName,
	te.name,
	Filename,
	CONVERT(DECIMAL(10, 3), Duration / 1000000e0) AS TimeTakenSeconds,
	StartTime,
	EndTime,
	IntegerData * 8.0 / 1024 AS 'ChangeInSize MB',
	ApplicationName,
	HostName,
	LoginName
FROM::fn_trace_gettable(@0_tracefilename, DEFAULT) AS t
INNER JOIN sys.trace_events AS te ON t.EventClass = te.trace_event_id
WHERE trace_event_id >= 92
	AND trace_event_id <= 95
ORDER BY t.StartTime;
GO


