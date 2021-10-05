-- Connect to SQL Server 2008 R2 instance
-- No symbols yet for SQL 2012

-- Set up the demo by running the code in the
-- C:\Pluralsight\SetupWorkload.sql file

-- Clear waits in WaitStats1.sql

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Examine WaitingTasks.sql output - why no waiting tasks?

-- Look at wait stats in WaitStats1.sql

-- Look at spinlock stats in SpinlockStats.sql

-- Looks like the LOCK_HASH spinlock could be the cause, but is it?

-- Use XEvents to capture call stacks when waits occur

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

-- Create the event session
-- Note that before SQL 2012, the wait_type to use is 120
CREATE EVENT SESSION [MonitorWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
	(ACTION ([package0].[callstack])
	WHERE [wait_type] = 124) -- SOS_SCHEDULER_YIELD only
ADD TARGET [package0].[asynchronous_bucketizer] (
    SET filtering_event_name = N'sqlos.wait_info',
    source_type = 1, -- source_type = 1 is an action
    source = N'package0.callstack') -- bucketize on the callstack
WITH (MAX_MEMORY = 50MB, max_dispatch_latency = 5 seconds)
GO

-- Start the session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = START;
GO

-- TF to allow call stack resolution
DBCC TRACEON (3656, -1);
GO

-- Get the callstacks from the bucketizer target
-- Are they showing calls into the lock manager?
SELECT
	[event_session_address],
	[target_name],
	[execution_count],
	CAST ([target_data] AS XML)
FROM sys.dm_xe_session_targets [xst]
INNER JOIN sys.dm_xe_sessions [xs]
	ON ([xst].[event_session_address] = [xs].[address])
WHERE [xs].[name] = 'MonitorWaits';
GO

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

-- Stop the event session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = STOP;
GO

-- And clean up
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

USE [master];
GO

IF DATABASEPROPERTYEX (N'YieldTest', N'Version') > 0
BEGIN
	ALTER DATABASE [YieldTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [YieldTest];
END
GO