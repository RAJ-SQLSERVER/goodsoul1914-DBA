/*
Download the SalesDB database zip file, unzip it and restore it.
Get it from:
http://bit.ly/M0HHUg

Here's an example of restoring it:

RESTORE DATABASE [SalesDB]
	FROM DISK = N'D:\OneDrive\SQL Server\Sample Data\SalesDB\SalesDBOriginal.bak'
	WITH MOVE N'SalesDBData' TO N'D:\SQLData\SalesDBData.mdf',
	MOVE N'SalesDBLog' TO N'D:\SQLLogs\SalesDBLog.ldf',
	REPLACE, STATS = 10;
GO
*/

-- Clear wait stats

RESTORE DATABASE SalesDBCopy
FROM DISK = N'D:\OneDrive\SQL Server\Sample Data\SalesDB\SalesDBOriginal.bak'
WITH MOVE N'SalesDBData'
     TO N'D:\SQLData\SalesDBDataCopy.mdf',
     MOVE N'SalesDBLog'
     TO N'D:\SQLLogs\SalesDBLogCopy.ldf',
     REPLACE,
     STATS = 10;
GO

-- Examine waiting tasks in WaitingTasks.sql as soon as the backup starts

-- Examine wait stats afterwards

DROP DATABASE SalesDBCopy;
GO
