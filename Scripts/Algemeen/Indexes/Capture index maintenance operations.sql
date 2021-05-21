/* Capture index maintenance operations */

SELECT c.OBJECT_NAME AS EventName,
	   p.name AS PackageName,
	   o.description AS EventDescription
FROM sys.dm_xe_objects o
INNER JOIN sys.dm_xe_object_columns c ON o.name = c.OBJECT_NAME and o.package_guid = c.object_package_guid
INNER JOIN sys.dm_xe_packages p ON o.package_guid = p.guid
WHERE object_type='event' AND c.name = 'channel' AND (c.OBJECT_NAME like '%index%' or o.description like '%index%')
ORDER BY o.package_guid;
GO


-- Create the Event Session
IF EXISTS(SELECT * 
          FROM sys.server_event_sessions 
          WHERE name='OnlineIXOps')
    DROP EVENT SESSION OnlineIXOps 
    ON SERVER;
GO
CREATE EVENT SESSION OnlineIXOps
ON SERVER
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* The online index operations */
--ADD EVENT sqlserver.progress_report_online_index_operation
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ADD EVENT sqlserver.progress_report_online_index_operation(
    ACTION (sqlserver.database_name,sqlserver.client_hostname,sqlserver.client_app_name,
            sqlserver.sql_text,
			sqlserver.session_id
			)
	--Change this to match the database in question, 
	WHERE sqlserver.database_id=5 
)
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO
 
-- Start the Event Session
ALTER EVENT SESSION OnlineIXOps 
ON SERVER 
STATE = START;
GO


SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS timestamp,
	event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(max)') as DBName
	,event_data.value('(event/data[@name="object_name"]/value)[1]', 'varchar(max)') as ObjName
	,event_data.value('(event/data[@name="index_name"]/value)[1]', 'varchar(max)') as index_name
	,event_data.value('(event/data[@name="partition_number"]/value)[1]', 'varchar(max)') as PartitionNumber
	,event_data.value('(event/action[@name="session_id"]/value)[1]', 'varchar(max)') as SessionID
	,event_data.value('(event/data[@name="build_stage"]/value)[1]', 'varchar(max)') as Build_Stage
	,event_data.value('(event/data[@name="build_stage"]/text)[1]', 'varchar(max)') as BuildStage_Description
	,event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') as Client_hostName,
	event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(max)') as Client_AppName,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/data[@name="duration"]/value)[1]', 'Decimal(18,2)')/1000 as Duration_ms
	,event_data.value('(event/data[@name="rows_inserted"]/value)[1]', 'varchar(max)') as rows_inserted
FROM(    SELECT evnt.query('.') AS event_data
        FROM
        (    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'OnlineIXOps'
              AND t.target_name = 'ring_buffer'
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
    ) AS evts(event_data)
Order by timestamp, Build_Stage
GO
