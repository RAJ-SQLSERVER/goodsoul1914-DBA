/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                    Creating Activation Procedures                        */
/****************************************************************************/

USE DBA;
GO

-- @CollectPlan variable in stored procedures controls if stored procedures collect
-- execution plans. This may introduce CPU overhead on CPU-bound systems with large
-- amount of blocking. Disable it unless you need this feature

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'SB_BlockedProcessReport_Activation'
)
    DROP PROC dbo.SB_BlockedProcessReport_Activation;
IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'SB_DeadlockEvent_Activation'
)
    DROP PROC dbo.SB_DeadlockEvent_Activation;
IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'BMFrameworkErrorNotification'
)
    DROP PROC dbo.BMFrameworkErrorNotification;
IF (OBJECT_ID (N'dbo.fnGetSqlText', 'IF') IS NOT NULL)
    DROP FUNCTION dbo.fnGetSqlText;
IF (OBJECT_ID (N'dbo.fnGetQueryInfoFromExecRequests', 'IF') IS NOT NULL)
    DROP FUNCTION dbo.fnGetQueryInfoFromExecRequests;
IF (OBJECT_ID (N'dbo.fnGetQueryInfoFromQueryStats', 'IF') IS NOT NULL)
    DROP FUNCTION dbo.fnGetQueryInfoFromQueryStats;
GO

CREATE FUNCTION dbo.fnGetSqlText (@SqlHandle VARBINARY(64), @StmtStart INT, @StmtEnd INT)
RETURNS TABLE
/****************************************************************************/
/* Function: dbo.fnGetSqlText                                               */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Returns sql text based on sql_handle and statement start/end offsets  */
/*    Includes several safeguards to avoid exceptions                       */
/*                                                                          */
/* Return Values                                                            */
/*    1-column table with SQL text                                          */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
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
        -- In some rare cases, SQL Server may return empty sql text
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
/****************************************************************************/
/* Function: dbo.fnGetQueryInfoFromExecRequests                             */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Returns query and plan hashes, and optional query plan when           */
/*    @collectPlan = 1 from sys.dm_exec_requests based on @@spid,           */
/*    sql_handle and statement start/end offsets                            */
/*                                                                          */
/* Return Values                                                            */
/*    1-row table	                                                        */
/*       DataExists = 1 when session is found in sys.dm_exec_requests       */
/*       query_hash, plan_hash, query_plan                                  */
/*                                                                          */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
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
/****************************************************************************/
/* Function: dbo.fnGetQueryInfoFromQueryStats                               */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Returns query and plan hashes, and optional query plan when           */
/*    @collectPlan = 1 from sys.dm_exec_query_stats based on @@spid,        */
/*    sql_handle and statement start/end offsets. Checks that @EventDate is */
/*    in between created_date and last_executed_time values.                */
/*    @LastExecTimeBuffer allows to add seconds to last_executed_time       */
/*                                                                          */
/* Return Values                                                            */
/*    1-row table	                                                        */
/*       query_hash, plan_hash, query_plan                                  */
/*                                                                          */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
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

CREATE PROCEDURE dbo.BMFrameworkErrorNotification (@Module      sysname, -- The name of the module where error occured
                                                   @IsPoisonMsg BIT,     -- Indicates if message is potentially poison
                                                   @ErrorMsg    NVARCHAR(512),
                                                   @ErrorLine   INT,
                                                   @Report      NVARCHAR(MAX) = NULL
)
WITH EXECUTE AS OWNER
/****************************************************************************/
/* Proc: dbo.SBMFrameworkErrorNotification                                 */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Send error notification in case if blocked process report or deadlock */
/*    graph cannot be processed                                             */
/*                                                                          */
/* This SP can be customized for particular installations. It will not be   */
/* changed in upgrade scripts in the future versionbs                       */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    /*
	declare
		@Recipient VARCHAR(255) = '<Recipients>',
		@Subject NVARCHAR(255) = @@SERVERNAME + ': ' + @Module + ' - Error',
		@Body NVARCHAR(MAX) = 'LINE: ' + convert(nvarchar(16), @ErrorLine) + char(13) + char(10) + 
			'ERROR:' + @ErrorMsg + char(13) + char(10) + 'Report:' + char(13) + char(10) +
			isnull(@Report,'<NULL>');
	
	if @IsPoisonMsg = 1
		@Subject = '(POISON MESSAGE): ' + @Subject;

	exec msdb.dbo.sp_send_dbmail
		@recipients = @Recipient, 
		@subject = @Subject, 
		@body = @Body;	
	*/
    RETURN;
