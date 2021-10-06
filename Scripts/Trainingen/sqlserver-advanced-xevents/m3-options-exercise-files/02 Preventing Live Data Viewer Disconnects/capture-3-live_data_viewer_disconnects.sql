USE [AdventureWorks2012];
GO

-- Create procedure to generate a lot of statement level events
IF OBJECT_ID(N'ExecuteLotsOfStatements') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[ExecuteLotsOfStatements]
END
GO
CREATE PROCEDURE [dbo].[ExecuteLotsOfStatements]
(@ExecutionLoopCount INT = 1000)
AS
	DECLARE @Loop INT = 0;
	WHILE @Loop < @ExecutionLoopCount;
	BEGIN
		DECLARE @Loop2 INT;
		SELECT @Loop2 = @Loop;
	
		SET @Loop = @Loop+1;
	END
GO

-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'XEOverhead')
	DROP EVENT SESSION [XEOverhead] 
	ON SERVER;
GO

-- Create an event session to capture statement events
CREATE EVENT SESSION [XEOverhead]
ON SERVER
ADD EVENT sqlserver.module_end(
	ACTION 
	(
			  sqlserver.client_app_name	-- ApplicationName from SQLTrace
			, sqlserver.client_pid	-- ClientProcessID from SQLTrace
			, sqlserver.nt_username	-- NTUserName from SQLTrace
			, sqlserver.server_principal_name	-- LoginName from SQLTrace
			, sqlserver.session_id	-- SPID from SQLTrace
			-- BinaryData not implemented in XE for this event
	)
),
ADD EVENT sqlserver.sp_statement_completed(
	ACTION 
	(
			  sqlserver.client_app_name	-- ApplicationName from SQLTrace
			, sqlserver.client_pid	-- ClientProcessID from SQLTrace
			, sqlserver.nt_username	-- NTUserName from SQLTrace
			, sqlserver.server_principal_name	-- LoginName from SQLTrace
			, sqlserver.session_id	-- SPID from SQLTrace
	)
);
GO

-- Start the event session
ALTER EVENT SESSION [XEOverhead]
ON SERVER
STATE=START;
GO

-- Open the Live Data View for the session

-- Run the following to generate a lot of statement events
EXECUTE [dbo].[ExecuteLotsOfStatements] @ExecutionLoopCount = 100000;
GO

-- Stop the session and reconfigure it to have more memory
-- Then run the test again
