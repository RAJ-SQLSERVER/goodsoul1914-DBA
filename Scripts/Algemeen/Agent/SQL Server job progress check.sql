SELECT D.text,
       Re.status,
       Re.command,
       DB_NAME(Re.database_id) DatabaseName,
       Re.cpu_time,
       Re.total_elapsed_time,
       Re.percent_complete
FROM sys.dm_exec_requests Re
    CROSS APPLY sys.dm_exec_sql_text(Re.sql_handle) D;
GO
