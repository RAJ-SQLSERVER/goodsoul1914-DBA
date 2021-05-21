USE AdventureWorks;
GO

/*
DROP TABLE #myplans
DROP TABLE #myExecutions
*/

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
                         ) AS "r"
    FROM #myplans
)
DELETE duplicate_queries
WHERE r > 1;

UPDATE #myplans
SET query_plan = qp.query_plan
FROM #myplans AS mp
CROSS APPLY sys.dm_exec_query_plan (mp.plan_handle) AS qp;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
, mycte AS
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
FROM mycte
WHERE schema_name IS NOT NULL
      AND OBJECT_ID (schema_name + '.' + table_name) IN ( SELECT object_id FROM sys.tables )
GROUP BY query_hash,
         schema_name,
         table_name;

SELECT DISTINCT A.table_name AS "first_table",
                B.table_name AS "second_table"
FROM #myExecutions AS A
JOIN #myExecutions AS B
    ON A.query_hash = B.query_hash
WHERE A.table_name < B.table_name;