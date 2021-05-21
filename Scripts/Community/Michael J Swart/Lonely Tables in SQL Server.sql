USE DBA;
GO

SELECT qs.query_hash,
       qs.plan_handle,
       CAST(NULL AS XML) AS "query_plan"
INTO #myplans
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_plan_attributes (qs.plan_handle) AS pa
WHERE pa.attribute = 'dbid'
      AND pa.value = DB_ID ();

WITH duplicate_queries AS
(
    SELECT ROW_NUMBER () OVER (PARTITION BY query_hash
ORDER BY (SELECT 1)
                         ) AS "n"
    FROM #myplans
)
DELETE duplicate_queries
WHERE n > 1;

UPDATE #myplans
SET query_plan = qp.query_plan
FROM #myplans AS mp
CROSS APPLY sys.dm_exec_query_plan (mp.plan_handle) AS qp;

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
, my_cte AS
(
    SELECT q.query_hash,
           obj.value ('(@Schema)[1]', 'sysname') AS "schema_name",
           obj.value ('(@Table)[1]', 'sysname') AS "table_name"
    FROM #myplans AS q
    CROSS APPLY q.query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS nodes(stmt)
    CROSS APPLY stmt.nodes ('.//IndexScan/Object') AS index_object(obj)
)
SELECT query_hash,
       schema_name,
       table_name
INTO #myExecutions
FROM my_cte
WHERE schema_name IS NOT NULL
      AND OBJECT_ID (schema_name + '.' + table_name) IN ( SELECT object_id FROM sys.tables )
GROUP BY query_hash,
         schema_name,
         table_name;

WITH multi_table_queries AS
(
    SELECT query_hash
    FROM #myExecutions
    GROUP BY query_hash
    HAVING COUNT (*) > 1
),
     lonely_tables AS
(
    SELECT schema_name,
           table_name
    FROM #myExecutions
    EXCEPT
    SELECT schema_name,
           table_name
    FROM #myExecutions
    WHERE query_hash IN ( SELECT query_hash FROM multi_table_queries )
)
SELECT l.*,
       ps.row_count
FROM lonely_tables AS l
JOIN sys.dm_db_partition_stats AS ps
    ON OBJECT_ID (l.schema_name + '.' + l.table_name) = ps.object_id
WHERE ps.index_id IN ( 0, 1 )
ORDER BY ps.row_count DESC;