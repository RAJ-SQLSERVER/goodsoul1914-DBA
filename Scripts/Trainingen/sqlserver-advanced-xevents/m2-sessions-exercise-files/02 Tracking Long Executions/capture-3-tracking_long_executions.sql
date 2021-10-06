-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'LongBatches')
	DROP EVENT SESSION [LongBatches] 
	ON SERVER;
GO

-- Event using textual comparator for predicate
CREATE EVENT SESSION [LongBatches] 
ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(
    WHERE (package0.greater_than_equal_uint64(duration,5000000)));
GO

-- Same effective session without the textual comparator
/*
CREATE EVENT SESSION [LongBatches] 
ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(
    WHERE ([duration] >= 5000000));
GO
*/

-- Start the event session
ALTER EVENT SESSION [LongBatches]
ON SERVER
STATE=START;
GO


-- Run a long running query
SELECT *
FROM AdventureWorks2012.Production.TransactionHistory AS th
CROSS JOIN master.dbo.spt_values AS sv
WHERE sv.type = N'P'
  AND sv.number < 5;

