-- Who is connected by SSMS?
---------------------------------------------------------------------------------------------------
SELECT DEC.client_net_address,
	des.host_name,
	dest.TEXT
FROM sys.dm_exec_sessions AS des
INNER JOIN sys.dm_exec_connections AS DEC ON des.session_id = DEC.session_id
CROSS APPLY sys.dm_exec_sql_text(DEC.most_recent_sql_handle) AS dest
WHERE des.program_name LIKE 'Microsoft SQL Server Management Studio%'
ORDER BY des.program_name,
	DEC.client_net_address;
GO


