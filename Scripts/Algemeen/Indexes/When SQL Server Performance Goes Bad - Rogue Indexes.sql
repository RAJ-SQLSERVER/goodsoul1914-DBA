
-------------------------------------------------------------------------------
-- Missing index details
-------------------------------------------------------------------------------
SELECT DB_NAME(mid.database_id) + '.' + OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) + '.'
       + OBJECT_NAME(mid.object_id, mid.database_id) AS [TheTable],
       migs.user_seeks AS [Index Uses (est)], /* Number of seeks caused by user queries that the recommended index in the group could have been used for. */
       migs.avg_user_impact [benefit % (est,Percent)],/* Average percentage benefit that user queries could experience if this missing index group was implemented. The value means that the query cost would on average drop by this percentage if this missing index group was implemented. */
       CONVERT(NUMERIC(5, 2), migs.avg_total_user_cost) [Avg Query Cost (est)], /* Average cost of the user queries that could be reduced by the index in the group.*/
       migs.unique_compiles, /* Number of compilations and recompilations that would benefit from this missing index group. Compilations and recompilations of many different queries can contribute to this column value. */
       CONVERT(CHAR(20), migs.last_user_seek, 113) AS [last user seek],
       'CREATE INDEX [IX_' + OBJECT_NAME(mid.object_id, mid.database_id) + '_'
       + REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns, ''), ', ', '_'), '[', ''), ']', '')
       + CASE
             WHEN mid.equality_columns IS NOT NULL
                  AND mid.inequality_columns IS NOT NULL THEN
                 '_'
             ELSE
                 ''
         END + REPLACE(REPLACE(REPLACE(ISNULL(mid.inequality_columns, ''), ', ', '_'), '[', ''), ']', '') + ']'
       + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '')
       + CASE
             WHEN mid.equality_columns IS NOT NULL
                  AND mid.inequality_columns IS NOT NULL THEN
                 ','
             ELSE
                 ''
         END + ISNULL(mid.inequality_columns, '') + ')'
       + ISNULL(
                   ' INCLUDE (' + mid.included_columns
                   + ') WITH (MAXDOP =?, FILLFACTOR=?, ONLINE=?, SORT_IN_TEMPDB=?);',
                   ''
               ) AS [TSQL to create index]
FROM sys.dm_db_missing_index_group_stats AS migs
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid
        ON mig.index_handle = mid.index_handle
ORDER BY [Index Uses (est)] DESC;
GO


-------------------------------------------------------------------------------
-- Missing indexes on Foreign Keys
-------------------------------------------------------------------------------
SELECT OBJECT_SCHEMA_NAME(keys.parent_object_id) + '.' + OBJECT_NAME(keys.parent_object_id) AS "Table",
       keys.name AS Foreign_Key,
       STRING_AGG(COL_NAME(keys.parent_object_id, Columns.constraint_column_id), ',') AS "ColumnList"
FROM sys.foreign_keys AS keys
    INNER JOIN sys.foreign_key_columns AS "Columns"
        ON keys.object_id = Columns.constraint_object_id
    LEFT OUTER JOIN sys.index_columns AS ic
        ON ic.object_id = Columns.parent_object_id
           AND ic.column_id = Columns.parent_column_id
           AND Columns.constraint_column_id = ic.key_ordinal
WHERE ic.object_id IS NULL
GROUP BY keys.parent_object_id,
         keys.name;
GO


-------------------------------------------------------------------------------
-- Finding Unused Indexes
-------------------------------------------------------------------------------
SELECT TOP (20)
       OBJECT_SCHEMA_NAME(si.object_id) + '.' + OBJECT_NAME(si.object_id) AS "Table",
       si.name AS "Index",
       COALESCE(s.user_lookups, 0) + COALESCE(s.user_scans, 0) + COALESCE(s.user_seeks, 0) AS activity,
       COALESCE(s.user_updates, 0) AS updates /* Number of updates by user queries. This includes Insert, Delete, and Updates representing number of operations done not the actual rows affected. For example, if you delete 1000 rows in one statement, this count increments by 1 */
FROM sys.indexes si
    LEFT OUTER JOIN sys.dm_db_index_usage_stats s
        ON s.object_id = si.object_id
           AND s.index_id = si.index_id
           AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(si.object_id, 'IsUserTable') = 1
      AND si.index_id > 0 -- Exclude heaps.
      AND si.is_primary_key = 0 -- Exclude primary keys.
      AND si.is_unique = 0 -- Exclude unique constraints.
--AND coalesce(s.user_updates, 0) > 0 -- Index is being updated.
ORDER BY activity ASC;
GO


