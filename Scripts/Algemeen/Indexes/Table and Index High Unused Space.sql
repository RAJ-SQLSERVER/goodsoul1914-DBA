DECLARE @TopPerDB              INT          = 100,
        @MinimumRowCount       INT          = 1000,
        @MinimumUnusedSizeMB   INT          = 1024,
        @MinimumUnusedSpacePct INT          = 50,
        @RebuildIndexOptions   VARCHAR(MAX) = 'ONLINE = ON, SORT_IN_TEMPDB = ON, MAXDOP = 1';

SET NOCOUNT, ARITHABORT, XACT_ABORT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @command NVARCHAR(MAX);
DECLARE @TempResult AS TABLE (
    DatabaseName         sysname,
    SchemaName           sysname NULL,
    TableName            sysname NULL,
    IndexName            sysname NULL,
    Fill_Factor          INT     NULL,
    DatabaseID           INT,
    ObjectId             INT,
    IndexId              INT,
    CompressionType      TINYINT,
    CompressionType_Desc AS (CASE CompressionType
                                 WHEN 0 THEN 'NONE'
                                 WHEN 1 THEN 'ROW'
                                 WHEN 2 THEN 'PAGE'
                                 WHEN 3 THEN 'COLUMNSTORE'
                                 WHEN 4 THEN 'COLUMNSTORE_ARCHIVE'
                                 ELSE 'UNKNOWN'
                             END
                            ),
    RowCounts            BIGINT  NULL,
    TotalSpaceMB         MONEY   NULL,
    UsedSpaceMB          MONEY   NULL,
    UnusedSpaceMB        MONEY   NULL,
    UserSeeks            INT     NULL,
    UserScans            INT     NULL,
    UserLookups          INT     NULL,
    UserUpdates          INT     NULL
);

SELECT @command = N'IF EXISTS (SELECT * FROM sys.databases WHERE state = 0 AND is_read_only = 0 AND database_id > 4 AND is_distributor = 0 AND DATABASEPROPERTYEX([name], ''Updateability'') = ''READ_WRITE'')
BEGIN
USE [?];
SELECT TOP (' + CONVERT (NVARCHAR(MAX), @TopPerDB)
                  + N')
	DB_NAME() AS DatabaseName,
	OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
	OBJECT_NAME(i.object_id) AS TableName,
	i.name AS IndexName,
	i.fill_factor,
	DB_ID(), i.object_id, i.index_id,
	MAX(p.data_compression) AS CompressionType,
	SUM(p.rows) AS RowCounts,
	ROUND(SUM(a.total_pages) / 128.0, 2) AS TotalSpaceMB,
	ROUND(SUM(a.used_pages) / 128.0, 2) AS UsedSpaceMB, 
	ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.0, 2) AS UnusedSpaceMB,
	MAX(us.user_seeks) AS user_seeks,
	MAX(us.user_scans) AS user_scans,
	MAX(us.user_lookups) AS user_lookups,
	MAX(us.user_updates) AS user_updates
FROM 
	sys.indexes i
INNER JOIN 
	sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
	sys.allocation_units a ON p.partition_id = a.container_id
LEFT JOIN
	sys.dm_db_index_usage_stats AS us ON us.database_id = DB_ID() AND us.object_id = i.object_id AND us.index_id = i.index_id
WHERE 
	OBJECT_NAME(i.object_id) NOT LIKE ''dt%''
	AND OBJECT_SCHEMA_NAME(i.object_id) <> ''sys''
	AND i.object_id > 255 
	and p.rows >= 1
GROUP BY 
	i.object_id, i.name, i.index_id, i.fill_factor
HAVING
	SUM(p.rows) >= ' + CONVERT (NVARCHAR(MAX), @MinimumRowCount)
                  + N'
	AND (SUM(a.total_pages) - SUM(a.used_pages)) / 128 >= ' + CONVERT (NVARCHAR(MAX), @MinimumUnusedSizeMB)
                  + N'
	AND (SUM(a.used_pages) * 1.0) / SUM(a.total_pages) <= 1 - (' + CONVERT (NVARCHAR(MAX), @MinimumUnusedSpacePct)
                  + N' / 100.0)
ORDER BY TotalSpaceMB DESC
END';

INSERT INTO @TempResult
EXEC sp_MSforeachdb @command;

SELECT r.*,
       UnusedSpaceMB / TotalSpaceMB * 100 AS "UnusedSpacePercent",
       --, frg.avg_fragmentation_in_percent, frg.page_count
       --, frg.avg_page_space_used_in_percent
       N'USE ' + QUOTENAME (DatabaseName) + N'; '
       + CASE
             WHEN IndexName IS NULL THEN N'ALTER TABLE ' + QUOTENAME (SchemaName) + '.' + QUOTENAME (TableName)
             ELSE
                 N'ALTER INDEX ' + QUOTENAME (IndexName) + N' ON ' + QUOTENAME (SchemaName) + '.'
                 + QUOTENAME (TableName)
         END + N' REBUILD WITH (FILLFACTOR = ' + CONVERT (NVARCHAR(MAX), ISNULL (NULLIF(Fill_Factor, 0), 100))
       + ISNULL (N', ' + NULLIF(@RebuildIndexOptions, N''), N'') + N');' AS "RebuildCommand",
       N'USE ' + QUOTENAME (DatabaseName) + N'; '
       + CASE
             WHEN IndexName IS NULL THEN N'ALTER TABLE ' + QUOTENAME (SchemaName) + '.' + QUOTENAME (TableName)
             ELSE
                 N'ALTER INDEX ' + QUOTENAME (IndexName) + N' ON ' + QUOTENAME (SchemaName) + '.'
                 + QUOTENAME (TableName)
         END + N' REORGANIZE;' AS "ReorganizeCommand",
       N'USE ' + QUOTENAME (DatabaseName) + N'; DBCC CLEANTABLE (' + QUOTENAME (DatabaseName, N'''') + N', '
       + QUOTENAME (QUOTENAME (SchemaName) + N'.' + QUOTENAME (TableName), N'''') + N', 10000 ) WITH NO_INFOMSGS;' AS "CleanTableCommand"
FROM @TempResult AS r
--OUTER APPLY sys.dm_db_index_physical_stats(DatabaseID, ObjectId, IndexId, NULL, 'LIMITED') AS frg
ORDER BY UnusedSpaceMB DESC
OPTION (MAXDOP 1);
