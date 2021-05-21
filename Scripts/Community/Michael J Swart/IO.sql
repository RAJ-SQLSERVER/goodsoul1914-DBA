;WITH high_io_queries AS
(
    SELECT TOP 20 query_hash,
                  SUM (total_logical_reads + total_logical_writes) AS "io"
    FROM sys.dm_exec_query_stats
    WHERE query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM (total_logical_reads + total_logical_writes) DESC
)
SELECT @@servername AS "servername",
       COALESCE (DB_NAME (st.dbid), DB_NAME (CAST(pa.value AS INT)), 'Resource') AS "DatabaseName",
       COALESCE (OBJECT_NAME (st.objectid, st.dbid), '<none>') AS "object_name",
       qs.query_hash,
       qs.total_logical_reads + total_logical_writes AS "total_io",
       qs.execution_count,
       CAST((total_logical_reads + total_logical_writes) / (execution_count + 0.0) AS MONEY) AS "average_io",
       io AS "total_io_for_query",
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
JOIN high_io_queries AS fq
    ON fq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes (qs.plan_handle) AS pa
WHERE pa.attribute = 'dbid'
ORDER BY fq.io DESC,
         fq.query_hash,
         qs.total_logical_reads + total_logical_writes DESC
OPTION (RECOMPILE);