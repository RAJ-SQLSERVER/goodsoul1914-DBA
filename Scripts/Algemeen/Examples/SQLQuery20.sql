SELECT plan_handle,
       pvt.set_options,
       pvt.object_id,
       pvt.sql_handle
FROM   (
    SELECT      plan_handle,
                epa.attribute,
                epa.value
    FROM        sys.dm_exec_cached_plans
    OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) AS epa
    WHERE       cacheobjtype = 'Compiled Plan'
) AS ecpa
PIVOT (
    MAX(value)
    FOR attribute IN (set_options, object_id, sql_handle)
) AS pvt;


SELECT      TOP 10
            SUBSTRING(text,
                      (statement_start_offset / 2) + 1,
                      ((CASE statement_end_offset
                            WHEN -1 THEN
                                DATALENGTH(text)
                            ELSE
                                statement_end_offset
                        END - statement_start_offset
                       ) / 2
                      ) + 1
            ) AS query_text,
            *
FROM        sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
ORDER BY    total_elapsed_time DESC;


SELECT      TOP 10
            SUBSTRING(text,
                      (statement_start_offset / 2) + 1,
                      ((CASE statement_end_offset
                            WHEN -1 THEN
                                DATALENGTH(text)
                            ELSE
                                statement_end_offset
                        END - statement_start_offset
                       ) / 2
                      ) + 1
            ) AS query_text,
            *
FROM        sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
ORDER BY    total_elapsed_time / execution_count DESC;



SELECT type AS [plan cache store],
       buckets_count
FROM   sys.dm_os_memory_cache_hash_tables
WHERE  type IN ( 'CACHESTORE_OBJCP', 'CACHESTORE_SQLCP' );
SELECT   type,
         COUNT(*) AS total_entries
FROM     sys.dm_os_memory_cache_entries
WHERE    type IN ( 'CACHESTORE_SQLCP', 'CACHESTORE_OBJCP' )
GROUP BY type;


SELECT      text,
            p.objtype,
            p.refcounts,
            p.usecounts,
            p.size_in_bytes,
            e.disk_ios_count,
            e.context_switches_count,
            --pages_allocated_count,
            e.original_cost,
            e.current_cost
FROM        sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle)
JOIN        sys.dm_os_memory_cache_entries AS e ON p.memory_object_address = e.memory_object_address
WHERE       p.cacheobjtype = 'Compiled Plan'
            AND e.type IN ( 'CACHESTORE_SQLCP', 'CACHESTORE_OBJCP' )
ORDER BY    p.objtype DESC,
            p.usecounts DESC;