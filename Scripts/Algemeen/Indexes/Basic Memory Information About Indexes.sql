-------------------------------------------------------------------------------
--	Basic memory information about indexes
-------------------------------------------------------------------------------
SELECT TOP (2147483647) DB_NAME () AS "database_name",
                        SCHEMA_NAME (o.schema_id) AS "schema_name",
                        o.name AS "object_name",
                        i.name AS "index_name",
                        SUM (CASE WHEN au.type IN ( 1, 3 ) THEN 1 ELSE 0 END) * 8. / 1024. AS "in_row_pages_mb",
                        SUM (CASE WHEN au.type = 2 THEN 1 ELSE 0 END) * 8. / 1024. AS "lob_pages_mb",
                        COUNT_BIG (*) * 8. / 1024. AS "total_pages_mb",
                        COUNT_BIG (*) AS "buffer_cache_pages_total"
FROM sys.dm_os_buffer_descriptors AS obd
INNER JOIN sys.allocation_units AS au
    ON au.allocation_unit_id = obd.allocation_unit_id
INNER JOIN sys.partitions AS p
    ON au.container_id = p.hobt_id
       AND au.type IN ( 1, 3 )
       OR au.container_id = p.partition_id
          AND au.type IN ( 2 )
INNER JOIN sys.objects AS o
    ON p.object_id = o.object_id
INNER JOIN sys.indexes AS i
    ON o.object_id = i.object_id
       AND p.index_id = i.index_id
WHERE au.type > 0
      AND o.is_ms_shipped = 0
      AND obd.database_id = DB_ID ()
GROUP BY SCHEMA_NAME (o.schema_id),
         i.name,
         o.name
ORDER BY COUNT (*) DESC;
GO
