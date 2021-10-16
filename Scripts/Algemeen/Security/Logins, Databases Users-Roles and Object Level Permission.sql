/*
Get logins, databases users/roles and object level permission (T-SQL)

Introduction
This script contains three code parts, one to get the result of server level logins 
and related roles, one to get the result of user databases� users and related roles, 
one to get the result of object level permission of specific database.

Scenarios
This script can be used to get the following results:
	� Server level logins and related roles
	� User databases users and related roles
	� Object level permission of specific database
*/
-- #1 Server level Logins and roles
SELECT sp.name AS "LoginName",
       sp.type_desc AS "LoginType",
       sp.default_database_name AS "DefaultDBName",
       slog.sysadmin AS "SysAdmin",
       slog.securityadmin AS "SecurityAdmin",
       slog.serveradmin AS "ServerAdmin",
       slog.setupadmin AS "SetupAdmin",
       slog.processadmin AS "ProcessAdmin",
       slog.diskadmin AS "DiskAdmin",
       slog.dbcreator AS "DBCreator",
       slog.bulkadmin AS "BulkAdmin"
FROM sys.server_principals AS sp
JOIN master..syslogins AS slog
    ON sp.sid = slog.sid
WHERE sp.type <> 'R'
      AND sp.name NOT LIKE '##%';

-- #2 Databases users and roles
DECLARE @SQLStatement VARCHAR(4000);
DECLARE @T_DBuser TABLE (DBName sysname, UserName sysname, AssociatedDBRole NVARCHAR(256));

SET @SQLStatement = '
SELECT ''?'' AS DBName,dp.name AS UserName,USER_NAME(drm.role_principal_id) AS AssociatedDBRole 
FROM ?.sys.database_principals dp
LEFT OUTER JOIN ?.sys.database_role_members drm
ON dp.principal_id=drm.member_principal_id 
WHERE dp.sid NOT IN (0x01) AND dp.sid IS NOT NULL AND dp.type NOT IN (''C'') AND dp.is_fixed_role <> 1 AND dp.name NOT LIKE ''##%'' AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY DBName';

INSERT @T_DBuser
EXEC sp_MSforeachdb @SQLStatement;

SELECT *
FROM @T_DBuser
ORDER BY DBName;

-- #3 Get objects permission of specified user database 
USE AdventureWorks;
GO

DECLARE @Obj VARCHAR(4000);
DECLARE @T_Obj TABLE (UserName sysname, ObjectName sysname, Permission NVARCHAR(128));

SET @Obj = '
SELECT Us.name AS username, Obj.name AS object,  dp.permission_name AS permission 
FROM sys.database_permissions dp
JOIN sys.sysusers Us 
ON dp.grantee_principal_id = Us.uid 
JOIN sys.sysobjects Obj
ON dp.major_id = Obj.id ';

INSERT @T_Obj
EXEC sp_MSforeachdb @Obj;

SELECT *
FROM @T_Obj;
