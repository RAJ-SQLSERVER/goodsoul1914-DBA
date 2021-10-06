SELECT 
    oc.name, 
    oc.type_name, 
    oc.description
FROM sys.dm_xe_packages AS p
INNER JOIN sys.dm_xe_objects AS o
    ON p.guid = o.package_guid
INNER JOIN sys.dm_xe_object_columns AS oc
    ON oc.object_name = o.name
        AND oc.object_package_guid = o.package_guid
WHERE o.name = N'transaction_log'
  AND oc.column_type = N'data';

-- Explain and look at the key for LOP_DELETE_SPLIT
SELECT *
FROM sys.dm_xe_map_values
WHERE name = N'log_op'
  AND map_value = N'LOP_DELETE_SPLIT';
  

-- If the event session exists drop it
IF EXISTS (SELECT 1 
            FROM sys.server_event_sessions 
            WHERE name = N'TrackPageSplits')
    DROP EVENT SESSION [TrackPageSplits] ON SERVER;

-- Create the event session to track LOP_DELETE_SPLIT
CREATE EVENT SESSION [TrackPageSplits]
ON SERVER
ADD EVENT sqlserver.transaction_log(
    WHERE operation = 11  -- LOP_DELETE_SPLIT 
)
ADD TARGET package0.histogram(
    SET filtering_event_name = N'sqlserver.transaction_log',
        source_type = 0, -- Event Column
        source = N'database_id');
GO
        
-- Start the event session
ALTER EVENT SESSION [TrackPageSplits]
ON SERVER
STATE=START;
GO

-- Setup the test database
USE [master];
GO
-- Drop the PageSplits database if it exists
IF DB_ID(N'PageSplits') IS NOT NULL
BEGIN
    ALTER DATABASE [PageSplits] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [PageSplits];
END
GO

-- Create the database
CREATE DATABASE [PageSplits]
GO
USE [PageSplits];
GO

-- Create a bad splitting clustered index table
CREATE TABLE [dbo].[BadSplitsPK]
( ROWID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
  ColVal INT NOT NULL DEFAULT (RAND()*1000),
  ChangeDate DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP);
GO

--  This index should mid-split based on the DEFAULT column value
CREATE INDEX [IX_BadSplitsPK_ColVal] ON [dbo].[BadSplitsPK] (ColVal);
GO

--  This index should end-split based on the DEFAULT column value
CREATE INDEX [IX_BadSplitsPK_ChangeDate] ON [dbo].[BadSplitsPK] (ChangeDate);
GO

-- Create a table with an increasing clustered index
CREATE TABLE [dbo].[EndSplitsPK]
( ROWID INT IDENTITY NOT NULL PRIMARY KEY,
  ColVal INT NOT NULL DEFAULT (RAND()*1000),
  ChangeDate DATETIME2 NOT NULL DEFAULT DATEADD(mi, RAND()*-1000, CURRENT_TIMESTAMP));
GO

--  This index should mid-split based on the DEFAULT column value
CREATE INDEX [IX_EndSplitsPK_ChangeDate] ON [dbo].[EndSplitsPK] (ChangeDate);
GO

-- Copy this query into a new window to run the workload
-- Insert the default values repeatedly into the tables
WHILE 1=1
BEGIN
    INSERT INTO [dbo].[BadSplitsPK] DEFAULT VALUES;
    INSERT INTO [dbo].[EndSplitsPK] DEFAULT VALUES;
    WAITFOR DELAY N'00:00:00.005';
END
GO

-- Query the target data to identify the worst splitting database_id
SELECT 
    n.value('(value)[1]', 'bigint') AS database_id,
    DB_NAME(n.value('(value)[1]', 'bigint')) AS database_name,
    n.value('(@count)[1]', 'bigint') AS split_count
FROM
(SELECT CAST(target_data as XML) target_data
 FROM sys.dm_xe_sessions AS s 
 INNER JOIN sys.dm_xe_session_targets AS t
     ON s.address = t.event_session_address
 WHERE s.name = N'TrackPageSplits'
  AND t.target_name = N'histogram' ) as tab
CROSS APPLY target_data.nodes('HistogramTarget/Slot') as q(n);
GO

