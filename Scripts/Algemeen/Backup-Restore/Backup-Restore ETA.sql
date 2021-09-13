/* When will the currently running backup/restore job be finished? */
SELECT r.session_id AS "SessionId",
       r.command AS "Command",
       CONVERT (NUMERIC(6, 2), r.percent_complete) AS "% Complete",
       CONVERT (VARCHAR(20), DATEADD (ms, r.estimated_completion_time, GETDATE ()), 20) AS "ETA",
       CONVERT (NUMERIC(6, 2), r.total_elapsed_time / 1000.0 / 60.0) AS "Elapsed_Min",
       CONVERT (NUMERIC(6, 2), r.estimated_completion_time / 1000.0 / 60.0) AS "ETA_Min",
       CONVERT (NUMERIC(6, 2), r.estimated_completion_time / 1000.0 / 60.0 / 60.0) AS "ETA_Hrs",
       CONVERT (
           VARCHAR(100),
       (
           SELECT SUBSTRING (
                      text,
                      r.statement_start_offset / 2,
                      CASE
                          WHEN r.statement_end_offset = -1 THEN 1000
                          ELSE (r.statement_end_offset - r.statement_start_offset) / 2
                      END
                  )
           FROM sys.dm_exec_sql_text (sql_handle)
       )
       ) AS "Stmt"
FROM sys.dm_exec_requests AS r
WHERE Command IN ( 'RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'ALTER TABLE' );
GO