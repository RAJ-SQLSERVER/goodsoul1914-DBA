USE MASTER
GO

DECLARE @name VARCHAR(50) -- database name    
DECLARE @path VARCHAR(256) -- path for backup files    
DECLARE @fileName VARCHAR(256) -- filename for backup    
DECLARE @fileDate VARCHAR(20) -- used for file name  
DECLARE @kill VARCHAR(8000) = '';

-- kill session for db 
SET @path = 'D:\LSBackup\' --Mention Tail log Backup location 

SELECT @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112) + ' _ ' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ' :', '')

DECLARE db_cursor CURSOR
FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name IN (' ReportServer ', ' ReportServerTempDB ') -- Mention list of Databases to be Switched over  AND DATABASEPROPERTYEX(name, ' Recovery ') IN (' FULL ',' BULK_LOGGED ')  

OPEN db_cursor

FETCH NEXT
FROM db_cursor
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @kill = @kill + ' KILL ' + CONVERT(VARCHAR(5), session_id) + ';'
	FROM sys.dm_exec_sessions
	WHERE database_id = db_id(@name)

	EXEC (@kill);

	PRINT ' Sessions Killed ON ' + @name
	PRINT ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '

	FETCH NEXT
	FROM db_cursor
	INTO @name
END

CLOSE db_cursor

OPEN db_cursor

FETCH NEXT
FROM db_cursor
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @fileName = @path + @name + ' _ ' + @fileDate + '.TRN '

	BACKUP LOG @name TO DISK = @fileName
	WITH NORECOVERY,
		COMPRESSION

	PRINT ' Log BACKUP generated FOR ' + @name
	PRINT ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '
	PRINT ' RESTORE LOG ' + @name + ' FROM DISK = ''' + @filename + ''' WITH RECOVERY ' --This will create restore script   
	PRINT ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '

	FETCH NEXT
	FROM db_cursor
	INTO @name
END

CLOSE db_cursor

DEALLOCATE db_cursor
