/*
	Trace flags can be used for many things. They can be used to 
	capture information about what is happening. For example trace 
	flags 1204 and 1222  can be used to capture information about 
	deadlocks. Trace flags can be used to change the behavior of SQL 
	Server for example, trace flag 3226 can be used to suppress 
	successful backup messages in the error log.  You can even use 
	trace flags to change the behavior of the TempDB, trace flags 1117 
	and 1118 can help keep the TempDB files close to the same size by 
	changing how the data files grow.

	Microsoft document:
	https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql?view=sql-server-2017

	In order to use trace flags they must be enabled first.
*/

--The first step would be to determine which flags are currently enabled.
DBCC TRACESTATUS(-1);
GO

-- I just want to check the status of one or more specific trace flags
DBCC TRACESTATUS(1118, 3205, 1204);
GO

-- If you run this code the trace flag will be turned on for the session.
--
-- It means that the trace flag is only active for the current session and 
-- is not visible from other sessions.
DBCC TRACEON(2528);
GO

DBCC TRACESTATUS(2528);
GO

-- In order to enable the trace flag globally, you will need to make one 
-- simple change to the DBCC statement.
DBCC TRACEON(2528, -1);
GO

DBCC TRACESTATUS(2528);
GO

/*
	You may have the question of, what happens when I restart the 
	SQL Server service. The answer is simple, the trace flags will no 
	longer be enabled. If you would like to have the trace flags 
	enabled upon start up, you can add the -T command line startup 
	option for SQLServr.exe.  One thing that is important here is for 
	you to assure that the trace flags you would like to have enabled 
	to be enabled again when the service is restarted.
*/

-- Now let’s say you want to disable the trace flags.
DBCC TRACEOFF(2528, -1);
GO

-- To turn off a trace flag for a session use this
DBCC TRACEOFF(2528);
GO

-- Multiple trace flags:
DBCC TRACEON(2528, 3205, 1204, -1);
GO

DBCC TRACESTATUS(2528, 3205, 1204);
GO

