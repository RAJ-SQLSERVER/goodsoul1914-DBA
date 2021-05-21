-- Index usage information
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(IX.OBJECT_ID) AS Table_Name,
	IX.name AS Index_Name,
	IX.type_desc AS Index_Type,
	SUM(PS.used_page_count) * 8 AS IndexSizeKB,
	IXUS.user_seeks AS NumOfSeeks,
	IXUS.user_scans AS NumOfScans,
	IXUS.user_lookups AS NumOfLookups,
	IXUS.user_updates AS NumOfUpdates,
	IXUS.last_user_seek AS LastSeek,
	IXUS.last_user_scan AS LastScan,
	IXUS.last_user_lookup AS LastLookup,
	IXUS.last_user_update AS LastUpdate
FROM sys.indexes AS IX
INNER JOIN sys.dm_db_index_usage_stats AS IXUS ON IXUS.index_id = IX.index_id
	AND IXUS.OBJECT_ID = IX.OBJECT_ID
INNER JOIN sys.dm_db_partition_stats AS PS ON PS.object_id = IX.object_id
WHERE OBJECTPROPERTY(IX.OBJECT_ID, 'IsUserTable') = 1
GROUP BY OBJECT_NAME(IX.OBJECT_ID),
	IX.name,
	IX.type_desc,
	IXUS.user_seeks,
	IXUS.user_scans,
	IXUS.user_lookups,
	IXUS.user_updates,
	IXUS.last_user_seek,
	IXUS.last_user_scan,
	IXUS.last_user_lookup,
	IXUS.last_user_update;
GO

-- Index usage information
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(i.object_id) AS ObjectName,
	i.name AS IndexName,
	i.index_id,
	s.user_seeks,
	s.user_scans,
	s.user_lookups,
	s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
	s.user_updates AS Writes,
	i.type_desc AS [Index Type],
	i.fill_factor AS [Fill Factor],
	i.has_filter,
	i.filter_definition,
	s.last_user_scan,
	s.last_user_lookup,
	s.last_user_seek
FROM sys.indexes AS i WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s WITH (NOLOCK) ON i.object_id = s.object_id
	AND i.index_id = s.index_id
	AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY s.user_seeks + s.user_scans + s.user_lookups DESC
OPTION (RECOMPILE);
GO

-- Index Usage Information IO
-------------------------------------------------------------------------------
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
	AND IX.index_id = 0
GROUP BY OBJECT_NAME(IXOS.OBJECT_ID),
	IX.name,
	IX.type_desc,
	IXOS.LEAF_INSERT_COUNT,
	IXOS.LEAF_UPDATE_COUNT,
	IXOS.LEAF_DELETE_COUNT;
