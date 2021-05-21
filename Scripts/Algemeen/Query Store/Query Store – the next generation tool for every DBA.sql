-------------------------------------------------------------------------------
-- Top 5 queries with the longest average execution time the last hour
-------------------------------------------------------------------------------
SELECT TOP (5)
       rs.avg_duration,
       qt.query_sql_text,
       rs.last_execution_time
FROM sys.query_store_query_text AS qt
    RIGHT JOIN sys.query_store_query AS q
        ON qt.query_text_id = q.query_text_id
    RIGHT JOIN sys.query_store_plan AS p
        ON q.query_id = p.query_id
    RIGHT JOIN sys.query_store_runtime_stats AS rs
        ON p.plan_id = rs.plan_id
WHERE 1 = 1
      AND rs.last_execution_time > DATEADD(HOUR, -1, GETUTCDATE())
ORDER BY rs.avg_duration DESC;
GO

-------------------------------------------------------------------------------
-- Last 10 queries executed on the server
-------------------------------------------------------------------------------
SELECT TOP 10 qt.query_sql_text, q.query_id, 
    qt.query_text_id, p.plan_id, rs.last_execution_time
FROM sys.query_store_query_text AS qt 
JOIN sys.query_store_query AS q 
    ON qt.query_text_id = q.query_text_id 
JOIN sys.query_store_plan AS p 
    ON q.query_id = p.query_id 
JOIN sys.query_store_runtime_stats AS rs 
    ON p.plan_id = rs.plan_id
ORDER BY rs.last_execution_time DESC;
GO

-------------------------------------------------------------------------------
-- Queries with more than one execution plan
-------------------------------------------------------------------------------
SELECT q.query_id,
       qt.query_sql_text,
       p.query_plan AS plan_xml,
       p.last_execution_time
FROM
(
    SELECT COUNT(*) AS count,
           q.query_id
    FROM sys.query_store_query_text AS qt
        JOIN sys.query_store_query AS q
            ON qt.query_text_id = q.query_text_id
        JOIN sys.query_store_plan AS p
            ON p.query_id = q.query_id
    GROUP BY q.query_id
    HAVING COUNT(DISTINCT plan_id) > 1
) AS qm
    JOIN sys.query_store_query AS q
        ON qm.query_id = q.query_id
    JOIN sys.query_store_plan AS p
        ON q.query_id = p.query_id
    JOIN sys.query_store_query_text qt
        ON qt.query_text_id = q.query_text_id
ORDER BY query_id,
         plan_id;
GO

