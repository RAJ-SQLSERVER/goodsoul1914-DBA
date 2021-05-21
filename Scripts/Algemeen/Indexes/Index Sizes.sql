DECLARE @objname sysname = NULL;
SELECT o.name AS ObjName
		, i.name AS IdxName
		, ReservedMB = CONVERT(DECIMAL(19, 2), SUM(ps.reserved_page_count) / 128.0)
		, TotalUsedMB = CONVERT(DECIMAL(19, 2), SUM( ps.used_page_count) / 128.0)
		, TotalDataMB = CONVERT(DECIMAL(19, 2), SUM(ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count) / 128.0)
		, UnusedMB = CONVERT(DECIMAL(19, 2), SUM(ps.reserved_page_count) / 128.0 - CONVERT(DECIMAL(19, 2), SUM( ps.used_page_count)) / 128.0)
		, RowCnt = MAX(ISNULL(row_count, 0))
FROM sys.dm_db_partition_stats ps
INNER JOIN sys.objects o ON o.object_id = ps.object_id
INNER JOIN sys.indexes i ON i.object_id = o.object_id AND ps.index_id = i.index_id
WHERE o.name = ISNULL(@objname, o.name) AND i.index_id NOT IN ( 0, 1, 255 ) AND o.is_ms_shipped = 0
GROUP BY GROUPING SETS(ROLLUP(o.name, i.name));
GO
