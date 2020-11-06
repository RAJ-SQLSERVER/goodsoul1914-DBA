
USE [master];
GO

CREATE TRIGGER [trigLogon_CheckForSysadmin]
ON ALL SERVER
FOR LOGON
AS
BEGIN
    IF EXISTS
    (
        SELECT sp.principal_id
        FROM sys.server_role_members srm
        JOIN sys.server_principals sp ON srm.member_principal_id = sp.principal_id
        WHERE srm.role_principal_id =
        (
            SELECT principal_id FROM sys.server_principals WHERE name = 'sysadmin'
        )
              AND ORIGINAL_LOGIN() = sp.name
    )
    BEGIN
        INSERT INTO DBA.dbo.AuditSysadminLogin
        (
            EventTime,
            ServerLogin
        )
        VALUES
        (GETDATE(), ORIGINAL_LOGIN());
    END;
END;
GO

ENABLE TRIGGER [trigLogon_CheckForSysadmin] ON ALL SERVER;
GO


