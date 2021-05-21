-- Retrieve buffer contents  
IF OBJECT_ID('tempdb..#events') IS NOT NULL
    DROP TABLE #events;
CREATE TABLE #events
(
    event_xml XML
);
INSERT INTO #events
SELECT      CAST(event_data AS XML) AS "xdata"
FROM
            (
                SELECT REPLACE(c.column_value, '.xel', '*.xel') AS "TargetFileName"
                FROM   sys.dm_xe_sessions AS s
                JOIN   sys.dm_xe_session_object_columns AS c
                    ON s.address = c.event_session_address
                WHERE  column_name = 'filename'
                       AND s.name = 'CaptureTSQLErrors'
            ) AS FileTarget
CROSS APPLY sys.fn_xe_file_target_read_file(FileTarget.TargetFileName, NULL, NULL, NULL) AS xft;
-- Unfurl raw data  
SELECT @@SERVERNAME AS "server_name",
       session_events.event_xml.value(N'(event/action[@name="database_name"]/value)[1]', N'SYSNAME') AS "database_name",
       session_events.event_xml.value(N'(event/@name)[1]', N'NVARCHAR(1000)') AS "event_name",
       session_events.event_xml.value(N'(event/@timestamp)[1]', N'DATETIME2(7)') AS "event_timestamp_utc",
       session_events.event_xml.value(N'(event/action[@name="session_id"]/value)[1]', N'INT') AS "session_id",
       session_events.event_xml.value(N'(event/data[@name="error_number"]/value)[1]', N'INT') AS "error_number",
       session_events.event_xml.value(N'(event/data[@name="severity"]/value)[1]', N'INT') AS "severity",
       session_events.event_xml.value(N'(event/data[@name="state"]/value)[1]', N'INT') AS "state",
       session_events.event_xml.value(N'(event/data[@name="category"]/value)[1]', N'INT') AS "category",
       session_events.event_xml.value(N'(event/data[@name="category"]/text)[1]', N'NVARCHAR(MAX)') AS "category_desc",
       session_events.event_xml.value(N'(event/data[@name="message"]/value)[1]', N'NVARCHAR(MAX)') AS "message",
       session_events.event_xml.value(N'(event/action[@name="client_app_name"]/value)[1]', N'NVARCHAR(1000)') AS "client_app_name",
       session_events.event_xml.value(N'(event/action[@name="client_hostname"]/value)[1]', N'NVARCHAR(1000)') AS "client_host_name",
       session_events.event_xml.value(N'(event/action[@name="client_pid"]/value)[1]', N'BIGINT') AS "client_process_id",
       session_events.event_xml.value(N'(event/action[@name="username"]/value)[1]', N'SYSNAME') AS "username",
       session_events.event_xml.value(N'(event/action[@name="sql_text"]/value)[1]', N'NVARCHAR(MAX)') AS "sql_text",
       event_xml
FROM   #events AS session_events;

-- Recreate session to flush buffer  
IF EXISTS
(
    SELECT *
    FROM   sys.server_event_sessions
    WHERE  name = 'CaptureTSQLErrors'
)
BEGIN
    DROP EVENT SESSION CaptureTSQLErrors ON SERVER;
END;

IF NOT EXISTS
(
    SELECT *
    FROM   sys.server_event_sessions
    WHERE  name = 'CaptureTSQLErrors'
)
BEGIN
    -- Create the event session  
    CREATE EVENT SESSION CaptureTSQLErrors
    ON SERVER
        ADD EVENT sqlserver.error_reported
        (ACTION
         (
             sqlserver.client_app_name,
             sqlserver.client_hostname,
             sqlserver.client_pid,
             sqlserver.username,
             sqlserver.database_name,
             sqlserver.nt_username,
             sqlserver.session_id,
             sqlserver.sql_text
         )
         WHERE (package0.equal_boolean(sqlserver.is_system, (0)))
               AND Severity >= (11)
               AND sqlserver.sql_text <> N''
               AND (sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense')
               AND (sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Query')
               AND (sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio')
               AND (sqlserver.client_app_name <> 'SQLServerCEIP')
               AND (sqlserver.client_app_name <> 'check_mssql_health')
               AND (sqlserver.client_app_name <> 'SQL Server Performance Investigator')
        )
        ADD TARGET package0.event_file
        (SET filename = N'CaptureTSQLErrors.xel', max_file_size = (20), max_rollover_files = (5))
    WITH
    (
        MAX_MEMORY = 16MB,
        EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 30 SECONDS,
        MAX_EVENT_SIZE = 0KB,
        MEMORY_PARTITION_MODE = PER_CPU,
        TRACK_CAUSALITY = OFF,
        STARTUP_STATE = ON
    );
END;

-- Start the event session  
IF NOT EXISTS
(
    SELECT *
    FROM   sys.dm_xe_sessions
    WHERE  name = 'CaptureTSQLErrors'
)
BEGIN
    ALTER EVENT SESSION CaptureTSQLErrors ON SERVER STATE = START;
END;