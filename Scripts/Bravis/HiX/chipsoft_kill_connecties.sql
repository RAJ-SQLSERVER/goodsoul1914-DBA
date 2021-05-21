USE HIX_PRODUCTIE

DECLARE UserCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    spid
FROM
    master.dbo.sysprocesses
WHERE DB_NAME(dbid) = 'HIX_PRODUCTIE'--replace the dbname with your database
DECLARE @spid SMALLINT
DECLARE @SQLCommand VARCHAR(300)
OPEN UserCursor
FETCH NEXT FROM UserCursor INTO
    @spid
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQLCommand = 'KILL ' + CAST(@spid AS VARCHAR)
    EXECUTE(@SQLCommand)
    FETCH NEXT FROM UserCursor INTO
        @spid
END
CLOSE UserCursor
DEALLOCATE UserCursor
GO
