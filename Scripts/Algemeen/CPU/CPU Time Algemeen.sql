-- CPU Time Algemeen
-------------------------------------------------------------------------------
SELECT er.session_id,
       es.program_name,
       est.text,
       er.database_id,
       eqp.query_plan,
       er.cpu_time,
       er.last_wait_type
FROM sys.dm_exec_requests AS er
    INNER JOIN sys.dm_exec_sessions AS es
        ON es.session_id = er.session_id
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS est
    OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS eqp
WHERE es.is_user_process = 1
ORDER BY er.cpu_time DESC,
         er.session_id;
GO