-- Drop the event session so we can recreate it 
-- to focus on the highest splitting database
DROP EVENT SESSION [TrackPageSplits] 
ON SERVER;
GO

-- Create the event session to track LOP_DELETE_SPLIT
-- **** Change the database_id here ****
CREATE EVENT SESSION [TrackPageSplits]
ON SERVER
ADD EVENT sqlserver.transaction_log(
    WHERE operation = 11  -- LOP_DELETE_SPLIT 
      AND database_id = 8 -- CHANGE THIS BASED ON TOP SPLITTING DATABASE!
)
ADD TARGET package0.histogram(
    SET filtering_event_name = N'sqlserver.transaction_log',
        source_type = 0, -- Event Column
        source = N'alloc_unit_id');
GO

-- Start the event session Again
ALTER EVENT SESSION [TrackPageSplits]
ON SERVER
STATE=START;
GO

-- Query Target Data to get the top splitting objects in the database:
SELECT
    o.name AS table_name,
    i.name AS index_name,
    tab.split_count,
    i.fill_factor
FROM (    SELECT 
            n.value('(value)[1]', 'bigint') AS alloc_unit_id,
            n.value('(@count)[1]', 'bigint') AS split_count
        FROM
        (SELECT CAST(target_data as XML) target_data
         FROM sys.dm_xe_sessions AS s 
         JOIN sys.dm_xe_session_targets t
             ON s.address = t.event_session_address
         WHERE s.name = N'TrackPageSplits'
          AND t.target_name = N'histogram' ) as tab
        CROSS APPLY target_data.nodes('HistogramTarget/Slot') as q(n)
) AS tab
JOIN sys.allocation_units AS au
    ON tab.alloc_unit_id = au.allocation_unit_id
JOIN sys.partitions AS p
    ON au.container_id = p.partition_id
JOIN sys.indexes AS i
    ON p.object_id = i.object_id
        AND p.index_id = i.index_id
JOIN sys.objects AS o
    ON p.object_id = o.object_id
WHERE o.is_ms_shipped = 0;

-- Change FillFactors based on split occurences
-- **** Change the Primary Key index name to match
ALTER INDEX [PK__BadSplit__97BD02EB726FCA55]
ON [dbo].[BadSplitsPK] 
REBUILD WITH (FILLFACTOR=70);
GO

ALTER INDEX [IX_BadSplitsPK_ColVal] 
ON [dbo].[BadSplitsPK] 
REBUILD WITH (FILLFACTOR=70);
GO

ALTER INDEX [IX_EndSplitsPK_ChangeDate] 
ON [dbo].[EndSplitsPK] 
REBUILD WITH (FILLFACTOR=80);
GO

-- Stop the event session to clear the target
ALTER EVENT SESSION [TrackPageSplits]
ON SERVER
STATE=STOP;
GO

-- Start the event session Again
ALTER EVENT SESSION [TrackPageSplits]
ON SERVER
STATE=START;
GO


-- Query Target Data to get the top splitting objects in the database:
SELECT
    o.name AS table_name,
    i.name AS index_name,
    tab.split_count,
    i.fill_factor
FROM (    SELECT 
            n.value('(value)[1]', 'bigint') AS alloc_unit_id,
            n.value('(@count)[1]', 'bigint') AS split_count
        FROM
        (SELECT CAST(target_data as XML) target_data
         FROM sys.dm_xe_sessions AS s 
         JOIN sys.dm_xe_session_targets t
             ON s.address = t.event_session_address
         WHERE s.name = N'TrackPageSplits'
          AND t.target_name = N'histogram' ) as tab
        CROSS APPLY target_data.nodes('HistogramTarget/Slot') as q(n)
) AS tab
JOIN sys.allocation_units AS au
    ON tab.alloc_unit_id = au.allocation_unit_id
JOIN sys.partitions AS p
    ON au.container_id = p.partition_id
JOIN sys.indexes AS i
    ON p.object_id = i.object_id
        AND p.index_id = i.index_id
JOIN sys.objects AS o
    ON p.object_id = o.object_id
WHERE o.is_ms_shipped = 0;
