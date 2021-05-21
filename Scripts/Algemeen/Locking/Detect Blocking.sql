-- Active blocking issues?
-------------------------------------------------------------------------------
SELECT session_id,
	wait_duration_ms,
	wait_type,
	blocking_session_id
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE N'LCK%';
GO

-- Detect blocking (run multiple times) 
--
-- Helps troubleshoot blocking and deadlocking issues
-- The results will change from second to second on a busy system
-- You should run this query multiple times when you see signs of blocking
-------------------------------------------------------------------------------
SELECT t1.resource_type AS [lock type],
	DB_NAME(resource_database_id) AS [database],
	t1.resource_associated_entity_id AS [blk object],
	t1.request_mode AS [lock req], -- lock requested
	t1.request_session_id AS [waiter sid], -- spid of waiter 
	t2.wait_duration_ms AS [wait time],
	(
		SELECT [text]
		FROM sys.dm_exec_requests AS r WITH (NOLOCK) -- get sql for waiter
		CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
		WHERE r.session_id = t1.request_session_id
		) AS waiter_batch,
	(
		SELECT SUBSTRING(qt.[text], r.statement_start_offset / 2, (
					CASE 
						WHEN r.statement_end_offset = - 1
							THEN LEN(CONVERT(NVARCHAR(max), qt.[text])) * 2
						ELSE r.statement_end_offset
						END - r.statement_start_offset
					) / 2)
		FROM sys.dm_exec_requests AS r WITH (NOLOCK)
		CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
		WHERE r.session_id = t1.request_session_id
		) AS waiter_stmt, -- statement blocked
	t2.blocking_session_id AS [blocker sid], -- spid of blocker
	(
		SELECT [text]
		FROM sys.sysprocesses AS p -- get sql for blocker
		CROSS APPLY sys.dm_exec_sql_text(p.sql_handle)
		WHERE p.spid = t2.blocking_session_id
		) AS blocker_batch
FROM sys.dm_tran_locks AS t1 WITH (NOLOCK)
INNER JOIN sys.dm_os_waiting_tasks AS t2 WITH (NOLOCK) ON t1.lock_owner_address = t2.resource_address
OPTION (RECOMPILE);
GO

-- 
---------------------------------------------------------------------------------------------------
WITH b
AS (
	SELECT DISTINCT blocking_session_id AS blockers
	FROM sys.dm_exec_requests
	)
SELECT session_id,
	0 AS blocking_session_id,
	Block_Desc = 'Lead'
FROM sys.dm_exec_sessions AS es
INNER JOIN b ON es.session_id = b.blockers
WHERE NOT EXISTS (
		SELECT 1
		FROM sys.dm_exec_requests AS er
		WHERE es.session_id = er.session_id
		)
	OR EXISTS (
		SELECT 1
		FROM sys.dm_exec_requests AS er
		WHERE es.session_id = er.session_id
			AND er.blocking_session_id = 0
		)

UNION ALL

SELECT session_id,
	blocking_session_id,
	Block_Desc = 'Victim'
FROM sys.dm_exec_requests
WHERE blocking_session_id != 0;
GO


