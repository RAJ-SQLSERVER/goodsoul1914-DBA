-- Connect to SQL Server 2008 R2 instance
-- No symbols yet for SQL 2012

-- Set up the demo by running the code in the C:\Temp\SetupWorkload.sql file

-- Clear waits in WaitStats1.sql
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO

-- Now start the workload by double-clicking the file C:\Temp\Add50Clients.cmd

-- Examine WaitingTasks.sql output - why no waiting tasks?

-- Look at wait stats

-- Look at spinlock stats

-- Looks like the LOCK_HASH spinlock could be the cause, but is it?

-- Use XEvents to capture call stacks when waits occur

-- Find out the key for SOS_SCHEDULER_YIELD
SELECT map_key
FROM sys.dm_xe_map_values
WHERE name = 'wait_types'
      AND map_value = 'SOS_SCHEDULER_YIELD';

-- Drop the session if it exists. 
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'MonitorWaits')
    DROP EVENT SESSION MonitorWaits ON SERVER;
GO

-- Create the event session
-- Plug in the right wait_type below
CREATE EVENT SESSION MonitorWaits
ON SERVER
    ADD EVENT sqlos.wait_info
    (ACTION (package0.callstack)
WHERE wait_type = 99
    ) -- SOS_SCHEDULER_YIELD only
    ADD TARGET package0.asynchronous_bucketizer
    (SET filtering_event_name = N'sqlos.wait_info', source_type = 1, -- source_type = 1 is an action
    source = N'package0.callstack'
    ) -- bucketize on the callstack
WITH (MAX_MEMORY = 50MB, MAX_DISPATCH_LATENCY = 5 SECONDS);
GO

-- Start the session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = START;
GO

-- TF to allow call stack resolution
DBCC TRACEON(3656, -1);
DBCC TRACEON(2592, -1);
GO

-- Get the callstacks from the bucketizer target
-- Are they showing calls into the lock manager?
SELECT event_session_address,
       target_name,
       execution_count,
       CAST(target_data AS XML)
FROM sys.dm_xe_session_targets AS xst
INNER JOIN sys.dm_xe_sessions AS xs
    ON (xst.event_session_address = xs.address)
WHERE xs.name = 'MonitorWaits';
GO

-- Now stop the workload by double-clicking the file C:\Temp\StopWorkload.cmd

-- Stop the event session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = STOP;
GO

-- And clean up
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'MonitorWaits')
    DROP EVENT SESSION MonitorWaits ON SERVER;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'YieldTest', N'Version') > 0
BEGIN
    ALTER DATABASE YieldTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE YieldTest;
END;
GO