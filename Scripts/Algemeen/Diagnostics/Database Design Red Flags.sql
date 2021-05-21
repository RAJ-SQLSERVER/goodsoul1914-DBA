/******************************************************************************
Kevin Kline, kkline@sentryone.com, @kekline on Twitter, LinkedIn, and Facebook

--Database Design : Naming standards
Inconsistent naming standards can cause confusion and even lead to plan cache
bloat. Look for the presence of consistent and meaningful names.

Look for stored procedures starting with 'sp_', as well as inconsistent naming 
patterns: dbo.GetCustomerDetails, dbo.Customer_Update, dbo.Create_Customer, 
dbo.usp_updatecust all in the same database.
******************************************************************************/
SELECT   o.name,
         SCHEMA_NAME(o.schema_id),
         o.type,
         o.type_desc,
         o.create_date,
         o.modify_date,
         o.is_ms_shipped
FROM     sys.objects AS o
WHERE    o.type NOT IN ( 'IT', 'SQ', 'S' )
         AND o.is_ms_shipped = 0
ORDER BY o.type,
         o.type_desc;

/******************************************************************************
-- Database Design : Data Type Issues : Oversize columns
Some developers and many ORMs consistently oversize the columns of their tables
compared to the amount of data actually stored, resulting in wasted space.
 
This script compares the column length according to the metadata versus the 
length of data actually in the column. 
******************************************************************************/
SET NOCOUNT ON;

DECLARE @table_schema NVARCHAR(128);
DECLARE @table_name NVARCHAR(128);
DECLARE @column_name NVARCHAR(128);
DECLARE @parms NVARCHAR(100);
DECLARE @data_type NVARCHAR(128);
DECLARE @character_maximum_length INT;
DECLARE @max_len NVARCHAR(10);
DECLARE @tsql NVARCHAR(4000);

DECLARE DDLCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT TABLE_SCHEMA,
       TABLE_NAME,
       COLUMN_NAME,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME IN
       (
           SELECT TABLE_NAME
           FROM   INFORMATION_SCHEMA.TABLES
           WHERE  TABLE_TYPE = 'BASE TABLE'
       )
       AND DATA_TYPE IN ( 'char', 'nchar', 'varchar', 'nvarchar' )
       AND CHARACTER_MAXIMUM_LENGTH > 1;

OPEN DDLCursor;

-- Should rewrite using sp_MSforeachtable instead of explicit cursor
SET @parms = N'@MAX_LENout nvarchar(10) OUTPUT';

CREATE TABLE #space
(
    table_schema NVARCHAR(128) NOT NULL,
    table_name NVARCHAR(128) NOT NULL,
    column_name NVARCHAR(128) NOT NULL,
    data_type NVARCHAR(128) NOT NULL,
    character_maximum_length INT NOT NULL,
    actual_maximum_length INT NOT NULL
);

-- Perform the first fetch.
FETCH NEXT FROM DDLCursor
INTO @table_schema,
     @table_name,
     @column_name,
     @data_type,
     @character_maximum_length;

