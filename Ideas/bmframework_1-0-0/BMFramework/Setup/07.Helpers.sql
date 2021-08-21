/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                        Creating Helpers Objects							*/
/****************************************************************************/

USE DBA;
GO

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'PurgeBlockingInfo'
)
    DROP PROC dbo.PurgeBlockingInfo;

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'BMFrameworkPartitionMaintenance'
)
    DROP PROC dbo.BMFrameworkPartitionMaintenance;

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'PurgeDeadlockInfo'
)
    DROP PROC dbo.PurgeDeadlockInfo;

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'PurgePoisonMessages'
)
    DROP PROC dbo.PurgePoisonMessages;

IF EXISTS (
    SELECT *
    FROM sys.procedures AS p
    JOIN sys.schemas AS s
        ON p.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND p.name = 'BMFrameworkQueuesCheck'
)
    DROP PROC dbo.BMFrameworkQueuesCheck;
GO

CREATE PROC dbo.PurgeBlockingInfo (@RetentionDays INT)
/****************************************************************************/
/* Proc: dbo.PurgeBlockingInfo                                              */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Purge blocking information based on retention interval defined by     */
/*    @RetentionDays parameter. This SP is recommended for non-partitioned  */
/*    data storage. Partitioned version should use                          */
/*    dbo.PurgeBMFrameworkDataPartitioned instead                           */
/*                                                                          */
/* Return Codes   :                                                         */
/*    -1: Invalid @RetentionDays value                                      */
/*     0: Data has been purged                                              */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

    IF @RetentionDays <= 0
    BEGIN
        RAISERROR (
            'PurgeBlockingInfo: @RetentionDays parameter should be positive. Current value: %d', 16, 1, @RetentionDays
        );
        RETURN -1;
    END;

    DELETE FROM dbo.BlockedProcessesInfo
    WHERE EventDate < DATEADD (DAY, -@RetentionDays, CONVERT (DATE, GETDATE ()));
    RETURN 0;
END;
GO

CREATE PROC dbo.PurgeDeadlockInfo (@RetentionDays INT)
/****************************************************************************/
/* Proc: dbo.PurgeDeadlockInfo                                              */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Purge deadlock information based on retention interval defined by     */
/*    @RetentionDays parameter. This SP is recommended for non-partitioned  */
/*    data storage. Partitioned version should use                          */
/*    dbo.PurgeBMFrameworkDataPartitioned instead                           */
/*                                                                          */
/* Return Codes   :                                                         */
/*    -1: Invalid @RetentionDays value                                      */
/*     0: Data has been purged                                              */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

    IF @RetentionDays <= 0
    BEGIN
        RAISERROR (
            'PurgeDeadlockInfo: @RetentionDays parameter should be positive. Current value: %d', 16, 1, @RetentionDays
        );
        RETURN -1;
    END;

    BEGIN TRAN;
    DELETE FROM dbo.DeadlockProcesses
    WHERE EventDate < DATEADD (DAY, -@RetentionDays, CONVERT (DATE, GETDATE ()));
    DELETE FROM dbo.Deadlocks
    WHERE EventDate < DATEADD (DAY, -@RetentionDays, CONVERT (DATE, GETDATE ()));;
    COMMIT;
    RETURN 0;
END;
GO

CREATE PROC dbo.PurgePoisonMessages (@RetentionDays INT = 1)
/****************************************************************************/
/* Proc: dbo.PurgePoisonMessages                                            */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Purge poison messages information based on retention interval defined */
/*    by @RetentionDays parameter. This SP is recommended for non-partitioned*/
/*    data storage. Partitioned version should use                          */
/*    dbo.BMFrameworkPartitionMaintenance instead                           */
/*                                                                          */
/* Return Codes   :                                                         */
/*    -1: Invalid @RetentionDays value                                      */
/*     0: Data has been purged                                              */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;

    IF @RetentionDays < 0
    BEGIN
        RAISERROR (
            'PurgePoisonMessages: @RetentionDays parameter should be >= 0. Current value: %d', 16, 1, @RetentionDays
        );
        RETURN -1;
    END;

    IF @RetentionDays = 0 TRUNCATE TABLE dbo.PoisonMessages;
    ELSE
        WHILE 1 = 1
        BEGIN
            ;WITH CTE AS
             (
                 SELECT TOP 1000 ServiceID,
                                 ConversationHandle,
                                 EventDate
                 FROM dbo.PoisonMessages
                 ORDER BY EventDate
             )
            DELETE FROM t
            FROM CTE AS c
            INNER LOOP JOIN dbo.PoisonMessages AS t
                ON c.ServiceID = t.ServiceID
                   AND c.ConversationHandle = t.ConversationHandle
                   AND c.EventDate = t.EventDate
            OPTION (MAXDOP 1);

            IF @@ROWCOUNT < 1000 BREAK;
        END;
    RETURN 0;
