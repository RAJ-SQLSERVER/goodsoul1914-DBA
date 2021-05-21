SELECT PARSENAME(REPLACE(REPLACE(s.name, '_WA', 'WA'), '_', '.'), 4) AS Origin,
	PARSENAME(REPLACE(REPLACE(s.name, '_WA', 'WA'), '_', '.'), 3) AS Stattype,
	CAST(CONVERT(VARBINARY(8), '0x' + RIGHT('00000000' + REPLACE('0x' + CONVERT(VARCHAR(10), PARSENAME(REPLACE(REPLACE(s.name, '_WA', 'WA'), '_', '.'), 2)), 'x', ''), 8), 1) AS INT) AS ParsedColumnID,
	CAST(CONVERT(VARBINARY(8), '0x' + RIGHT('00000000' + REPLACE('0x' + CONVERT(VARCHAR(10), PARSENAME(REPLACE(REPLACE(s.name, '_WA', 'WA'), '_', '.'), 1)), 'x', ''), 8), 1) AS INT) AS ParsedObjectID,
	s.name AS StatName,
	s.object_id AS ObjectID,
	o.name AS ObjName,
	sc.column_id AS ColumnID,
	c.name AS ColumnName,
	sc.stats_column_id,
	s.stats_id,
	i.index_id,
	i.name AS IdxName,
	sp.last_updated,
	s.auto_created,
	sp.rows,
	sp.rows_sampled,
	sp.unfiltered_rows,
	sp.modification_counter,
	sp.steps,
	sp.persisted_sample_percent,
	i.is_hypothetical,
	i.is_ignored_in_optimization
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc ON s.object_id = sc.object_id
	AND sc.stats_id = s.stats_id
LEFT OUTER JOIN sys.indexes AS i ON s.stats_id = i.index_id
	AND i.object_id = s.object_id
INNER JOIN sys.objects AS o ON o.object_id = s.object_id
INNER JOIN sys.columns AS c ON c.column_id = sc.column_id
	AND c.object_id = s.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE s.auto_created = 1
	AND s.user_created = 0

UNION

SELECT CASE s.user_created
		WHEN 1
			THEN 'User'
		ELSE 'MS'
		END AS Origin,
	CASE s.user_created
		WHEN 1
			THEN 'User'
		ELSE 'Sys'
		END AS Stattype,
	'' AS ParsedColumnID,
	'' AS ParsedObjectID,
	s.name AS StatName,
	s.object_id AS ObjectID,
	s.name AS ObjName,
	sc.column_id AS ColumnID,
	c.name AS ColumnName,
	sc.stats_column_id,
	s.stats_id,
	i.index_id,
	i.name AS IdxName,
	sp.last_updated,
	s.auto_created,
	sp.rows,
	sp.rows_sampled,
	sp.unfiltered_rows,
	sp.modification_counter,
	sp.steps,
	sp.persisted_sample_percent,
	i.is_hypothetical,
	i.is_ignored_in_optimization
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc ON s.object_id = sc.object_id
	AND sc.stats_id = s.stats_id
LEFT OUTER JOIN sys.indexes AS i ON i.object_id = s.object_id
	AND i.index_id = s.stats_id
INNER JOIN sys.objects AS o ON o.object_id = s.object_id
INNER JOIN sys.columns AS c ON c.object_id = s.object_id
	AND c.column_id = sc.column_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE o.is_ms_shipped = 0
	AND s.auto_created = 0
ORDER BY s.object_id,
	s.stats_id;
