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

-- Clear wait stats in WaitStats1.sql

RESTORE DATABASE [SalesDBCopy]
	FROM DISK = N'D:\PluralSight\SalesDBOriginal.bak'
	WITH MOVE N'SalesDBData' TO N'D:\PluralSight\SalesDBDataCopy.mdf',
	MOVE N'SalesDBLog' TO N'D:\PluralSight\SalesDBLogCopy.ldf',
	REPLACE, STATS = 10;
GO

-- Examine waiting tasks in WaitingTasks.sql as soon
-- as the backup starts

-- Examine wait stats in WaitStats1.sql afterwards

DROP DATABASE [SalesDBCopy];
GO
