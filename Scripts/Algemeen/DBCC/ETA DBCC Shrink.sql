-------------------------------
-- Track DBCC shrink status
-------------------------------
SELECT a.session_id,
       a.command,
       b.text,
       a.percent_complete,
       a.estimated_completion_time / 1000 / 60 AS done_in_minutes,
       DATEDIFF (MI, a.start_time, DATEADD (ms, a.estimated_completion_time, GETDATE ())) AS min_in_progress,
       a.start_time,
       DATEADD (ms, a.estimated_completion_time, GETDATE ()) AS estimated_completion_time
FROM sys.dm_exec_requests AS a
CROSS APPLY sys.dm_exec_sql_text (a.sql_handle) AS b
WHERE a.command LIKE '%dbcc%';
GO

