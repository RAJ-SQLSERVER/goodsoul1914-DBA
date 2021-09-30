-- Now set up the demo by running the code in the
-- C:\Pluralsight\SetupWorkload.sql file

-- Clear waits in WaitStats1.sql

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Examine waiting tasks
-- Examine wait stats in WaitStats1.sql

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