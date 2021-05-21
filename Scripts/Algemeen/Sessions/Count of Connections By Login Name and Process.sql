-- Count of Connections by Login Name/Process (i.e. how many connections does an app have open)
-- ------------------------------------------------------------------------------------------------
SELECT login_name,
	host_name,
	host_process_id,
	COUNT(1) AS LoginCount
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY login_name,
	host_name,
	host_process_id;
