-- Active I/O issues?
-- ------------------------------------------------------------------------------------------------

SELECT session_id,
       wait_duration_ms,
       wait_type,
       resource_description
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE N'PAGEIOLATCH%'
      OR wait_type IN ( N'IO_COMPLETION', N'WRITELOG', N'ASYNC_IO_COMPLETION' );
GO