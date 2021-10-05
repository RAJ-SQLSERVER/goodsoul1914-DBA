USE [ParallelismTest];
GO

SET NOCOUNT ON;
GO

-- Clear latch stats in LatchStats.sql

DECLARE @ExecString VARCHAR (8000);
DECLARE @starttime DATETIME;

WHILE (1=1)
BEGIN
	SELECT @starttime = GETDATE ();
	
	-- Calculate doc name length
	SELECT @ExecString = 'SELECT TOP 10 * FROM [NonSparseDocRepository] ORDER BY [c' +
		CAST (3 + CONVERT (INT, RAND () * 996) AS VARCHAR) +
		'] DESC OPTION (MAXDOP 8)';
		
	EXEC (@ExecString);
	
	SELECT DATEDIFF (SECOND, @starttime, GETDATE ());
	
	--WAITFOR DELAY '00:00:00.5';
END;
GO

-- Look at latch stats in LatchStats.sql

-- You can do the same thing for the workload
-- used in the PAGELATCH_XX demo

-- Stop the test