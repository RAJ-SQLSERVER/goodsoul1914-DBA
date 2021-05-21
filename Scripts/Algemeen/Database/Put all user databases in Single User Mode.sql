-------------------------------------------------------------------------------
-- Put all user databases in Single User Mode
-------------------------------------------------------------------------------

USE master;
GO

DECLARE @DatabaseName AS VARCHAR(128);

DECLARE Cur CURSOR FOR
--Get list of Database those we want to put into Single User Mode
SELECT name
FROM   sys.databases
WHERE  user_access_desc = 'Multi_USER'
       AND name NOT IN ( 'master', 'tempdb', 'model', 'msdb' );

OPEN Cur;

FETCH NEXT FROM Cur
INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN
    --Inner Cursor Start
    --Kill all connection to DB before Putting into Single User Mode
    DECLARE @Spid INT;

    DECLARE KillProcessCur CURSOR FOR
    SELECT request_session_id
    FROM   sys.dm_tran_locks
    WHERE  resource_database_id = DB_ID(@DatabaseName);

    OPEN KillProcessCur;

    FETCH NEXT FROM KillProcessCur
    INTO @Spid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SQL VARCHAR(500) = NULL;
        SET @SQL = 'Kill ' + CAST(@Spid AS VARCHAR(5));
        EXEC (@SQL);

        PRINT 'ProcessID =' + CAST(@Spid AS VARCHAR(5)) + ' killed successfull';

        FETCH NEXT FROM KillProcessCur
        INTO @Spid;
    END;

    CLOSE KillProcessCur;

    DEALLOCATE KillProcessCur;

    --Inner Cursor Ends
    --Outer Cursor: Put DB in single User Mode
    DECLARE @SQLSingleUSer NVARCHAR(MAX) = NULL;
    SET @SQLSingleUSer = N'ALTER DATABASE [' + @DatabaseName + N'] 
						 SET SINGLE_USER WITH ROLLBACK IMMEDIATE';

    PRINT @SQLSingleUSer;

    EXEC (@SQLSingleUSer);

    FETCH NEXT FROM Cur
    INTO @DatabaseName;
END;

CLOSE Cur;

DEALLOCATE Cur;

--Check if all DBS are in Single Mode
SELECT name AS DBName,
       state_desc,
       user_access_desc
FROM   sys.databases
WHERE  user_access_desc = 'SINGLE_USER';