--------------------------------------------------------------------------------- 
-- The sample scripts are not supported under any Microsoft standard support 
-- program or service. The sample scripts are provided AS IS without warranty  
-- of any kind. Microsoft further disclaims all implied warranties including,  
-- without limitation, any implied warranties of merchantability or of fitness for 
-- a particular purpose. The entire risk arising out of the use or performance of  
-- the sample scripts and documentation remains with you. In no event shall 
-- Microsoft, its authors, or anyone else involved in the creation, production, or 
-- delivery of the scripts be liable for any damages whatsoever (including, 
-- without limitation, damages for loss of business profits, business interruption, 
-- loss of business information, or other pecuniary loss) arising out of the use 
-- of or inability to use the sample scripts or documentation, even if Microsoft 
-- has been advised of the possibility of such damages 
--------------------------------------------------------------------------------- 
DECLARE @FilePath NVARCHAR(200);
DECLARE @DatabaseName NVARCHAR(100);
DECLARE @Operate NVARCHAR(40);
DECLARE @Category NVARCHAR(100);
DECLARE @IsScript TINYINT;

--------------------------------------------------------------------------------- 
-- Parameters
--------------------------------------------------------------------------------- 
-- Audit file storage directory
SET @FilePath = N'D:\SQLAudits';
SET @DatabaseName = N'AdventureWorks2019';

-- DML,DDL,OTHER
SET @Operate = N'DML';

-- DML OPTION:   SELECT,UPDATE,INSERT,DELETE,EXECUTE
-- DDL OPTION:   DATABASE,OBJECT,USER,SCHEMA
-- OTHER OPTION: PERMISSION,DBCC,BACKUP,SUCCEED,FAILED
-- PERMISSION: Executing grant, deny or revoke for a object.
-- DBCC: Executing DBCC command.
-- BACKUP: Executing backup or restore.
-- SUCCEED: Login to database.
-- FAILED: Login to database failed.
SET @Category = N'UPDATE';

-- 1:Generate script; 2:Execute Immediately
SET @IsScript = 1;

--------------------------------------------------------------------------------- 
IF @Operate NOT IN ( 'DML', 'DDL', 'OTHER' )
BEGIN
    PRINT @Operate + ' PARAMETER NOT EXISTS!';

    RETURN;
END;

IF @Category NOT IN ( 'SELECT', 'UPDATE', 'INSERT', 'DELETE', 'EXECUTE', 'DATABASE', 'OBJECT', 'USER', 'SCHEMA',
                      'PERMISSION', 'DBCC', 'BACKUP', 'SUCCEED', 'FAILED'
)
BEGIN
    PRINT @Category + ' PARAMETER NOT EXISTS!';

    RETURN;
END;

DECLARE @SQL NVARCHAR(MAX);
DECLARE @SQLSpec NVARCHAR(MAX);
DECLARE @AuditName NVARCHAR(500);
DECLARE @AuditSpecName NVARCHAR(500);
DECLARE @AuditActionType NVARCHAR(200);

SET @AuditName = N'AUDIT_' + @Operate + N'_' + @Category;
SET @AuditSpecName = N'AUDIT_' + @Operate + N'_' + @Category + N'_SPECIFICATION';
SET @AuditActionType = CASE @Category
                           WHEN 'OBJECT' THEN 'SCHEMA_OBJECT_CHANGE_GROUP'
                           WHEN 'DATABASE' THEN 'DATABASE_CHANGE_GROUP'
                           WHEN 'USER' THEN 'DATABASE_PRINCIPAL_CHANGE_GROUP'
                           WHEN 'SCHEMA' THEN 'DATABASE_OBJECT_CHANGE_GROUP'
                           WHEN 'PERMISSION' THEN 'SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP'
                           WHEN 'DBCC' THEN 'DBCC_GROUP'
                           WHEN 'BACKUP' THEN 'BACKUP_RESTORE_GROUP'
                           WHEN 'SUCCEED' THEN 'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
                           WHEN 'FAILED' THEN 'FAILED_DATABASE_AUTHENTICATION_GROUP'
                       END;

IF @Operate = 'DML'
BEGIN
    SET @SQL = N'
		USE MASTER
		CREATE SERVER AUDIT ' + @AuditName + N'
		TO FILE (FILEPATH = ' + N'''' + @FilePath + N'''' + N')
		ALTER SERVER AUDIT ' + @AuditName + N' WITH (STATE = ON)
		';
    SET @SQLSpec = N'
		USE ' + @DatabaseName + N'
		CREATE DATABASE AUDIT SPECIFICATION ' + @AuditSpecName + N'
		FOR SERVER AUDIT ' + @AuditName + N'
		ADD (' + @Category + N' ON DATABASE::' + @DatabaseName + N' BY [public])
		WITH (STATE = ON)
		';

    IF @IsScript = 1
    BEGIN
        PRINT @SQL;
        PRINT @SQLSpec;
    END;
    ELSE IF @IsScript = 2 BEGIN
EXEC (@SQL);

EXEC (@SQLSpec);
    END;
END;

IF @Operate = 'DDL'
   OR @Operate = 'OTHER'
BEGIN
    SET @SQL = N'
		USE MASTER
		CREATE SERVER AUDIT ' + @AuditName + N'
		TO FILE (FILEPATH = ' + N'''' + @FilePath + N'''' + N')
		ALTER SERVER AUDIT ' + @AuditName + N' WITH (STATE = ON)
		';
    SET @SQLSpec = N'
		USE ' + @DatabaseName + N'
		CREATE DATABASE AUDIT SPECIFICATION ' + @AuditSpecName + N'
		FOR SERVER AUDIT ' + @AuditName + N'
		ADD (' + @AuditActionType + N')
		WITH (STATE = ON)
		';

    IF @IsScript = 1
    BEGIN
        PRINT @SQL;
        PRINT @SQLSpec;
    END;
    ELSE IF @IsScript = 2 BEGIN
EXEC (@SQL);

EXEC (@SQLSpec);
    END;
END;
