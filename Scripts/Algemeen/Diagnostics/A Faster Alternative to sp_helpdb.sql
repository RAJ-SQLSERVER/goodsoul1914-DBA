CREATE TABLE #variables
(
    StartDate DATETIME
);
GO

INSERT INTO #variables
SELECT GETDATE();
GO

EXEC sp_helpdb;

DECLARE @t2 DATETIME;
SET @t2 = GETDATE();
DECLARE @t1 DATETIME;
SELECT @t1 = StartDate
FROM   #variables;

SELECT DATEDIFF(MILLISECOND, @t1, @t2) AS "TotalTime";

DROP TABLE #variables;
GO



/*
	The faster alternative
*/

DECLARE @t1 DATETIME;
DECLARE @t2 DATETIME;

SET @t1 = GETDATE();

CREATE TABLE #DBSize
(
    DatabaseName VARCHAR(200),
    Size BIGINT
);

INSERT INTO #DBSize
SELECT     d1.name,
           CONVERT(VARCHAR, SUM(m.size) * 8 / 1024) AS "Total disk space"
FROM       sys.databases AS d1
INNER JOIN sys.master_files AS m
    ON d1.database_id = m.database_id
GROUP BY   d1.name
ORDER BY   d1.name;

SELECT     CONVERT(VARCHAR(50), d.name) AS "Name",
           s.Size AS "DatabaseSizeInMB",
           d.create_date AS "CreatedDate",
           d.compatibility_level AS "CompatibilityLevel",
           CASE
               WHEN d.is_auto_create_stats_on = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsAutoStatsOn",
           CASE
               WHEN d.is_auto_update_stats_on = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsAutoUpdateStatsOn",
           b.name AS "DBOwner",
           CASE
               WHEN d.state = 0 THEN
                   'ONLINE'
               WHEN d.state = 1 THEN
                   'RESTORING'
               WHEN d.state = 2 THEN
                   'RECOVERING'
               WHEN d.state = 3 THEN
                   'RECOVERY_PENDING'
               WHEN d.state = 4 THEN
                   'SUSPECT'
               WHEN d.state = 5 THEN
                   'EMERGENCY'
               WHEN d.state = 6 THEN
                   'OFFLINE'
               WHEN d.state = 7 THEN
                   'COPYING'
               WHEN d.state = 10 THEN
                   'OFFLINE_SECONDARY'
               ELSE
                   'Unknown State'
           END AS "State",
           SERVERPROPERTY('ProductMajorversion') AS "ProductMajorVersion",
           ISNULL(DB_NAME(d.source_database_id), 'Not A Snapshot') AS "SourceDBName",
           d.collation_name AS "CollationName",
           d.user_access_desc AS "UserAccessDesc",
           CASE
               WHEN d.is_read_only = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsReadOnly",
           CASE
               WHEN d.is_auto_close_on = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsAutoCloseOn",
           CASE
               WHEN d.is_auto_shrink_on = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsAutoShrinkOn",
           d.state_desc,
           DATABASEPROPERTYEX(d.name, 'Recovery') AS "RecoveryModel",
           d.log_reuse_wait_desc AS "LogReuseWaitDesc",
           d.containment_desc AS "ContainmentDesc", --This column will need be removed for older versions.
           d.delayed_durability_desc AS "DelayedDurabilityDesc",
                                                  --CASE
                                                  --    WHEN d.is_memory_optimized_enabled = 1 THEN 
                                                  --        'True'
                                                  --    ELSE
                                                  --        'False'
                                                  --END AS [IsMemoryOptimizedEnabled], --This column will need to be removed for older versions.
           DATABASEPROPERTYEX(d.name, 'Updateability') AS "Updateability",
           DATABASEPROPERTYEX(d.name, 'SQLSortOrder') AS "SQLSortOrder",
           CASE
               WHEN DATABASEPROPERTYEX(d.name, 'IsFulltextEnabled') = 1 THEN
                   'True'
               ELSE
                   'False'
           END AS "IsFullTextEnabled",
           DATABASEPROPERTYEX(d.name, 'Version') AS "Version"
FROM       sys.databases AS d
INNER JOIN sys.syslogins AS b
    ON d.owner_sid = b.sid
INNER JOIN #DBSize AS s
    ON d.name = s.DatabaseName;

DROP TABLE #DBSize;

SET @t2 = GETDATE();
SELECT DATEDIFF(MILLISECOND, @t1, @t2) AS "elapsed_ms";