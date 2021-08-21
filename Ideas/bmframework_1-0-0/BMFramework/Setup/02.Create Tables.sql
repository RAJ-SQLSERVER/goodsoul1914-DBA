/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                           Creating the Tables                            */
/****************************************************************************/

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'CheckVersion'
)
    DROP PROC dbo.CheckVersion;

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'SetVersion'
)
    DROP PROC dbo.SetVersion;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'Versions'
)
    DROP TABLE dbo.Versions;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'BMFrameworkConfig'
)
    DROP TABLE dbo.BMFrameworkConfig;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'BlockedProcessesInfo'
)
    DROP TABLE dbo.BlockedProcessesInfo;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'Deadlocks'
)
    DROP TABLE dbo.Deadlocks;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'DeadlockProcesses'
)
    DROP TABLE dbo.DeadlockProcesses;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'BlockedProcessesInfoTmp'
)
    DROP TABLE dbo.BlockedProcessesInfoTmp;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'DeadlocksTmp'
)
    DROP TABLE dbo.DeadlocksTmp;
IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'DeadlockProcessesTmp'
)
    DROP TABLE dbo.DeadlockProcessesTmp;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'PoisonMessages'
)
    DROP TABLE dbo.PoisonMessages;

IF EXISTS (
    SELECT *
    FROM sys.tables AS t
    JOIN sys.schemas AS s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND t.name = 'PoisonMessagesTmp'
)
    DROP TABLE dbo.PoisonMessagesTmp;
GO

CREATE TABLE dbo.Versions (
    Product         sysname     NOT NULL,
    Version         VARCHAR(32) NOT NULL,
    CreatedDate     DATETIME    NOT NULL
        CONSTRAINT DEF_Versions_CreatedDate
            DEFAULT GETDATE (),
    LastAppliedDate DATETIME    NOT NULL
        CONSTRAINT DEF_Versions_LastAppliedDate
            DEFAULT GETDATE (),
    CONSTRAINT PK_Versions
        PRIMARY KEY CLUSTERED (Product)
);
GO

CREATE PROC dbo.CheckVersion (@Product sysname, @Version VARCHAR(32))
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @CurrVersion VARCHAR(32) = 'NULL';

    SELECT @CurrVersion = ISNULL (Version, 'NULL')
    FROM dbo.Versions
    WHERE Product = @Product;

    IF @CurrVersion <> @Version
    BEGIN
        RAISERROR ('Incorrent %s version. Expected: %s. Actual: %s', 20, 1, @Product, @Version, @CurrVersion) WITH LOG;
        RETURN -1;
    END;
    RAISERROR ('Product %s version has been validated. Current version: %s', 0, 1, @Product, @CurrVersion) WITH NOWAIT;
    RETURN 0;
END;
GO

CREATE PROC dbo.SetVersion (@Product sysname, @Version VARCHAR(32))
AS
BEGIN
    MERGE INTO dbo.Versions AS T
    USING (SELECT @Product AS "Product", @Version AS "Version") AS S
    ON T.Product = S.Product
    WHEN NOT MATCHED BY TARGET THEN INSERT (Product, Version)
                                    VALUES (S.Product, S.Version)
    WHEN MATCHED THEN UPDATE SET LastAppliedDate = GETDATE ();
END;
GO

CREATE TABLE dbo.BMFrameworkConfig (
    [Key] VARCHAR(64)  NOT NULL,
    Value VARCHAR(256) NOT NULL,
    CONSTRAINT PK_BMFrameworkConfig
        PRIMARY KEY CLUSTERED ([Key])
);
GO

INSERT INTO dbo.BMFrameworkConfig ([Key], Value)
VALUES ('CollectPlanFromBlockingReport', '1');
INSERT INTO dbo.BMFrameworkConfig ([Key], Value)
VALUES ('CollectPlanFromDeadlockGraph', '1');
GO

