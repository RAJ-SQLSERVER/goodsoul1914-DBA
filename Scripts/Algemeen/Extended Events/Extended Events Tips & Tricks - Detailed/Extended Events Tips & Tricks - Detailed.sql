CREATE EVENT SESSION [Query_Stats]
ON SERVER
    ADD EVENT sqlserver.sp_statement_completed
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.nt_username,
         sqlserver.session_id,
         sqlserver.sql_text
     )
    ),
    ADD EVENT sqlserver.sp_statement_starting
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.nt_username,
         sqlserver.session_id,
         sqlserver.sql_text
     )
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.nt_username,
         sqlserver.session_id,
         sqlserver.sql_text
     )
    ),
    ADD EVENT sqlserver.sql_batch_starting
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.nt_username,
         sqlserver.session_id,
         sqlserver.sql_text
     )
    ),
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.nt_username,
         sqlserver.session_id,
         sqlserver.sql_text
     )
    )
    ADD TARGET package0.ring_buffer
    (SET max_memory = (2097152))
WITH
(
    STARTUP_STATE = ON
);
GO



/* Run workloads */
USE AdventureWorks
GO

WHILE 1 = 1
BEGIN
    EXEC dbo.uspGetEmployeeManagers @BusinessEntityID = 12;
    WAITFOR DELAY '00:00:10';
END;
