/*
 Fastest Way to Retrieve Rowcount for a Table
*/

SELECT SCHEMA_NAME(t.schema_id) SchemaName,
       t.[name] TableName,
       SUM(p.row_count) TotalRows
FROM sys.tables t
    INNER JOIN sys.dm_db_partition_stats p
        ON t.object_id = p.object_id
           AND t.type_desc = 'USER_TABLE'
           AND p.index_id IN ( 0, 1 )
-- WHERE t.[name] = 'Invoices'
GROUP BY t.schema_id,
         t.[name]
ORDER BY TotalRows DESC;