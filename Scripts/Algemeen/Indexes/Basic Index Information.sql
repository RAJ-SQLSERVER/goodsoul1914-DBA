-------------------------------------------------------------------------------
-- Basic information about indexes
-------------------------------------------------------------------------------
SELECT TOP (2147483647) s.name AS "schema_name",
                        OBJECT_NAME (ps.object_id) AS "table_name",
                        i.name AS "index_name",
                        ps.row_count,
                        ps.in_row_used_page_count,
                        ps.reserved_page_count * 8. / 1024. AS "reserved_MB",
                        ps.lob_reserved_page_count * 8. / 1024. AS "reserved_LOB_MB",
                        ps.row_overflow_reserved_page_count * 8. / 1024. AS "reserved_row_overflow_MB"
FROM sys.dm_db_partition_stats AS ps
JOIN sys.objects AS so
    ON ps.object_id = so.object_id
       AND so.is_ms_shipped = 0
       AND so.type <> 'TF'
JOIN sys.schemas AS s
    ON s.schema_id = so.schema_id
JOIN sys.indexes AS i
    ON ps.object_id = i.object_id
       AND ps.index_id = i.index_id
ORDER BY ps.object_id,
         ps.index_id,
         ps.partition_number;