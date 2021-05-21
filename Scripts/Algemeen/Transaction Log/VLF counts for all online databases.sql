/* ----------------------------------------------------------------------------
 – Find VLF counts per database

   Resolution
   If the database is in Simple recovery model and doesn’t see much traffic, 
   this is easy enough to fix. Manually shrink the log file as small as it will 
   go, verify the autogrow is appropriate, and grow it back to its normal size. 
   If the database is in Full recovery model and is in high use, it’s a little 
   more complex. Follow these steps (you may have to do it more than once):

   - Take a transaction log backup .
   - Issue a CHECKPOINT manually.
   - Check the empty space in the transaction log to make sure you have room 
   to shrink it.
   - Shrink the log file as small as it will go.
   - Grow the file back to its normal size.
   - Lather, Rinse, Repeat as needed

   Now check your VLF counts again, and make sure you are down to a nice low 
   number. Done!
---------------------------------------------------------------------------- */

--variables to hold each 'iteration'  
DECLARE @query VARCHAR(100);
DECLARE @dbname sysname;
DECLARE @vlfs INT;

--table variable used to 'loop' over databases  
DECLARE @databases TABLE
(
    dbname sysname
);
INSERT INTO @databases
--only choose online databases  
SELECT name
FROM sys.databases
WHERE state = 0;

--table variable to hold results  
DECLARE @vlfcounts TABLE
(
    dbname sysname,
    vlfcount INT
);

--table variable to capture DBCC loginfo output  
--changes in the output of DBCC loginfo from SQL2012 mean we have to determine the version 

DECLARE @MajorVersion TINYINT;
SET @MajorVersion
    = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)), 
		CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX))) - 1);

IF @MajorVersion < 11 -- pre-SQL2012 
BEGIN
    DECLARE @dbccloginfo TABLE
    (
        fileid SMALLINT,
        file_size BIGINT,
        start_offset BIGINT,
        fseqno INT,
        status TINYINT,
        parity TINYINT,
        create_lsn NUMERIC(25, 0)
    );

    WHILE EXISTS (SELECT TOP 1 dbname FROM @databases)
    BEGIN

        SET @dbname = (
            SELECT TOP 1 dbname FROM @databases
        );
        SET @query = 'dbcc loginfo (' + '''' + @dbname + ''') ';

        INSERT INTO @dbccloginfo
        EXEC (@query);

        SET @vlfs = @@rowcount;

        INSERT @vlfcounts
        VALUES (@dbname, @vlfs);

        DELETE FROM @databases
        WHERE dbname = @dbname;

    END; --while 
END;
ELSE
BEGIN
    DECLARE @dbccloginfo2012 TABLE
    (
        RecoveryUnitId INT,
        fileid SMALLINT,
        file_size BIGINT,
        start_offset BIGINT,
        fseqno INT,
        status TINYINT,
        parity TINYINT,
        create_lsn NUMERIC(25, 0)
    );

    WHILE EXISTS (SELECT TOP 1 dbname FROM @databases)
    BEGIN

        SET @dbname = (
            SELECT TOP 1 dbname FROM @databases
        );
        SET @query = 'dbcc loginfo (' + '''' + @dbname + ''') ';

        INSERT INTO @dbccloginfo2012
        EXEC (@query);

        SET @vlfs = @@rowcount;

        INSERT @vlfcounts
        VALUES (@dbname, @vlfs);

        DELETE FROM @databases
        WHERE dbname = @dbname;

    END; --while 
END;

--output the full list  
SELECT dbname,
       vlfcount
FROM @vlfcounts
ORDER BY dbname;
GO



DECLARE @DB_NAME NVARCHAR(50);
DECLARE @DB_ID AS SMALLINT;
DECLARE @SQLString2 AS NVARCHAR(MAX);
DECLARE @COUNT AS INT;
IF OBJECT_ID('tempdb..#VLFInfo') != 0 DROP TABLE #VLFInfo;
CREATE TABLE #VLFInfo
(
    ServerName VARCHAR(50),
    DatabaseName VARCHAR(50),
    VLFCount INT
);
IF OBJECT_ID('tempdb..#log_info') != 0 DROP TABLE #log_info;
CREATE TABLE #log_info
(
    recoveryunitid TINYINT,
    fileid TINYINT,
    file_size BIGINT,
    start_offset BIGINT,
    FSeqNo INT,
    status TINYINT,
    parity TINYINT,
    create_lsn NUMERIC(25, 0)
);

DECLARE db_cursor CURSOR FOR
SELECT name AS database_name,
       database_id AS database_id
FROM sys.databases
WHERE database_id > 4; -- exclude master, msdb, model, tempdb
OPEN db_cursor;
FETCH NEXT FROM db_cursor
INTO @DB_NAME,
     @DB_ID;

DECLARE @ProductBuild AS INT;
SET @ProductBuild = PARSENAME(CONVERT(VARCHAR, SERVERPROPERTY('ProductVersion')), 4);

WHILE @@FETCH_STATUS = 0
BEGIN

    IF @ProductBuild >= 11 -- Applies TO: SQL Server 2014 (12.x) through SQL Server 2017, SQL DATABASE.
    BEGIN

        SET @SQLString2
            = N'SELECT ''' + @@SERVERNAME + N''' AS Servername' + N',''' + @DB_NAME + N''' AS database_name'
              + N', COUNT(database_id) AS "vlf_count"' + N' FROM sys.dm_db_log_info(' + CONVERT(VARCHAR, @DB_ID) + N')';
        PRINT @SQLString2;
        INSERT INTO #VLFInfo (ServerName, DatabaseName, VLFCount)
        EXECUTE sys.sp_executesql @SQLString2;
    END;
    ELSE
    BEGIN
        SET @SQLString2 = N'DBCC LOGINFO (' + N'''' + @DB_NAME + N''')';

        PRINT @SQLString2;
        INSERT INTO #log_info
        EXEC (@SQLString2);

        SET @COUNT = @@ROWCOUNT;
        TRUNCATE TABLE #log_info;

        INSERT INTO #VLFInfo (ServerName, DatabaseName, VLFCount)
        SELECT @@SERVERNAME,
               @DB_NAME,
               @COUNT;

    END;
    FETCH NEXT FROM db_cursor
    INTO @DB_NAME,
         @DB_ID;

END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

SELECT *
FROM #VLFInfo
WHERE 1 = 1
      --AND VLFCount >= 100
ORDER BY DatabaseName;
GO
