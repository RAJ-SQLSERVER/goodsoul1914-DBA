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

-- Simple transaction
BEGIN TRAN;
GO

DELETE FROM salesdb.dbo.Sales
WHERE SalesID = 1;
GO
-- Execute to here...

-- Commit and run a larger transaction
COMMIT TRAN;
GO

DELETE FROM salesdb.dbo.Sales;
GO

-- Execute to here...

-- Then cancel the query and look again
