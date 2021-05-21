-- Statements executing by session
---------------------------------------------------------------------------------------------------
SELECT der.session_id,
	DB_NAME(der.database_id) AS database_name,
	deqp.query_plan,
	SUBSTRING(dest.TEXT, der.statement_start_offset / 2, (
			CASE 
				WHEN der.statement_end_offset = - 1
					THEN DATALENGTH(dest.TEXT)
				ELSE der.statement_end_offset
				END - der.statement_start_offset
			) / 2) AS [statement executing],
	der.cpu_time,
	der.granted_query_memory,
	der.wait_time,
	der.total_elapsed_time,
	der.reads
FROM sys.dm_exec_requests AS der
INNER JOIN sys.dm_exec_sessions AS des ON des.session_id = der.session_id
CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
WHERE des.is_user_process = 1
	AND der.session_id <> @@spid
ORDER BY der.cpu_time DESC;
	-- ORDER BY der.granted_query_memory DESC ;
	-- ORDER BY der.wait_time DESC;
	-- ORDER BY der.total_elapsed_time DESC;
	-- ORDER BY der.reads DESC;
GO


