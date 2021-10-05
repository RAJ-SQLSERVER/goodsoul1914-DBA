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

-- Create the database snapshot
CREATE DATABASE [SalesDB_Snapshot]
ON (
	NAME = N'SalesDBData',
	FILENAME = N'D:\PluralSight\SalesDBData.mdfss')
AS SNAPSHOT OF [SalesDB];
GO

-- Drop a table in the source database
DROP TABLE [SalesDB].[dbo].[Sales];
GO

-- It's still there in the database snapshot
SELECT COUNT (*) FROM [SalesDB_Snapshot].[dbo].[Sales];
GO

-- We can revert from the database snapshot

-- But beforehand, what does the SalesDB log look like?
DBCC LOGINFO (N'SalesDB');
DBCC SQLPERF (LOGSPACE);
GO

-- Now revert
USE [master];
GO

-- Make sure all connections are killed (including SSMS)
ALTER DATABASE [SalesDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE [SalesDB]
FROM DATABASE_SNAPSHOT = N'SalesDB_Snapshot';
GO

ALTER DATABASE [SalesDB] SET MULTI_USER;
GO

-- Cool, but...
DBCC LOGINFO (N'SalesDB');
DBCC SQLPERF (LOGSPACE);
GO

-- And it didn't use the model database either
DBCC LOGINFO (N'model');
