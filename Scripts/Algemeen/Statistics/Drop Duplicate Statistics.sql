---------------------------------------------------------------------------------------------------
--Name:		StatisticsDuplicateDrop.sql
--Purpose:	To find autocreated stats that have an overlapping statistic, and generate a script to drop them.
--Notes:	Auto created stats have only one column.
--History:
--mm/dd/yyyy	Init	Description
------------	----	---------------------------------------------------------------------------
--02/13/2020	PLS		Created
---------------------------------------------------------------------------------------------------
--Make CTEs
---------------------------------------------------------------------------------------------------
WITH cteAutoStats
AS (
	SELECT s.object_id,
		s.name,
		sc.column_id
	FROM sys.stats AS s
	JOIN sys.stats_columns AS sc ON s.object_id = sc.object_id
		AND s.stats_id = sc.stats_id
	WHERE s.auto_created = 1
		AND sc.stats_column_id = 1
		AND OBJECT_SCHEMA_NAME(s.object_id) != 'sys'
	),
cteUserStats
AS (
	SELECT s.object_id,
		s.name,
		sc.column_id
	FROM sys.stats AS s
	JOIN sys.stats_columns AS sc ON s.object_id = sc.object_id
		AND s.stats_id = sc.stats_id
	WHERE s.auto_created = 0
		AND sc.stats_column_id = 1
		AND OBJECT_SCHEMA_NAME(s.object_id) != 'sys'
	)
---------------------------------------------------------------------------------------------------
--Get results
---------------------------------------------------------------------------------------------------
SELECT DISTINCT SchemaName = OBJECT_SCHEMA_NAME(cus.object_id),
	TableName = OBJECT_NAME(cus.object_id),
	ColumnName = c.name,
	OverlappingStat = STUFF((
			SELECT '; ' + xmls.name
			FROM cteUserStats AS xmls
			WHERE xmls.object_id = cus.object_id
				AND xmls.column_id = cas.column_id
			ORDER BY xmls.name
			FOR XML path('')
			), 1, 1, ''),
	DuplicateAutoStat = cas.name,
	DropScript = 'USE ' + QUOTENAME(DB_NAME()) + '; DROP STATISTICS ' + QUOTENAME(OBJECT_SCHEMA_NAME(cus.object_id)) + '.' + QUOTENAME(OBJECT_NAME(cus.object_id)) + '.' + QUOTENAME(cas.name)
FROM cteAutoStats AS cas
JOIN cteUserStats AS cus ON cas.object_id = cus.object_id
	AND cas.column_id = cus.column_id
JOIN sys.columns AS c ON cus.object_id = c.object_id
	AND cus.column_id = c.column_id
ORDER BY SchemaName,
	TableName,
	ColumnName;
