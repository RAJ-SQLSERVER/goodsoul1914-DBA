SELECT  os.forwarded_fetch_count ,
        command = N'ALTER TABLE ' + QUOTENAME(DB_NAME(os.database_id)) + N'.'
        + QUOTENAME(OBJECT_SCHEMA_NAME(os.object_id, os.database_id)) + N'.'
        + QUOTENAME(OBJECT_NAME(os.object_id, os.database_id)) + N' REBUILD WITH (ONLINE = ON);' ,
        heap_size_mb = CAST(ps.reserved_page_count * 8. / 1024. AS BIGINT) ,
        nonclustered_indexes = ( SELECT COUNT(DISTINCT i.index_id)
                                 FROM   sys.indexes i
                                 WHERE  os.object_id = i.object_id
                                        AND i.index_id <> 0
                                        AND i.is_disabled = 0
                                        AND i.is_hypothetical = 0
                               )
FROM    sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) os
        INNER JOIN sys.dm_db_partition_stats ps ON ps.object_id = os.object_id
                                                   AND ps.index_id = os.index_id
                                                   AND ps.partition_number = os.partition_number
WHERE   os.index_id = 0
        AND os.forwarded_fetch_count > 0
ORDER BY os.forwarded_fetch_count DESC