CREATE TABLE dbo.BlockedProcessesInfo (
    ID                    INT           NOT NULL IDENTITY(1, 1),
    EventDate             DATETIME      NOT NULL,
    -- ID of the database where locking occurs
    DatabaseID            SMALLINT      NULL,
    -- Blocking resource
    Resource              VARCHAR(64)   NULL,
    -- Wait time in MS
    WaitTime              INT           NULL,
    -- Raw blocked process report
    BlockedProcessReport  XML           NULL,
    -- SPID of the blocked process
    BlockedSPID           SMALLINT      NULL,
    -- XACTID of the blocked process
    BlockedXactId         BIGINT        NULL,
    -- Blocked Lock Request Mode
    BlockedLockMode       VARCHAR(16)   NULL,
    -- Transaction isolation level for
    -- blocked session
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

CREATE TABLE dbo.Deadlocks (
    EventDate     DATETIME NOT NULL,
    DeadlockID    INT      NOT NULL IDENTITY(1, 1),
    DeadlockGraph XML      NOT NULL,
);
GO

CREATE TABLE dbo.DeadlockProcesses (
    EventDate      DATETIME      NOT NULL,
    DeadlockID     INT           NOT NULL,
    Process        sysname       NULL,
    IsVictim       BIT           NOT NULL,
    -- SPID of the process
    SPID           SMALLINT      NULL,
    -- ID of the database where deadlock occured
    DatabaseID     SMALLINT      NULL,
    -- Blocking resource
    Resource       VARCHAR(64)   NULL,
    -- Lock Mode
    LockMode       VARCHAR(16)   NULL,
    -- Wait time in MS
    WaitTime       INT           NULL,
    -- Tran Count
    TranCount      SMALLINT      NULL,
    -- Transaction isolation level for the process
    IsolationLevel VARCHAR(32)   NULL,
    -- Top ProcName from execution stack
    ProcName       sysname       NULL,
    -- Top Line from execution stack
    Line           sysname       NULL,
    -- Top SQL Handle from execution stack
    SQLHandle      VARBINARY(64) NULL,
    -- Query Hash
    QueryHash      BINARY(8)     NULL,
    -- Blocked Query Plan Hash
    PlanHash       BINARY(8)     NULL,
    -- SQL Statement Start offset
    StmtStart      INT           NULL,
    -- SQL Statement End offset
    StmtEnd        INT           NULL,
    -- SQL based on frame data and/or SQL Handle
    Sql            NVARCHAR(MAX) NULL,
    -- InputBuf from the report
    InputBuf       NVARCHAR(MAX) NULL,
    -- Query Plan based on SQL Handle
    QueryPlan      XML           NULL,
);
GO

CREATE TABLE dbo.PoisonMessages (
    EventDate          DATETIME         NOT NULL
        CONSTRAINT PK_PoisonMessages_EventDate
            DEFAULT GETDATE (),
    ServiceID          INT              NOT NULL,
    ConversationHandle UNIQUEIDENTIFIER NOT NULL,
    MsgTypeName        sysname          NOT NULL,
    Msg                VARBINARY(MAX)   NULL,
    ErrorLine          INT              NULL,
    ErrorMsg           NVARCHAR(MAX)    NULL
);
GO


ALTER TABLE dbo.BlockedProcessesInfo SET (LOCK_ESCALATION = DISABLE);
ALTER TABLE dbo.Deadlocks SET (LOCK_ESCALATION = DISABLE);
ALTER TABLE dbo.DeadlockProcesses SET (LOCK_ESCALATION = DISABLE);
ALTER TABLE dbo.PoisonMessages SET (LOCK_ESCALATION = DISABLE);
GO

-- Indexing tables. We will partition the tables on weekly basis if it is supported
-- You may change the filegroups if needed

-- You may need to create other indexes for analysis queries depending on how you are planning
-- to analyze and aggregate the data
DECLARE @EngineEdition INT = CONVERT (INT, SERVERPROPERTY ('EngineEdition')), -- 3 means Enterprise
        @EngineVersion INT = CONVERT (
                                 INT,
                                 LEFT(CONVERT (NVARCHAR(128), SERVERPROPERTY ('ProductVersion')), CHARINDEX (
                                                                                                      '.',
                                                                                                      CONVERT (
                                                                                                      NVARCHAR(128),
                                                                                                      SERVERPROPERTY (
                                                                                                      'ProductVersion'
                                                                                                      )
                                                                                                      )
                                                                                                  ) - 1)
                             );

IF (@EngineEdition = 3)
   OR -- Enterprise / Developer
(@EngineVersion > 13)
   OR -- SQL Server 2017+
   (
       @EngineVersion = 13
       AND LEFT(CONVERT (VARCHAR(64), SERVERPROPERTY ('productlevel')), 2) = 'SP'
   ) -- SQL Server 2016 with SP	
BEGIN
    RAISERROR ('Partitioning is supported', 0, 1) WITH NOWAIT;

    IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'psBMFramework')
        DROP PARTITION SCHEME psBMFramework;
    IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'pfBMFramework')
        DROP PARTITION FUNCTION pfBMFramework;

    DECLARE @sql       NVARCHAR(MAX),
            @firstDate DATETIME = DATEADD (WEEK, DATEDIFF (WEEK, '2018-06-03', GETDATE ()), '2018-06-03'); -- find last Sunday

    SET @sql = N'
