-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'SamplingSessionIDs')
	DROP EVENT SESSION [SamplingSessionIDs]
	ON SERVER;
GO

-- Create the event session
CREATE EVENT SESSION [SamplingSessionIDs] 
ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.session_id)
    WHERE (package0.divides_by_uint64(sqlserver.session_id,2)));
GO

-- Start the event session
ALTER EVENT SESSION [SamplingSessionIDs]
ON SERVER
STATE=START;
GO

-- Run the AdventureWorks Books Online workload
-- only events with an even session_id will be collected