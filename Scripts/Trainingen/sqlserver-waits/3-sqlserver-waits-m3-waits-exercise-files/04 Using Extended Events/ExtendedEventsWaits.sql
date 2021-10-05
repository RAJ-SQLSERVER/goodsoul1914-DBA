-- How can we find out all the waits for
-- a particular query?
USE [master];
GO

IF DATABASEPROPERTYEX (N'Production', N'Version') > 0
BEGIN
	ALTER DATABASE [Production] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Production];
END
GO

CREATE DATABASE [Production];
GO

USE [Production];
GO

CREATE TABLE [test] (
	[c1] INT IDENTITY,
	[c2] UNIQUEIDENTIFIER ROWGUIDCOL DEFAULT NEWID(),
	[c3] CHAR (5000) DEFAULT 'a');
CREATE CLUSTERED INDEX [test_CL] ON [test] ([c1]);
GO

SET NOCOUNT ON;
INSERT INTO [test] DEFAULT VALUES;
GO 5000

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

-- Run the first part of RunAQuery.sql
-- Get session number of window with RunAQuery.sql in it

-- Create the event session
CREATE EVENT SESSION [MonitorWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
	(WHERE [sqlserver].[session_id] = XX /*session_id of window 2*/)
ADD TARGET [package0].[asynchronous_file_target]
    (SET FILENAME = N'C:\Pluralsight\EE_WaitStats.xel', 
    METADATAFILE = N'C:\Pluralsight\EE_WaitStats.xem')
WITH (max_dispatch_latency = 1 seconds);
GO

-- Start the session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = START;
GO

-- Go do the query

-- Stop the event session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = STOP;
GO

-- Do we have any rows yet?
SELECT COUNT (*)
	FROM sys.fn_xe_file_target_read_file (
	'C:\Pluralsight\EE_WaitStats*.xel',
	'C:\Pluralsight\EE_WaitStats*.xem',
	null, null);
GO

-- Create intermediate temp table for raw event data
CREATE TABLE [##RawEventData] (
	[Rowid]			INT IDENTITY PRIMARY KEY,
	[event_data]	XML);
GO

-- Read the file data into intermediate temp table
INSERT INTO [##RawEventData] ([event_data])
SELECT
    CAST ([event_data] AS XML) AS [event_data]
FROM sys.fn_xe_file_target_read_file (
	'C:\Pluralsight\EE_WaitStats*.xel',
	'C:\Pluralsight\EE_WaitStats*.xem',
	null, null);
GO

-- And now extract everything nicely
SELECT
	[event_data].[value] (
		'(/event/@timestamp)[1]',
			'DATETIME') AS [Time],
	[event_data].[value] (
		'(/event/data[@name=''wait_type'']/text)[1]',
			'VARCHAR(100)') AS [Wait Type],
	[event_data].[value] (
		'(/event/data[@name=''opcode'']/text)[1]',
			'VARCHAR(100)') AS [Op],
	[event_data].[value] (
		'(/event/data[@name=''duration'']/value)[1]',
			'BIGINT') AS [Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''max_duration'']/value)[1]',
			'BIGINT') AS [Max Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''total_duration'']/value)[1]',
			'BIGINT') AS [Total Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''signal_duration'']/value)[1]',
			'BIGINT') AS [Signal Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''completed_count'']/value)[1]',
			'BIGINT') AS [Count]
FROM [##RawEventData];
GO

-- And finally, aggregation
SELECT
	[waits].[Wait Type],
	COUNT (*) AS [Wait Count],
	SUM ([waits].[Duration]) AS [Total Wait Time (ms)],
	SUM ([waits].[Duration]) - SUM ([waits].[Signal Duration])
		AS [Total Resource Wait Time (ms)],
	SUM ([waits].[Signal Duration]) AS [Total Signal Wait Time (ms)]
FROM 
	(SELECT
		[event_data].[value] (
			'(/event/@timestamp)[1]',
				'DATETIME') AS [Time],
		[event_data].[value] (
			'(/event/data[@name=''wait_type'']/text)[1]',
				'VARCHAR(100)') AS [Wait Type],
		[event_data].[value] (
			'(/event/data[@name=''opcode'']/text)[1]',
				'VARCHAR(100)') AS [Op],
		[event_data].[value] (
			'(/event/data[@name=''duration'']/value)[1]',
				'BIGINT') AS [Duration],
		[event_data].[value] (
			'(/event/data[@name=''signal_duration'']/value)[1]',
				'BIGINT') AS [Signal Duration]
	FROM [##RawEventData]
	) AS [waits]
WHERE [waits].[op] = 'End'
GROUP BY [waits].[Wait Type]
ORDER BY [Total Wait Time (ms)] DESC;
GO

-- Cleanup
DROP TABLE [##RawEventData];
GO

IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

USE [master];
GO

IF DATABASEPROPERTYEX (N'Production', N'Version') > 0
BEGIN
	ALTER DATABASE [Production] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Production];
END
GO