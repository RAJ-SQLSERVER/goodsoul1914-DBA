IF OBJECTPROPERTY(OBJECT_ID('usp_SearchErrorLogs'), 'IsProcedure') = 1
    DROP PROCEDURE dbo.usp_SearchErrorLogs;
GO

CREATE PROCEDURE usp_SearchErrorLogs
	@StartDate NVARCHAR(8) = NULL,
	@EndDate NVARCHAR(8) = NULL,
    @SearchString1 NVARCHAR(500) = NULL,
    @SearchString2 NVARCHAR(500) = NULL
AS
BEGIN
    IF OBJECT_ID(N'tempdb..#LogInfo', 'U') IS NOT NULL
        DROP TABLE #LogInfo;

    DECLARE @FileList AS TABLE
    (
        subdirectory NVARCHAR(4000) NOT NULL,
        DEPTH BIGINT NOT NULL,
        [FILE] BIGINT NOT NULL
    );

    DECLARE @ErrorLog     NVARCHAR(4000),
            @ErrorLogPath NVARCHAR(4000);
    SELECT @ErrorLog = CAST(SERVERPROPERTY(N'errorlogfilename') AS NVARCHAR(4000));
    SELECT @ErrorLogPath = SUBSTRING(@ErrorLog, 1, LEN(@ErrorLog) - CHARINDEX(N'\', REVERSE(@ErrorLog))) + N'\';

    INSERT INTO @FileList
    EXEC sys.xp_dirtree @ErrorLogPath, 0, 1;

    DECLARE @NumberOfLogfiles INT;
    SET @NumberOfLogfiles = (
        SELECT COUNT(*) FROM @FileList WHERE subdirectory LIKE N'ERRORLOG%'
    );
    -- SELECT @NumberOfLogfiles;
    ----------------------------------------------------------------------
    CREATE TABLE #LogInfo
    (
        LogDate DATETIME,
        ProcessInfo NVARCHAR(500),
        ErrorText NVARCHAR(MAX)
    );

    DECLARE @p1 INT = 0; -- P1 is the file number starting at 0

    WHILE @p1 < @NumberOfLogfiles
    BEGIN

        DECLARE @p2 INT           = 1,
                @p3 NVARCHAR(255) = @SearchString1,
                @p4 NVARCHAR(255) = @SearchString2;

        BEGIN TRY
            INSERT INTO #LogInfo
            EXEC sys.xp_readerrorlog @p1, @p2, @p3, @p4;
        END TRY
        BEGIN CATCH
            PRINT 'Error occurred processing file ' + CAST(@p1 AS VARCHAR(10));
        END CATCH;

        SET @p1 = @p1 + 1;
    END;

	DECLARE @Where NVARCHAR(255) = N'1 = 1';

	IF @StartDate IS NOT NULL
		SET @Where += N' AND LogDate >= ''' + @StartDate + N'''';

	IF @EndDate IS NOT NULL
		SET @Where += N' AND LogDate < ''' + @EndDate + N'''';

	DECLARE @SqlToExecute NVARCHAR(512) = N'SELECT * 
		FROM #LogInfo
		WHERE ' + @Where +   
		N' ORDER BY LogDate DESC;'
	
	PRINT @SqlToExecute

	EXEC sp_executesql @SqlToExecute
END;