END;
GO

CREATE PROC dbo.BMFrameworkPartitionMaintenance (@RetentionWeeks INT = 8)
/****************************************************************************/
/* Proc: dbo.BMFrameworkPartitionMaintenance                                */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Purge blocking and deadlock information based on retention interval   */
/*    defined by @RetentionWeeks parameter. This SP is recommended for      */
/*    partitioned data storage. Ideally, should be setup running as         */
/*    SQL Agent job running on Sundays.                                     */
/*                                                                          */
/* Change Filegroup in ALTER PARTITION SCHEME if you store the data on      */
/* different filegroup than PRIMARY                                         */
/*                                                                          */
/* Return Codes:                                                            */
/*    -2: SP cannot run in the transaction                                  */
/*    -1: Invalid @RetentionDays value                                      */
/*     0: Data has been purged                                              */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON;
    SET DEADLOCK_PRIORITY 10;

    DECLARE @PFName            sysname = 'pfBMFramework',
            @CurrentDate       DATE    = GETDATE (),                                                              -- Current Date
            @PartitionDate     DATE    = DATEADD (WEEK, DATEDIFF (WEEK, '2018-08-03', GETDATE ()), '2018-08-03'), -- find last Sunday
            @PreallocatedWeeks INT     = 2,                                                                       -- How many weeks we want to pre-allocate
            @PurgeDate         DATE,                                                                              -- Last parition value we want to keep
            @MaxSplitDate      DATE,                                                                              -- Date that corresponds to @PreallocatedWeeks
            @BoundaryValue     DATE,
            @Msg               NVARCHAR(256);

    IF @RetentionWeeks <= 0
    BEGIN
        RAISERROR (
            'PurgeBMFrameworkDataPartitioned: @@RetentionWeeks parameter should be positive. Current value: %d',
            16,
            1,
            @RetentionWeeks
        );
        RETURN -1;
    END;

    IF @@TRANCOUNT > 0
    BEGIN
        RAISERROR ('dbo.PurgeBMFrameworkDataPartitioned procedure cannot run within a transaction', 16, 1);
        RETURN -2;
    END;

    SELECT @PurgeDate = DATEADD (WEEK, -1 * @RetentionWeeks, @PartitionDate),
           @MaxSplitDate = DATEADD (WEEK, @PreallocatedWeeks + 1, @PartitionDate);

    -- First, we will create new partitions
    SELECT @BoundaryValue = CONVERT (DATE, MAX (r.value))
    FROM sys.partition_functions AS pf
    INNER JOIN sys.partition_range_values AS r
        ON pf.function_id = r.function_id
    WHERE pf.name = @PFName;

    IF @BoundaryValue < @CurrentDate SET @BoundaryValue = @PartitionDate;

    SET @Msg = N'@MaxSplitDate: ' + CONVERT (VARCHAR(10), @MaxSplitDate, 121) + N'; @BoundaryValue: '
               + CONVERT (VARCHAR(10), @BoundaryValue, 121);
    RAISERROR ('%s', 0, 1, @Msg) WITH NOWAIT;

    WHILE @BoundaryValue < @MaxSplitDate
    BEGIN
        SET @BoundaryValue = DATEADD (WEEK, 1, @BoundaryValue);

        SET @Msg = N'Creating the new partition with value: ' + CONVERT (VARCHAR(10), @BoundaryValue, 121);
        RAISERROR ('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRAN;
        ALTER PARTITION SCHEME psBMFramework
        NEXT USED [PRIMARY];
        ALTER PARTITION FUNCTION pfBMFramework () SPLIT RANGE (@BoundaryValue);
        COMMIT;
    END;

    -- Next, we will purge
    SET @Msg = N'Starting purge. @PurgeDate: ' + CONVERT (VARCHAR(10), @PurgeDate, 121);
    RAISERROR ('%s', 0, 1, @Msg) WITH NOWAIT;

    SELECT @BoundaryValue = CONVERT (DATE, MIN (r.value))
    FROM sys.partition_functions AS pf
    INNER JOIN sys.partition_range_values AS r
        ON pf.function_id = r.function_id
    WHERE pf.name = @PFName;

    WHILE 1 = 1
    BEGIN
        SET @BoundaryValue = NULL;

        SELECT @BoundaryValue = CONVERT (DATE, MIN (r.value))
        FROM sys.partition_functions AS pf
        INNER JOIN sys.partition_range_values AS r
            ON pf.function_id = r.function_id
        WHERE pf.name = @PFName
              AND CONVERT (DATE, r.value) <= @PurgeDate;

        IF @BoundaryValue IS NULL BREAK;

        TRUNCATE TABLE dbo.BlockedProcessesInfoTmp;
        TRUNCATE TABLE dbo.DeadlocksTmp;
        TRUNCATE TABLE dbo.DeadlockProcessesTmp;
        TRUNCATE TABLE dbo.PoisonMessagesTmp;

        SET @Msg = N'Truncating partition: ' + CONVERT (VARCHAR(10), @BoundaryValue, 121);
        RAISERROR ('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRAN;
        ALTER TABLE dbo.BlockedProcessesInfo SWITCH PARTITION 1 TO dbo.BlockedProcessesInfoTmp;
        ALTER TABLE dbo.Deadlocks SWITCH PARTITION 1 TO dbo.DeadlocksTmp;
        ALTER TABLE dbo.DeadlockProcesses SWITCH PARTITION 1 TO dbo.DeadlockProcessesTmp;
        ALTER TABLE dbo.PoisonMessages SWITCH PARTITION 1 TO dbo.PoisonMessagesTmp;

        ALTER PARTITION FUNCTION pfBMFramework () MERGE RANGE (@BoundaryValue);
        COMMIT;

        TRUNCATE TABLE dbo.BlockedProcessesInfoTmp;
        TRUNCATE TABLE dbo.DeadlocksTmp;
        TRUNCATE TABLE dbo.DeadlockProcessesTmp;
    END;
    RAISERROR ('Purge successfully completed', 0, 1) WITH NOWAIT;

    RETURN 0;
END;
GO

CREATE PROC dbo.BMFrameworkQueuesCheck
/****************************************************************************/
/* Proc: dbo.BMFrameworkQueuesCheck                                         */
/* Author: Dmitri V. Korotkevitch                                           */
/*                                                                          */
/* Purpose:                                                                 */
/*    Checkign that SB Queues are enabled. Can be run as SQL Agent Job      */
/*                                                                          */
/* Version History:                                                         */
/*     v1.0 2018-08-01. Initial implementation                              */
/****************************************************************************/
AS
BEGIN
    SET NOCOUNT ON;

    IF (
        SELECT COUNT (*)
        FROM sys.service_queues
        WHERE name IN ( 'BlockedProcessNotificationQueue', 'DeadlockNotificationQueue' )
              AND is_receive_enabled = 1
    ) < 2
    BEGIN
        DECLARE @MailStatus INT,
                @Recipient  VARCHAR(255)  = '<recipients>',
                @Subject    NVARCHAR(255) = N'Blocking Monitoring Service Queues - Disabled',
                @Body       NVARCHAR(255) = N'Blocking Monitoring Service Queues are not enabled on ' + @@SERVERNAME;

        EXEC @MailStatus = msdb.dbo.sp_send_dbmail @recipients = @Recipient,
                                                   @subject = @Subject,
                                                   @body = @Body;

        IF @MailStatus <> 0 RAISERROR ('Unable to Send DB Mail', 16, 1);
    END;
END;
GO