-------------------------------------------------------------------------------
-- Detailed view of the usage of indexes
-------------------------------------------------------------------------------
SELECT OBJECT_SCHEMA_NAME(IndexOpStats.object_id) + '.' + OBJECT_NAME(IndexOpStats.object_id) AS TableName,
       si.name AS IndexName,
       LOWER(si.type_desc) AS IndexType,
       SUM(PartitionStats.used_page_count) * 8 AS IndexSizeInKB,
       SUM(IndexOpStats.leaf_insert_count) AS InsertCount,
       SUM(IndexOpStats.leaf_update_count) AS UpdateCount,
       SUM(IndexOpStats.leaf_delete_count) AS DeleteCount
FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL) IndexOpStats -- (Database_id, Object_id, index_id, Partition_id)
    INNER JOIN sys.indexes AS si
        ON si.object_id = IndexOpStats.object_id
           AND si.index_id = IndexOpStats.index_id
    INNER JOIN sys.dm_db_partition_stats PartitionStats
        ON PartitionStats.object_id = si.object_id
WHERE OBJECTPROPERTY(si.[object_id], 'IsUserTable') = 1
GROUP BY IndexOpStats.object_id,
         si.name,
         si.type_desc;
GO


-------------------------------------------------------------------------------
-- Duplicate indexes
-------------------------------------------------------------------------------
SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + OBJECT_NAME(object_id) AS "Table",
       COUNT(*) AS "Similar",
       ColumnList AS "Column",
       MAX(name) + ', ' + MIN(name) AS "Duplicates"
FROM
(
    SELECT object_id,
           name,
           STUFF(
                    (
                        SELECT ', ' + COL_NAME(sc.object_id, sc.column_id)
                        FROM sys.stats_columns sc
                        WHERE sc.object_id = s.object_id
                              AND sc.stats_id = s.stats_id
                        ORDER BY stats_column_id ASC
                        FOR XML PATH(''), TYPE
                    ).value('.', 'varchar(max)'), --get a list of columns
                    1,
                    2,
                    ''
                ) AS ColumnList
    FROM sys.stats s
) f
WHERE OBJECTPROPERTYEX(f.object_id, N'IsUserTable') <> 0
GROUP BY object_id,
         ColumnList
HAVING COUNT(*) > 1;
GO


-------------------------------------------------------------------------------
-- See if two indexes share a column list
-------------------------------------------------------------------------------
SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + OBJECT_NAME(object_id) AS "Table",
       COUNT(*) AS "Similar",
       ColumnList AS "Columns",
       STRING_AGG(name, ',') AS "Duplicates"
FROM
(
    SELECT s.object_id,
           s.name,
           (
               SELECT STRING_AGG(COL_NAME(sc.object_id, sc.column_id), ',') WITHIN GROUP(ORDER BY key_ordinal) AS TheColumns -- order them by the column name to assume that they are the same regardless of order.
               FROM sys.index_columns sc
               WHERE sc.object_id = s.object_id
                     AND sc.index_id = s.index_id
           ) AS ColumnList
    FROM sys.indexes s
        LEFT OUTER JOIN sys.xml_indexes xi
            ON xi.index_id = s.index_id
               AND xi.object_id = s.object_id
    WHERE xi.index_id IS NULL -- eliminate XML indexes from list
) f
WHERE OBJECTPROPERTYEX(f.object_id, N'IsUserTable') <> 0 -- we only want the user tables.
GROUP BY f.object_id,
         ColumnList
HAVING COUNT(*) > 1; -- if a table has more than one index with the same column list
GO


-------------------------------------------------------------------------------
-- Check fragmentation of indexes
-------------------------------------------------------------------------------
SELECT COALESCE(OBJECT_SCHEMA_NAME(si.object_id) + '.', '') + COALESCE(OBJECT_NAME(si.object_id) + '/', '')
       + COALESCE(si.name, 'Heap') AS "table_name/index_name",
       STR(IPS.avg_fragmentation_in_percent, 10, 1) AS [avg_fragmentation_%],
       STR(IPS.avg_page_space_used_in_percent, 10, 1) AS [avg_page_space_used_%],
       si.fill_factor,
       STR((IPS.avg_record_size_in_bytes * IPS.record_count) / (1024.0 * 1024), 10, 2) AS [index_size_mb]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'Sampled') AS IPS
    INNER JOIN sys.indexes si
        ON si.index_id = IPS.index_id
           AND si.object_id = IPS.object_id
WHERE OBJECTPROPERTY(si.object_id, 'IsUserTable') = 1
      AND IPS.index_level = 0 -- leaf level
ORDER BY [index_size_mb] DESC;
GO

