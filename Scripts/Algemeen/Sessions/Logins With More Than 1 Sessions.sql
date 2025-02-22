-- Logins with more than one session
---------------------------------------------------------------------------------------------------
SELECT login_name,
	COUNT(session_id) AS session_count
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY login_name
ORDER BY login_name;
GO


