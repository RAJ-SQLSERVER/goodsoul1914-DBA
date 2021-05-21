-- Identify sessions with context switching
---------------------------------------------------------------------------------------------------
SELECT session_id,
	login_name,
	original_login_name
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
	AND login_name <> original_login_name;
GO


