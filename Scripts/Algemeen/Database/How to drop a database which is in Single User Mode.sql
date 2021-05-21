-------------------------------------------------------------------------------
-- How to Drop Database which is in Single User Mode
-------------------------------------------------------------------------------

/* ----------------------------------------------------------------------------
Scenario:
You are working as SQL Server DBA or developer, You have put the database in Single User Mode. Now you would like to drop the database.But when you use below statement to drop it gives you either of one error.

Msg 924, Level 14, State 1, Line 27
Database '' is already open and can only have one user at a time.

Msg 3702, Level 16, State 4, Line 9
Cannot drop database "" because it is currently in use.
---------------------------------------------------------------------------- */

EXEC sys.sp_who2;

/*
It returned you all processes but you don't see the database name in the list. 
Means no process is running. You tried to drop the database again but received 
the same error as given above.

Now you used below query to get more information and hoping it should return 
you the processid so you can kill it and then drop the database.
*/
SELECT *
FROM   sys.sysprocesses
WHERE  DB_NAME(dbid) = 'YourDBName';

/*
Instead of using sp_who2 and sys.sysprocesses, use below query and kill 
the spid.
*/

SELECT request_session_id
FROM   sys.dm_tran_locks
WHERE  resource_database_id = DB_ID('YourDBName');
GO

KILL 57;
GO


DROP DATABASE YourDatabaseName;
GO
