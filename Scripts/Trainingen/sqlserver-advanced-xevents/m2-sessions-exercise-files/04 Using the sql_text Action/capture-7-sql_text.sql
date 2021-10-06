-- Get the current session_id
SELECT @@SPID;

-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'sql_textAction')
	DROP EVENT SESSION [sql_textAction] 
	ON SERVER;
GO

-- Create the event session
-- **** Change the session_id to match this session ****
CREATE EVENT SESSION [sql_textAction] 
ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.sql_text)
    WHERE (sqlserver.session_id=54)),
ADD EVENT sqlserver.sql_statement_completed(
	SET collect_statement=1
    ACTION(sqlserver.sql_text)
    WHERE (sqlserver.session_id=54));
GO

-- Start the event session
ALTER EVENT SESSION [sql_textAction]
ON SERVER
STATE=START;
GO

-- Open the Live Data Viewer

-- Execute a number of statements in a single batch
SELECT PASSWORD = N'bar12345!!';
SELECT N'password' AS Secret;
CREATE LOGIN foo WITH PASSWORD = N'bar12345!!';
SELECT N'reallylongstringwithpasswordincludedintext' AS Funny;
EXEC(N'SELECT N''reallylongstringwithpasswordincludedintext'' AS Funny;');
GO


-- Perform the same statements in individual batches
SELECT PASSWORD = N'bar12345!!';
GO
SELECT N'password' AS Secret;
GO
CREATE LOGIN foo WITH PASSWORD = N'bar12345!!';
GO
SELECT N'reallylongstringwithpasswordincludedintext' AS Funny;
GO
EXEC(N'SELECT N''reallylongstringwithpasswordincludedintext'' AS Funny;');
GO