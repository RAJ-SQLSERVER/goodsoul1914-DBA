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
-- Exercise 1: Extended Event Objects
-------------------------------------------------------

SET NOCOUNT ON;
-------------
-- Packages 
-------------
-- Step 1: View packages of extended events
SELECT name, description FROM sys.dm_xe_packages;
GO


-------------
-- Events
-------------
-- Step 2: View all the extended events available 
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'event';
GO

-----------------------
-- Event Data Elements
-----------------------
-- Step 3: View all the data returend by a particular extended event
SELECT XOC.name, XOC.type_name, XOC.column_type, XOC.column_value, XOC.description FROM sys.dm_xe_objects AS XO
INNER JOIN sys.dm_xe_object_columns AS XOC 
ON XO.name = XOC.object_name WHERE XO.name = 'missing_column_statistics'
AND XO.object_type = 'event';
GO

-------------
-- Actions
-------------
-- Step 4: View all the actions available 
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'action';
GO

-------------
-- Predicates
-------------

-- Predicate Sources
-- Step 5: View all the predicate source available 
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'pred_source';
GO

-- Predicate Comparators
-- Step 6: View all the predicate comparators available
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'pred_compare';
GO

-------------
-- Types
-------------
-- Step 7: View all the data types of the data returned by extended event
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'type';
GO

-------------
-- Targets
-------------
-- Step 8: View all the available targets
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'target' AND XP.name = 'package0';
GO


-------------
-- Maps
-------------
-- Step 9: View all the mapping objects available
SELECT XP.name AS package_name,
	        XO.name AS event_name,
	        XO.description
	FROM sys.dm_xe_packages AS XP
	JOIN sys.dm_xe_objects AS XO
	     ON XP.guid = XO.package_guid
	WHERE  XO.object_type = 'map';
GO

-- Step 10: View mappings objects from map table
SELECT name, map_key, map_value
FROM sys.dm_xe_map_values
WHERE name = 'wait_types';
GO

/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/
