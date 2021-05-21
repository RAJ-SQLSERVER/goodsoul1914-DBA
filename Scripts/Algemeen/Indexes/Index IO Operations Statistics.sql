-- Index Read/Write stats (all tables in current DB) ordered by Reads
-- Show which indexes in the current database are most active for Reads
---------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(i.object_id) AS ObjectName,
	i.name AS IndexName,
	i.index_id,
	s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
	s.user_updates AS [Total Writes],
	s.user_seeks,
	s.user_scans,
	s.user_lookups,
	i.type_desc AS [Index Type],
	i.fill_factor AS [Fill Factor],
	i.has_filter,
	i.filter_definition,
	FORMAT(s.last_user_scan, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS [Last User Scan],
	FORMAT(s.last_user_lookup, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS [Last User Lookup],
	FORMAT(s.last_user_seek, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS [Last User Seek]
FROM sys.indexes AS i WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s WITH (NOLOCK) ON i.object_id = s.object_id
	AND i.index_id = s.index_id
	AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY s.user_seeks + s.user_scans + s.user_lookups DESC -- Order by reads
OPTION (RECOMPILE);
GO

-- Index Read/Write stats (all tables in current DB) ordered by Writes
-- Show which indexes in the current database are most active for Writes
---------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(i.object_id) AS ObjectName,
	i.name AS IndexName,
	i.index_id,
	s.user_updates AS [Total Writes],
	s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
	i.type_desc AS [Index Type],
	i.fill_factor AS [Fill Factor],
	i.has_filter,
	i.filter_definition,
	FORMAT(s.last_user_update, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS [Last User Update]
FROM sys.indexes AS i WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s WITH (NOLOCK) ON i.object_id = s.object_id
	AND i.index_id = s.index_id
	AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY s.user_updates DESC
OPTION (RECOMPILE);-- Order by writes
GO

-- Index I/O operations statistics
SELECT OBJECT_NAME(IXOS.OBJECT_ID) AS Table_Name,
	IX.name AS Index_Name,
	IX.type_desc AS Index_Type,
	SUM(PS.used_page_count) * 8 AS IndexSizeKB,
	IXOS.LEAF_INSERT_COUNT AS NumOfInserts,
	IXOS.LEAF_UPDATE_COUNT AS NumOfupdates,
	IXOS.LEAF_DELETE_COUNT AS NumOfDeletes
FROM SYS.DM_DB_INDEX_OPERATIONAL_STATS(NULL, NULL, NULL, NULL) AS IXOS
INNER JOIN SYS.INDEXES AS IX ON IX.OBJECT_ID = IXOS.OBJECT_ID
	AND IX.INDEX_ID = IXOS.INDEX_ID
INNER JOIN sys.dm_db_partition_stats AS PS ON PS.object_id = IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID, 'IsUserTable') = 1
GROUP BY OBJECT_NAME(IXOS.OBJECT_ID),
	IX.name,
	IX.type_desc,
	IXOS.LEAF_INSERT_COUNT,
	IXOS.LEAF_UPDATE_COUNT,
	IXOS.LEAF_DELETE_COUNT;
GO

-- Getting Stats on What Indexes are Used and What Indexes are Not
-- ------------------------------------------------------------------------------------------------
SELECT DatabaseName = DB_NAME(DB_ID()),
	TableName = OBJECT_NAME(i.object_id),
	IndexName = i.name,
	IndexType = i.type_desc,
	TotalUsage = ISNULL(user_seeks, 0) + ISNULL(user_scans, 0) + ISNULL(user_lookups, 0),
	UserSeeks = ISNULL(user_seeks, 0),
	UserScans = ISNULL(user_scans, 0),
	UserLookups = ISNULL(user_lookups, 0),
	UserUpdates = ISNULL(user_updates, 0)
FROM sys.indexes AS i
INNER JOIN sys.objects AS o ON i.object_id = o.object_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s ON s.object_id = i.object_id
	AND s.index_id = i.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsMsShipped') = 0
ORDER BY TableName,
	IndexName;
GO


