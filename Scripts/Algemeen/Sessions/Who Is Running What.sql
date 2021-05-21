-- Who is running what at this instance?
---------------------------------------------------------------------------------------------------
SELECT dest.TEXT AS [Command text],
	des.login_time,
	des.host_name,
	des.program_name,
	der.session_id,
	DEC.client_net_address,
	der.STATUS,
	der.command,
	DB_NAME(der.database_id) AS DatabaseName
FROM sys.dm_exec_requests AS der
INNER JOIN sys.dm_exec_connections AS DEC ON der.session_id = DEC.session_id
INNER JOIN sys.dm_exec_sessions AS des ON des.session_id = der.session_id
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS dest
WHERE des.is_user_process = 1;
GO

-- Isolation level of session?
SELECT session_id,
	CHOOSE(transaction_isolation_level, 'Read Uncommitted', 'Read Committed', 'Repeatable Read', 'Serializable', 'Snapshot') AS isolation_level
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID;
GO


SELECT @@SPID AS my_session_id,
       ses.*
FROM sys.dm_exec_sessions AS ses
    JOIN sys.endpoints ep
        ON ses.endpoint_id = ep.endpoint_id
WHERE ep.name = N'Dedicated Admin Connection';
GO
