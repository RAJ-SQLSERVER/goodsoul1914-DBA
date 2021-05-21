-- Returns one row per authenticated session on SQL Server. sys.dm_exec_sessions 
-- is a server-scope view that shows information about all active user connections 
-- and internal tasks. This information includes client version, client program name, 
-- client login time, login user, current session setting, and more. 
-- 
-- Use sys.dm_exec_sessions to first view the current system load and to identify a 
-- session of interest, and then learn more information about that session by using 
-- other dynamic management views or dynamic management functions.
---------------------------------------------------------------------------------------------------
SELECT session_id,
	login_time,
	host_name,
	program_name,
	host_process_id,
	client_interface_name,
	login_name,
	original_login_name,
	STATUS,
	cpu_time,
	memory_usage,
	total_scheduled_time,
	total_elapsed_time,
	last_request_start_time,
	last_request_end_time,
	reads,
	writes,
	logical_reads,
	is_user_process,
	transaction_isolation_level,
	open_transaction_count,
	database_id,
	authenticating_database_id
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;
GO


