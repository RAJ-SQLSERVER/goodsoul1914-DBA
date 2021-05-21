IF OBJECT_ID('dbo.ArchivingActivityLog') IS NULL
BEGIN
    CREATE TABLE dbo.ArchivingActivityLog
    (
        Id INT NOT NULL IDENTITY(1, 1),
        SourceTable sysname NOT NULL,
        Command NVARCHAR(MAX) NULL,
        StartTime DATETIME NOT NULL
            CONSTRAINT DF_ArchivingActivityLog_StartTime
                DEFAULT (GETDATE()),
        EndTime DATETIME NULL,
        RowsMoved INT NULL,
        Success BIT NULL,
        ErrorMsg NVARCHAR(MAX) NULL,
        CONSTRAINT PK_ArchivingActivityLog
            PRIMARY KEY CLUSTERED (
                                      StartTime ASC,
                                      Id ASC
                                  )
    );
END;
GO

IF OBJECT_ID('dbo.usp_MoveHistoricalDataForTable', 'P') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_MoveHistoricalDataForTable AS RETURN 0;');
GO

/*
==============================================
Move Table to Archive
==============================================
Author: Eitan Blumin | Madeira Data Solutions
Create Date: 2020-07-30
Description:
	This procedure moves time-based data
	from one table to another, for the purpose
	of saving historical data to archive.

Notes:
	The source and target tables should have the same structure.
	Columns are copied on a name-by-name basis.
	Columns that exist in one table but not in the other, will be ignored.
  Source table must not have enabled DELETE triggers.
  Target table must not have enabled INSERT triggers.
==============================================
Example Execution:
	DECLARE @ThresholdDate DATETIME
	SET @ThresholdDate = DATEADD(dd, -90, CURRENT_TIMESTAMP)

	EXEC dbo.usp_MoveHistoricalDataForTable
		  @SourceTableName = 'dbo.tblForms' 
		, @TargetTableName = 'dbo.tblFormsHistorical'
		, @TimeBasedColumnName = 'Timestamp'
		, @MoveDataOlderThan = @ThresholdDate
		, @ChunkSize = 10000
		, @AdditionalWhereFilter = N'IsCompleted = 1'
		, @Verbose = 1
		, @WhatIf = 1
==============================================
Changes:
	2020-07-30	Eitan Blumin	First version
==============================================
*/
CREATE OR ALTER PROCEDURE dbo.usp_MoveHistoricalDataForTable
    @SourceTableName NVARCHAR(1000),                -- Source table. For example: 'dbo.tblForms'
    @TargetTableName NVARCHAR(1000),                -- Target table. For example: 'dbo.tblFormsHistorical'
    @TimeBasedColumnName sysname = NULL,            -- Time-based column to filter on. For example: 'UpdateTime'
    @MoveDataOlderThan DATETIME,                    -- Threshold date/time. Data older than this will be moved.
    @ChunkSize INT = 1000,                          -- Maximum chunk size per data movement.
    @AdditionalWhereFilter NVARCHAR(MAX) = NULL,    -- Optional additional WHERE filter for the source table. DO NOT prefix this with AND/OR. If you need to correlate with the source table, use the alias "Src".
    @TotalCount INT = 0 OUTPUT,                     -- Output parameter for total number of rows moved
    @DelayBetweenChunks VARCHAR(15) = '00:00:00.5', -- Time expression to use in WAITFOR DELAY between each chunk.
    @SkipLockedRows BIT = 1,                        -- Set to 1 to skip rows currently locked in the source table.
    @Verbose BIT = 0,                               -- Set to 1 to enable informational messages.
    @WhatIf BIT = 0                                 -- Set to 1 to only print the generated scripts instead of actually running them.
