-- Identifying oldest active transactions in the system
SELECT TOP (5) at.transaction_id,
             at.elapsed_time_seconds,
             at.session_id,
             s.login_time,
             s.login_name,
             s.host_name,
             s.program_name,
             s.last_request_start_time,
             s.last_request_end_time,
             er.status,
             er.wait_type,
             er.blocking_session_id,
             er.wait_type,
             SUBSTRING (st.text,
                        (er.statement_start_offset / 2) + 1,
                        (CASE er.statement_end_offset
                             WHEN -1 THEN DATALENGTH (st.text)
                             ELSE er.statement_end_offset
                         END - er.statement_start_offset
                        ) / 2 + 1
             ) AS "SQL"
FROM sys.dm_tran_active_snapshot_database_transactions AS at
JOIN sys.dm_exec_sessions AS s
    ON at.session_id = s.session_id
LEFT JOIN sys.dm_exec_requests AS er
    ON at.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) AS st
ORDER BY at.elapsed_time_seconds DESC;