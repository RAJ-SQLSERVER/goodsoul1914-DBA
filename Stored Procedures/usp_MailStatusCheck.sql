USE DBA;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

BEGIN TRY
    DROP PROCEDURE dbo.usp_MailStatusCheck;
END TRY
BEGIN CATCH
END CATCH;
GO

CREATE PROCEDURE dbo.usp_MailStatusCheck @Test NVARCHAR(3) = NULL
AS
BEGIN
    BEGIN
        SET NOCOUNT ON;

        -- File name : usp_MailStatusCheck.sql
        -- Author    : Graham Okely B App Sc (IT)
        -- Reference : https://www.mssqltips.com/sqlserverauthor/106/graham-okely/

        DECLARE @Report_Name NVARCHAR(128) = N'SQL Server Status Report';
        -- Just in case @@Servername is null
        DECLARE @Instance NVARCHAR(128)
            =   (
                    SELECT ISNULL(
                               @@Servername, CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + '\' + @@servicename
                           )
                );
        -- Get this many days from the SQL Agent log
        DECLARE @Log_Days_Agent INT = 4;
        -- Build a table for the report
        DECLARE @SQL_Status_Report TABLE
        (
            Line_Number INT NOT NULL IDENTITY(1, 1),
            Information NVARCHAR(MAX)
        );

        -- Main title of the report
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'SQL Server Status Check Report on ' + @Instance + ' at ' + CAST(GETDATE() AS NVARCHAR(28));

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'On node : ' + CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS NVARCHAR(1024));

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT @@version;

        -- This line makes a blank row in the report
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT '';

        -- Get the last restart date and time from sqlserver_start_time
        INSERT INTO @SQL_Status_Report
        SELECT 'Start time from DMV sqlserver_start_time ' + CAST(sqlserver_start_time AS NVARCHAR(28))
        FROM   sys.dm_os_sys_info;

        -- Disk Drive Space
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Drive space on ' + @Instance + ' (Lowest space free first)';

        DECLARE @drives TABLE
        (
            drive NVARCHAR(1),
            MbFree INT
        );

        INSERT INTO @drives
        EXEC sys.xp_fixeddrives;

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT   drive + ' has  ' + CAST(MbFree / 1000 AS NVARCHAR(20)) + ' GB Free'
        FROM     @drives
        ORDER BY MbFree ASC; -- Show least amount of space first			
        -- Users added in the last X days
        DECLARE @DaysBack INT = 7;

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Users added in last ' + CAST(@DaysBack AS NVARCHAR(12)) + ' days';

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT name + ' ' + type_desc + ' ' + CAST(create_date AS NVARCHAR(28)) + ' '
               + CAST(DATEDIFF(DAY, create_date, GETDATE()) AS NVARCHAR(12)) + ' days ago'
        FROM   sys.server_principals
        WHERE  type_desc IN ( 'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'SQL_LOGIN' )
               AND DATEDIFF(DAY, create_date, GETDATE()) < @DaysBack;

        -- Gather summary of databases using sp_helpdb
        DECLARE @sp_helpdb_results TABLE
        (
            db_name NVARCHAR(256),
            db_size NVARCHAR(25),
            owner NVARCHAR(128),
            db_id INT,
            created_data DATETIME,
            status NVARCHAR(MAX),
            compatability INT
        );

        INSERT INTO @sp_helpdb_results
        EXEC sys.sp_helpdb;

        -- Flag databases with an unknown status
        INSERT INTO @sp_helpdb_results
        (
            db_name,
            owner,
            db_size
        )
        SELECT name,
               'Database Status Unknown' COLLATE DATABASE_DEFAULT,
               0
        FROM   sys.sysdatabases
        WHERE  name COLLATE DATABASE_DEFAULT NOT IN (
                   SELECT db_name COLLATE DATABASE_DEFAULT FROM @sp_helpdb_results
               );

        -- Remove " MB"
        UPDATE @sp_helpdb_results
        SET    db_size = REPLACE(db_size, ' MB', '');

        DELETE FROM @sp_helpdb_results
        WHERE db_size = '0';

        -- Report summary of databases using sp_helpdb
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT @Instance + ' has ' + CAST(COUNT(*) AS NVARCHAR(8)) + ' databases with '
               + CAST(CAST(SUM(CAST(REPLACE(db_size, ' MB', '') AS FLOAT)) AS INT) / 1000 AS NVARCHAR(20))
               + ' GB of data'
        FROM   @sp_helpdb_results;

        -- Database sizes
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Largest database on ' + @Instance + ' in MB';

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT   TOP (1)
                 db_name + ' ' + CONVERT(NVARCHAR(10), ROUND(CONVERT(NUMERIC, LTRIM(REPLACE(db_size, ' Mb', ''))), 0))
        FROM     @sp_helpdb_results
        ORDER BY db_size DESC;

        -- Oldest backup
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Oldest full database backup on ' + @Instance;

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT   TOP (1)
                 LEFT(database_name, 30) + ' '
                 + COALESCE(CONVERT(VARCHAR(10), MAX(backup_finish_date), 121), 'Not Yet Taken')
        FROM     msdb..backupset
        WHERE    database_name NOT IN ( 'tempdb' )
                 AND type = 'D'
        GROUP BY database_name
        ORDER BY MAX(backup_finish_date) ASC;

        -- Agent log information
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Agent log check on ' + @Instance + ' Last ' + CAST(@Log_Days_Agent AS NVARCHAR(12)) + ' days';

        DECLARE @SqlAgenterrorLog TABLE
        (
            logdate DATETIME,
            ProcessInfo VARCHAR(29),
            errortext VARCHAR(MAX)
        );

        INSERT INTO @SqlAgenterrorLog
        EXEC sys.xp_readerrorlog 0, 2;

        -- Report
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT   DISTINCT
                 CAST(logdate AS NVARCHAR(28)) + ' ' + ProcessInfo + ' ' + LEFT(errortext, 300)
        FROM     @SqlAgenterrorLog
        WHERE    logdate > DATEDIFF(DAY, -@Log_Days_Agent, GETDATE())
        ORDER BY 1 DESC;

        -- Server log last 20 rows
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'Sql Server log check on ' + @Instance + ' top 20 rows';

        DECLARE @SqlerrorLog TABLE
        (
            logdate DATETIME,
            ProcessInfo VARCHAR(29),
            errortext VARCHAR(MAX)
        );

        INSERT INTO @SqlerrorLog
        EXEC sys.xp_readerrorlog;

        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT   TOP (20)
                 CAST(logdate AS NVARCHAR(28)) + ' ' + ProcessInfo + ' ' + LEFT(errortext, 300)
        FROM     @SqlerrorLog
        ORDER BY 1 DESC;

        -- Report Footer
        INSERT INTO @SQL_Status_Report
        (
            Information
        )
        SELECT 'End of the ' + @Report_Name + ' on ' + @Instance + ' at ' + CAST(GETDATE() AS NVARCHAR(28));
    END;

    -- Prepare email
    DECLARE @xml NVARCHAR(MAX);
    DECLARE @body NVARCHAR(MAX);

    SET @xml = CAST((
                   SELECT   LTRIM(Information) AS td
                   FROM     @SQL_Status_Report
                   ORDER BY Line_Number
                   FOR XML PATH('tr'), ELEMENTS
               ) AS NVARCHAR(MAX));

    DECLARE @Subject_Line NVARCHAR(128) = N'SQL Server Status Report from ' + @Instance;

    SET @body = N'<html><body><table border = 1 width="80%"><th><H3>' + @Subject_Line + N'</H3></th>';
    SET @body = @body + @xml + N'</table></body></html>';

    IF @Test = 'Yes'
    BEGIN
        SET @Subject_Line = @Subject_Line + N' Test Mode';

        EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPNMail', 
                                     @body = @body,
                                     @body_format = 'HTML',
                                     @recipients = 'mboomaars@gmail.com',
                                     @subject = @Subject_Line;

        PRINT @body;
    END;
    ELSE
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPNMail',
                                     @body = @body,
                                     @body_format = 'HTML',
                                     @recipients = 'mboomaars@gmail.com', 
                                     @subject = @Subject_Line;
    END;
END;