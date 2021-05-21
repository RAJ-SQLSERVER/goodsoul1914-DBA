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
-- Exercise 3: Targets
-------------------------------------------------------

SET NOCOUNT ON;
-- Step 1: View all the available targets
SELECT
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'target' AND XP.name = 'package0';
GO

--------------------------------
-- Begin: Step 2 (Event Counter)
--------------------------------
-- Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo1')
DROP EVENT SESSION [LockingInfo1] ON SERVER;
CREATE EVENT SESSION [LockingInfo1] ON SERVER 
ADD EVENT sqlserver.lock_acquired
ADD TARGET package0.event_counter
WITH (EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS)
GO

-- Start event session
ALTER EVENT SESSION LockingInfo1
ON SERVER
STATE=START;
GO

-- Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- View event data
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'LockingInfo1'

-- Rollback transaction T1
ROLLBACK TRAN T1;

---------------------------
-- End: Step 2
---------------------------


---------------------------
-- Begin: Step3 (Event File)
---------------------------

-- Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo2')
DROP EVENT SESSION [LockingInfo2] ON SERVER;
CREATE EVENT SESSION [LockingInfo2] ON SERVER 
ADD EVENT sqlserver.lock_acquired 
ADD TARGET package0.event_file(SET filename=N'C:\temp\LockingInfo2.xel')
WITH (MAX_DISPATCH_LATENCY=5 SECONDS)
GO
-- Start event session
ALTER EVENT SESSION LockingInfo2
ON SERVER
STATE=START;
GO

-- Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- View event data
SELECT *, CAST(event_data AS XML) AS 'event_data_XML'
FROM sys.fn_xe_file_target_read_file('C:\temp\LockingInfo2*.xel', NULL, NULL, NULL)

-- Rollback transaction T1
ROLLBACK TRAN T1;

---------------------------
-- End: Step3
---------------------------


---------------------------
-- Begin: Step4 (Histograms)
---------------------------
-- Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo3')
DROP EVENT SESSION [LockingInfo3] ON SERVER;
CREATE EVENT SESSION [LockingInfo3] ON SERVER 
ADD EVENT sqlserver.lock_acquired 
ADD TARGET package0.histogram(SET filtering_event_name=N'sqlserver.lock_acquired',source=N'mode',source_type=(0))
WITH (MAX_DISPATCH_LATENCY=3 SECONDS)
GO

-- Start event session
ALTER EVENT SESSION LockingInfo3
ON SERVER
STATE=START;
GO

-- Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- View event data
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'LockingInfo3'

-- Rollback transaction T1
ROLLBACK TRAN T1;

---------------------------
-- End: Step4
---------------------------

---------------------------
-- Begin: Step5(Ring Buffer)
---------------------------
-- Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo4')
DROP EVENT SESSION [LockingInfo4] ON SERVER;
CREATE EVENT SESSION [LockingInfo4] ON SERVER 
ADD EVENT sqlserver.lock_acquired
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5 SECONDS)
GO


-- Start event session
ALTER EVENT SESSION LockingInfo4
ON SERVER
STATE=START;
GO


-- Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- View event data
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'LockingInfo4'

-- Rollback transaction T1
ROLLBACK TRAN T1;

---------------------------
-- End: Step5
---------------------------

---------------------------
-- Begin: Step 6(Event Paring)
---------------------------
-- Create event session
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LockingInfo5')
DROP EVENT SESSION [LockingInfo5] ON SERVER;
CREATE EVENT SESSION [LockingInfo5] ON SERVER 
ADD EVENT sqlserver.lock_acquired,
ADD EVENT sqlserver.lock_released 
ADD TARGET package0.pair_matching(SET begin_event=N'sqlserver.lock_acquired',end_event=N'sqlserver.lock_released')
WITH (MAX_DISPATCH_LATENCY=3 SECONDS)
GO

-- Start event session
ALTER EVENT SESSION LockingInfo5
ON SERVER
STATE=START;
GO


-- Execute an explicit transaction
USE AdventureWorks2012
BEGIN TRAN T1;
UPDATE Person.Person SET FirstName = 'test'
WHERE BusinessEntityID = 100;
GO

-- View event data
SELECT name, target_name, CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
   ON (xe.address = xet.event_session_address)
WHERE xe.name = 'LockingInfo5'

-- Rollback transaction T1
ROLLBACK TRAN T1;




---------------------------
-- End: Step 6
---------------------------

-------------------
-- Begin: Cleanup
-------------------

-- Stop the event sessions
ALTER EVENT SESSION LockingInfo1
ON SERVER
STATE=STOP
ALTER EVENT SESSION LockingInfo2
ON SERVER
STATE=STOP
ALTER EVENT SESSION LockingInfo3
ON SERVER
STATE=STOP
ALTER EVENT SESSION LockingInfo4
ON SERVER
STATE=STOP
ALTER EVENT SESSION LockingInfo5
ON SERVER
STATE=STOP

-- Drop the event sessions
DROP EVENT SESSION LockingInfo1
ON SERVER
DROP EVENT SESSION LockingInfo2
ON SERVER
DROP EVENT SESSION LockingInfo3
ON SERVER
DROP EVENT SESSION LockingInfo4
ON SERVER
DROP EVENT SESSION LockingInfo5
ON SERVER

-------------------
-- End: Cleanup
-------------------

/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/