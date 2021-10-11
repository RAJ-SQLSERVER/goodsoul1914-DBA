-- Set up the demo by running the code in the
-- C:\Temp\SetupWorkload.sql file

-- Now start the workload by double-clicking the
-- file C:\Temp\Add50Clients.cmd

-- Look at Waiting Tasks

USE HotSpot;
GO

ALTER INDEX HotSpotTable_CL ON HotSpotTable SET (ALLOW_ROW_LOCKS = OFF);
GO

-- Look at Waiting Tasks

ALTER INDEX HotSpotTable_CL ON HotSpotTable SET (ALLOW_ROW_LOCKS = ON);
GO

-- Look at Waiting Tasks
       owt.exec_context_id,
       owt.wait_duration_ms,
       owt.wait_type,
       owt.blocking_session_id,
       owt.resource_description,
       es.program_name,
       est.text,
       est.dbid,
       eqp.query_plan,
       es.cpu_time,
       es.memory_usage
FROM sys.dm_os_waiting_tasks AS owt
INNER JOIN sys.dm_exec_sessions AS es
    ON owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests AS er
    ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) AS est
OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) AS eqp
WHERE es.is_user_process = 1
ORDER BY owt.session_id,
         owt.exec_context_id;
GO

BEGIN TRAN;
GO
UPDATE HotSpotTable
SET c2 = 2;
GO

-- Look at Waiting Tasks

COMMIT TRAN;
GO

-- Look at Waiting Tasks

-- Now stop the workload by double-clicking the
-- file C:\Temp\StopWorkload.cmd

USE master;
GO

IF DATABASEPROPERTYEX (N'HotSpot', N'Version') > 0
BEGIN
    ALTER DATABASE HotSpot SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HotSpot;
END;
GO