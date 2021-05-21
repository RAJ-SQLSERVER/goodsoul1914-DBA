/*============================================================================================
  Copyright (C) 2016 SQLMaestros.com | eDominer Systems P Ltd.
  All rights reserved.
    
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.

=============================================================================================*/


-------------------------------------------------------
-- Lab: SQL Server Extended Events Basics 
-- Exercise 2: Event Session
-------------------------------------------------------

-- Step 1: Find event information and package name
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.name = 'lock_acquired';
GO



-- Step 2: View data elements of lock_acquired extended event
SELECT XOC.name, XOC.type_name, XOC.column_type, XOC.column_value, XOC.description FROM sys.dm_xe_objects AS XO
INNER JOIN sys.dm_xe_object_columns AS XOC 
ON XO.name = XOC.object_name WHERE XO.name = 'lock_acquired'
AND XO.object_type = 'event';
GO


-- Step 3: Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo')
DROP EVENT SESSION [LockingInfo] ON SERVER;
CREATE EVENT SESSION [LockingInfo] ON SERVER 
ADD EVENT sqlserver.lock_acquired(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.session_id)
    WHERE ([package0].[equal_unicode_string]([database_name],N'AdventureWorks2012'))) 
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5 SECONDS)
GO


-- Step 4: Start event session
ALTER EVENT SESSION LockingInfo
ON SERVER
STATE=START;
GO


-- Step 5: Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- Step 6: View event data in XML format
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'LockingInfo'

-- Step 7: View event session details from system catalogs
SELECT sessions.name AS SessionName, sevents.package as PackageName, 
sevents.name AS EventName, 
sevents.predicate, sactions.name AS ActionName, stargets.name AS TargetName 
FROM sys.server_event_sessions sessions 
INNER JOIN sys.server_event_session_events sevents 
ON sessions.event_session_id = sevents.event_session_id 
INNER JOIN sys.server_event_session_actions sactions 
ON sessions.event_session_id = sactions.event_session_id 
INNER JOIN sys.server_event_session_targets stargets 
ON sessions.event_session_id = stargets.event_session_id 
WHERE sessions.name = 'LockingInfo' 
GO

-- Step 8: View configurable event and target column information from DMV
SELECT DISTINCT s.name AS session_name, 
	   t.target_name,
       oc.object_type, 
       oc.column_name, 
       oc.column_value,
	   ea.action_name
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t
     ON s.address = t.event_session_address
INNER JOIN sys.dm_xe_session_events AS e
     ON s.address = e.event_session_address
INNER JOIN sys.dm_xe_session_object_columns AS oc
     ON s.address = oc.event_session_address
INNER JOIN sys.dm_xe_session_event_actions as ea
	ON s.address = ea.event_session_address
       AND ((oc.object_type = 'target' AND t.target_name = oc.object_name) 
       OR (oc.object_type = 'event' AND e.event_name = oc.object_name)) WHERE S.name = 'LockingInfo';

---------------------
-- Begin: Cleanup
---------------------
-- Rollback trasaction T1
ROLLBACK TRAN T1

-- Stop the event session
ALTER EVENT SESSION LockingInfo
ON SERVER
STATE=STOP

-- Drop the event session
DROP EVENT SESSION LockingInfo
ON SERVER

---------------------
-- End: Cleanup
---------------------

/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/
