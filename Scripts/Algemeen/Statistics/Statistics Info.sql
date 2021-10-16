-- stat updates free the plan cache for any plans that have that stat in them
/*********************************
 Find Statistics of a single table
*********************************/
SELECT s.object_id,
       s.name,
       s.auto_created,
       COL_NAME (s.object_id, sc.column_id) AS "col_name"
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
    ON s.stats_id = sc.stats_id
       AND s.object_id = sc.object_id
WHERE s.object_id = OBJECT_ID ('dbo.charge');

/**********************************************
 Find Details for Statistics of Whole Database 
**********************************************/
SELECT DISTINCT OBJECT_NAME (s.object_id) AS "TableName",
                c.name AS "ColumnName",
                s.name AS "StatName",
                STATS_DATE (s.object_id, s.stats_id) AS "LastUpdated",
                DATEDIFF (d, STATS_DATE (s.object_id, s.stats_id), GETDATE ()) AS "DaysOld",
                dsp.modification_counter,
                s.auto_created,
                s.user_created,
                s.no_recompute,
                s.object_id,
                s.stats_id,
                sc.stats_column_id,
                sc.column_id
FROM sys.stats AS s
JOIN sys.stats_columns AS sc
    ON sc.object_id = s.object_id
       AND sc.stats_id = s.stats_id
JOIN sys.columns AS c
    ON c.object_id = sc.object_id
       AND c.column_id = sc.column_id
JOIN sys.partitions AS par
    ON par.object_id = s.object_id
JOIN sys.objects AS obj
    ON par.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties (sc.object_id, s.stats_id) AS dsp
WHERE OBJECTPROPERTY (s.object_id, 'IsUserTable') = 1
      AND (s.auto_created = 1 OR s.user_created = 1)
ORDER BY DaysOld;
GO

