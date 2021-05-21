;WITH long_queries AS
(
    SELECT TOP 20 query_hash,
                  SUM (total_elapsed_time) AS "elapsed_time"
    FROM sys.dm_exec_query_stats
    WHERE query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM (total_elapsed_time) DESC
)
SELECT @@servername AS "server_name",
       COALESCE (DB_NAME (st.dbid), DB_NAME (CAST(pa.value AS INT)), 'Resource') AS "DatabaseName",
       COALESCE (OBJECT_NAME (st.objectid, st.dbid), '<none>') AS "object_name",
       qs.query_hash,
       qs.total_elapsed_time,
       qs.execution_count,
       CAST(total_elapsed_time / (execution_count + 0.0) AS MONEY) AS "average_duration_in_ms",
       elapsed_time AS "total_elapsed_time_for_query",
       SUBSTRING (
           st.text,
           (qs.statement_start_offset + 2) / 2,
           (CASE
                WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text)) * 2
                ELSE qs.statement_end_offset
            END - qs.statement_start_offset
           ) / 2
       ) AS "sql_text",
       qp.query_plan
FROM sys.dm_exec_query_stats AS qs
JOIN long_queries AS lq
    ON lq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes (qs.plan_handle) AS pa
WHERE pa.attribute = 'dbid'
ORDER BY lq.elapsed_time DESC,
         lq.query_hash,
         qs.total_elapsed_time DESC
OPTION (RECOMPILE);