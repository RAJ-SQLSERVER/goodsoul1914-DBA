/*
Original link: https://sqlundercover.com/2017/06/06/undercover-toolbox-sp_failedlogins-capture-those-failed-logins-with-ease
Author: David Fowler
*/

USE [DBA];
GO

CREATE PROCEDURE [dbo].[usp_FailedLogins]
(
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
)
AS
BEGIN
    IF @FromDate IS NULL
    BEGIN
        SET @FromDate = DATEADD(HOUR, -6, GETDATE());
    END;
    IF @ToDate IS NULL
    BEGIN
        SET @ToDate = GETDATE();
    END;

    IF OBJECT_ID('Tempdb..#Errors') IS NOT NULL
        DROP TABLE #Errors;

    CREATE TABLE #Errors
    (
        Logdate DATETIME,
        Processinfo VARCHAR(30),
        Text VARCHAR(255)
    );
    INSERT INTO #Errors
    EXEC xp_readerrorlog 0, 1, N'FAILED', N'login', @FromDate, @ToDate;

    SELECT REPLACE(LoginErrors.Username, '''', '') AS Username,
           CAST(LoginErrors.Attempts AS NVARCHAR(6)) AS Attempts,
           LatestDate.Logdate,
           LatestDate.LastError
    FROM
    (
        SELECT SUBSTRING(Text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text))) AS Username,
               COUNT(*) AS Attempts
        FROM #Errors Errors
        GROUP BY SUBSTRING(Text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text)))
    ) LoginErrors
        CROSS APPLY
    (
        SELECT TOP (1)
               Logdate,
               Text AS LastError
        FROM #Errors LatestDate
        WHERE LoginErrors.Username = SUBSTRING(
                                                  Text,
                                                  PATINDEX('%''%''%', Text),
                                                  CHARINDEX('.', Text) - (PATINDEX('%''%''%', Text))
                                              )
        ORDER BY Logdate DESC
    ) LatestDate
    ORDER BY LoginErrors.Attempts DESC;

END;
GO
