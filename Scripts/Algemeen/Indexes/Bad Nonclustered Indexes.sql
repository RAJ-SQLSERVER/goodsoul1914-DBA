-------------------------------------------------------------------------------
-- Possible Bad NC Indexes (writes > reads)
--
-- Look for indexes with high numbers of writes and zero or very low numbers of 
-- reads. Consider your complete workload, and how long your instance has been 
-- running. Investigate further before dropping an index!
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(s.object_id) AS [Table Name],
	i.name AS [Index Name],
	i.index_id,
	i.is_disabled,
	i.is_hypothetical,
	i.has_filter,
	i.fill_factor,
	s.user_updates AS [Total Writes],
	s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
	s.user_updates - (s.user_seeks + s.user_scans + s.user_lookups) AS Difference
FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON s.object_id = i.object_id
	AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
	AND s.database_id = DB_ID()
	AND s.user_updates > s.user_seeks + s.user_scans + s.user_lookups
	AND i.index_id > 1
	AND i.type_desc = N'NONCLUSTERED'
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
	AND i.is_unique = 0
ORDER BY Difference DESC,
	[Total Writes] DESC,
	[Total Reads] ASC
OPTION (RECOMPILE);
GO

-------------------------------------------------------------------------------
-- Potentially inefficient non-clustered indexes (writes > reads)
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(ddius.object_id) AS [Table Name],
	i.name AS [Index Name],
	i.index_id,
	user_updates AS [Total Writes],
	user_seeks + user_scans + user_lookups AS [Total Reads],
	user_updates - (user_seeks + user_scans + user_lookups) AS Difference
FROM sys.dm_db_index_usage_stats AS ddius WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON ddius.object_id = i.object_id
	AND i.index_id = ddius.index_id
WHERE OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
	AND ddius.database_id = DB_ID()
	AND user_updates > user_seeks + user_scans + user_lookups
	AND i.index_id > 1
ORDER BY Difference DESC,
	[Total Writes] DESC,
	[Total Reads] ASC;
GO


