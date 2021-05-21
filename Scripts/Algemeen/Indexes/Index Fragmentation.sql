/****************************************
 Shows internal fragmentation of an index
****************************************/
SELECT IX.name AS 'Name',
	PS.index_level AS 'Level',
	PS.page_count AS 'Pages',
	PS.avg_page_space_used_in_percent AS 'Page Fullness (%)'
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Sales.SalesOrderDetail'), DEFAULT, DEFAULT, 'DETAILED') AS PS
JOIN sys.indexes AS IX ON IX.OBJECT_ID = PS.OBJECT_ID
	AND IX.index_id = PS.index_id
WHERE IX.name = 'PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID';
GO

/****************************************
 Shows external fragmentation of an index
****************************************/
SELECT IX.name AS 'Name',
	PS.index_level AS 'Level',
	PS.page_count AS 'Pages',
	PS.avg_fragmentation_in_percent AS 'External Fragmentation (%)',
	PS.fragment_count AS 'Fragments',
	PS.avg_fragment_size_in_pages AS 'Avg Fragment Size'
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Sales.SalesOrderDetail'), DEFAULT, DEFAULT, 'LIMITED') AS PS
JOIN sys.indexes AS IX ON IX.OBJECT_ID = PS.OBJECT_ID
	AND IX.index_id = PS.index_id
WHERE IX.name = 'PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID';
GO

/*********************************************************
Get fragmentation for indexes (including rebuild statement
*********************************************************/
SELECT GETDATE() AS [Date],
	ROW_NUMBER() OVER (
		ORDER BY indexstats.avg_fragmentation_in_percent DESC
		) AS RowNumber,
	DB_NAME() AS Databasename,
	dbtables.name AS 'Table',
	dbindexes.name AS 'Index',
	indexstats.page_count AS Pages,
	indexstats.avg_fragmentation_in_percent AS AVG_Fragmentation,
	'ALTER INDEX ' + dbindexes.name + ' ON ' + DB_NAME() + '.' + dbschemas.name + '.' + dbtables.name + ' REBUILD WITH (FILLFACTOR = 90, ONLINE = ON, SORT_IN_TEMPDB = ON);' AS SqlCommand,
	fill_factor AS Fill_Factor
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables AS dbtables ON dbtables.object_id = indexstats.object_id
INNER JOIN sys.schemas AS dbschemas ON dbtables.schema_id = dbschemas.schema_id
INNER JOIN sys.indexes AS dbindexes ON dbindexes.object_id = indexstats.object_id
	AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
	--and indexstats.avg_fragmentation_in_percent >= 60
	AND indexstats.page_count > 100
	AND dbindexes.name IS NOT NULL
ORDER BY indexstats.avg_fragmentation_in_percent DESC;
GO

/*****************************************************************
 Shows detailed index fragmentation for all indexes in a database 
*****************************************************************/
SELECT DB_NAME(ps.database_id) AS [Database Name],
	SCHEMA_NAME(o.schema_id) AS [Schema Name],
	OBJECT_NAME(ps.OBJECT_ID) AS [Object Name],
	i.name AS [Index Name],
	ps.index_id,
	ps.index_type_desc,
	ps.avg_fragmentation_in_percent,
	ps.fragment_count,
	ps.page_count,
	i.fill_factor,
	i.has_filter,
	i.filter_definition,
	i.allow_page_locks
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, N'LIMITED') AS ps
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON ps.object_id = i.object_id
	AND ps.index_id = i.index_id
INNER JOIN sys.objects AS o WITH (NOLOCK) ON i.object_id = o.object_id
WHERE ps.database_id = DB_ID()
--and ps.page_count > 2500
ORDER BY ps.avg_fragmentation_in_percent DESC
OPTION (RECOMPILE);
GO

/*************************************************************
 Shows detailed index information of all indexes in a database
*************************************************************/
SELECT '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME(ddips.object_id, DB_ID()) + '].[' + OBJECT_NAME(ddips.object_id, DB_ID()) + ']' AS [statement],
	i.name AS index_name,
	ddips.index_type_desc,
	ddips.partition_number,
	ddips.alloc_unit_type_desc,
	ddips.index_depth,
	ddips.index_level,
	CAST(ddips.avg_fragmentation_in_percent AS SMALLINT) AS [avg_frag_%],
	CAST(ddips.avg_fragment_size_in_pages AS SMALLINT) AS avg_frag_size_in_pages,
	ddips.fragment_count,
	ddips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'limited') AS ddips
INNER JOIN sys.indexes AS i ON ddips.object_id = i.object_id
	AND ddips.index_id = i.index_id
WHERE ddips.avg_fragmentation_in_percent > 15
	AND ddips.page_count > 500
ORDER BY ddips.avg_fragmentation_in_percent,
	OBJECT_NAME(ddips.object_id, DB_ID()),
	i.name;
GO


