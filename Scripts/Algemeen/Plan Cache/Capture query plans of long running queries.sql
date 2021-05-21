-------------------------------------------------------------------------------
-- Capture query plans of queries that run longer than 1 second
-------------------------------------------------------------------------------

CREATE EVENT SESSION [ExecPlansDuration]
ON SERVER
    ADD EVENT sqlserver.query_post_execution_showplan
    (ACTION
     (
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.nt_username,
         sqlserver.sql_text
     )
     WHERE ([duration] > (1000000))
    )
    ADD TARGET package0.event_file
    (SET filename = N'ExecPlansDuration')
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
);
GO
