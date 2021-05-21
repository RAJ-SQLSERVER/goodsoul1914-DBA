-- Demo script for REBUILD and REORGANIZE demo

-- Run the CreateFragmentation.sql script from second demo in Module 5

USE [Company];
GO

-- Look at the fragmentation again
SELECT
	OBJECT_NAME ([ips].[object_id]) AS [Object Name],
	[si].[name] AS [Index Name],
	ROUND ([ips].[avg_fragmentation_in_percent], 2) AS [Fragmentation],
	[ips].[page_count] AS [Pages],
	ROUND ([ips].[avg_page_space_used_in_percent], 2) AS [Page Density]
FROM sys.dm_db_index_physical_stats (
	DB_ID (N'Company'),
	NULL,
	NULL,
	NULL,
	N'DETAILED') [ips]
CROSS APPLY [sys].[indexes] [si]
WHERE
	[si].[object_id] = [ips].[object_id]
	AND [si].[index_id] = [ips].[index_id]
	AND [ips].[index_level] = 0 -- Just the leaf level
	AND [ips].[alloc_unit_type_desc] = N'IN_ROW_DATA';
GO

-- Online rebuild the clustered index
-- This will fail on SQL Server 2005 through 2008 R2
ALTER INDEX [BadKeyTable_CL] ON [BadKeyTable] REBUILD
WITH (ONLINE = ON, FILLFACTOR = 70);
GO

-- On 2005 through 2008 R2, use offline
ALTER INDEX [BadKeyTable_CL] ON [BadKeyTable] REBUILD
WITH (FILLFACTOR = 70);
GO

-- And check again...

-- Reorganize the non-clustered index
ALTER INDEX [BadKeyTable_NCL] ON [BadKeyTable] REORGANIZE;
GO

-- And check again...

-- Now rebuild the non-clustered index
ALTER INDEX [BadKeyTable_NCL] ON [BadKeyTable] REBUILD
WITH (ONLINE = ON, FILLFACTOR = 70);
GO

-- And check again...