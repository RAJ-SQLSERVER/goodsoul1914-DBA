-- Isolating the executing statement within a SQL handle
---------------------------------------------------------------------------------------------------
SELECT der.statement_start_offset,
	der.statement_end_offset,
	SUBSTRING(dest.TEXT, der.statement_start_offset / 2, (
			CASE 
				WHEN der.statement_end_offset = - 1
					THEN DATALENGTH(dest.TEXT)
				ELSE der.statement_end_offset
				END - der.statement_start_offset
			) / 2) AS statement_executing,
	dest.TEXT AS [full statement code]
FROM sys.dm_exec_requests AS der
INNER JOIN sys.dm_exec_sessions AS des ON des.session_id = der.session_id
CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
WHERE des.is_user_process = 1
	AND der.session_id <> @@spid
ORDER BY der.session_id;
GO


