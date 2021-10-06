-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'CounterPredicate')
	DROP EVENT SESSION [CounterPredicate]
	ON SERVER;
GO

-- Create the event session
CREATE EVENT SESSION [CounterPredicate] 
ON SERVER 
ADD EVENT sqlserver.sql_statement_completed(
	SET collect_statement=1
    WHERE (package0.counter<5));
GO

-- Start the event session
ALTER EVENT SESSION [CounterPredicate]
ON SERVER
STATE=START;
GO

-- Run AdventureWorks Books Online Workload
-- the event session will only capture four events


