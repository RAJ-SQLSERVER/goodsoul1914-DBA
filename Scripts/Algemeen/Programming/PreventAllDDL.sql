/******************************************************************************

	“EXECUTE AS” and an important update your DDL Triggers 
	(for auditing or prevention)

******************************************************************************/


USE AdventureWorks2019;
GO

-- Create a login/user
CREATE LOGIN Paul WITH PASSWORD = 'PxKoJ29!07';
GO
CREATE USER Paul FOR LOGIN Paul;
GO

sys.sp_addrolemember 'db_ddladmin', 'Paul';
GO

CREATE SCHEMA SecurityAdministration;
GO

CREATE TABLE SecurityAdministration.AuditDDLOperations
(
    OpID INT NOT NULL IDENTITY
        CONSTRAINT AuditDDLOperationsPK PRIMARY KEY CLUSTERED,
    OriginalLoginName sysname NOT NULL,
    LoginName sysname NOT NULL,
    UserName sysname NOT NULL,
    PostTime DATETIME NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    DDLOp NVARCHAR(2000) NOT NULL
);
GO

GRANT INSERT ON SecurityAdministration.AuditDDLOperations TO PUBLIC;
GO

CREATE TRIGGER PreventAllDDL
ON DATABASE
WITH ENCRYPTION
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN

    DECLARE @data XML;
    SET @data = EVENTDATA();
    RAISERROR('DDL Operations are prohibited on this production database. Please contact ITOperations for proper policies and change control procedures.', 16, -1);
    ROLLBACK;
    INSERT SecurityAdministration.AuditDDLOperations (OriginalLoginName,
                                                      LoginName,
                                                      UserName,
                                                      PostTime,
                                                      EventType,
                                                      DDLOp)
    VALUES (ORIGINAL_LOGIN(), SYSTEM_USER, CURRENT_USER, GETDATE(),
            @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
            @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)'));
    RETURN;
END;
GO

--Test the trigger.

CREATE TABLE TestTable
(
    col1 INT
);
GO

DROP TABLE SecurityAdministration.AuditDDLOperations;
GO

EXECUTE AS LOGIN = 'Paul'; -- note: Remember, Paul is a DDL_admin
GO

DROP TABLE SecurityAdministration.AuditDDLOperations;
GO

REVERT;
GO

SELECT *
FROM   SecurityAdministration.AuditDDLOperations;
GO

DROP TRIGGER PreventAllDDL
ON DATABASE;
GO

DROP TABLE SecurityAdministration.AuditDDLOperations;
GO

DROP SCHEMA SecurityAdministration;
GO

DROP USER Paul;
GO

DROP LOGIN Paul;
GO