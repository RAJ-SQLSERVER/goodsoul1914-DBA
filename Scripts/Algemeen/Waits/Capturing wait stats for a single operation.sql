-- Drop the session if it exists.
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'MonitorWaits')
    DROP EVENT SESSION MonitorWaits ON SERVER;
GO

CREATE EVENT SESSION MonitorWaits
ON SERVER
    ADD EVENT sqlos.wait_info
    (WHERE sqlserver.session_id = 86 /* session_id of connection to monitor */)
    ADD TARGET package0.asynchronous_file_target
    (SET FILENAME = N'C:\Temp\EE_WaitStats.xel', METADATAFILE = N'C:\Temp\EE_WaitStats.xem')
WITH (MAX_DISPATCH_LATENCY = 1 SECONDS);
GO


-- You can also filter out any wait types you're not interested in by adding another predicate to the session that filters on the sqlos.wait_type. 
-- You'll need to specify numbers, and you can list the mapping between numbers and human-understandable wait types using this code:
SELECT xmv.map_key,
       xmv.map_value
FROM sys.dm_xe_map_values AS xmv
JOIN sys.dm_xe_packages AS xp
    ON xmv.object_package_guid = xp.guid
WHERE xmv.name = 'wait_types'
      AND xp.name = 'sqlos';
GO


-- Start the session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = START;
GO

-- Go do your query

-- Stop the event session
ALTER EVENT SESSION MonitorWaits ON SERVER STATE = STOP;
GO


-- How many events fired:
SELECT COUNT (*)
FROM sys.fn_xe_file_target_read_file ('C:\Temp\EE_WaitStats*.xel', 'C:\Temp\EE_WaitStats*.xem', NULL, NULL);
GO


-- Create intermediate temp table for raw event data
CREATE TABLE #RawEventData (Rowid INT IDENTITY PRIMARY KEY, event_data XML);
GO

-- Read the file data into intermediate temp table
INSERT INTO #RawEventData (event_data)
SELECT CAST(event_data AS XML) AS "event_data"
FROM sys.fn_xe_file_target_read_file ('C:\Temp\EE_WaitStats*.xel', 'C:\Temp\EE_WaitStats*.xem', NULL, NULL);
GO

SELECT waits.[Wait Type],
       COUNT (*) AS "Wait Count",
       SUM (waits.Duration) AS "Total Wait Time (ms)",
       SUM (waits.Duration) - SUM (waits.[Signal Duration]) AS "Total Resource Wait Time (ms)",
       SUM (waits.[Signal Duration]) AS "Total Signal Wait Time (ms)"
FROM (
    SELECT event_data.value ('(/event/@timestamp)[1]', 'DATETIME') AS "Time",
           event_data.value ('(/event/data[@name=''wait_type'']/text)[1]', 'VARCHAR(100)') AS "Wait Type",
           event_data.value ('(/event/data[@name=''opcode'']/text)[1]', 'VARCHAR(100)') AS "Op",
           event_data.value ('(/event/data[@name=''duration'']/value)[1]', 'BIGINT') AS "Duration",
           event_data.value ('(/event/data[@name=''signal_duration'']/value)[1]', 'BIGINT') AS "Signal Duration"
    FROM #RawEventData
) AS waits
WHERE waits.Op = 'End'
GROUP BY waits.[Wait Type]
ORDER BY [Total Wait Time (ms)] DESC;
GO

-- Cleanup
DROP TABLE #RawEventData;
GO





-- Drop the session if it exists.
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'InvestigateWaits')
    DROP EVENT SESSION InvestigateWaits ON SERVER;
GO

-- Create the event session
CREATE EVENT SESSION InvestigateWaits
ON SERVER
    ADD EVENT sqlos.wait_info
    (ACTION (package0.callstack)
     WHERE wait_type = 668 -- WRITE_COMPLETION only
           AND opcode = 1 -- Just the end wait events
    )
    ADD TARGET package0.asynchronous_bucketizer
    (SET filtering_event_name = N'sqlos.wait_info', source_type = 1, source = N'package0.callstack')
WITH (MAX_MEMORY = 50MB, MAX_DISPATCH_LATENCY = 5 SECONDS);
GO

-- Start the session
ALTER EVENT SESSION InvestigateWaits ON SERVER STATE = START;
GO

-- TF to allow call stack resolution
DBCC TRACEON(3656, -1);
GO
