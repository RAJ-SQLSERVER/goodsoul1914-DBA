-- event_counter target configurable fields
SELECT 
   oc.name AS column_name,
   oc.column_id,
   oc.type_name,
   oc.capabilities_desc,
   oc.description
FROM sys.dm_xe_packages AS p
INNER JOIN sys.dm_xe_objects AS o 
    ON p.guid = o.package_guid
INNER JOIN sys.dm_xe_object_columns AS oc 
    ON o.name = oc.OBJECT_NAME 
   AND o.package_guid = oc.object_package_guid
WHERE(p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = N'target'
  AND o.name = N'event_counter';
  

-- Create an event session to rrack recompiles
IF EXISTS(SELECT * 
			FROM sys.server_event_sessions 
			WHERE name = N'CounterTargetDemo')
    DROP EVENT SESSION [CounterTargetDemo] 
    ON SERVER;
GO
CREATE EVENT SESSION [CounterTargetDemo]
ON SERVER
ADD EVENT sqlserver.sql_statement_starting,
ADD EVENT sqlos.wait_info
(    WHERE (duration > 0))
ADD TARGET package0.event_counter;
GO

-- Start the event session
ALTER EVENT SESSION [CounterTargetDemo]
ON SERVER
STATE=START;
GO

-- Wait for events to generate and then query target

-- Query the target
SELECT 
    n.value('../@name[1]', 'varchar(50)') as PackageName,
    n.value('@name[1]', 'varchar(50)') as EventName,
    n.value('@count[1]', 'int') as Occurence
FROM
(
	SELECT CAST(target_data AS XML) as target_data
	FROM sys.dm_xe_sessions AS s 
	INNER JOIN sys.dm_xe_session_targets AS t 
		ON t.event_session_address = s.address
	WHERE s.name = N'CounterTargetDemo'
	  AND t.target_name = N'event_counter'
) as tab
CROSS APPLY target_data.nodes('CounterTarget/Packages/Package/Event') as q(n);

