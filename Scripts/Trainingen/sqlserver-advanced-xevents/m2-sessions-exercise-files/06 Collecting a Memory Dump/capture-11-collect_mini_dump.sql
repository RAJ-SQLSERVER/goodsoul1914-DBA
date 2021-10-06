-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'CollectMiniDump')
	DROP EVENT SESSION [CollectMiniDump] 
	ON SERVER;
GO

-- Create event session to collect a dump for 
-- error 50000, severity 16, and state 1
CREATE EVENT SESSION [CollectMiniDump]
ON SERVER
ADD EVENT sqlserver.error_reported(
	ACTION (sqlserver.create_dump_single_thread)
	WHERE (error_number = 50000 AND
		   severity = 16 AND
		   state = 1));
GO

-- Start the event session
ALTER EVENT SESSION [CollectMiniDump]
ON SERVER
STATE=START;
GO

-- Open the following path in Windows 
-- C:\Pluralsight\Data\MSSQL11.MSSQLSERVER\MSSQL\Log

-- Generate a error matching the event criteria
RAISERROR('TestMessage', 16, 1);
GO

-- Stop the event session
ALTER EVENT SESSION [CollectMiniDump]
ON SERVER
STATE=STOP;
GO