create partition function pfBMFramework(datetime) 
as range right for values
(''' + CONVERT (NVARCHAR(10), @firstDate, 121) + N''',''' + +CONVERT (NVARCHAR(10), DATEADD (WEEK, 1, @firstDate), 121)
               + N''',''' + +CONVERT (NVARCHAR(10), DATEADD (WEEK, 2, @firstDate), 121)
               + N''');

create partition scheme psBMFramework as partition pfBMFramework all to ([PRIMARY]);

'   ;
    RAISERROR ('Executing: %s', 0, 1, @sql) WITH NOWAIT;
    EXEC sp_executesql @sql;

    CREATE UNIQUE CLUSTERED INDEX IDX_BlockedProcessInfo_EventDate_ID
    ON dbo.BlockedProcessesInfo (EventDate, ID)
    WITH (DATA_COMPRESSION = PAGE)
    ON psBMFramework(EventDate);

    CREATE UNIQUE CLUSTERED INDEX IDX_Deadlocks_EventDate_DeadlockID
    ON dbo.Deadlocks (EventDate, DeadlockID)
    WITH (DATA_COMPRESSION = ROW)
    ON psBMFramework(EventDate);

    CREATE UNIQUE CLUSTERED INDEX IDX_DeadlockProcesses_EventDate_DeadlockID_Process
    ON dbo.DeadlockProcesses (EventDate, DeadlockID, Process)
    WITH (DATA_COMPRESSION = PAGE)
    ON psBMFramework(EventDate);

    CREATE CLUSTERED INDEX IDX_PoisonMessages_ServiceID_ConversationHandle
    ON dbo.PoisonMessages (ServiceID, ConversationHandle, EventDate)
    ON psBMFramework(EventDate);

    -- Creating tables for sliding window purge
    CREATE TABLE dbo.BlockedProcessesInfoTmp (
        ID                    INT           NOT NULL,
        EventDate             DATETIME      NOT NULL,
        DatabaseID            SMALLINT      NULL,
        Resource              VARCHAR(64)   NULL,
        WaitTime              INT           NULL,
        BlockedProcessReport  XML           NULL,
        BlockedSPID           SMALLINT      NULL,
        BlockedXactId         BIGINT        NULL,
        BlockedLockMode       VARCHAR(16)   NULL,
        BlockedIsolationLevel VARCHAR(32)   NULL,
        BlockedSQLHandle      VARBINARY(64) NULL,
        BlockedStmtStart      INT           NULL,
        BlockedStmtEnd        INT           NULL,
        BlockedQueryHash      BINARY(8)     NULL,
        BlockedPlanHash       BINARY(8)     NULL,
        BlockedSql            NVARCHAR(MAX) NULL,
        BlockedInputBuf       NVARCHAR(MAX) NULL,
        BlockedQueryPlan      XML           NULL,
        BlockingSPID          SMALLINT      NULL,
        BlockingStatus        VARCHAR(16)   NULL,
        BlockingTranCount     INT           NULL,
        BlockingInputBuf      NVARCHAR(MAX) NULL,
        BlockingSql           NVARCHAR(MAX) NULL,
        BlockingQueryPlan     XML           NULL
    );

    CREATE TABLE dbo.DeadlocksTmp (
        EventDate     DATETIME NOT NULL,
        DeadlockID    INT      NOT NULL,
        DeadlockGraph XML      NOT NULL,
    );

    CREATE TABLE dbo.DeadlockProcessesTmp (
        EventDate      DATETIME      NOT NULL,
        DeadlockID     INT           NOT NULL,
        Process        sysname       NULL,
        IsVictim       BIT           NOT NULL,
        SPID           SMALLINT      NULL,
        DatabaseID     SMALLINT      NULL,
        Resource       VARCHAR(64)   NULL,
        LockMode       VARCHAR(16)   NULL,
        WaitTime       INT           NULL,
        TranCount      SMALLINT      NULL,
        IsolationLevel VARCHAR(32)   NULL,
        ProcName       sysname       NULL,
        Line           sysname       NULL,
        SQLHandle      VARBINARY(64) NULL,
        QueryHash      BINARY(8)     NULL,
        PlanHash       BINARY(8)     NULL,
        StmtStart      INT           NULL,
        StmtEnd        INT           NULL,
        Sql            NVARCHAR(MAX) NULL,
        InputBuf       NVARCHAR(MAX) NULL,
        QueryPlan      XML           NULL
    );

    CREATE TABLE dbo.PoisonMessagesTmp (
        EventDate          DATETIME         NOT NULL,
        ServiceID          INT              NOT NULL,
        ConversationHandle UNIQUEIDENTIFIER NOT NULL,
        MsgTypeName        sysname          NOT NULL,
        Msg                VARBINARY(MAX)   NULL,
        ErrorLine          INT              NULL,
        ErrorMsg           NVARCHAR(MAX)    NULL
    );

    CREATE UNIQUE CLUSTERED INDEX IDX_BlockedProcessInfo_EventDate_ID
    ON dbo.BlockedProcessesInfoTmp (EventDate, ID)
    WITH (DATA_COMPRESSION = PAGE);

    CREATE UNIQUE CLUSTERED INDEX IDX_Deadlocks_EventDate_DeadlockID
    ON dbo.DeadlocksTmp (EventDate, DeadlockID)
    WITH (DATA_COMPRESSION = ROW);

    CREATE UNIQUE CLUSTERED INDEX IDX_DeadlockProcesses_EventDate_DeadlockID_Process
    ON dbo.DeadlockProcessesTmp (EventDate, DeadlockID, Process)
    WITH (DATA_COMPRESSION = PAGE);

    CREATE CLUSTERED INDEX IDX_PoisonMessages_ServiceID_ConversationHandle
    ON dbo.PoisonMessagesTmp (ServiceID, ConversationHandle, EventDate);

    RAISERROR ('Setup Partition Management Job using SPs from 07.Helpers.sql script', 0, 1) WITH NOWAIT;
END;
ELSE
BEGIN
    RAISERROR ('Partitioning is not supported', 0, 1) WITH NOWAIT;

    CREATE UNIQUE CLUSTERED INDEX IDX_BlockedProcessInfo_EventDate_ID
    ON dbo.BlockedProcessesInfo (EventDate, ID);

    CREATE UNIQUE CLUSTERED INDEX IDX_Deadlocks_EventDate_DeadlockID
    ON dbo.Deadlocks (EventDate, DeadlockID);

    CREATE UNIQUE CLUSTERED INDEX IDX_DeadlockProcesses_EventDate_DeadlockID_Process
    ON dbo.DeadlockProcesses (EventDate, DeadlockID, Process);

    CREATE CLUSTERED INDEX IDX_PoisonMessages_ServiceID_ConversationHandle
    ON dbo.PoisonMessages (ServiceID, ConversationHandle);

    CREATE NONCLUSTERED INDEX IDX_PoisonMessages_EventDate
    ON dbo.PoisonMessages (EventDate);
END;
GO
