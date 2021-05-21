-------------------------------------------------------------------------------
-- Drill Into Recompile Causes
-------------------------------------------------------------------------------

-- Measure
CREATE EVENT SESSION Recompile_Histogram
ON SERVER
    ADD EVENT sqlserver.sql_statement_recompile
    ADD TARGET package0.histogram
    (SET filtering_event_name = N'sqlserver.sql_statement_recompile', source = N'recompile_cause', source_type = (0));

ALTER EVENT SESSION Recompile_Histogram ON SERVER STATE = START;

-- Analyze
SELECT sv.subclass_name AS "recompile_cause",
       shredded.recompile_count
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
    ON (xe.address = xet.event_session_address)
CROSS APPLY (SELECT CAST(xet.target_data AS XML)) AS target_data_xml(xml)
CROSS APPLY target_data_xml.xml.nodes ('/HistogramTarget/Slot') AS nodes(slot_data)
CROSS APPLY (
    SELECT nodes.slot_data.value ('(value)[1]', 'int') AS "recompile_cause",
           nodes.slot_data.value ('(@count)[1]', 'int') AS "recompile_count"
) AS shredded
JOIN sys.trace_subclass_values AS sv
    ON shredded.recompile_cause = sv.subclass_value
WHERE xe.name = 'Recompile_Histogram'
      AND sv.trace_event_id = 37; -- SP:Recompile

-- Measure infrequent recompiles
CREATE EVENT SESSION DarkQueries
ON SERVER
    ADD EVENT sqlserver.sql_statement_recompile
    (ACTION (sqlserver.database_id, sqlserver.sql_text)
     WHERE (recompile_cause = (11))
    ) -- Option (RECOMPILE) Requested
    ADD TARGET package0.event_file
    (SET filename = N'DarkQueries');
ALTER EVENT SESSION DarkQueries ON SERVER STATE = START;
GO

-- Analyze
SELECT DarkQueryData.eventDate,
       DB_NAME(DarkQueryData.database_id) as DatabaseName,
       DarkQueryData.object_type,
       COALESCE(DarkQueryData.sql_text, 
                OBJECT_NAME(DarkQueryData.object_id, DarkQueryData.database_id)) command,
       DarkQueryData.recompile_cause
  FROM sys.fn_xe_file_target_read_file ( 'DarkQueries*xel', null, null, null) event_file_value
 CROSS APPLY ( SELECT CAST(event_file_value.[event_data] as xml) ) event_file_value_xml ([xml])
 CROSS APPLY (
         SELECT event_file_value_xml.[xml].value('(event/@timestamp)[1]', 'datetime') as eventDate,
                event_file_value_xml.[xml].value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') as sql_text,
                event_file_value_xml.[xml].value('(event/data[@name="object_type"]/text)[1]', 'nvarchar(100)') as object_type,
                event_file_value_xml.[xml].value('(event/data[@name="object_id"]/value)[1]', 'bigint') as object_id,
                event_file_value_xml.[xml].value('(event/data[@name="source_database_id"]/value)[1]', 'bigint') as database_id,
                event_file_value_xml.[xml].value('(event/data[@name="recompile_cause"]/text)[1]', 'nvarchar(100)') as recompile_cause
       ) as DarkQueryData
 ORDER BY eventDate DESC