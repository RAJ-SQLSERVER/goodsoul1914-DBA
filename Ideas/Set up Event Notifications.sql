sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'blocked process threshold', 10; -- in seconds
GO
RECONFIGURE;
GO


USE master
GO
ALTER DATABASE DBA SET ENABLE_BROKER;
ALTER DATABASE DBA SET RECOVERY SIMPLE;
GO


USE DBA;
GO

CREATE QUEUE dbo.BlockedProcessNotificationQueue
WITH STATUS = ON;
GO


CREATE SERVICE BlockedProcessNotificationService
ON QUEUE dbo.BlockedProcessNotificationQueue([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO


CREATE EVENT NOTIFICATION BlockedProcessNotificationEvent ON SERVER 
FOR BLOCKED_PROCESS_REPORT 
TO SERVICE 'BlockedProcessNotificationService', 'current database';
GO


CREATE TABLE dbo.BlockedProcessesInfo (
    ID                    INT           NOT NULL IDENTITY(1, 1),
    EventDate             DATETIME      NOT NULL,
    -- ID of the database where locking occurs
    DatabaseID            SMALLINT      NOT NULL,
    -- Blocking resource
    Resource              VARCHAR(64)   NULL,
    -- Wait time in MS
    WaitTime              INT           NOT NULL,
    -- Raw blocked process report
    BlockedProcessReport  XML           NOT NULL,
    -- SPID of the blocked process
    BlockedSPID           SMALLINT      NOT NULL,
    -- XACTID of the blocked process
    BlockedXactId         BIGINT        NULL,
    -- Blocked Lock Request Mode
    BlockedLockMode       VARCHAR(16)   NULL,
    -- Transaction isolation level for blocked session
    BlockedIsolationLevel VARCHAR(32)   NULL,
    -- Top SQL Handle from execution stack
    BlockedSQLHandle      VARBINARY(64) NULL,
    -- Blocked SQL Statement Start offset
    BlockedStmtStart      INT           NULL,
    -- Blocked SQL Statement End offset
    BlockedStmtEnd        INT           NULL,
    -- Blocked Query Hash
    BlockedQueryHash      BINARY(8)     NULL,
    -- Blocked Query Plan Hash
    BlockedPlanHash       BINARY(8)     NULL,
    -- Blocked SQL based on SQL Handle
    BlockedSql            NVARCHAR(MAX) NULL,
    -- Blocked InputBuf from the report
    BlockedInputBuf       NVARCHAR(MAX) NULL,
    -- Blocked Plan based on SQL Handle
    BlockedQueryPlan      XML           NULL,
    -- SPID of the blocking process
    BlockingSPID          SMALLINT      NULL,
    -- Blocking Process status
    BlockingStatus        VARCHAR(16)   NULL,
    -- Blocking Process Transaction Count
    BlockingTranCount     INT           NULL,
    -- Blocking InputBuf from the report
    BlockingInputBuf      NVARCHAR(MAX) NULL,
    -- Blocked SQL based on SQL Handle
    BlockingSql           NVARCHAR(MAX) NULL,
    -- Blocking Plan based on SQL Handle
    BlockingQueryPlan     XML           NULL
);

CREATE UNIQUE CLUSTERED INDEX IDX_BlockedProcessInfo_EventDate_ID
ON dbo.BlockedProcessesInfo (EventDate, ID);
GO


CREATE FUNCTION dbo.fnGetSqlText (@SqlHandle VARBINARY(64), @StmtStart INT, @StmtEnd INT)
RETURNS TABLE
/**********************************************************************
Function: dbo.fnGetSqlText
Author: Dmitri V. Korotkevitch
Purpose:
Returns sql text based on sql_handle and statement start/end offsets
Includes several safeguards to avoid exceptions
Returns: 1-column table with SQL text
*********************************************************************/
AS
RETURN (
    SELECT SUBSTRING (t.text,
                      @StmtStart / 2 + 1,
                      ((CASE
                            WHEN @StmtEnd = -1 THEN DATALENGTH (t.text)
                            ELSE @StmtEnd
                        END - @StmtStart
                       ) / 2
                      ) + 1
           ) AS "SQL"
    FROM sys.dm_exec_sql_text (NULLIF(@SqlHandle, 0x)) AS t
    WHERE ISNULL (@SqlHandle, 0x) <> 0x
          AND
        -- In some rare cases, SQL Server may return empty or
        -- incorrect sql text
        ISNULL (t.text, '') <> ''
          AND (CASE
                   WHEN @StmtEnd = -1 THEN DATALENGTH (t.text)
                   ELSE @StmtEnd
               END > @StmtStart
          )
);
GO


CREATE FUNCTION dbo.fnGetQueryInfoFromExecRequests (
    @collectPlan BIT,
    @SPID        SMALLINT,
    @SqlHandle   VARBINARY(64),
    @StmtStart   INT,
    @StmtEnd     INT
)
/**********************************************************************
Function: dbo. fnGetQueryInfoFromExecRequests
Author: Dmitri V. Korotkevitch
Purpose:
Returns Returns query and plan hashes, and optional query plan
from sys.dm_exec_requests based on @@spid, sql_handle and
statement start/end offsets
*********************************************************************/
RETURNS TABLE
AS
RETURN (
    SELECT 1 AS "DataExists",
           er.query_plan_hash AS "plan_hash",
           er.query_hash,
           CASE
               WHEN @collectPlan = 1 THEN (SELECT qp.query_plan FROM sys.dm_exec_query_plan (er.plan_handle) AS qp )
               ELSE NULL
           END AS "query_plan"
    FROM sys.dm_exec_requests AS er
    WHERE er.session_id = @SPID
          AND er.sql_handle = @SqlHandle
          AND er.statement_start_offset = @StmtStart
          AND er.statement_end_offset = @StmtEnd
);
GO


CREATE FUNCTION dbo.fnGetQueryInfoFromQueryStats (
    @collectPlan        BIT,
    @SqlHandle          VARBINARY(64),
    @StmtStart          INT,
    @StmtEnd            INT,
    @EventDate          DATETIME,
    @LastExecTimeBuffer INT
)
/**********************************************************************
Function: dbo. fnGetQueryInfoFromQueryStats
Author: Dmitri V. Korotkevitch
Purpose:
Returns Returns query and plan hashes, and optional query plan
from sys.dm_exec_query_stats based on @@spid, sql_handle and
statement start/end offsets
*********************************************************************/
RETURNS TABLE
AS
RETURN (
    SELECT TOP 1 qs.query_plan_hash AS "plan_hash",
                 qs.query_hash,
                 CASE
                     WHEN @collectPlan = 1 THEN
                     (   SELECT qp.query_plan FROM sys.dm_exec_query_plan (qs.plan_handle) AS qp )
                     ELSE NULL
                 END AS "query_plan"
    FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
    WHERE qs.sql_handle = @SqlHandle
          AND qs.statement_start_offset = @StmtStart
          AND qs.statement_end_offset = @StmtEnd
          AND @EventDate BETWEEN qs.creation_time AND DATEADD (SECOND, @LastExecTimeBuffer, qs.last_execution_time)
    ORDER BY qs.last_execution_time DESC
);
GO


CREATE PROCEDURE dbo.SB_BlockedProcessReport_Activation
WITH EXECUTE AS OWNER
/********************************************************************
Proc: dbo.SB_BlockedProcessReport_Activation
Author: Dmitri V. Korotkevitch
Purpose:
Activation stored procedure for Blocked Processes Event Notification
*******************************************************************/
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg              VARBINARY(MAX),
            @ch               UNIQUEIDENTIFIER,
            @MsgType          sysname,
            @Report           XML,
            @EventDate        DATETIME,
            @DBID             SMALLINT,
            @EventType        VARCHAR(128),
            @blockedSPID      INT,
            @blockedXactID    BIGINT,
            @resource         VARCHAR(64),
            @blockingSPID     INT,
            @blockedSqlHandle VARBINARY(64),
            @blockedStmtStart INT,
            @blockedStmtEnd   INT,
            @waitTime         INT,
            @blockedXML       XML,
            @blockingXML      XML,
            @collectPlan      BIT = 1; -- Controls if we collect execution plans
    WHILE 1 = 1
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
            WAITFOR (
                RECEIVE TOP (1) @ch = conversation_handle,
                                @Msg = message_body,
                                @MsgType = message_type_name
                FROM dbo.BlockedProcessNotificationQueue
            ),
            TIMEOUT 10000;
            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK;
                BREAK;
            END;
            IF @MsgType = N'http://schemas.microsoft.com/SQL/Notifications/EventNotification'
            BEGIN
                SELECT @Report = CONVERT (XML, @Msg);
                SELECT @EventDate = @Report.value ('(/EVENT_INSTANCE/StartTime/text())[1]', 'datetime'),
                       @DBID = @Report.value ('(/EVENT_INSTANCE/DatabaseID/text())[1]', 'smallint'),
                       @EventType = @Report.value ('(/EVENT_INSTANCE/EventType/text())[1]', 'varchar(128)');
                IF @EventType = 'BLOCKED_PROCESS_REPORT'
                BEGIN
                    SELECT @Report = @Report.query ('/EVENT_INSTANCE/TextData/*');
                    SELECT @blockedXML = @Report.query ('/blocked-process-report/blocked-process/*');
                    SELECT @resource = @blockedXML.value ('/process[1]/@waitresource', 'varchar(64)'),
                           @blockedXactID = @blockedXML.value ('/process[1]/@xactid', 'bigint'),
                           @waitTime = @blockedXML.value ('/process[1]/@waittime', 'int'),
                           @blockedSPID = @blockedXML.value ('process[1]/@spid', 'smallint'),
                           @blockingSPID = @Report.value (
                                                       '/blocked-process-report[1]/blocking-process[1]/process[1]/@spid',
                                                       'smallint'
                                                   ),
                           @blockedSqlHandle = @blockedXML.value (
                                                               'xs:hexBinary(substring((/process[1]/executionStack[1]/frame[1]/@sqlhandle)[1],3))',
                                                               'varbinary(max)'
                                                           ),
                           @blockedStmtStart = ISNULL (
                                                   @blockedXML.value (
                                                                   '/process[1]/executionStack[1]/frame[1]/@stmtstart',
                                                                   'int'
                                                               ),
                                                   0
                                               ),
                           @blockedStmtEnd = ISNULL (
                                                 @blockedXML.value ('/process[1]/executionStack[1]/frame[1]/@stmtend', 'int'), -1
                                             );
                    UPDATE t
                    SET t.WaitTime = CASE
                                         WHEN t.WaitTime < @waitTime THEN @waitTime
                                         ELSE t.WaitTime
                                     END
                    FROM dbo.BlockedProcessesInfo AS t
                    WHERE t.BlockedSPID = @blockedSPID
                          AND ISNULL (t.BlockedXactId, -1) = ISNULL (@blockedXactID, -1)
                          AND ISNULL (t.Resource, 'aaa') = ISNULL (@resource, 'aaa')
                          AND t.BlockingSPID = @blockingSPID
                          AND t.BlockedSQLHandle = @blockedSqlHandle
                          AND t.BlockedStmtStart = @blockedStmtStart
                          AND t.BlockedStmtEnd = @blockedStmtEnd
                          AND t.EventDate >= DATEADD (MILLISECOND, -@waitTime - 100, @EventDate);
                    IF @@rowcount = 0
                    BEGIN
                        SELECT @blockingXML = @Report.query ('/blocked-process-report/blocking-process/*');
                        ;WITH Source AS
                        (
                            SELECT repData.BlockedLockMode,
                                   repData.BlockedIsolationLevel,
                                   repData.BlockingStmtStart,
                                   repData.BlockingStmtEnd,
                                   repData.BlockedInputBuf,
                                   repData.BlockingStatus,
                                   repData.BlockingTranCount,
                                   BlockedSQLText.SQL AS "BlockedSQL",
                                   COALESCE (blockedERPlan.query_plan, blockedQSPlan.query_plan) AS "BlockedQueryPlan",
                                   COALESCE (blockedERPlan.query_hash, blockedQSPlan.query_hash) AS "BlockedQueryHash",
                                   COALESCE (blockedERPlan.plan_hash, blockedQSPlan.plan_hash) AS "BlockedPlanHash",
                                   BlockingSQLText.SQL AS "BlockingSQL",
                                   repData.BlockingInputBuf,
                                   COALESCE (blockingERPlan.query_plan, blockingQSPlan.query_plan) AS "BlockingQueryPlan"
                            FROM
                            -- Parsing report XML
                            (
                                SELECT @blockedXML.value ('/process[1]/@lockMode', 'varchar(16)') AS "BlockedLockMode",
                                       @blockedXML.value ('/process[1]/@isolationlevel', 'varchar(32)') AS "BlockedIsolationLevel",
                                       ISNULL (
                                           @blockingXML.value ('/process[1]/executionStack[1]/frame[1]/@stmtstart', 'int'), 0
                                       )                AS "BlockingStmtStart",
                                       ISNULL (@blockingXML.value ('/process[1]/executionStack[1]/frame[1]/@stmtend', 'int'), -1)                 AS "BlockingStmtEnd",
                                       @blockedXML.value ('(/process[1]/inputbuf/text())[1]', 'nvarchar(max)') AS "BlockedInputBuf",
                                       @blockingXML.value ('/process[1]/@status', 'varchar(16)') AS "BlockingStatus",
                                       @blockingXML.value ('/process[1]/@trancount', 'smallint') AS "BlockingTranCount",
                                       @blockingXML.value ('(/process[1]/inputbuf/text())[1]', 'nvarchar(max)') AS "BlockingInputBuf",
                                       @blockingXML.value (
                                                        'xs:hexBinary(substring((/process[1]/executionStack[1]/frame[1]/@sqlhandle)[1],3))',
                                                        'varbinary(max)'
                                                    ) AS "BlockingSQLHandle"
                            ) AS repData
                            -- Getting Query Text
                            OUTER APPLY dbo.fnGetSqlText (@blockedSqlHandle, @blockedStmtStart, @blockedStmtEnd) AS BlockedSQLText
                            OUTER APPLY dbo.fnGetSqlText (
                                            repData.BlockingSQLHandle,
                                            repData.BlockingStmtStart,
                                            repData.BlockingStmtEnd
                                        ) AS BlockingSQLText
                            -- Check if statement is still blocked in sys.dm_exec_requests
                            OUTER APPLY dbo.fnGetQueryInfoFromExecRequests (
                                            @collectPlan,
                                            @blockedSPID,
                                            @blockedSqlHandle,
                                            @blockedStmtStart,
                                            @blockedStmtEnd
                                        ) AS blockedERPlan
                            -- if there is no plan handle
                            -- let's try sys.dm_exec_query_stats
                            OUTER APPLY (
                                SELECT plan_hash,
                                       query_hash,
                                       query_plan
                                FROM dbo.fnGetQueryInfoFromQueryStats (
                                         @collectPlan,
                                         @blockedSqlHandle,
                                         @blockedStmtStart,
                                         @blockedStmtEnd,
                                         @EventDate,
                                         60
                                     )
                                WHERE blockedERPlan.DataExists IS NULL
                            ) AS blockedQSPlan
                            OUTER APPLY dbo.fnGetQueryInfoFromExecRequests (
                                            @collectPlan,
                                            @blockingSPID,
                                            repData.BlockingSQLHandle,
                                            repData.BlockingStmtStart,
                                            repData.BlockingStmtEnd
                                        ) AS blockingERPlan
                            -- if there is no plan handle
                            -- let's try sys.dm_exec_query_stats
                            OUTER APPLY (
                                SELECT query_plan
                                FROM dbo.fnGetQueryInfoFromQueryStats (
                                         @collectPlan,
                                         repData.BlockingSQLHandle,
                                         repData.BlockingStmtStart,
                                         repData.BlockingStmtEnd,
                                         @EventDate,
                                         60
                                     )
                                WHERE blockingERPlan.DataExists IS NULL
                            ) AS blockingQSPlan
                        )
                        INSERT INTO dbo.BlockedProcessesInfo (EventDate,
                                                              DatabaseID,
                                                              Resource,
                                                              WaitTime,
                                                              BlockedProcessReport,
                                                              BlockedSPID,
                                                              BlockedXactId,
                                                              BlockedLockMode,
                                                              BlockedIsolationLevel,
                                                              BlockedSQLHandle,
                                                              BlockedStmtStart,
                                                              BlockedStmtEnd,
                                                              BlockedSql,
                                                              BlockedInputBuf,
                                                              BlockedQueryPlan,
                                                              BlockingSPID,
                                                              BlockingStatus,
                                                              BlockingTranCount,
                                                              BlockingSql,
                                                              BlockingInputBuf,
                                                              BlockingQueryPlan,
                                                              BlockedQueryHash,
                                                              BlockedPlanHash)
                        SELECT @EventDate,
                               @DBID,
                               @resource,
                               @waitTime,
                               @Report,
                               @blockedSPID,
                               @blockedXactID,
                               BlockedLockMode,
                               BlockedIsolationLevel,
                               @blockedSqlHandle,
                               @blockedStmtStart,
                               @blockedStmtEnd,
                               BlockedSQL,
                               BlockedInputBuf,
                               BlockedQueryPlan,
                               @blockingSPID,
                               BlockingStatus,
                               BlockingTranCount,
                               BlockingSQL,
                               BlockingInputBuf,
                               BlockingQueryPlan,
                               BlockedQueryHash,
                               BlockedPlanHash
                        FROM Source
                        OPTION (MAXDOP 1);
                    END;
                END; -- @EventType = BLOCKED_PROCESS_REPORT
            END; -- @MsgType = http://schemas.microsoft.com/SQL/Notifications/EventNotification
            ELSE IF @MsgType = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
                END CONVERSATION @ch;
            -- else handle errors here
            COMMIT;
        END TRY
        BEGIN CATCH
            -- capture info about error message here
            IF @@trancount > 0 ROLLBACK;
            DECLARE @Recipient VARCHAR(255)  = 'DBA@mycompany.com',
                    @Subject   NVARCHAR(255) = +@@SERVERNAME + N': SB_BlockedProcessReport_Activation - Error',
                    @Body      NVARCHAR(MAX) = N'LINE: ' + CONVERT (NVARCHAR(16), ERROR_LINE ()) + CHAR (13) + CHAR (10)
                                               + N'ERROR:' + ERROR_MESSAGE ();
            EXEC msdb.dbo.sp_send_dbmail @recipients = @Recipient,
                                         @subject = @Subject,
                                         @body = @Body;
            THROW;
        END CATCH;
    END;
END;