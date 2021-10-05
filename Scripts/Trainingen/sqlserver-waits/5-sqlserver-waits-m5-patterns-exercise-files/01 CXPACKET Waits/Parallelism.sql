USE [ParallelismTest];
GO

SET NOCOUNT ON;
GO

-- Clear wait stats in WaitStats1.sql

DECLARE @ExecString VARCHAR (8000);
DECLARE @starttime DATETIME;

WHILE (1=1)
BEGIN
	SELECT @starttime = GETDATE ();
	
	-- Calculate doc name length
	SELECT @ExecString = 
	'SELECT TOP 10 * FROM [NonSparseDocRepository] ORDER BY [c' +
		CAST (3 + CONVERT (INT, RAND () * 996) AS VARCHAR) +
		'] DESC OPTION (MAXDOP 8)';
		
	EXEC (@ExecString);
	
	SELECT DATEDIFF (SECOND, @starttime, GETDATE ());
END;
GO

-- Look at sys.dm_os_waiting_tasks in WaitingTasks.sql
-- Problem is thread not waiting for CXPACKET

-- Look at wait stats in WaitStats1.sql
-- Look at costs in ParallelCosts.sql

-- Stop the test

-- Clear wait stats in WaitStats2.sql
-- Add in OPTION (MAXDOP 2) and re-run the test
-- Look at wait stats in WaitStats2.sql
-- Compare the times - they're slower

-- Stop the test

-- Clear wait stats in WaitStats2.sql
-- Add in OPTION (MAXDOP 1), and re-run the test
-- Look at wait stats in WaitStats2.sql

-- Stop the test