END;
GO

CREATE PROCEDURE dbo.SB_BlockedProcessReport_Activation
WITH EXECUTE AS OWNER
/****************************************************************************/
/* Proc: dbo.SB_DeadlockEvent_Activation                                    */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Activation stored procedure for Blocked Processes Event Notification  */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Msg              VARBINARY(MAX),
            @serviceID        INT,
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

    DECLARE @Module      sysname = OBJECT_NAME (@@PROCID),
            @IsPoisonMsg BIT,
            @ErrorMsg    NVARCHAR(256),
            @ErrorLine   INT,
            @ReportMsg   NVARCHAR(MAX);

    IF EXISTS (
        SELECT *
        FROM dbo.BMFrameworkConfig
        WHERE [Key] = 'CollectPlanFromBlockingReport'
              AND Value = '0'
    )
        SET @collectPlan = 0;

    WHILE 1 = 1
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
            WAITFOR (
                RECEIVE TOP (1) @serviceID = service_id,
                                @ch = conversation_handle,
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



            IF NOT EXISTS -- Checking if it is the poison message
            (
                SELECT *
                FROM dbo.PoisonMessages
                WHERE ServiceID = @serviceID
                      AND ConversationHandle = @ch
                      AND MsgTypeName = @MsgType
                      AND ((@Msg IS NULL AND Msg IS NULL) OR (Msg = @Msg))
            )
            BEGIN
                IF @MsgType = N'http://schemas.microsoft.com/SQL/Notifications/EventNotification'
                BEGIN
                    SELECT @Report = CONVERT (XML, @Msg);

                    SELECT @EventDate = @Report.value ('(/EVENT_INSTANCE/StartTime/text())[1]', 'datetime'),
                           @DBID = @Report.value ('(/EVENT_INSTANCE/DatabaseID/text())[1]', 'smallint'),
                           @EventType = @Report.value ('(/EVENT_INSTANCE/EventType/text())[1]', 'varchar(128)');

                    IF @EventType = 'BLOCKED_PROCESS_REPORT'
                    BEGIN
                        BEGIN TRY
                            SELECT @Report = @Report.query ('/EVENT_INSTANCE/TextData/*');

                            SELECT @blockedXML = @Report.query ('/blocked-process-report/blocked-process/*');

                            -- Merge is not the best option due to overhead of parsing execution plans for long blocking scenarios
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
                                                         @blockedXML.value (
                                                                         '/process[1]/executionStack[1]/frame[1]/@stmtend',
                                                                         'int'
                                                                     ),
                                                         -1
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
                                                   @blockingXML.value (
                                                                    '/process[1]/executionStack[1]/frame[1]/@stmtstart',
                                                                    'int'
                                                                ),
                                                   0
                                               ) AS "BlockingStmtStart",
                                               ISNULL (
                                                   @blockingXML.value (
                                                                    '/process[1]/executionStack[1]/frame[1]/@stmtend',
                                                                    'int'
                                                                ),
                                                   -1
                                               ) AS "BlockingStmtEnd",
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
                                    -- if there is no plan handle let's try sys.dm_exec_query_stats
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
                                    -- if there is no plan handle let's try sys.dm_exec_query_stats
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
                        END TRY
                        BEGIN CATCH
                            SELECT @ErrorMsg = ERROR_MESSAGE (),
                                   @ErrorLine = ERROR_LINE (),
                                   @ReportMsg = CONVERT (NVARCHAR(MAX), @Report);

                            IF XACT_STATE () = -1 -- uncommittable transaction
                            BEGIN
                                SET @IsPoisonMsg = 1;
                                ROLLBACK;

                                INSERT INTO dbo.PoisonMessages (ServiceID,
                                                                ConversationHandle,
                                                                MsgTypeName,
                                                                Msg,
                                                                ErrorLine,
                                                                ErrorMsg)
                                VALUES (@serviceID, @ch, @MsgType, @Msg, @ErrorLine, @ErrorMsg);
                            END;
                            ELSE
                            BEGIN
                                SET @IsPoisonMsg = 0;
                                INSERT INTO dbo.BlockedProcessesInfo (EventDate, BlockedProcessReport)
                                VALUES (@EventDate, @Report);
                            END;

                            EXEC dbo.BMFrameworkErrorNotification @Module = @Module,
                                                                  @IsPoisonMsg = @IsPoisonMsg,
                                                                  @ErrorMsg = @ErrorMsg,
                                                                  @ErrorLine = @ErrorLine,
                                                                  @Report = @ReportMsg;
                        END CATCH;
                    END; -- @EventType = BLOCKED_PROCESS_REPORT
                END; -- @MsgType = http://schemas.microsoft.com/SQL/Notifications/EventNotification
                ELSE IF @MsgType = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
                    END CONVERSATION @ch;
            -- else handle errors here			
            END;
            WHILE @@TRANCOUNT > 0
            COMMIT;
        END TRY
        BEGIN CATCH
            -- capture info about error message here      
            IF @@trancount > 0 ROLLBACK;

            SELECT @ErrorMsg = ERROR_MESSAGE (),
                   @ErrorLine = ERROR_LINE (),
                   @ReportMsg = N'Outer catch block';

            EXEC dbo.BMFrameworkErrorNotification @Module = @Module,
                                                  @IsPoisonMsg = 1,
                                                  @ErrorMsg = @ErrorMsg,
                                                  @ErrorLine = @ErrorLine,
                                                  @Report = @ReportMsg;

            -- Using raiserror instead of throw for SS2008 compatibility;
            RAISERROR (@ErrorMsg, 16, 1);
            BREAK;
        END CATCH;
    END;
