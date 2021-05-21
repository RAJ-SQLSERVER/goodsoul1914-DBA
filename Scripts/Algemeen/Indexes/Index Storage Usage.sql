SELECT index_id AS ID,
	index_depth AS D,
	index_level AS L,
	record_count AS Rows,
	page_count AS Pages,
	avg_page_space_used_in_percent AS [Page:Percent Full],
	min_record_size_in_bytes AS [Row:MinLen],
	max_record_size_in_bytes AS [Row:MaxLen],
	avg_record_size_in_bytes AS [Row:AvgLen]
FROM sys.dm_db_index_physical_stats(DB_ID(N'StackOverflow2010') -- Database ID
		, OBJECT_ID(N'StackOverflow2010.dbo.Posts') -- Object ID
		, NULL -- Index ID
		, NULL -- Partition ID
		, 'DETAILED');-- Mode
GO

-- SELECT 709 + 1320 + 1433 + 1409 = 4871 PAGES
-- SELECT 4871 * 8192 / 1024 / 1024 = 38MB
EXEC sp_spaceused N'StackOverflow2010.dbo.Posts';
GO


