-- The wait_type for a BUF latch is PAGELATCH_XX or PAGEIOLATCH_XX
-- The wait_resource is a pageno for a PAGELATCH and "class" and
-- "address" for a non-BUF latch
SELECT session_id,
	command,
	wait_type,
	wait_resource,
	wait_time,
	blocking_session_id
FROM sys.dm_exec_requests
WHERE session_id > 50;
GO


