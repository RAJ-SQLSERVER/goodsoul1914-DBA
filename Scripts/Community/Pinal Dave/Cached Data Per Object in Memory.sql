SELECT COUNT (1) * 8 / 1024 AS "MBUsed",
       OBJECT_SCHEMA_NAME (object_id) AS "SchemaName",
       name AS "TableName",
       index_id
FROM sys.dm_os_buffer_descriptors AS bd
INNER JOIN (
    SELECT OBJECT_NAME (object_id) AS "name",
           index_id,
           allocation_unit_id,
           object_id
    FROM sys.allocation_units AS au
    INNER JOIN sys.partitions AS p
        ON au.container_id = p.hobt_id
           AND (au.type = 1 OR au.type = 3)
    UNION ALL
    SELECT OBJECT_NAME (object_id) AS "name",
           index_id,
           allocation_unit_id,
           object_id
    FROM sys.allocation_units AS au
    INNER JOIN sys.partitions AS p
        ON au.container_id = p.partition_id
           AND au.type = 2
) AS obj
    ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = DB_ID ()
GROUP BY OBJECT_SCHEMA_NAME (object_id),
         name,
         index_id
ORDER BY COUNT (*) * 8 / 1024 DESC;
GO