/************************************************************************
 Look at most frequently modified indexes and statistics

 This helps you understand your workload and make better decisions about 
 things like data compression and adding new indexes to a table
************************************************************************/
SELECT o.name AS "Object Name",
       o.object_id,
       o.type_desc,
       s.name AS "Statistics Name",
       s.stats_id,
       s.no_recompute,
       s.auto_created,
       s.is_incremental,
       s.is_temporary,
       sp.modification_counter,
       sp.rows,
       sp.rows_sampled,
       FORMAT (sp.last_updated, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Last Updated"
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.stats AS s WITH (NOLOCK)
    ON s.object_id = o.object_id
CROSS APPLY sys.dm_db_stats_properties (s.object_id, s.stats_id) AS sp
WHERE o.type_desc NOT IN ( N'SYSTEM_TABLE', N'INTERNAL_TABLE' )
      AND sp.modification_counter > 0
ORDER BY sp.modification_counter DESC,
         o.name
OPTION (RECOMPILE);
GO

/******************************************
 What stats were updated last 120 minutes? 
******************************************/
SELECT DB_NAME (),
       SCHEMA_NAME (obj.schema_id),
       obj.name,
       stat.name,
       stat.stats_id,
       sp.last_updated,
       sp.rows,
       sp.rows_sampled,
       sp.modification_counter
FROM sys.objects AS obj
INNER JOIN sys.stats AS stat
    ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties (stat.object_id, stat.stats_id) AS sp
WHERE sp.last_updated > DATEADD (MI, -120, GETDATE ())
      AND obj.is_ms_shipped = 0
      AND DB_NAME () <> 'tempdb';

/**********************************************************
 What stats were updated on all databases last 120 minutes ?
**********************************************************/
EXEC sp_MSforeachdb N'USE [?];
select QUOTENAME(DB_NAME()) + N''.'' + 
	   QUOTENAME(SCHEMA_NAME(obj.schema_id)) + N''.'' + 
	   QUOTENAME(obj.name) + 
	   N'' statistic '' + QUOTENAME(stat.name) +
	   N'' was updated on '' + CONVERT(nvarchar(50), sp.last_updated, 121) +
	   N'', had '' + CAST(sp.rows as nvarchar(50)) + N'' rows, with '' + 
	   CAST(sp.rows_sampled as nvarchar(50)) + N'' rows sampled, producing '' + 
	   CAST(sp.steps as nvarchar(50)) + N'' steps in the histogram.''
from sys.objects as obj
	 inner join sys.stats as stat on stat.object_id = obj.object_id
	 cross apply sys.dm_db_stats_properties(stat.object_id, stat.stats_id) as sp
where sp.last_updated > DATEADD(MI, -120, GETDATE()) 
	AND obj.is_ms_shipped = 0 
	AND ''[?]'' <> ''[tempdb]'';';

/*******************
 Statistics updated 
*******************/
SELECT SCHEMA_NAME (o.schema_id) + N'.' + o.name AS "Object Name",
       o.type_desc AS "Object Type",
       i.name AS "Index Name",
       STATS_DATE (i.object_id, i.index_id) AS "Statistics Date",
       s.auto_created,
       s.no_recompute,
       s.user_created,
       s.is_incremental,
       s.is_temporary,
       st.row_count,
       st.used_page_count
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
    ON o.object_id = i.object_id
INNER JOIN sys.stats AS s WITH (NOLOCK)
    ON i.object_id = s.object_id
       AND i.index_id = s.stats_id
INNER JOIN sys.dm_db_partition_stats AS st WITH (NOLOCK)
    ON o.object_id = st.object_id
       AND i.index_id = st.index_id
WHERE o.type IN ( 'U', 'V' )
      AND st.row_count > 0
ORDER BY STATS_DATE (i.object_id, i.index_id) DESC
OPTION (RECOMPILE);
GO

/*
*/
SELECT DISTINCT tb.name AS "table_name",
                --,tc.name  
                tb.type,
                st.name AS "stats_name",
                st.auto_created,
                st.is_temporary,
                st.user_created,
                st.stats_id,
                STATS_DATE (st.object_id, st.stats_id) AS "LastUpdated"
FROM sys.stats AS st
JOIN sys.tables AS tb
    ON st.object_id = tb.object_id
JOIN sys.stats_columns AS sc
    ON sc.stats_id = st.stats_id
       AND sc.object_id = st.object_id
--JOIN sys.all_columns tc ON tb.object_id = tc.object_id AND tc.column_id = sc.column_id 
WHERE tb.name NOT LIKE 'sys%'
      AND STATS_DATE (st.object_id, st.stats_id) IS NOT NULL
--AND tb.name = 'Address' 
ORDER BY 8;

/*
*/
SET NOCOUNT ON;

DECLARE @baseQuery NVARCHAR(2000);
DECLARE @mainQuery NVARCHAR(2000);

SET @baseQuery = N'
SELECT	DB_NAME() as dbName
		,i.name AS index_name
		,i.type_desc
		,STATS_DATE(i.object_id, index_id) AS StatsUpdated
		,QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id,DB_ID()))+''.''+QUOTENAME(o.name) as TableName
		,o.create_date
FROM sys.indexes as i
INNER JOIN
		sys.objects as o
	ON	o.object_id = i.object_id
WHERE	o.type_desc = ''USER_TABLE''
	AND	i.type_desc <> ''HEAP''
';

IF OBJECT_ID ('tempdb..#StatsInfo') IS NOT NULL DROP TABLE #StatsInfo;

CREATE TABLE #StatsInfo (
    dbName           VARCHAR(125),
    index_name       VARCHAR(125),
    IndexType        VARCHAR(50),
    StatsUpdatedDate DATETIME,
    TableName        VARCHAR(125),
    create_date      DATETIME
);

DECLARE @c_dbName VARCHAR(125);

DECLARE curDBs CURSOR LOCAL FORWARD_ONLY FOR
SELECT QUOTENAME (d.name) AS "dbName"
FROM sys.databases AS d
WHERE d.state_desc IN ( 'ONLINE' )
      AND d.database_id > 4;

OPEN curDBs;

FETCH NEXT FROM curDBs
INTO @c_dbName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @c_dbName;

    SET @mainQuery = N'USE ' + @c_dbName + N';';
    SET @mainQuery += @baseQuery;

    INSERT INTO #StatsInfo (dbName, index_name, IndexType, StatsUpdatedDate, TableName, create_date)
    EXEC (@mainQuery);

    FETCH NEXT FROM curDBs
    INTO @c_dbName;
END;

CLOSE curDBs;

DEALLOCATE curDBs;

SELECT *,
       CASE
           WHEN DATEDIFF (dd, COALESCE (StatsUpdatedDate, create_date), GETDATE ()) > 7 THEN 'Old Stats'
           ELSE 'Stats OK'
       END AS "Stats(OK/NotOK)"
FROM #StatsInfo;
GO


