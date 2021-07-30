/*
Invalid owner for a system Role, Schema, or Database
====================================================
Author: Eitan Blumin | Madeira Data Solutions | https://www.madeiradata.com
Date: 2020-11-25
Description:

System roles and schemas must have specific owning users or roles.
 
For example, all system database roles such as db_owner, db_datawriter, db_datareader, etc. must be owned by dbo.
All system schemas such as sys, dbo, db_owner, db_datawriter, db_datareader, etc. must be owned by the system role or user of the same name.
 
It's a 3-part relationship like so:
schema X - owned by role X - owned by dbo.
 
If the database is a system database, its owner should be sa (or equivalent, if it was renamed).
 
Invalid owners for such system objects can potentially cause severe errors during version updates/upgrades, or when using certain HADR features.
Additionally, once a system object is owned by a user-created login/user, it becomes very problematic to remove or make changes to such logins/users.

This script will detect any such misconfigurations, and provide you with the proper remediation scripts to fix it.
*/
SET NOCOUNT, ARITHABORT, XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @CMD      NVARCHAR(MAX),
        @DBName   sysname,
        @Executor NVARCHAR(1000),
        @SaName   sysname;

SELECT @SaName = name
FROM sys.server_principals
WHERE sid = 0x01;

SET @CMD = N'SELECT DB_ID(), DB_NAME(), ''SCHEMA'', sch.[name], pr.[name]
FROM sys.schemas AS sch
LEFT JOIN sys.database_principals AS pr ON sch.principal_id = pr.principal_id
WHERE (sch.schema_id >= 16384 OR DB_NAME() = ''msdb'')
AND (pr.principal_id IS NULL
    OR (sch.[name] NOT IN (''managed_backup'',''smart_admin'',''MS_PerfDashboard'') AND sch.[name] <> pr.[name])
    OR (sch.[name] IN (''managed_backup'',''smart_admin'',''MS_PerfDashboard'') AND sch.principal_id <> 1)
    )

UNION ALL

SELECT DB_ID(), DB_NAME(), ''ROLE'', rol.[name], pr.[name]
FROM sys.database_principals AS rol
LEFT JOIN sys.database_principals AS pr ON rol.owning_principal_id = pr.principal_id
WHERE (rol.principal_id >= 16384 OR DB_NAME() = ''msdb'')
AND rol.type = ''R''
AND (pr.principal_id IS NULL OR rol.owning_principal_id <> 1)

UNION ALL

SELECT DB_ID(), DB_NAME(), ''DATABASE'', DB_NAME(), sp.[name] COLLATE database_default
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON dp.sid = sp.sid
WHERE dp.principal_id = 1
AND DB_ID() <= 4
AND (sp.sid IS NULL OR sp.sid <> 0x01)';

DECLARE @Result AS TABLE (
    DBId         INT     NULL,
    DBName       sysname NULL,
    ObjType      sysname NULL,
    SchemaName   sysname NULL,
    RoleName     sysname NULL,
    DefaultOwner AS (CASE
                         WHEN ObjType = 'SCHEMA' THEN SchemaName
                         WHEN ObjType = 'ROLE' THEN 'dbo'
                     END
                    )
);

DECLARE DBs CURSOR LOCAL FAST_FORWARD FOR
SELECT name
FROM sys.databases
WHERE state = 0
      AND is_read_only = 0
      AND DATABASEPROPERTYEX (name, 'Updateability') = 'READ_WRITE';

OPEN DBs;
FETCH NEXT FROM DBs
INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Executor = QUOTENAME (@DBName) + N'..sp_executesql';

    INSERT INTO @Result
    EXEC @Executor @CMD;

    FETCH NEXT FROM DBs
    INTO @DBName;
END;

CLOSE DBs;
DEALLOCATE DBs;

SELECT N'In server: ' + @@SERVERNAME + N', database: ' + QUOTENAME (DBName) + N', system ' + ObjType + N'::'
       + QUOTENAME (SchemaName) + N' has an invalid owner ' + ISNULL (QUOTENAME (RoleName), N'(null)')
       + N'. should be: ' + QUOTENAME (ISNULL (DefaultOwner, @SaName)) AS "Msg",
       N'USE ' + QUOTENAME (DBName) + N'; ALTER AUTHORIZATION ON ' + UPPER (ObjType) + N'::' + QUOTENAME (SchemaName)
       + N' TO ' + QUOTENAME (ISNULL (DefaultOwner, @SaName)) + N';' AS "RemediationCmd"
FROM @Result
ORDER BY DBId ASC;
