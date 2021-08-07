USE [master]

--clear backup history, maintenance plan history, SQL Agent job history and Database Mail history one day at a time
--from the msdb system database by calling system stored procedures in the msdb system database
--this script can be used when clearing has not yet been done (as at SQL Server 2016, by default, no automated clearing is set up on new servers)
--why do this one day at a time? Clearing years' worth of history at once will possibly impact performance including running SQL Agent jobs
--after running this script, a SQL Agent job should be created & scheduled to clear regularly (suggest weekly), only keeping the last 30 days
--you may also want to check msdb system database data and log file sizes and free space following running this script
--adapted from https://sqlnotesfromtheunderground.wordpress.com/2014/08/26/purge-msdb-backup-history-in-chunks/
--will need high level permission to run this script (sysadmin) as per https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-purge-jobhistory-transact-sql
--tested on SQL Server 2016

--earliest date in backup or maintenance plan history tables
--start with backup history table
DECLARE @start_date DATE = (SELECT CONVERT(DATE, MIN([backup_start_date])) FROM msdb..[backupset] (READPAST))
--check maintenence plan history table - if older than backup history, set start date to new earliest date
--possibly maintenance plans are not in use on the server, in which case will keep original earliest date from backup history table
IF @start_date IS NULL OR (SELECT CONVERT(DATE, MIN([start_time])) FROM msdb..[sysmaintplan_logdetail] (READPAST)) < @start_date BEGIN
    SELECT @start_date = CONVERT(DATE, MIN([start_time])) FROM msdb..[sysmaintplan_logdetail] (READPAST)
END
--check database mail history - if older, set start date to this date
IF @start_date IS NULL OR (SELECT CONVERT(DATE, MIN([log_date])) FROM msdb..[sysmail_event_log] (READPAST)) < @start_date BEGIN
    SELECT @start_date = CONVERT(DATE, MIN([log_date])) FROM msdb..[sysmail_event_log] (READPAST)
END
--could also check SQL Agent job history - not done here, as by default limited to 1,000 records (so probably not as much history as default backup history)

--date to delete to
--should start by setting close to start date (to delete less records)
--for this sample script, setting to 100 days ago USE WITH CAUTION
--this should eventually be set to 30 and run regularly
DECLARE @end_date DATE = (SELECT CONVERT(DATE, DATEADD(DAY, -100, GETDATE())))

--sanity check: do we have a start date? And is the start date earlier than the end date? If not, nothing to delete
IF @start_date IS NULL BEGIN
    PRINT 'No data to delete'
END ELSE IF @start_date > @end_date BEGIN
    PRINT 'No data to delete - oldest data is newer than the date to delete to'
END ELSE BEGIN
    PRINT 'Looping until ' + CONVERT(VARCHAR(25), @end_date, 113) + ' (' + CONVERT(VARCHAR(25), DATEDIFF(DAY, @start_date, @end_date)) + ' days)'

    --delete in single days, starting from the start date, until the end date
    WHILE (@start_date <= @end_date) BEGIN
        PRINT 'About to delete to ' + CONVERT(VARCHAR(25), @start_date, 113) + '...'
        --delete backup history
        EXEC msdb..sp_delete_backuphistory @start_date
        --delete maintenance plan history as per http://www.sqldbadiaries.com/2011/03/16/clean-up-maintenance-plan-history/
        EXEC msdb..sp_maintplan_delete_log NULL, NULL, @start_date
        --delete SQL Agent history as per https://docs.microsoft.com/en-us/sql/ssms/agent/clear-the-job-history-log
        EXEC msdb..sp_purge_jobhistory NULL, NULL, @start_date
        --delete database mail history as per https://www.madeiradata.com/post/keep-your-msdb-clean
        EXEC msdb..sysmail_delete_mailitems_sp @sent_before = @start_date
        EXEC msdb..sysmail_delete_log_sp @logged_before = @start_date
        --increment the start date by 1 day
        SET @start_date = DATEADD(DAY, 1, @start_date)
    END
END