/***************************************************************************************
 List schema name, owner user name, and owner login name for user tables and views 
***************************************************************************************/
SELECT so.name AS OBJECT,
	sc.name AS [Schema],
	USER_NAME(COALESCE(so.principal_id, sc.principal_id)) AS OwnerUserName,
	sp.name AS OwnerLoginName,
	so.type_desc AS ObjectType
FROM sys.objects AS so
JOIN sys.schemas AS sc ON so.schema_id = sc.schema_id
JOIN sys.database_principals AS dp ON dp.principal_id = COALESCE(so.principal_id, sc.principal_id)
LEFT JOIN master.sys.server_principals AS sp ON dp.sid = sp.sid
WHERE so.type IN ('U', 'V');
