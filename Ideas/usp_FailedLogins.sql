CREATE PROC dbo.usp_FailedLogins (
    @FromDate DATETIME = NULL,
    @ToDate   DATETIME = NULL
)
AS
BEGIN
    IF @FromDate IS NULL
    BEGIN
        SET @FromDate = DATEADD(DAY, -7, GETDATE());
    END;
    IF @ToDate IS NULL
    BEGIN
        SET @ToDate = GETDATE();
    END;

    IF OBJECT_ID('Tempdb..#Errors') IS NOT NULL
        DROP TABLE #Errors;

    CREATE TABLE #Errors (
        Logdate     DATETIME,
        Processinfo VARCHAR(30),
        Text        VARCHAR(255)
    );
    INSERT INTO #Errors
    EXEC xp_readerrorlog 0, 1, N'FAILED', N'login', @FromDate, @ToDate;

    SELECT      REPLACE(LoginErrors.Username, '''', '') AS Username,
                CAST(LoginErrors.Attempts AS NVARCHAR(6)) AS Attempts,
                LatestDate.Logdate,
                LatestDate.LastError
    FROM        (
        SELECT   SUBSTRING(Text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text))) AS Username,
                 COUNT(*) AS Attempts
        FROM     #Errors AS Errors
        GROUP BY SUBSTRING(Text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text)))
    ) AS LoginErrors
    CROSS APPLY (
        SELECT   TOP (1)
                 Logdate,
                 Text AS LastError
        FROM     #Errors AS LatestDate
        WHERE    LoginErrors.Username = SUBSTRING(
                                            Text,
                                            PATINDEX('%''%''%', Text),
                                            CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text))
                                        )
        ORDER BY Logdate DESC
    ) AS LatestDate
    ORDER BY    LoginErrors.Attempts DESC;

END;
GO
