-- Finding Connections to Your Database
-- ------------------------------------------------------------------------------------------------
SELECT database_id,
	session_id,
	STATUS,
	login_time,
	cpu_time,
	memory_usage,
	reads,
	writes,
	logical_reads,
	host_name,
	program_name,
	host_process_id,
	client_interface_name,
	login_name AS database_login_name,
	last_request_start_time
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY cpu_time DESC;
GO


