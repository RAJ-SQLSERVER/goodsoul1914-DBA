/****************************************************************************/
/*							 DBA Framework									*/
/*                                                                          */
/*						Written by Mark Boomaars							*/
/*					 http://www.bravisziekenhuis.nl							*/
/*                        m.boomaars@bravis.nl								*/
/*																			*/
/*							  2021-03-25									*/
/****************************************************************************/
/*                   Process SQL Server Log Entries                         */
/*					and send mail alerts about events						*/
/****************************************************************************/

CREATE OR ALTER PROCEDURE dbo.usp_ProcessSQLLogEntries @profile_name sysname,
                                                       @recipients   VARCHAR(MAX)
AS
BEGIN
    DECLARE @LastProcessedDateTime VARCHAR(20) = NULL;
    DECLARE @subj VARCHAR(200),
            @body NVARCHAR(MAX),
            @xml  NVARCHAR(MAX);
	
	-- When was the errorlog last processed?
	SELECT @LastProcessedDateTime = Value
    FROM dbo.DBA_Config
    WHERE [Key] = 'LastProcessedDateTime';

	-- Create a temp table
    IF OBJECT_ID ('tempdb.dbo.#SQLErrorLog') IS NOT NULL DROP TABLE #SQLErrorLog;
    CREATE TABLE #SQLErrorLog (
        SQLInstance VARCHAR(100)   NOT NULL,
        LogDate     DATETIME       NOT NULL,
        ProcessInfo NVARCHAR(200)  NOT NULL,
        LogType     VARCHAR(20)    NULL,
        LogText     NVARCHAR(3999) NULL,
        Count       INT            NULL
    );

	-- Store all applicable errorlog entries in a temp table
    INSERT INTO #SQLErrorLog (SQLInstance, LogDate, ProcessInfo, LogType, LogText, Count)
    EXEC dbo.usp_GetSQLLogEntries @LogType = N'Errorlog',
                                  @Group = 1,
                                  @UseExclusions = 1,
								  @StartDate = @LastProcessedDateTime,
                                  @ExecSql = 1;

    -------------------------------------------------------------------------------
    -- Failed Logins
    -------------------------------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM #SQLErrorLog
        WHERE CHARINDEX ('Login failed for user', LogText) > 0
    )
    BEGIN
        SELECT @subj = 'Failed SQL logins';
        SET @body = N'<html><body>
				   <font size="2" face="monaco">
				   (This mail was sent by the procedure ''' + DB_NAME () + N'.' + OBJECT_SCHEMA_NAME (@@PROCID) + N'.'
                    + OBJECT_NAME (@@PROCID)
                    + N''') <BR><BR>                              
				   The table below contains the most recent overview of SQL failed logins.  
				   <h3>SQL Server Failed Logins</h3>
				   <table border="1" cellpadding="5"> 
				   <tr> <th> Server </th> <th> Date </th> <th> Login Name </th> <th> Client Name </th> <th> Extra Info </th> </tr>';
        SELECT @xml = CAST((
            SELECT SQLInstance AS "td",
                   '', -- SQL Instance
                   CONVERT (CHAR(30), LogDate, 21) AS "td",
                   '', -- Date
                   CASE
                       WHEN CHARINDEX ('''''', LogText) > 0 THEN ''
                       ELSE
                           LEFT(SUBSTRING (
                                    LogText,
                                    CHARINDEX ('''', LogText) + 1,
                                    CHARINDEX ('''', LogText, CHARINDEX ('''', LogText) + 1)
                                    - CHARINDEX ('''', LogText) - 1
                                ), 30)
                   END AS "td",
                   '', -- Login Name
                   LEFT(SUBSTRING (
                            LogText,
                            CHARINDEX ('[CLIENT', LogText) + 9,
                            CHARINDEX (']', LogText) - CHARINDEX ('[CLIENT', LogText) - 9
                        ), 17) AS "td",
                   '', -- Client Name
                   SUBSTRING (
                       LogText,
                       CHARINDEX ('Reason: ', LogText),
                       CHARINDEX ('. [CLIENT:', LogText) - CHARINDEX ('Reason: ', LogText)
                   ) AS "td",
                   ''  -- Extra info between the strings 'Reason:' and '[CLIENT:'
            FROM #SQLErrorLog
            WHERE CHARINDEX ('Login failed for user', LogText) > 0
            ORDER BY 1,
                     2,
                     3,
                     5
            FOR XML PATH ('tr'), ELEMENTS
        )   AS NVARCHAR(MAX));

        SET @body = @body + @xml + N'</table></body></html>';

        EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
                                     @recipients = @recipients,
                                     @subject = @subj,
                                     @body = @body,
                                     @body_format = 'HTML';
    END;

    -------------------------------------------------------------------------------
    -- Unusual SQL Server Errorlog entries
    -------------------------------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM #SQLErrorLog
        WHERE CHARINDEX ('Login failed for user', LogText) = 0
    )
    BEGIN
        SELECT @subj = 'SQL Errorlog entries';
        SET @body = N'<html><body>  
				<font size="2" face="monaco">
               (This mail was sent by the procedure ''' + DB_NAME () + N'.' + OBJECT_SCHEMA_NAME (@@PROCID) + N'.'
                    + OBJECT_NAME (@@PROCID)
                    + N''') <BR><BR>               
               The table below contains unusual SQL Log entries recorded during the last scan.
               <h3>SQL Errorlog entries</h3>
               <table border="1" cellpadding="5">               
               <tr>
               <th> Server </th> <th> Date </th> <th> Process </th> <th> Count </th> <th> Text </th> </tr>';

        SET @xml = CAST((
                       SELECT SQLInstance AS "td",
                              '',
                              CONVERT (CHAR(30), LogDate, 21) AS "td",
                              '',
                              ProcessInfo AS "td",
                              '',
                              Count AS "td",
                              '',
                              LogText AS "td",
                              ''
                       FROM #SQLErrorLog
                       WHERE CHARINDEX ('Login failed for user', LogText) = 0 -- no regular failed login warnings
                       ORDER BY SQLInstance,
                                Count DESC,
                                LogDate DESC
                       FOR XML PATH ('tr'), ELEMENTS
                   ) AS NVARCHAR(MAX));

        SET @body = @body + @xml + N'</table></body></html>';

        EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
                                     @recipients = @recipients,
                                     @subject = @subj,
                                     @body = @body,
                                     @body_format = 'HTML';
    END;

	UPDATE dbo.DBA_Config
    SET Value = GETDATE ()
    WHERE [Key] = 'LastProcessedDateTime';
END;
GO
