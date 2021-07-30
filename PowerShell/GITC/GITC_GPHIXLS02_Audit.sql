USE master;
GO

CREATE SERVER AUDIT [GITC_GPHIXLS02_Audit]
    TO FILE (
        FILEPATH = 'D:\SQLAudit',
		MAXSIZE = 1GB
    )
    WITH (
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE
);

CREATE SERVER AUDIT SPECIFICATION [GITC_GPHIXLS02_AuditSpec]
    FOR SERVER AUDIT [GITC_GPHIXLS02_Audit]
        ADD (AUDIT_CHANGE_GROUP),              --raised whenever any audit is created, modified or deleted
        ADD (DBCC_GROUP),                      --raised whenever a principal issues any DBCC command
        ADD (FAILED_LOGIN_GROUP),              --indicates that a principal tried to log on to SQL Server and failed
        ADD (SERVER_PRINCIPAL_CHANGE_GROUP),   --raised when server principals are created, altered, or dropped
        ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP), --raised whenever a login IS added or removed from a fixed server role
        ADD (SUCCESSFUL_LOGIN_GROUP),          --indicates that a principal hassuccessfully logged in to SQL Server
        ADD (TRACE_CHANGE_GROUP)               --raised for all statements that check for the ALTER TRACE permission
    WITH (STATE = ON);


ALTER SERVER AUDIT [GITC_GPHIXLS02_Audit]
    WITH (
    STATE = ON
);
GO