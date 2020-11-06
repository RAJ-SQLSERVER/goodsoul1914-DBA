IF OBJECTPROPERTY(OBJECT_ID('usp_CreateServerAudit'), 'IsProcedure') = 1
    DROP PROCEDURE dbo.usp_CreateServerAudit;
GO

CREATE PROCEDURE dbo.usp_CreateServerAudit (
    @AuditLogPath     NVARCHAR(255),
    @AllUserDatabases BIT = 1
)
AS
BEGIN
    DECLARE @ServerName   NVARCHAR(255) = N'GPSQL01',
            @SqlToExecute NVARCHAR(MAX) = N'';

    -- Create server audit
    IF NOT EXISTS (
        SELECT *
        FROM   sys.server_audits
        WHERE  name = 'DBA_' + @ServerName + '_Audit'
    )
    BEGIN
        SET @SqlToExecute
            = N'Use master; 
				CREATE SERVER AUDIT [DBA_' + @ServerName + N'_Audit]
				TO FILE (FILEPATH = ''' + @AuditLogPath + N''')
				WITH (
					QUEUE_DELAY = 1000,
					ON_FAILURE = CONTINUE
				);';
        EXEC sys.sp_executesql @SqlToExecute;
    END;

    -- Create server audit specification
    IF NOT EXISTS (
        SELECT *
        FROM   sys.server_audit_specifications
        WHERE  name = 'DBA_' + @ServerName + '_AuditSpec'
    )
    BEGIN
        SET @SqlToExecute
            = N'Use master; 
				CREATE SERVER AUDIT SPECIFICATION [DBA_' + @ServerName + N'_AuditSpec]
				FOR SERVER AUDIT [DBA_' + @ServerName + N'_Audit]
					ADD (AUDIT_CHANGE_GROUP),
					ADD (DBCC_GROUP),
					ADD (FAILED_LOGIN_GROUP),
					ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
					ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
					ADD (SUCCESSFUL_LOGIN_GROUP),
					ADD (TRACE_CHANGE_GROUP)
				WITH (STATE = ON);';
        EXEC sys.sp_executesql @SqlToExecute;
    END;

    -- Create database audit specification (for every user database)
    IF (@AllUserDatabases = 1)
    BEGIN
        SET @SqlToExecute
            = N'EXEC sp_MSforeachdb ''USE [?];
				IF DB_ID(''''?'''') > 4 
				BEGIN
					CREATE DATABASE AUDIT SPECIFICATION DBA_?_AuditSpec
					FOR SERVER AUDIT [DBA_' + @ServerName + N'_Audit]
						ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
						ADD (DATABASE_PERMISSION_CHANGE_GROUP),
						ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
						ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
						ADD (SCHEMA_OBJECT_CHANGE_GROUP),
						ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
					WITH (STATE = ON)
				END;''';
        EXEC sys.sp_executesql @SqlToExecute;
    END;

    -- Start server audit
    SET @SqlToExecute = N'Use master; 
						ALTER SERVER AUDIT [DBA_' + @ServerName + N'_Audit]
						WITH (STATE = ON);';
    EXEC sys.sp_executesql @SqlToExecute;
END;
GO

EXEC dbo.usp_CreateServerAudit @AuditLogPath = 'L:\SQLAudit',
                               @AllUserDatabases = 1;
