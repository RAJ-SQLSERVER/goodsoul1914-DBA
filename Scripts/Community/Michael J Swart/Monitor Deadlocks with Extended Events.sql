-- Create The Session
CREATE EVENT SESSION capture_deadlocks
ON SERVER
    ADD EVENT sqlserver.xml_deadlock_report
    (ACTION (sqlserver.database_name))
    ADD TARGET package0.asynchronous_file_target
    (SET filename = 'capture_deadlocks.xel', max_file_size = 10, max_rollover_files = 5)
WITH (
    STARTUP_STATE = ON,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 15 SECONDS,
    TRACK_CAUSALITY = OFF
);

ALTER EVENT SESSION capture_deadlocks ON SERVER STATE = START;


-- Query the Results
DECLARE @filenamePattern sysname;

SELECT @filenamePattern = REPLACE (CAST(field.value AS sysname), '.xel', '*xel')
FROM sys.server_event_sessions AS session
JOIN sys.server_event_session_targets AS target
    ON session.event_session_id = target.event_session_id
JOIN sys.server_event_session_fields AS field
    ON field.event_session_id = target.event_session_id
       AND field.object_id = target.target_id
WHERE field.name = 'filename'
      AND session.name = N'capture_deadlocks';

SELECT deadlockData.*
FROM sys.fn_xe_file_target_read_file (@filenamePattern, NULL, NULL, NULL) AS event_file_value
CROSS APPLY (SELECT CAST(event_file_value.event_data AS XML)) AS event_file_value_xml(xml)
CROSS APPLY (
    SELECT event_file_value_xml.xml.value ('(event/data/value/deadlock/process-list/process/@spid)[1]', 'int') AS "first_process_spid",
           event_file_value_xml.xml.value ('(event/@name)[1]', 'varchar(100)') AS "eventName",
           event_file_value_xml.xml.value ('(event/@timestamp)[1]', 'datetime') AS "eventDate",
           event_file_value_xml.xml.query ('//event/data/value/deadlock') AS "deadlock"
) AS deadlockData
WHERE deadlockData.eventName = 'xml_deadlock_report'
ORDER BY eventDate DESC;