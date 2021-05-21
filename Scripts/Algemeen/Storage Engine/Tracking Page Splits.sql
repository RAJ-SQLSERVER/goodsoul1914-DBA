-- Demo script for Tracking Page Splits demo
-- Investigate the transaction_log Extended Event
SELECT [oc].[name],
	[oc].[type_name],
	[oc].[description]
FROM sys.dm_xe_packages AS [p]
INNER JOIN sys.dm_xe_objects AS [o] ON [p].[guid] = [o].[package_guid]
INNER JOIN sys.dm_xe_object_columns AS [oc] ON [oc].[object_name] = [o].[name]
	AND [oc].[object_package_guid] = [o].[package_guid]
WHERE [o].[name] = N'transaction_log'
	AND [oc].[column_type] = N'data';
GO

SELECT *
FROM sys.dm_xe_map_values
WHERE [name] = N'log_op'
	AND [map_value] = N'LOP_DELETE_SPLIT';
GO

-- If the Event Session exists DROP it
IF EXISTS (
		SELECT 1
		FROM sys.server_event_sessions
		WHERE [name] = N'TrackPageSplits'
		)
	DROP EVENT SESSION [TrackPageSplits] ON SERVER;
GO

-- Create the Event Session to track LOP_DELETE_SPLIT transaction_log
-- operations in the server
CREATE EVENT SESSION [TrackPageSplits] ON SERVER ADD EVENT [sqlserver].[transaction_log] (
	WHERE [operation] = 11 -- LOP_DELETE_SPLIT 
	) ADD TARGET [package0].[histogram] (
	SET filtering_event_name = 'sqlserver.transaction_log',
	source_type = 0,
	-- Event Column
	source = 'database_id'
	);
GO

-- Start the Event Session
ALTER EVENT SESSION [TrackPageSplits] ON SERVER STATE = START;
GO

-- Create the first set of page splits using the CausePageSplits.sql script
-- Query the target data to identify the worst splitting database_id
SELECT [n].[value]('(value)[1]', 'bigint') AS [database_id],
	DB_NAME([n].[value]('(value)[1]', 'bigint')) AS [database_name],
	[n].[value]('(@count)[1]', 'bigint') AS [split_count]
FROM (
	SELECT CAST([target_data] AS XML) [target_data]
	FROM sys.dm_xe_sessions AS [s]
	JOIN sys.dm_xe_session_targets [t] ON [s].[address] = [t].[event_session_address]
	WHERE [s].[name] = 'TrackPageSplits'
		AND [t].[target_name] = 'histogram'
	) AS [tab]
CROSS APPLY [target_data].[nodes]('HistogramTarget/Slot') AS [q]([n]);
GO

-- Drop the Event Session so we can recreate it 
-- to focus on the highest splitting database
DROP EVENT SESSION [TrackPageSplits] ON SERVER;
GO

-- Create the Event Session to track LOP_DELETE_SPLIT transaction_log
-- operations in the server
CREATE EVENT SESSION [TrackPageSplits] ON SERVER ADD EVENT [sqlserver].[transaction_log] (
	WHERE [operation] = 11 -- LOP_DELETE_SPLIT 
	AND [database_id] = 8 -- CHANGE THIS BASED ON TOP SPLITTING DATABASE!
	) ADD TARGET [package0].[histogram] (
	SET filtering_event_name = 'sqlserver.transaction_log',
	source_type = 0,
	-- Event Column
	source = 'alloc_unit_id'
	);
GO

-- Start the Event Session again
ALTER EVENT SESSION [TrackPageSplits] ON SERVER STATE = START;
GO

-- Create the second set of page splits using the CausePageSplits.sql script
USE [Company];
GO

-- Query Target Data to get the top splitting objects in the database:
SELECT [s].[name] AS [schema_name],
	[o].[name] AS [table_name],
	[i].[name] AS [index_name],
	[tab].[split_count],
	[i].[fill_factor]
FROM (
	SELECT [n].[value]('(value)[1]', 'bigint') AS [alloc_unit_id],
		[n].[value]('(@count)[1]', 'bigint') AS [split_count]
	FROM (
		SELECT CAST([target_data] AS XML) [target_data]
		FROM sys.dm_xe_sessions AS [s]
		JOIN sys.dm_xe_session_targets [t] ON [s].[address] = [t].[event_session_address]
		WHERE [s].[name] = 'TrackPageSplits'
			AND [t].[target_name] = 'histogram'
		) AS [tab]
	CROSS APPLY [target_data].[nodes]('HistogramTarget/Slot') AS [q]([n])
	) AS [tab]
JOIN sys.allocation_units AS [au] ON [tab].[alloc_unit_id] = [au].[allocation_unit_id]
JOIN sys.partitions AS [p] ON [au].[container_id] = [p].[partition_id]
JOIN sys.indexes AS [i] ON [p].[object_id] = [i].[object_id]
	AND [p].[index_id] = [i].[index_id]
JOIN sys.objects AS [o] ON [p].[object_id] = [o].[object_id]
JOIN sys.schemas AS [s] ON [o].[schema_id] = [s].[schema_id]
WHERE [o].[is_ms_shipped] = 0;
GO

-- Cleanup
DROP EVENT SESSION [TrackPageSplits] ON SERVER;
GO

-- Now look in the transaction log
USE [Company];
GO

SELECT [AllocUnitName] AS N'Index',
	(
		CASE [Context]
			WHEN N 'LCX_INDEX_LEAF'
				THEN N 'Nonclustered'
			WHEN N'LCX_CLUSTERED'
				THEN N'Clustered'
			ELSE N 'Non-Leaf'
			END
		) AS [SplitType],
	COUNT(1) AS [SplitCount]
FROM fn_dblog(NULL, NULL)
WHERE [Operation] = N'LOP_DELETE_SPLIT'
GROUP BY [AllocUnitName],
	[Context];
GO

-- For looking in log backups, see http://bit.ly/1aX1qVD
