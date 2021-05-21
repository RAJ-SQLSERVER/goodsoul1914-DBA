/* ----------------------------------------------------------------------------
 – How Many VLFs are in My Databases?
---------------------------------------------------------------------------- */
DECLARE @query  VARCHAR(1000),
        @dbname VARCHAR(1000),
        @count  INT;

SET NOCOUNT ON;

DECLARE csr CURSOR FAST_FORWARD READ_ONLY FOR
SELECT name
FROM master.dbo.sysdatabases;

CREATE TABLE ##loginfo
(
    dbname VARCHAR(100),
    num_of_rows INT
);

OPEN csr;

FETCH NEXT FROM csr
INTO @dbname;

WHILE (@@fetch_status <> -1)
BEGIN

    CREATE TABLE #log_info
    (
        fileid TINYINT,
        file_size BIGINT,
        start_offset BIGINT,
        FSeqNo INT,
        status TINYINT,
        parity TINYINT,
        create_lsn NUMERIC(25, 0)
    );

    SET @query = 'DBCC loginfo (' + '''' + @dbname + ''') ';

    INSERT INTO #log_info
    EXEC (@query);

    SET @count = @@rowcount;

    DROP TABLE #log_info;

    INSERT ##loginfo
    VALUES (@dbname, @count);

    FETCH NEXT FROM csr
    INTO @dbname;
END;

CLOSE csr;
DEALLOCATE csr;

SELECT dbname,
       num_of_rows
FROM ##loginfo
WHERE num_of_rows > 50 --My rule of thumb is 50 VLFs. Your mileage may vary.
ORDER BY dbname;

DROP TABLE ##loginfo;


/* ----------------------------------------------------------------------------
 – How Many VLFs are in My Databases?
---------------------------------------------------------------------------- */
DECLARE @query  VARCHAR(1000),
        @dbname VARCHAR(1000),
        @count  INT;

SET NOCOUNT ON;

DECLARE csr CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT name
	FROM sys.databases;

CREATE TABLE ##loginfo
(
    dbname VARCHAR(100),
    num_of_rows INT
);

OPEN csr;

FETCH NEXT FROM csr
INTO @dbname;

WHILE (@@fetch_status <> -1)
BEGIN
    CREATE TABLE #log_info
    (
        RecoveryUnitId TINYINT,
        fileid TINYINT,
        file_size BIGINT,
        start_offset BIGINT,
        FSeqNo INT,
        status TINYINT,
        parity TINYINT,
        create_lsn NUMERIC(25, 0)
    );
    SET @query = 'DBCC loginfo (' + '''' + @dbname + ''') ';
    INSERT INTO #log_info
    EXEC (@query);
    SET @count = @@rowcount;
    DROP TABLE #log_info;
    INSERT ##loginfo
    VALUES (@dbname, @count);
    FETCH NEXT FROM csr
    INTO @dbname;
END;

CLOSE csr;
DEALLOCATE csr;

SELECT dbname,
       num_of_rows
FROM ##loginfo
WHERE num_of_rows >= 50
ORDER BY dbname;

DROP TABLE ##loginfo;
GO


/* ----------------------------------------------------------------------------
 – How Do I Lower a Database’s VLF Count?
---------------------------------------------------------------------------- */
DECLARE @file_name      sysname,
        @file_size      INT,
        @file_growth    INT,
        @shrink_command NVARCHAR(MAX),
        @alter_command  NVARCHAR(MAX);
SELECT @file_name = name,
       @file_size = (size / 128)
FROM sys.database_files
WHERE type_desc = 'log';
SELECT @shrink_command = N'DBCC SHRINKFILE (N''' + @file_name + N''' , 0, TRUNCATEONLY)';
PRINT @shrink_command;
EXEC sys.sp_executesql @shrink_command;
SELECT @shrink_command = N'DBCC SHRINKFILE (N''' + @file_name + N''' , 0)';
PRINT @shrink_command;
EXEC sys.sp_executesql @shrink_command;
SELECT @alter_command
    = N'ALTER DATABASE [' + DB_NAME() + N'] MODIFY FILE (NAME = N''' + @file_name + N''', SIZE = '
      + CAST(@file_size AS NVARCHAR) + N'MB)';
PRINT @alter_command;
EXEC sys.sp_executesql @alter_command;
GO
