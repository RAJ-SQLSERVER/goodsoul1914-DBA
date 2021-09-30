/*
Download the SalesDB database zip file, unzip it and restore it.
Get it from:
http://bit.ly/M0HHUg

Here's an example of restoring it:

RESTORE DATABASE [SalesDB]
	FROM DISK = N'D:\PluralSight\SalesDBOriginal.bak'
	WITH MOVE N'SalesDBData' TO N'D:\PluralSight\SalesDBData.mdf',
	MOVE N'SalesDBLog' TO N'D:\PluralSight\SalesDBLog.ldf',
	REPLACE, STATS = 10;
GO
*/

-- Basic DMV
SELECT * FROM sys.dm_os_buffer_descriptors;
GO

-- Explain about DBID 32767

-- Now to see aggregated by database
SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO 

-- What about getting a view of what's in
-- memory per *table*?
SELECT * FROM sys.dm_os_buffer_descriptors;
GO

-- All we get is an allocation unit ID

-- For a single database, with names
USE [SalesDB];
GO

-- In the other window, delete from the sales
-- table then watch over here
SELECT
	OBJECT_NAME ([p].[object_id]) AS [ObjectName],
	[p].[index_id],
	[i].[name],
	[i].[type_desc],
	[au].[type_desc],
	[DirtyPageCount],
	[CleanPageCount],
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT
		[allocation_unit_id],
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	WHERE [database_id] = DB_ID (N'SalesDB')
	GROUP BY [allocation_unit_id]) AS [buffers]
INNER JOIN sys.allocation_units AS [au]
	ON [au].[allocation_unit_id] = [buffers].[allocation_unit_id]
INNER JOIN sys.partitions AS [p]
	ON [au].[container_id] = [p].[partition_id]
INNER JOIN sys.indexes AS [i]
	ON [i].[index_id] = [p].[index_id]
		AND [p].[object_id] = [i].[object_id]
WHERE [p].[object_id] > 100
ORDER BY [ObjectName], [p].[index_id];
GO

-- Now checkpoint and check again
CHECKPOINT;
GO