AS
BEGIN
    SET NOCOUNT, ARITHABORT, XACT_ABORT ON;

    -- Variable initialization
    DECLARE @SourceTableObjId INT,
            @TargetTableObjId INT,
            @IdentityInsert   BIT;
    DECLARE @ActivityLogId     INT,
            @Command           NVARCHAR(MAX),
            @Params            NVARCHAR(MAX),
            @ColumnsList       NVARCHAR(MAX),
            @OutputColumnsList NVARCHAR(MAX);

    DECLARE @SharedColumns AS TABLE
    (
        ColumnName sysname NOT NULL PRIMARY KEY
                                    WITH (IGNORE_DUP_KEY = ON),
        IsIdentity BIT NOT NULL
            DEFAULT 0
    );

    -- Verbose logging
    IF @Verbose = 1
        PRINT CONCAT(
                        N'
==============================================
Parameters:
==============================================',
                        CHAR(13) + CHAR(10),
                        N'@SourceTableName: ',
                        ISNULL(@SourceTableName, N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@TargetTableName: ',
                        ISNULL(@TargetTableName, N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@TimeBasedColumnName: ',
                        ISNULL(@TimeBasedColumnName, N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@MoveDataOlderThan: ',
                        ISNULL(CONVERT(NVARCHAR(25), @MoveDataOlderThan, 121), N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@ChunkSize: ',
                        ISNULL(CONVERT(NVARCHAR(100), @ChunkSize), N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@AdditionalWhereFilter: ',
                        ISNULL(@AdditionalWhereFilter, N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@DelayBetweenChunks: ',
                        ISNULL(@DelayBetweenChunks, N'(null)'),
                        CHAR(13) + CHAR(10),
                        N'@SkipLockedRows: ',
                        ISNULL(@SkipLockedRows, 0),
                        CHAR(13) + CHAR(10),
                        N'@WhatIf: ',
                        ISNULL(@WhatIf, 1),
                        N'
=============================================='
                    );

    -- Source and target table validations
    SELECT @SourceTableObjId = OBJECT_ID(@SourceTableName),
           @TargetTableObjId = OBJECT_ID(@TargetTableName);

    IF @SourceTableObjId IS NULL
    BEGIN
        RAISERROR(N'Source table "%s" was not found.', 16, 1, @SourceTableName);
        GOTO Quit;
    END;
    IF @TargetTableObjId IS NULL
    BEGIN
        RAISERROR(N'Target table "%s" was not found.', 16, 1, @TargetTableName);
        GOTO Quit;
    END;
    IF @SourceTableObjId = @TargetTableObjId
    BEGIN
        RAISERROR(N'Source table and target table cannot be the same table.', 16, 1);
        GOTO Quit;
    END;

    -- Standardize table names
    SELECT @SourceTableName
        = QUOTENAME(OBJECT_SCHEMA_NAME(@SourceTableObjId)) + N'.' + QUOTENAME(OBJECT_NAME(@SourceTableObjId)),
           @TargetTableName
               = QUOTENAME(OBJECT_SCHEMA_NAME(@TargetTableObjId)) + N'.' + QUOTENAME(OBJECT_NAME(@TargetTableObjId));

    -- Validate filters
    IF ISNULL(@AdditionalWhereFilter, N'') NOT LIKE '%@MoveDataOlderThan%'
       AND ISNULL(@TimeBasedColumnName, N'') = N''
    BEGIN
        RAISERROR(
                     N'At least one of the following must be provided: a time-based column name (@TimeBasedColumnName), or a filter on "@MoveDataOlderThan" in @AdditionalWhereFilter',
                     16,
                     1
                 );
        GOTO Quit;
    END;

    -- Get list of columns that exist in both source and target tables.
    -- Also, note which column is an identity in the target table,
    -- Ignore computed columns in the target table.
    INSERT INTO @SharedColumns (ColumnName, IsIdentity)
    SELECT   name,
             MAX(is_identity)
    FROM
             (
                 SELECT name,
                        0 AS "is_identity"
                 FROM   sys.columns
                 WHERE  object_id = @SourceTableObjId
                 UNION ALL
                 SELECT name,
                        is_identity
                 FROM   sys.columns
                 WHERE  object_id = @TargetTableObjId
                        AND is_computed = 0
             ) AS c
    GROUP BY name
    HAVING   COUNT(*) = 2;

    -- If no shared columns found, we cannot proceed
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(N'No shared columns found between "%s" and "%s".', 16, 1, @SourceTableName, @TargetTableName);
        GOTO Quit;
    END;

    -- Validate specified time-based column in the source table
    IF ISNULL(@TimeBasedColumnName, N'') <> N''
       AND NOT EXISTS
    (
        SELECT *
        FROM   sys.columns
        WHERE  system_type_id IN ( 61, 40, 41, 42, 58 )
               AND object_id = @SourceTableObjId
               AND name = @TimeBasedColumnName
    )
    BEGIN
        RAISERROR(
                     N'Time-based column "%s" was not found in source table "%s".',
                     16,
                     1,
                     @TimeBasedColumnName,
                     @SourceTableName
                 );
        GOTO Quit;
    END;

    -- Check whether the time-based column is indexed
    IF ISNULL(@TimeBasedColumnName, N'') <> N''
       AND NOT EXISTS
    (
        SELECT     *
        FROM       sys.index_columns AS ic
        INNER JOIN sys.columns AS c
            ON ic.object_id = c.object_id
               AND ic.column_id = c.column_id
        WHERE      c.object_id = @SourceTableObjId
                   AND c.name = @TimeBasedColumnName
                   AND ic.key_ordinal = 1
                   AND ic.is_included_column = 0
    )
    BEGIN
        RAISERROR(
                     N'WARNING: Column "%s" in source table "%s" is not properly indexed. This may cause significant performance issues during data movement.',
                     1,
                     1,
                     @TimeBasedColumnName,
                     @SourceTableName
                 ) WITH NOWAIT;
    END;

    -- If an identity column in the target table also exists in the source table
    IF EXISTS (SELECT * FROM @SharedColumns WHERE IsIdentity = 1)
        SET @IdentityInsert = 1;
    ELSE
        SET @IdentityInsert = 0;

    -- Construct a comma-separated list of the shared columns
    SELECT @ColumnsList = ISNULL(@ColumnsList + N', ', N'') + QUOTENAME(ColumnName),
           @OutputColumnsList = ISNULL(@OutputColumnsList + N', ', N'') + N'deleted.' + QUOTENAME(ColumnName)
    FROM   @SharedColumns;

    IF @Verbose = 1
        RAISERROR(N'Columns List: %s
==============================================', 0, 1, @ColumnsList) WITH NOWAIT;

    -- Construct the data movement command
    SET @Command
        = CASE
              WHEN @IdentityInsert = 1 THEN
                  N'
SET IDENTITY_INSERT ' + @TargetTableName + N' ON;'
              ELSE
                  N''
          END + N'
DECLARE @RCount INT;
SET @RCount = 0;

WHILE 1=1
BEGIN
	DELETE TOP (@ChunkSize) Src
	OUTPUT '       + @OutputColumnsList + N'
	INTO '         + @TargetTableName + N'
	('             + @ColumnsList + N')
	FROM '         + @SourceTableName + N' AS Src' + CASE
                                                         WHEN @SkipLockedRows = 1 THEN
                                                             N' WITH(READPAST)'
                                                         ELSE
                                                             N''
                                                     END + N'
	WHERE '        + ISNULL(QUOTENAME(NULLIF(@TimeBasedColumnName, N'')) + N' < @MoveDataOlderThan', N'') + N'
	'              + CASE
                         WHEN NULLIF(@TimeBasedColumnName, N'') IS NOT NULL
                              AND NULLIF(@AdditionalWhereFilter, N'') IS NOT NULL THEN
                             N'AND '
                         ELSE
                             N''
                     END + ISNULL(@AdditionalWhereFilter, N'')
          + N'
	;
	SET @RCount = @@ROWCOUNT;
	SET @TotalCount = @TotalCount + @RCount;

	IF @RCount < @ChunkSize
		BREAK;
	ELSE IF @DelayBetweenChunks IS NOT NULL
		WAITFOR DELAY @DelayBetweenChunks;
END
'                  + CASE
                         WHEN @IdentityInsert = 1 THEN
                             N'
SET IDENTITY_INSERT ' + @TargetTableName + N' OFF;'
                         ELSE
                             N''
                     END;

    SET @Params
        = N'@TotalCount INT OUTPUT, @ChunkSize INT, @MoveDataOlderThan DATETIME, @DelayBetweenChunks VARCHAR(15)';

    IF ISNULL(@WhatIf, 1) = 1
       OR @Verbose = 1
        RAISERROR(N'------ Generated Command: ---------%s
==============================================', 0, 1, @Command) WITH NOWAIT;

    IF @WhatIf = 0
    BEGIN
        INSERT INTO dbo.ArchivingActivityLog (SourceTable, Command)
        VALUES (@SourceTableName, @Command);

        SET @ActivityLogId = SCOPE_IDENTITY();

        SET @TotalCount = 0;

        BEGIN TRY
            EXEC sp_executesql @Command,
                               @Params,
                               @TotalCount OUTPUT,
                               @ChunkSize,
                               @MoveDataOlderThan,
                               @DelayBetweenChunks;

            UPDATE dbo.ArchivingActivityLog
            SET    EndTime = GETDATE(),
                   RowsMoved = @TotalCount,
                   Success = 1
            WHERE  Id = @ActivityLogId;
        END TRY
        BEGIN CATCH
            DECLARE @ErrMsg NVARCHAR(MAX);
            SET @ErrMsg
                = CONCAT(
                            N'Error ',
                            ERROR_NUMBER(),
                            N' State ',
                            ERROR_STATE(),
                            N' at Line ',
                            ERROR_LINE(),
                            N': ',
                            ERROR_MESSAGE()
                        );

            UPDATE dbo.ArchivingActivityLog
            SET    EndTime = GETDATE(),
                   RowsMoved = @TotalCount,
                   ErrorMsg = @ErrMsg,
                   Success = 0
            WHERE  Id = @ActivityLogId;

            PRINT @ErrMsg;
        END CATCH;
    END;
    Quit:
END;
GO