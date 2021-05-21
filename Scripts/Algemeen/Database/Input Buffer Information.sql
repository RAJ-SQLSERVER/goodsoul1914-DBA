-- Get input buffer information for the current database
--
-- Gives you input buffer information from all non-system sessions for the current database
-- Replaces DBCC INPUTBUFFER
--
-- New DMF for retrieving input buffer in SQL Server
-- https://bit.ly/2uHKMbz
--
-- sys.dm_exec_input_buffer (Transact-SQL)
-- https://bit.ly/2J5Hf9q
--
---------------------------------------------------------------------------------------------------
SELECT es.session_id,
	DB_NAME(es.database_id) AS [Database Name],
	es.login_time,
	es.cpu_time,
	es.logical_reads,
	es.memory_usage,
	es.STATUS,
	ib.event_info AS [Input Buffer]
FROM sys.dm_exec_sessions AS es WITH (NOLOCK)
CROSS APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib
WHERE es.database_id = DB_ID()
	AND es.session_id > 50
	AND es.session_id <> @@SPID
OPTION (RECOMPILE);
GO
