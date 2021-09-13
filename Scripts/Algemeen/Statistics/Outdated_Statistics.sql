DECLARE @MinimumTableRows   INT = 200000,
        @MinimumModCountr   INT = 100000,
        @MinimumDaysOld     INT = 35,   -- adjust as needed
        @MaxDOP             INT = NULL, -- set to 1 to reduce server workload
        @SampleRatePercent  INT = NULL, -- set to number between 1 and 100 to force a specific sample rate, where 100 = FULLSCAN
        @ExecuteRemediation BIT = 0;    -- set to 1 to automatically execute UPDATE STATISTICS remediation commands

SET NOCOUNT, ARITHABORT, XACT_ABORT ON;
IF OBJECT_ID ('tempdb..#tmpStats') IS NOT NULL DROP TABLE #tmpStats;
CREATE TABLE #tmpStats (
    DBname     sysname,
    DatabaseId INT,
    ObjectId   INT,
    StatsName  sysname,
    LastUpdate DATETIME,
    ModCntr    BIGINT,
    TotalRows  BIGINT
);

DECLARE @qry     NVARCHAR(MAX),
        @options NVARCHAR(MAX);

IF @MaxDOP IS NOT NULL
    SET @options = ISNULL (@options + N', ', N' WITH ') + N'MAXDOP = ' + CONVERT (NVARCHAR, @MaxDOP);

IF @SampleRatePercent = 100
    SET @options = ISNULL (@options + N', ', N' WITH ') + N'FULLSCAN';
ELSE IF @SampleRatePercent IS NOT NULL
    SET @options = ISNULL (@options + N', ', N' WITH ') + N'SAMPLE ' + CONVERT (NVARCHAR, @SampleRatePercent)
                   + N' PERCENT';

SET @qry = N'
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  
  INSERT #tmpStats
  SELECT
    DB_NAME(),
    DB_ID(),
    stat.object_id,
    stat.name,
    MIN(sp.last_updated),
    MAX(sp.modification_counter),
    SUM(ps.rows)
  FROM sys.objects AS t
  INNER JOIN (
     SELECT SUM(ps.rows) AS rows, ps.object_id
     FROM sys.partitions ps 
     WHERE ps.index_id <= 1 
     GROUP BY ps.object_id
     HAVING SUM(ps.rows) >= ' + CONVERT (NVARCHAR, @MinimumTableRows)
           + N'
     ) AS ps
     ON t.object_id = ps.object_id 
  INNER JOIN sys.stats AS stat ON t.object_id = stat.object_id
  LEFT JOIN sys.indexes AS ix ON t.object_id = ix.object_id AND stat.stats_id = ix.index_id
  CROSS APPLY
    (
    SELECT modification_counter, last_updated
    FROM sys.dm_db_stats_properties(stat.object_id, stat.stats_id)
    WHERE modification_counter >= ' + CONVERT (NVARCHAR, @MinimumModCountr)
           + N'
    AND last_updated < DATEADD(day, -' + CONVERT (NVARCHAR, @MinimumDaysOld) + N', GETDATE())
    ' + CASE
            WHEN OBJECT_ID ('sys.dm_db_incremental_stats_properties') IS NULL THEN N''
            ELSE
                N'UNION ALL
    SELECT modification_counter, last_updated
    FROM sys.dm_db_incremental_stats_properties(stat.object_id, stat.stats_id)
    WHERE modification_counter >= ' + CONVERT (NVARCHAR, @MinimumModCountr)
                + N'
    AND last_updated < DATEADD(day, -' + CONVERT (NVARCHAR, @MinimumDaysOld) + N', GETDATE())
    '
        END
           + N') AS sp
  WHERE t.is_ms_shipped = 0
  AND t.[type] = ''U''
  AND (ix.index_id IS NULL OR ix.is_disabled = 0)
  GROUP BY stat.object_id,stat.name
  OPTION (MAXDOP 1)';

IF CONVERT (VARCHAR(300), SERVERPROPERTY ('Edition')) = 'SQL Azure'
BEGIN
    EXEC (@qry);
END;
ELSE
BEGIN
    SET @qry = N'
IF EXISTS (SELECT * FROM sys.databases WHERE database_id > 4 AND name = ''?'' AND state_desc = ''ONLINE'' AND DATABASEPROPERTYEX(name, ''Updateability'') = ''READ_WRITE'')
 AND ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''ReportServerTempDB'', ''distribution'', ''SSISDB'')
