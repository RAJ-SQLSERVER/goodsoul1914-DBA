-- Now set up the demo by running the code in the
-- C:\Pluralsight\SetupWorkload.sql file

-- Clear waits in WaitStats1.sql
-- Clear latches in LatchStats.sql

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Examine waiting tasks
-- Examine wait stats in WaitStats1.sql
-- What proportion are the LATCH_EX waits?
-- Examine latches in LatchStats.sql

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

-- Now set up the demo again by running the code in the
-- C:\Pluralsight\SetupWorkload.sql file

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'FGCB_ADDREMOVE')
    DROP EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
GO

CREATE EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
ADD EVENT [sqlserver].[database_file_size_change],
ADD EVENT [sqlserver].[latch_suspend_begin]
	(WHERE [class]= 48),
ADD EVENT [sqlserver].[latch_suspend_end]
	(WHERE [class]=48)
ADD TARGET [package0].[ring_buffer]
WITH (TRACK_CAUSALITY = ON);
GO

-- Start the event session
ALTER EVENT SESSION [FGCB_ADDREMOVE]
ON SERVER STATE = START;
GO

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- I could write code to view the Events, but
-- using SQL Server 2012 SSMS is much better
-- in this case

-- Drill to the XEvent session, view live data
-- Add activity ID, GUID, file_name, database_id
-- Pick an activity GUID and filter on it

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

-- Clean up
ALTER EVENT SESSION [FGCB_ADDREMOVE]
ON SERVER STATE = STOP;
GO

IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'FGCB_ADDREMOVE')
    DROP EVENT SESSION [FGCB_ADDREMOVE] ON SERVER
GO

USE [master];
GO

IF DATABASEPROPERTYEX (N'PageSplit', N'Version') > 0
BEGIN
	ALTER DATABASE [PageSplit] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PageSplit];
END
GO