-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @tsql
        = N'select @MAX_LENout = cast(max(len(isnull(' + QUOTENAME(@column_name) + N',''''))) as nvarchar(10)) from '
          + QUOTENAME(@table_schema) + N'.' + QUOTENAME(@table_name);

    EXEC sp_executesql @tsql, @parms, @MAX_LENout = @max_len OUTPUT;

    IF CAST(@max_len AS INT) < @character_maximum_length -- not interested if lengths match
    BEGIN
        SET @tsql
            = N'insert into #space values (''' + @table_schema + N''',''' + @table_name + N''',''' + @column_name
              + N''',''' + @data_type + N''',' + CAST(@character_maximum_length AS NVARCHAR(10)) + N',' + @max_len
              + N')';

        EXEC sp_executesql @tsql;
    END;

    -- This is executed as long as the previous fetch succeeds.
    FETCH NEXT FROM DDLCursor
    INTO @table_schema,
         @table_name,
         @column_name,
         @data_type,
         @character_maximum_length;
END;

CLOSE DDLCursor;

DEALLOCATE DDLCursor;

SELECT *
FROM   #space;

DROP TABLE #space;
GO

/****************************************************************************************************************************************
--Proper and consistent use of indexes.
First, find all tables without any clustered indexes and/or non-clustered indexes.
If there are more than a handful of very small tables without clustered indexes,
then clustered indexes should be created on them. If the tables will be large and 
have columns used in search arguments, like WHERE clauses or JOIN clauses, then 
indexes should probably be created there too.

Original author, Davide Mauri at http://sqlblog.com/blogs/davide_mauri/archive/2010/08/09/find-all-the-tables-with-no-indexes-at-all.aspx
****************************************************************************************************************************************/
WITH CTE
AS (
SELECT     o.name AS "table_name",
           o.object_id,
           i.index_id,
           i.type,
           i.type_desc
FROM       sys.indexes AS i
INNER JOIN sys.objects AS o
    ON i.object_id = o.object_id
WHERE      o.type IN ( 'U' )
           AND o.is_ms_shipped = 0
           AND i.is_disabled = 0
           AND i.is_hypothetical = 0
           AND i.type <= 2
),
     cte2
AS (
SELECT *
FROM   CTE AS c
    PIVOT
    (
        COUNT(type)
        FOR type_desc IN (HEAP, [CLUSTERED], [NONCLUSTERED])
    ) AS pv
)
SELECT     c2.table_name,
           MAX(p.rows) AS "rows",
           SUM(HEAP) AS "is_heap",
           SUM([CLUSTERED]) AS "is_clustered",
           SUM([NONCLUSTERED]) AS "num_of_nonclustered"
FROM       cte2 AS c2
INNER JOIN sys.partitions AS p
    ON c2.object_id = p.object_id
       AND c2.index_id = p.index_id
GROUP BY   table_name;

/****************************************************************************
-- Proper and consistent use of keys and constraints: Primary Key. This is a 
quick indicator of the VERY WORST sort of database design habits. If your 
vendor doesn't have primary keys, they very likely don't know anything about 
databases. Expect LOTS of other problems!
****************************************************************************/
SELECT T.name AS "Tables without Primary Keys"
FROM   sys.tables AS T
WHERE  OBJECTPROPERTY(object_id, 'TableHasPrimaryKey') = 0
       AND type = 'U';

/*******************************************************************************************
-- Proper and consistent use of keys and constraints: Foreign Keys. 
While not as critical as primary keys, foreign keys are very important for 
defending against insert, update, and delete anomalies on relational database.
Just as bad as having no foreign keys is having foreign keys that are not 
also indexed. 

In a more detailed session, we would look at other types of constraints: 
unique, default, and check. Check out https://msdn.microsoft.com/en-us/library/ms176105.aspx
for details on how to look up tables with those kinds of constraints and check
to see if the columns with those constraints are properly indexed.
*******************************************************************************************/
SELECT T.name AS "Tables without Foreign Keys"
FROM   sys.tables AS T
WHERE  OBJECTPROPERTY(object_id, 'TableHasForeignKey') = 0
       AND type = 'U';

SELECT T.name AS "Tables has Foreign Keys but no Non-clustered indexes"
FROM   sys.tables AS T
WHERE  OBJECTPROPERTY(object_id, 'TableHasForeignKey') = 1
       AND OBJECTPROPERTY(object_id, 'TableHasNonclustIndex') = 0
       AND type = 'U';

/***************************************************************************************
-- Red flags about database design provided by PerfMon counters
Run this query after running a workload, such as in a software POC or after a live demo.

Forwarded records indicate a serious design flaw for the database. $$$
***************************************************************************************/
SELECT   RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
         cntr_type,
         cntr_value
FROM     sys.dm_os_performance_counters
WHERE    counter_name IN ( N'Number of Deadlocks/sec', N'Forwarded Records/sec', N'Full Scans/sec', N'Batch Requests/sec',
                           N'SQL Compilations/sec', N'SQL Re-Compilations/sec'
                         )
ORDER BY object_name + N':' + counter_name + N':' + instance_name;
GO

/***************************************************************************************
-- Lookups
This query shows full table scans and key lookups caused by user activity.
Full table scans are only a problem on large tables, and even then only if they 
happen frequently. Lookups a drag on performs. A few are not unusual, but if a 
vendor app has many of these on many objec ts, it means that database design is 
low quality. 

This query only identifies that they are happening. To fix them, read more at
--http://kendalvandyke.blogspot.com/2010/07/finding-key-lookups-in-cached-execution.html
***************************************************************************************/
SELECT DISTINCT
       DB_NAME(database_id),
       OBJECT_NAME(object_id),
       user_scans,
       user_lookups
FROM   sys.dm_db_index_usage_stats
WHERE  (
           user_scans > 0
           OR user_lookups > 0
       )
       AND database_id = DB_ID();