BEGIN
 USE [?];' + @qry + N'
END';
    EXEC sp_MSforeachdb @qry;
END;

IF @ExecuteRemediation = 0 PRINT @qry;

SELECT DB_NAME (DatabaseId) AS "database_name",
       OBJECT_SCHEMA_NAME (ObjectId, DatabaseId) AS "schema_name",
       OBJECT_NAME (ObjectId, DatabaseId) AS "table_name",
       StatsName,
       ModCntr,
       LastUpdate,
       N'USE ' + QUOTENAME (DB_NAME (DatabaseId)) COLLATE DATABASE_DEFAULT + N'; UPDATE STATISTICS '
       + QUOTENAME (DB_NAME (DatabaseId)) COLLATE DATABASE_DEFAULT + N'.'
       + QUOTENAME (OBJECT_SCHEMA_NAME (ObjectId, DatabaseId)) COLLATE DATABASE_DEFAULT + N'.'
       + QUOTENAME (OBJECT_NAME (ObjectId, DatabaseId)) COLLATE DATABASE_DEFAULT + N' '
       + QUOTENAME (StatsName) COLLATE DATABASE_DEFAULT + ISNULL (@options, N'') + N';' AS "RemediationCmd"
FROM #tmpStats
ORDER BY ModCntr DESC,
         LastUpdate ASC;

IF @ExecuteRemediation = 1
BEGIN
    DECLARE @Msg NVARCHAR(4000);
    DECLARE Cmds CURSOR LOCAL FAST_FORWARD FOR
    SELECT N'ModCntr: ' + CAST(ModCntr AS NVARCHAR(MAX)) + N', LastUpdate: '
           + ISNULL (CONVERT (NVARCHAR(25), LastUpdate, 121), N'(never)') AS "Msg",
           N'USE ' + QUOTENAME (DB_NAME (DatabaseId)) COLLATE DATABASE_DEFAULT + N'; UPDATE STATISTICS '
           + QUOTENAME (DB_NAME (DatabaseId)) COLLATE DATABASE_DEFAULT + N'.'
           + QUOTENAME (OBJECT_SCHEMA_NAME (ObjectId, DatabaseId)) COLLATE DATABASE_DEFAULT + N'.'
           + QUOTENAME (OBJECT_NAME (ObjectId, DatabaseId)) COLLATE DATABASE_DEFAULT + N' '
           + QUOTENAME (StatsName) COLLATE DATABASE_DEFAULT + ISNULL (@options, N'') + N';' AS "RemediationCmd"
    FROM #tmpStats
    ORDER BY ModCntr DESC,
             LastUpdate ASC;

    OPEN Cmds;
    FETCH NEXT FROM Cmds
    INTO @Msg,
         @qry;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Msg = CHAR (13) + CHAR (10) + N'-- ' + CONVERT (NVARCHAR(25), GETDATE (), 121) + CHAR (13) + CHAR (10)
                   + N'-- ' + @Msg;
        RAISERROR (N'%s', 0, 1, @Msg) WITH NOWAIT;
        RAISERROR (N'%s', 0, 1, @qry) WITH NOWAIT;

        EXEC (@qry);

        FETCH NEXT FROM Cmds
        INTO @Msg,
             @qry;
    END;

    CLOSE Cmds;
    DEALLOCATE Cmds;


    SET @Msg = CHAR (13) + CHAR (10) + N'-- ' + CONVERT (NVARCHAR(25), GETDATE (), 121) + CHAR (13) + CHAR (10)
               + N'-- Done.';
    RAISERROR (N'%s', 0, 1, @Msg) WITH NOWAIT;
END;