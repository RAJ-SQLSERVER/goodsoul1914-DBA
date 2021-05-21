-- create the database
USE master;

IF (DB_ID ('DeadlockLogging') IS NOT NULL)
    BEGIN
        ALTER DATABASE DeadlockLogging SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE DeadlockLogging;
    END;

CREATE DATABASE DeadlockLogging WITH TRUSTWORTHY ON;
GO

-- create the Service Broker Objects
USE DeadlockLogging;

CREATE QUEUE dbo.LogDeadlocksQueue;

CREATE SERVICE LogDeadlocksService
ON QUEUE dbo.LogDeadlocksQueue
([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);

CREATE ROUTE LogDeadlocksRoute
WITH
SERVICE_NAME = 'LogDeadlocksService',
ADDRESS = 'LOCAL';

-- add server level notification
IF EXISTS (SELECT * FROM sys.server_event_notifications WHERE name = 'LogDeadlocks')
    DROP EVENT NOTIFICATION LogDeadlocks
    ON SERVER;

DECLARE @SQL NVARCHAR(MAX);
SELECT @SQL = N'
    CREATE EVENT NOTIFICATION LogDeadlocks 
    ON SERVER 
    FOR deadlock_graph -- name of SQLTrace event type
    TO SERVICE ''LogDeadlocksService'', ''' + CAST(service_broker_guid AS NVARCHAR(MAX)) + N''';'
FROM sys.databases
WHERE name = DB_NAME ();
EXEC sp_executesql @SQL;
GO

-- create a place to store the deadlock graphs along with query plan information
CREATE SEQUENCE dbo.DeadlockIdentity START WITH 1;

CREATE TABLE dbo.ExtendedDeadlocks (
    DeadlockId     BIGINT        NOT NULL,
    DeadlockTime   DATETIME      NOT NULL,
    SqlHandle      VARBINARY(64),
    StatementStart INT,
    Statement      NVARCHAR(MAX) NULL,
    Deadlock       XML           NOT NULL,
    FirstQueryPlan XML
);

CREATE CLUSTERED INDEX IX_ExtendedDeadlocks
ON dbo.ExtendedDeadlocks (DeadlockTime, DeadlockId);
GO

-- the Procedure That Processes Queue Messages
CREATE PROCEDURE dbo.ProcessDeadlockMessage
AS
DECLARE @RecvMsg NVARCHAR(MAX);
DECLARE @RecvMsgTime DATETIME;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

WAITFOR (
    RECEIVE TOP (1) @RecvMsgTime = message_enqueue_time,
                    @RecvMsg = message_body
    FROM dbo.LogDeadlocksQueue
),
TIMEOUT 5000;

IF (@@ROWCOUNT = 0)
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN;
    END;

DECLARE @DeadlockId BIGINT = NEXT VALUE FOR dbo.DeadlockIdentity;
DECLARE @RecsvMsgXML XML = CAST(@RecvMsg AS XML);
DECLARE @DeadlockGraph XML = @RecsvMsgXML.query ('/EVENT_INSTANCE/TextData/deadlock-list/deadlock');

WITH DistinctSqlHandles AS
(
    SELECT DISTINCT node.value ('@sqlhandle', 'varchar(max)') AS "SqlHandle"
    FROM @RecsvMsgXML.nodes('//frame') AS frames(node)
)
INSERT ExtendedDeadlocks (DeadlockId, DeadlockTime, SqlHandle, StatementStart, Statement, Deadlock, FirstQueryPlan)
SELECT @DeadlockId,
       @RecvMsgTime,
       qs.sql_handle,
       qs.statement_start_offset,
       statement,
       @DeadlockGraph,
       qp.query_plan
FROM DistinctSqlHandles AS s
LEFT JOIN sys.dm_exec_query_stats AS qs
    ON qs.sql_handle = CONVERT (VARBINARY(64), SqlHandle, 1)
OUTER APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_sql_text (CONVERT (VARBINARY(64), SqlHandle, 1)) AS st
OUTER APPLY (
    SELECT SUBSTRING (
               st.text,
               (qs.statement_start_offset + 2) / 2,
               (CASE
                    WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text)) * 2
                    ELSE qs.statement_end_offset + 2
                END - qs.statement_start_offset
               ) / 2
           )
) AS sqlStatement(statement);

-- clean up old deadlocks
DECLARE @limit BIGINT;
SELECT DISTINCT TOP (500) @limit = DeadlockId
FROM ExtendedDeadlocks
ORDER BY DeadlockId DESC;
DELETE ExtendedDeadlocks
WHERE DeadlockId < @limit;

COMMIT;
GO

-- activating the Procedure
ALTER QUEUE dbo.LogDeadlocksQueue
WITH ACTIVATION (
         STATUS = ON,
         PROCEDURE_NAME = dbo.ProcessDeadlockMessage,
         MAX_QUEUE_READERS = 1,
         EXECUTE AS SELF
     );
GO



-- when done cleanup afterwards
/*

USE master;

IF (DB_ID ('DeadlockLogging') IS NOT NULL)
    BEGIN
        ALTER DATABASE DeadlockLogging SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE DeadlockLogging;
    END;

IF EXISTS (
    SELECT *
    FROM sys.server_event_notifications
    WHERE name = 'DeadlockLogging'
)
    DROP EVENT NOTIFICATION LogDeadlocks
    ON SERVER;

*/