END;
GO

CREATE PROCEDURE dbo.SB_DeadlockEvent_Activation
WITH EXECUTE AS OWNER
/****************************************************************************/
/* Proc: dbo.SB_DeadlockEvent_Activation                                    */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Activation stored procedure for Deadlock Event Notification           */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Msg         VARBINARY(MAX),
            @serviceID   INT,
            @ch          UNIQUEIDENTIFIER,
            @MsgType     sysname,
            @Report      XML,
            @EventDate   DATETIME,
            @DeadlockID  INT,
            @EventType   VARCHAR(128),
            @collectPlan BIT = 1; -- Controls if we collect execution plans

    DECLARE @Module      sysname = OBJECT_NAME (@@PROCID),
            @ErrorMsg    NVARCHAR(256),
            @ErrorLine   INT,
            @ReportMsg   NVARCHAR(MAX),
            @IsPoisonMsg BIT;

    IF EXISTS (
        SELECT *
        FROM dbo.BMFrameworkConfig
        WHERE [Key] = 'CollectPlanFromDeadlockGraph'
              AND Value = '0'
    )
        SET @collectPlan = 0;

    DECLARE @Victims TABLE (Victim sysname NOT NULL PRIMARY KEY);

    WHILE 1 = 1
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
            -- for simplicity sake we are processing data in one-by-one facion      
            -- rather than load everything to the temporary
            -- table variable
            WAITFOR (
                RECEIVE TOP (1) @serviceID = service_id,
                                @ch = conversation_handle,
                                @Msg = message_body,
                                @MsgType = message_type_name
                FROM dbo.DeadlockNotificationQueue
            ),
            TIMEOUT 10000;

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK;
                BREAK;
            END;

            IF NOT EXISTS -- Checking if it is the poison message
            (
                SELECT *
                FROM dbo.PoisonMessages
                WHERE ServiceID = @serviceID
                      AND ConversationHandle = @ch
                      AND MsgTypeName = @MsgType
                      AND ((@Msg IS NULL AND Msg IS NULL) OR (Msg = @Msg))
            )
            BEGIN
                IF @MsgType = N'http://schemas.microsoft.com/SQL/Notifications/EventNotification'
                BEGIN
                    SELECT @Report = CONVERT (XML, @Msg);

                    SELECT @EventDate = @Report.value ('(/EVENT_INSTANCE/PostTime/text())[1]', 'datetime'),
                           @EventType = @Report.value ('(/EVENT_INSTANCE/EventType/text())[1]', 'varchar(128)');

                    IF @EventType = 'DEADLOCK_GRAPH'
                    BEGIN
                        SET @Report = @Report.query ('/EVENT_INSTANCE/TextData/*');

                        BEGIN TRY
                            INSERT INTO dbo.Deadlocks (EventDate, DeadlockGraph)
                            VALUES (@EventDate, @Report);
                            SET @DeadlockID = SCOPE_IDENTITY ();

                            -- In majority of cases, we will have single-victim deadlock. However, we need to support
                            -- the cases when we may have multiple victims
                            DELETE FROM @Victims;

                            ;WITH Victim (victim) AS (SELECT @Report.value (
                                                                     '/deadlock-list[1]/deadlock[1]/@victim', 'sysname'
                                                                     )
                                                     )
                            INSERT INTO @Victims (Victim)
                            SELECT victim
                            FROM Victim
                            WHERE Victim IS NOT NULL;

                            IF @@rowcount = 0 -- Multiple victims
                                INSERT INTO @Victims (Victim)
                                SELECT DISTINCT v.p.value ('@id', 'sysname')
                                FROM @Report.nodes('/deadlock-list[1]/deadlock[1]/victim-list[1]/victimProcess') AS v(p);

                                ;WITH ProcessInfo (Process, SPID, DatabaseID, Resource, LockMode, WaitTime, TranCount,
                                                   IsolationLevel, ProcName, Line, SQLHandle, StmtStart, StmtEnd,
                                                   InputBuf, SQLFromFrame
                                ) AS
                                (
                                    SELECT d.p.value ('./@id', 'sysname'),
                                           d.p.value ('./@spid', 'smallint'),
                                           d.p.value ('./@currentdb', 'smallint'),
                                           d.p.value ('./@waitresource', 'varchar(64)'),
                                           d.p.value ('./@lockMode', 'varchar(16)'),
                                           d.p.value ('./@waittime', 'int'),
                                           d.p.value ('./@trancount', 'smallint'),
                                           d.p.value ('./@isolationlevel', 'varchar(32)'),
                                           d.p.value ('./executionStack[1]/frame[1]/@procname', 'sysname'),
                                           d.p.value ('./executionStack[1]/frame[1]/@line', 'int'),
                                           d.p.value (
                                               'xs:hexBinary(substring((./executionStack[1]/frame[1]/@sqlhandle)[1],3))',
                                               'varbinary(max)'
                                           ),
                                           ISNULL (d.p.value ('./executionStack[1]/frame[1]/@stmtstart', 'int'), 0),
                                           ISNULL (d.p.value ('./executionStack[1]/frame[1]/@stmtend', 'int'), -1),
                                           d.p.value ('(./inputbuf/text())[1]', 'nvarchar(max)'),
                                           d.p.value ('(./executionStack[1]/frame[1]/text())[1]', 'nvarchar(max)')
                                    FROM @Report.nodes('/deadlock-list[1]/deadlock[1]/process-list[1]/process') AS d(p)
                                )
                            INSERT INTO dbo.DeadlockProcesses (EventDate,
                                                               DeadlockID,
                                                               Process,
                                                               IsVictim,
                                                               SPID,
                                                               DatabaseID,
                                                               Resource,
                                                               LockMode,
                                                               WaitTime,
                                                               TranCount,
                                                               IsolationLevel,
                                                               ProcName,
                                                               Line,
                                                               SQLHandle,
                                                               QueryHash,
                                                               PlanHash,
                                                               StmtStart,
                                                               StmtEnd,
                                                               Sql,
                                                               InputBuf,
                                                               QueryPlan)
                            SELECT @EventDate,
                                   @DeadlockID,
                                   p.Process,
                                   vic.IsVictim,
                                   p.SPID,
                                   p.DatabaseID,
                                   p.Resource,
                                   p.LockMode,
                                   p.WaitTime,
                                   p.TranCount,
                                   p.IsolationLevel,
                                   p.ProcName,
                                   p.Line,
                                   p.SQLHandle,
                                   QP.query_hash,
                                   QP.plan_hash,
                                   p.StmtStart,
                                   p.StmtEnd,
                                   SQLText.SQL,
                                   p.InputBuf,
                                   QP.query_plan
                            FROM ProcessInfo AS p
                            CROSS APPLY (
                                SELECT CASE
                                           WHEN EXISTS (SELECT * FROM @Victims AS v WHERE v.Victim = p.Process) THEN 1
                                           ELSE 0
                                       END AS "IsVictim"
                            ) AS vic
                            CROSS APPLY (
                                SELECT CASE
                                           WHEN (ISNULL (LTRIM (RTRIM (p.SQLFromFrame)), '') <> '')
                                                OR ISNULL (p.SQLHandle, 0x) = 0x THEN LTRIM (RTRIM (p.SQLFromFrame))
                                           ELSE
                                       (SELECT SQL FROM dbo.fnGetSqlText (p.SQLHandle, p.StmtStart, p.StmtEnd) )
                                       END AS "SQL"
                            ) AS SQLText
                            OUTER APPLY dbo.fnGetQueryInfoFromQueryStats (
                                            @collectPlan, p.SQLHandle, p.StmtStart, p.StmtEnd, @EventDate, 60
                                        ) AS QP;
                        END TRY
                        BEGIN CATCH
                            SELECT @ErrorMsg = ERROR_MESSAGE (),
                                   @ErrorLine = ERROR_LINE (),
                                   @ReportMsg = CONVERT (NVARCHAR(MAX), @Report);

                            IF XACT_STATE () = -1 -- uncommittable transaction
                            BEGIN
                                SET @IsPoisonMsg = 1;
                                ROLLBACK;

                                INSERT INTO dbo.PoisonMessages (ServiceID,
                                                                ConversationHandle,
                                                                MsgTypeName,
                                                                Msg,
                                                                ErrorLine,
                                                                ErrorMsg)
                                VALUES (@serviceID, @ch, @MsgType, @Msg, @ErrorLine, @ErrorMsg);
                            END;
                            ELSE SET @IsPoisonMsg = 0;



                            EXEC dbo.BMFrameworkErrorNotification @Module = @Module,
                                                                  @IsPoisonMsg = @IsPoisonMsg,
                                                                  @ErrorMsg = @ErrorMsg,
                                                                  @ErrorLine = @ErrorLine,
                                                                  @Report = @ReportMsg;
                        END CATCH;
                    END; -- @EventType = DEADLOCK_GRAPH
                END; -- @MsgType = http://schemas.microsoft.com/SQL/Notifications/EventNotification
                ELSE IF @MsgType = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
                    END CONVERSATION @ch;
            END;
            WHILE @@TranCount > 0
            COMMIT;
        END TRY
        BEGIN CATCH
            -- capture info about error message here      
            IF @@trancount > 0 ROLLBACK;

            SELECT @ErrorMsg = ERROR_MESSAGE (),
                   @ErrorLine = ERROR_LINE (),
                   @ReportMsg = N'Outer catch block';

            EXEC dbo.BMFrameworkErrorNotification @Module = @Module,
                                                  @IsPoisonMsg = 1,
                                                  @ErrorMsg = @ErrorMsg,
                                                  @ErrorLine = @ErrorLine,
                                                  @Report = @ReportMsg;
            -- Using raiserror instead of throw for SS2008 compatibility;
            RAISERROR (@ErrorMsg, 16, 1);
            BREAK;
        END CATCH;
    END;
END;
GO
