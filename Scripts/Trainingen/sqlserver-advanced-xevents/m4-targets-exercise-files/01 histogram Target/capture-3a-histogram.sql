-- Target Configurable Fields
SELECT 
    oc.name AS column_name,
    oc.column_id,
    oc.type_name,
    oc.capabilities_desc,
    oc.description
FROM sys.dm_xe_packages AS p
JOIN sys.dm_xe_objects AS o 
    ON p.guid = o.package_guid
JOIN sys.dm_xe_object_columns AS oc 
    ON o.name = oc.OBJECT_NAME 
    AND o.package_guid = oc.object_package_guid
WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
  AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
  AND o.object_type = N'target'
  AND o.name = N'histogram';


-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'RecompilingProcedures')
	DROP EVENT SESSION [RecompilingProcedures] ON SERVER;

-- Create event session to find the database with most recompile events
CREATE EVENT SESSION [RecompilingProcedures]
ON SERVER
ADD EVENT sqlserver.sp_statement_starting(
	ACTION(sqlserver.database_id)
	WHERE(state = 1) -- Recompile statement_state map_key
)
ADD TARGET package0.histogram(
	SET filtering_event_name = N'sqlserver.sp_statement_starting',
		source_type = 1, -- Action
		source = N'sqlserver.database_id'),
ADD TARGET package0.ring_buffer;
		
--Start the event session
ALTER EVENT SESSION [RecompilingProcedures]
ON SERVER
STATE=START;
		
		
-- RUN Workload!
EXECUTE [AdventureWorks2012].[dbo].[AnnualTop5SalesPersonByMonthlyPercent] @Year=2005;
GO
EXECUTE [AdventureWorks2012].[dbo].[AnnualTop5SalesPersonByMonthlyPercent] @Year=2006;
GO
EXECUTE [AdventureWorks2012].[dbo].[AnnualTop5SalesPersonByMonthlyPercent] @Year=2007;
GO
EXECUTE [AdventureWorks2012].[dbo].[AnnualTop5SalesPersonByMonthlyPercent] @Year=2008;

GO
DECLARE @ManagerID int
SELECT TOP 1 @ManagerID = ManagerID 
FROM [AdventureWorks].[HumanResources].[Employee]
ORDER BY NEWID();

EXECUTE [AdventureWorks].[dbo].[uspGetManagerEmployees] @ManagerID;
EXECUTE [AdventureWorks2012].[dbo].[uspGetManagerEmployees] @ManagerID;
EXECUTE [AdventureWorks2012].[dbo].[uspGetEmployeeManagers] @ManagerID;
EXECUTE [AdventureWorks].[dbo].[uspGetEmployeeManagers] @ManagerID;
GO


-- Query target data
SELECT 
    n.value('(value)[1]', 'int') AS DatabaseID,
    DB_NAME(n.value('(value)[1]', 'int')) AS DatabaseName,
    n.value('(@count)[1]', 'int') AS RecompileEventCount,
    n.value('(@trunc)[1]', 'int') AS RecompileEventsTrunc
FROM
(SELECT CAST(target_data AS XML) target_data
 FROM sys.dm_xe_sessions AS s 
 INNER JOIN sys.dm_xe_session_targets AS t
     ON s.address = t.event_session_address
 WHERE s.name = N'RecompilingProcedures'
 AND t.target_name = N'histogram' ) AS tab
CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS q(n);
GO

-- Drop the event session since we are changing 
-- all of the objects in the session this is faster
DROP EVENT SESSION [RecompilingProcedures] 
ON SERVER;
GO

-- Create event session to find the specific objects recompiling
-- ***** Change the database_id here *****
CREATE EVENT SESSION [RecompilingProcedures]
ON SERVER
ADD EVENT sqlserver.sp_statement_starting(
	ACTION(sqlserver.database_id)
	WHERE(state = 1 -- Recompile statement_state map_key
		AND sqlserver.database_id = 7) -- databaseid from first capture
)
ADD TARGET package0.histogram(
	SET filtering_event_name = N'sqlserver.sp_statement_starting',
		source_type = 0, -- Event Data
		source = N'object_id');
		

-- Query target data
SELECT 
    n.value('(value)[1]', 'int') AS ObjectID,
    OBJECT_NAME(n.value('(value)[1]', 'int'), 7) AS ObjectName,
    n.value('(@count)[1]', 'int') AS RecompileEventCount,
    n.value('(@trunc)[1]', 'int') AS RecompileEventsTrunc
FROM
(SELECT CAST(target_data AS XML) target_data
 FROM sys.dm_xe_sessions AS s 
 INNER JOIN sys.dm_xe_session_targets AS t
     ON s.address = t.event_session_address
 WHERE s.name = N'RecompilingProcedures'
   AND t.target_name = N'histogram' ) AS tab
CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS q(n);