-- =========
-- SESSION 3
-- =========
SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id IN (54)
	AND resource_type = 'KEY';
GO

-- Analyze the locks that were acquired
-- Now there is a Shared Lock acquired for the SELECT statement
-- This now leads to a blocking situation, bacause we already have acquired an exclusive lock
SELECT *
FROM sys.dm_tran_locks
WHERE request_session_id IN (55)
	AND resource_type = 'KEY';
GO

-- Analyze the waiting tasks
-- The 2nd session is waiting for another session ("blocking_session_id")
-- The column "resource_desciption" tells us for which lock on which object we are waiting
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE session_id IN (54, 55);
GO

-- The blocked session is currently suspended ("status")
SELECT *
FROM sys.dm_exec_requests
WHERE session_id IN (54, 55);
GO


