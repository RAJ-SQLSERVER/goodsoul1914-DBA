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

-- Clear latch stats in LatchStats.sql

DBCC CHECKDB (N'SalesDB') WITH NO_INFOMSGS;
GO

-- Examine latches in LatchStats.sql