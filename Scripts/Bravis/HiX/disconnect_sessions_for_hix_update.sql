DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'KILL ' + CONVERT(VARCHAR(11), session_id) + N';'
FROM sys.dm_exec_sessions
WHERE 
	(login_name LIKE N'LIEVENS%' OR -- Bergse clients 
	host_name NOT IN (N'GPHIXCOMEZ01', N'GPHIXMETING01', N'GPHIXMETING02', N'GPCSTS01', N'GPHIXDWH02')) AND -- Servers die actief moeten blijven
	session_id NOT IN (88, 181) -- Eigen session id's

EXEC sys.sp_executesql @sql;

