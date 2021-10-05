-- Set up the demo by running the code in the
-- C:\Pluralsight\SetupWorkload.sql file

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Look at WaitingTasks.sql

USE [HotSpot];
GO

ALTER INDEX [HotSpotTable_CL] ON [HotSpotTable]
SET (ALLOW_ROW_LOCKS=OFF);
GO

-- Look at WaitingTasks.sql

ALTER INDEX [HotSpotTable_CL] ON [HotSpotTable]
SET (ALLOW_ROW_LOCKS=ON);
GO

-- Look at WaitingTasks.sql

BEGIN TRAN;
GO
UPDATE [HotSpotTable] SET [c2] = 2;
GO

-- Look at WaitingTasks.sql

COMMIT TRAN;
GO

-- Look at WaitingTasks.sql

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

USE [master];
GO

IF DATABASEPROPERTYEX (N'HotSpot', N'Version') > 0
BEGIN
	ALTER DATABASE [HotSpot] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [HotSpot];
END
GO