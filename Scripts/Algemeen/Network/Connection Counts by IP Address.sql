-- Get a count of SQL connections by IP address
---------------------------------------------------------------------------------------------------
SELECT DEC.client_net_address,
	des.program_name,
	des.host_name,
	des.login_name,
	COUNT(DEC.session_id) AS connection_count
FROM sys.dm_exec_sessions AS des
INNER JOIN sys.dm_exec_connections AS DEC ON des.session_id = DEC.session_id
--WHERE	LEFT(des.host_name, 2) = 'WK'
GROUP BY DEC.client_net_address,
	des.program_name,
	des.host_name,
	des.login_name
-- HAVING COUNT(dec.session_id) > 1
ORDER BY des.program_name,
	DEC.client_net_address;
GO
