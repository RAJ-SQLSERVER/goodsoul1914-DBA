-- Query to create wait-time table
SELECT r.session_id,
       r.wait_time,
       r.status,
       r.wait_type,
       r.blocking_session_id,
       s.text,
       r.statement_start_offset,
       r.statement_end_offset,
       p.query_plan,
       CURRENT_TIMESTAMP AS "time_polled"
INTO rta_data
FROM sys.dm_exec_requests AS r
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) AS s
OUTER APPLY sys.dm_exec_text_query_plan (r.plan_handle, r.statement_start_offset, r.statement_end_offset) AS p
WHERE r.status <> 'background'
      AND r.status <> 'sleeping'
      AND r.session_id <> @@SPID;
GO

-- Query to automate INSERT
INSERT INTO rta_data
SELECT r.session_id,
       r.wait_time,
       r.status,
       r.wait_type,
       r.blocking_session_id,
       s.text,
       r.statement_start_offset,
       r.statement_end_offset,
       p.query_plan,
       CURRENT_TIMESTAMP AS "time_polled"
FROM sys.dm_exec_requests AS r
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) AS s
OUTER APPLY sys.dm_exec_text_query_plan (r.plan_handle, r.statement_start_offset, r.statement_end_offset) AS p
WHERE r.status <> 'background'
      AND r.status <> 'sleeping'
      AND r.session_id <> @@SPID;
GO

-- Query for CTE
WITH rta (sql_text, wait_type, time_in_second) AS
(
    SELECT text AS "sql_text",
           wait_type,
           COUNT (*) AS "time_in_second"
    FROM rta_data AS rta
    GROUP BY text,
             wait_type
),
     tot (text, tot_time) AS (SELECT text, COUNT (*) AS "tot_time" FROM rta_data GROUP BY text)
SELECT sql_text,
       wait_type,
       time_in_second,
       tot_time
FROM rta
JOIN tot
    ON sql_text = text
ORDER BY tot_time,
         time_in_second,
         wait_type,
         sql_text;