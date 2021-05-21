-- Unused Indexes
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(i.object_id) AS TableName,
	i.index_id,
	ISNULL(user_seeks, 0) AS UserSeeks,
	ISNULL(user_scans, 0) AS UserScans,
	ISNULL(user_lookups, 0) AS UserLookups,
	ISNULL(user_updates, 0) AS UserUpdates
FROM sys.indexes AS i
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS ius ON ius.object_id = i.object_id
	AND ius.index_id = i.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsMSShipped') = 0;
GO

-- Displays potentially unused indexes for the current database
--
-- Dropping these indexes may improve database performance. These statistics are reset each time 
-- the server is rebooted, so make sure to review the [sqlserver_start_time] value to ensure the 
-- statistics are captured for a meaningful time period.
-- ------------------------------------------------------------------------------------------------
SELECT * -- sqlserver_start_time
FROM sys.dm_os_sys_info;

DECLARE @dbid INT,
	@dbname VARCHAR(100);

SELECT @dbid = DB_ID(),
	@dbname = DB_NAME();

WITH partitionCTE (
	object_id,
	index_id,
	row_count,
	partition_count
	)
AS (
	SELECT object_id,
		index_id,
		SUM(rows) AS 'row_count',
		COUNT(partition_id) AS 'partition_count'
	FROM sys.partitions
	GROUP BY object_id,
		index_id
	)
SELECT OBJECT_NAME(i.object_id) AS objectName,
	i.name,
	CASE 
		WHEN i.is_unique = 1
			THEN 'UNIQUE '
		ELSE ''
		END + i.type_desc AS 'indexType',
	ddius.user_seeks,
	ddius.user_scans,
	ddius.user_lookups,
	ddius.user_updates,
	cte.row_count,
	CASE 
		WHEN partition_count > 1
			THEN 'yes'
		ELSE 'no'
		END AS 'partitioned?',
	CASE 
		WHEN i.type = 2
			AND i.is_unique = 0
			THEN 'Drop Index ' + i.name + ' On ' + @dbname + '.dbo.' + OBJECT_NAME(ddius.object_id) + ';'
		WHEN i.type = 2
			AND i.is_unique = 1
			THEN 'Alter Table ' + @dbname + '.dbo.' + OBJECT_NAME(ddius.object_ID) + ' Drop Constraint ' + i.name + ';'
		ELSE ''
		END AS 'SQL_DropStatement'
FROM sys.indexes AS i
INNER JOIN sys.dm_db_index_usage_stats AS ddius ON i.object_id = ddius.object_id
	AND i.index_id = ddius.index_id
INNER JOIN partitionCTE AS cte ON i.object_id = cte.object_id
	AND i.index_id = cte.index_id
WHERE ddius.database_id = @dbid
	AND i.type = 2 ----> retrieve nonclustered indexes only
	AND i.is_unique = 0 ----> ignore unique indexes, we'll assume they're serving a necessary business use
	AND ddius.user_seeks + ddius.user_scans + ddius.user_lookups = 0 ----> starting point, update this value as needed; 0 retrieves completely unused indexes
ORDER BY user_updates DESC;
GO

-- Unused indexes
-- ------------------------------------------------------------------------------------------------
SELECT o.name AS ObjectName,
	i.name AS IndexName,
	i.index_id AS IndexID,
	dm_ius.user_seeks AS UserSeek,
	dm_ius.user_scans AS UserScans,
	dm_ius.user_lookups AS UserLookups,
	dm_ius.user_updates AS UserUpdates,
	p.TableRows,
	'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.object_id)) AS 'drop statement'
FROM sys.dm_db_index_usage_stats AS dm_ius
INNER JOIN sys.indexes AS i ON i.index_id = dm_ius.index_id
	AND dm_ius.object_id = i.object_id
INNER JOIN sys.objects AS o ON dm_ius.object_id = o.object_id
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN (
	SELECT SUM(p.rows) AS TableRows,
		p.index_id,
		p.object_id
	FROM sys.partitions AS p
	GROUP BY p.index_id,
		p.object_id
	) AS p ON p.index_id = dm_ius.index_id
	AND dm_ius.object_id = p.object_id
WHERE OBJECTPROPERTY(dm_ius.object_id, 'IsUserTable') = 1
	AND dm_ius.database_id = DB_ID()
	AND i.type_desc = 'nonclustered'
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
ORDER BY dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups ASC;
GO

-- Identify indexes that are being maintained but not used
---------------------------------------------------------------------------------------------------
SELECT '[' + DB_NAME() + '].[' + su.name + '].[' + o.name + ']' AS [statement],
	i.name AS index_name,
	ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads,
	ddius.user_updates AS user_writes,
	SUM(SP.rows) AS total_rows
FROM sys.dm_db_index_usage_stats AS ddius
INNER JOIN sys.indexes AS i ON ddius.object_id = i.object_id
	AND i.index_id = ddius.index_id
INNER JOIN sys.partitions AS SP ON ddius.object_id = SP.object_id
	AND SP.index_id = ddius.index_id
INNER JOIN sys.objects AS o ON ddius.object_id = o.object_id
INNER JOIN sys.sysusers AS su ON o.schema_id = su.UID
WHERE ddius.database_id = DB_ID()
	AND -- current database only 
	objectproperty(ddius.object_id, 'IsUserTable') = 1
	AND ddius.index_id > 0
GROUP BY su.name,
	o.name,
	i.name,
	ddius.user_seeks + ddius.user_scans + ddius.user_lookups,
	ddius.user_updates
HAVING ddius.user_seeks + ddius.user_scans + ddius.user_lookups = 0
ORDER BY ddius.user_updates DESC,
	su.name,
	o.name,
	i.name;
GO

-- Unused Index Script
-- Original Author: David Waller 
-- Date: 4/2020
SELECT TOP 25 o.name AS ObjectName,
	i.name AS IndexName,
	i.index_id AS IndexID,
	dm_ius.user_seeks AS UserSeek,
	dm_ius.user_scans AS UserScans,
	dm_ius.user_lookups AS UserLookups,
	dm_ius.user_updates AS UserUpdates,
	p.TableRows,
	'DROP INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'drop statement'
FROM sys.dm_db_index_usage_stats AS dm_ius
INNER JOIN sys.indexes AS i ON i.index_id = dm_ius.index_id
	AND dm_ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects AS o ON dm_ius.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN (
	SELECT SUM(p.rows) AS TableRows,
		p.index_id,
		p.OBJECT_ID
	FROM sys.partitions AS p
	GROUP BY p.index_id,
		p.OBJECT_ID
	) AS p ON p.index_id = dm_ius.index_id
	AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID, 'IsUserTable') = 1
	AND dm_ius.database_id = DB_ID()
	AND i.type_desc = 'nonclustered'
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
	AND dm_ius.user_seeks = 0
	AND dm_ius.user_scans = 0
	AND dm_ius.user_lookups = 0
ORDER BY dm_ius.user_updates DESC;
GO


