-- Event ETW Keyword/Channel pairings
SELECT 
	package_name,
	object_name,
	description,
	CHANNEL as channel_name,
	KEYWORD as keyword_name
FROM
(
SELECT 
	p.name AS package_name, 
	o.name AS object_name,
	o.description,
	oc.name AS column_name,
	mv1.map_value
FROM sys.dm_xe_packages p
JOIN sys.dm_xe_objects o
	ON p.guid = o.package_guid
JOIN sys.dm_xe_object_columns oc
	ON o.package_guid = oc.object_package_guid
		AND o.name = oc.object_name
LEFT JOIN sys.dm_xe_map_values mv1 
	on oc.type_name = mv1.name and oc.type_package_guid = mv1.object_package_guid
		and oc.column_value = mv1.map_key
WHERE oc.name IN (N'CHANNEL', N'KEYWORD')
	-- Filter out private internal use only objects
  AND (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND (oc.capabilities IS NULL OR oc.capabilities & 1 = 0)
) AS tab
PIVOT
( 
	MAX(map_value)
	FOR column_name IN ([CHANNEL], [KEYWORD])
) as pvt
WHERE CHANNEL <> N'debug'
ORDER BY CHANNEL, KEYWORD, package_name, object_name;


-- Create an event session to use the ETW provider
IF EXISTS(SELECT * 
			FROM sys.server_event_sessions 
			WHERE name=N'etw_test_session') 
	DROP EVENT SESSION [etw_test_session] 
	ON SERVER; 
GO
CREATE EVENT SESSION [etw_test_session] 
ON SERVER 
ADD EVENT sqlserver.file_read( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlserver.file_written( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlserver.file_read_completed( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlserver.file_write_completed( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlos.async_io_requested( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlos.async_io_completed( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlos.wait_info( 
     ACTION (sqlserver.database_id, sqlserver.session_id)), 
ADD EVENT sqlserver.sql_statement_starting( 
     ACTION (sqlserver.database_id, sqlserver.plan_handle, 
            sqlserver.session_id, sqlserver.sql_text)), 
ADD EVENT sqlserver.sql_statement_completed( 
     ACTION (sqlserver.database_id, sqlserver.plan_handle, 
            sqlserver.session_id, sqlserver.sql_text)) 
ADD TARGET package0.ring_buffer,
-- ADD ETW target 
ADD TARGET package0.etw_classic_sync_target (
       SET default_etw_session_logfile_path = N'C:\Pluralsight\sqletwtarget.etl')
WITH (MAX_MEMORY = 4096KB, 
     EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, 
     MAX_DISPATCH_LATENCY = 5 SECONDS, 
     MAX_EVENT_SIZE = 4096KB, 
     MEMORY_PARTITION_MODE = PER_CPU, 
     TRACK_CAUSALITY = ON, 
     STARTUP_STATE = OFF);
GO

USE [AdventureWorks2012] 
GO 
-- Clear the Buffer Cache to force reads from Disk 
DBCC DROPCLEANBUFFERS 
GO 

-- Start the Event Session so we capture the Events caused by running the test 
ALTER EVENT SESSION etw_test_session 
ON SERVER 
STATE=START 
GO 

-- Enable Windows Kernel ETW Tracing by running the following
-- command from an elevated command prompt
-- logman start "NT Kernel Logger" /p "Windows Kernel Trace" (process,thread,disk) /o C:\Pluralsight\systemevents.etl /ets

GO

-- Run the Simple SELECT against AdventureWorks 
SELECT SUM(TotalDue), SalesPersonID 
FROM Sales.SalesOrderHeader 
GROUP BY SalesPersonID 
GO 

-- Flush the Kernel ETW buffers to disk by running the following
-- commands from an elevated command prompt
-- logman update "NT Kernel Logger" /fd /ets
-- logman stop "NT Kernel Logger" /ets
GO

-- Disable Event collection by dropping the Events from the Event Session 
ALTER EVENT SESSION etw_test_session 
ON SERVER 
DROP EVENT sqlos.async_io_requested, 
DROP EVENT sqlos.async_io_completed, 
DROP EVENT sqlos.wait_info, 
DROP EVENT sqlserver.file_read, 
DROP EVENT sqlserver.file_written, 
DROP EVENT sqlserver.file_read_completed, 
DROP EVENT sqlserver.file_write_completed, 
DROP EVENT sqlserver.sql_statement_starting, 
DROP EVENT sqlserver.sql_statement_completed;
GO 

-- Flush Extended Event ETW buffers to diskby running the following
-- command from an elevated command prompt
-- logman update XE_DEFAULT_ETW_SESSION /fd /ets

-- Disable Extended Event ETW Tracingby running the following
-- command from an elevated command prompt
-- logman stop XE_DEFAULT_ETW_SESSION /ets
GO
-- Generate a merged ETW csv fileby running the following
-- commands from an elevated command prompt
-- tracerpt C:\Pluralsight\systemevents.etl C:\Pluralsight\sqletwtarget.etl -o C:\Pluralsight\ETW_Merged.csv
GO

---- Stop the Event Session 
ALTER EVENT SESSION etw_test_session 
ON SERVER 
STATE=STOP
GO 

-- Open the CSV file from the file system to show merged XML output