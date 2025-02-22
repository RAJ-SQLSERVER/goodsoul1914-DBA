USE [tsql_stackDemo];
GO

-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'TrackCausality')
	DROP EVENT SESSION [TrackCausality] ON SERVER;
GO

-- Create the Event Session 
CREATE EVENT SESSION [TrackCausality] ON SERVER 
ADD EVENT sqlserver.module_end,
ADD EVENT sqlserver.module_start,
ADD EVENT sqlserver.sp_statement_completed,
ADD EVENT sqlserver.sp_statement_starting 
ADD TARGET package0.ring_buffer
WITH (TRACK_CAUSALITY=ON);
GO

-- Start the event session
ALTER EVENT SESSION [TrackCausality]
ON SERVER
STATE=START;
GO

-- Open the Live Data Viewer

-- Execute the test procedures
EXECUTE dbo.CalledFirst;
GO
EXECUTE dbo.OtherProcedure;
GO
-- Switch to Live Data Viewer and show activity_id columns

