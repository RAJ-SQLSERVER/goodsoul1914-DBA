/*
Author: Nagaraj
Original link: http://www.sqlservercentral.com/blogs/sql-and-sql-only/2016/08/07/current-running-queries/
*/

SELECT GETDATE () AS "dt",
       ss.session_id,
       DB_NAME (sp.dbid) AS "dbname",
       er.status AS "req_status",
       ss.login_name,
       cs.client_net_address,
       ss.program_name,
       sp.open_tran,
       er.blocking_session_id,
       ss.host_name,
       ss.client_interface_name,
       eqp.query_plan AS "qplan",
       SUBSTRING (
           est.text,
           (er.statement_start_offset / 2) + 1,
           CASE
               WHEN er.statement_end_offset = -1
                    OR er.statement_end_offset = 0 THEN (DATALENGTH (est.text) - er.statement_start_offset / 2) + 1
               ELSE (er.statement_end_offset - er.statement_start_offset) / 2 + 1
           END
       ) AS "req_query_text",
       er.granted_query_memory,
       er.logical_reads AS "req_logical_reads",
       er.cpu_time AS "req_cpu_time",
       er.reads AS "req_physical_reads",
       er.row_count AS "req_row_count",
       er.scheduler_id,
       er.total_elapsed_time AS "req_elapsed_time",
       er.start_time AS "req_start_time",
       er.percent_complete,
       er.wait_resource AS "wait_resource",
       er.wait_type AS "req_waittype",
       er.wait_time AS "req_wait_time",
       wait.wait_duration_ms AS "blocking_time_ms",
       lock.resource_associated_entity_id,
       lock.request_status AS "lock_request_status",
       lock.request_mode AS "lock_mode",
       er.writes AS "req_writes",
       sp.lastwaittype,
       fn_sql.text AS "session_query",
       ss.status AS "session_status",
       ss.cpu_time AS "session_cpu_time",
       ss.reads AS "session_reads",
       ss.writes AS "session_writes",
       ss.logical_reads AS "session_logical_reads",
       ss.memory_usage AS "session_memory_usage",
       ss.last_request_start_time,
       ss.last_request_end_time,
       ss.total_scheduled_time AS "session_scheduled_time",
       ss.total_elapsed_time AS "session_elpased_time",
       ss.row_count AS "session_rowcount"
FROM sys.dm_exec_sessions AS ss
INNER JOIN sys.dm_exec_connections AS cs
    ON ss.session_id = cs.session_id
OUTER APPLY fn_get_sql (cs.most_recent_sql_handle) AS fn_sql
INNER JOIN sys.sysprocesses AS sp
    ON sp.spid = cs.session_id
LEFT OUTER JOIN sys.dm_exec_requests AS er
    ON er.session_id = ss.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) AS est
OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) AS eqp
LEFT OUTER JOIN sys.dm_os_waiting_tasks AS wait
    ON er.session_id = wait.session_id
       AND wait.wait_type LIKE 'LCK%'
       AND er.blocking_session_id = wait.blocking_session_id
LEFT OUTER JOIN sys.dm_tran_locks AS lock
    ON lock.lock_owner_address = wait.resource_address
       AND lock.request_session_id = er.blocking_session_id
WHERE ss.status <> 'sleeping'
      AND ss.session_id <> @@SPID;
