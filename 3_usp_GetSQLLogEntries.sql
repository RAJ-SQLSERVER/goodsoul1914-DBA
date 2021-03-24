/****************************************************************************/
/*							 DBA Framework									*/
/*                                                                          */
/*						Written by Mark Boomaars							*/
/*					 http://www.bravisziekenhuis.nl							*/
/*                        m.boomaars@bravis.nl								*/
/****************************************************************************/
/*                       Get SQL Server Log Entries                         */
/****************************************************************************/

CREATE OR ALTER PROCEDURE dbo.usp_GetSQLLogEntries (@LogType       VARCHAR(50) = NULL, -- ErrorLog, AgentLog, DefaultTrace
                                                    @Group         BIT         = 0,
                                                    @StartDate     VARCHAR(50) = NULL,
                                                    @EndDate       VARCHAR(50) = NULL,
                                                    @UseExclusions BIT         = 1,
                                                    @PrintSql      BIT         = 0,
                                                    @ExecSql       BIT         = 1
)
AS
BEGIN
    DECLARE @Sql NVARCHAR(MAX) = N'';

    IF @Group = 1
    BEGIN
        SET @Sql = N'
			SELECT SUBSTRING (CONVERT (NVARCHAR(10), LogDate, 120), 1, 10) AS "LogDate",
				   ProcessInfo,
				   LogText,
				   COUNT (*) AS "Occurrence"
			FROM dbo.DBA_ServerLogging 
			WHERE 1 = 1';
    END;
    ELSE
    BEGIN
        SET @Sql = N'
			SELECT SQLInstance,
				   LogDate,
				   ProcessInfo,
				   LogText
			FROM dbo.DBA_ServerLogging 
			WHERE 1 = 1';
    END;

    IF @LogType IS NOT NULL
        SET @Sql += N' 
				AND LogType = ''' + @LogType + N'''';

    IF @StartDate IS NOT NULL
        SET @Sql += N' 
				AND LogDate >= ''' + @StartDate + N'''';

    IF @EndDate IS NOT NULL
        SET @Sql += N' 
				AND LogDate <= ''' + @EndDate + N'''';

    IF @UseExclusions = 1
    BEGIN
        SELECT @Sql += N' 
				AND LogText NOT LIKE ''' + Text + N''''
        FROM dbo.DBA_ServerLogging_Exclusions
        ORDER BY Text;
    END;

    IF @Group = 1
        SET @Sql += N' 
			GROUP BY SUBSTRING (CONVERT (NVARCHAR(10), LogDate, 120), 1, 10), ProcessInfo, LogText
			ORDER BY LogDate DESC, Occurrence DESC, ProcessInfo, LogText
		';
    ELSE SET @Sql += N' ORDER BY LogDate DESC, ProcessInfo, LogText';

    IF @PrintSql = 1 PRINT @Sql;

    IF @ExecSql = 1 EXEC (@Sql);
END;
GO
