USE DBA;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetDailyHealthReport
AS
BEGIN
    /*Variables for server property*/
    DECLARE @DatabaseServerInformation NVARCHAR(MAX);
    DECLARE @Hostname VARCHAR(50) = (
                SELECT CONVERT(VARCHAR(50), @@SERVERNAME)
            );
    DECLARE @Version VARCHAR(MAX) = (
                SELECT CONVERT(VARCHAR(MAX), @@version)
            );
    DECLARE @Edition VARCHAR(50) = (
                SELECT CONVERT(VARCHAR(50), SERVERPROPERTY('edition'))
            );
    DECLARE @IsClusteredInstance VARCHAR(50) = (
                SELECT CASE SERVERPROPERTY('IsClustered')
                           WHEN 1 THEN
                               'Clustered Instance'
                           WHEN 0 THEN
                               'Non Clustered instance'
                           ELSE
                               'null'
                       END
            );
    DECLARE @IsInstanceinSingleUserMode VARCHAR(50) = (
                SELECT CASE SERVERPROPERTY('IsSingleUser')
                           WHEN 1 THEN
                               'Single user'
                           WHEN 0 THEN
                               'Multi user'
                           ELSE
                               'null'
                       END
            );
    /*HTML Table with variables*/
    SET @DatabaseServerInformation
        = N'<font face="Verdana" size="4">Server Info</font>  
         <table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="90%" id="AutoNumber1" height="50">  
         <tr>  
         <td width="27%" height="22" bgcolor="#D3D3D3"><b>  
           <font face="Verdana" size="1" color="#FFFFFF">Host Name</font></b></td>  
         <td width="39%" height="22" bgcolor="#D3D3D3"><b>  
         <font face="Verdana" size="1" color="#FFFFFF">SQL Server version</font></b></td>  
         <td width="90%" height="22" bgcolor="#D3D3D3"><b>  
         <font face="Verdana" size="1" color="#FFFFFF">SQL Server edition</font></b></td> 
	<td width="90%" height="22" bgcolor="#D3D3D3"><b>  
         <font face="Verdana" size="1" color="#FFFFFF">Failover Clustered Instance</font></b></td> 
	<td width="90%" height="22" bgcolor="#D3D3D3"><b>  
         <font face="Verdana" size="1" color="#FFFFFF">Single User mode</font></b></td> 
         </tr>  

         <tr>  
         <td width="27%" height="27"><font face="Verdana" size="2">' + @Hostname
          + N'</font></td>  
         <td width="39%" height="27"><font face="Verdana" size="2">' + @Version
          + N'</font></td>  
         <td width="90%" height="27"><font face="Verdana" size="2">' + @Edition
          + N'</font></td>
		 <td width="90%" height="27"><font face="Verdana" size="2">' + @IsClusteredInstance
          + N'</font></td>
		 <td width="90%" height="27"><font face="Verdana" size="2">' + @IsInstanceinSingleUserMode
          + N'</font></td>
         </tr>  
         </table>';
    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation
          + N'<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="24%" border="1">
	  <tr>
		<td width="27%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database Name</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Volume </font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Free Space (GB)</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Occupied Space (GB)</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Total Space (GB)</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	<p><font face="Verdana" size="4">Disk Stats</font></p>';
    SELECT      DISTINCT
                @DatabaseServerInformation
                    = @DatabaseServerInformation + N'<tr><td><font face="Verdana" size="1">' + volumes.logical_volume_name
                      + N'</font></td>' + N'<td><font face="Verdana" size="1">' + volumes.volume_mount_point + N'</font></td>'
                      + N'<td><font face="Verdana" size="1">'
                      + CONVERT(VARCHAR, CONVERT(INT, volumes.available_bytes / 1024 / 1024 / 1024)) + N'</font></td>'
                      + N'<td><font face="Verdana" size="1">'
                      + CONVERT(
                            VARCHAR,
                            CONVERT(INT, volumes.total_bytes / 1024 / 1024 / 1024)
                            - CONVERT(INT, volumes.available_bytes / 1024 / 1024 / 1024)
                        ) + N'</font></td>' + N'<td><font face="Verdana" size="1">'
                      + CONVERT(VARCHAR, CONVERT(INT, volumes.total_bytes / 1024 / 1024 / 1024)) + N'</font></td></tr>'
    FROM        sys.master_files AS mf
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS volumes;

    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation
          + N'<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="24%" border="1">
	  <tr>
		<td width="27%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database Name</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Created Date and Time </font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database created by</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database Status</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database access status</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Compatibility Level</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Recovary Model</font></b></td>
		<td width="59%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database Size</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	<p><font face="Verdana" size="4">Disk Stats</font></p>';
    SELECT     @DatabaseServerInformation
        = @DatabaseServerInformation + N'<tr><td><font face="Verdana" size="1">' + CONVERT(VARCHAR, a.name)
          + N'</font></td>' + N'<td><font face="Verdana" size="1">' + CONVERT(NVARCHAR, a.create_date)
          + N'</font></td>' + N'<td><font face="Verdana" size="1">' + b.name + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + a.state_desc + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + a.user_access_desc + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + CONVERT(NVARCHAR, a.compatibility_level) + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + a.recovery_model_desc + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + CONVERT(NVARCHAR, SUM((c.size * 8) / 1024)) + N'</font></td></tr>'
    FROM       sys.databases AS a
    INNER JOIN sys.server_principals AS b ON a.owner_sid = b.sid
    INNER JOIN sys.master_files AS c ON a.database_id = c.database_id
    WHERE      a.database_id > 5
    GROUP BY   a.name,
               a.create_date,
               b.name,
               a.user_access_desc,
               a.compatibility_level,
               a.recovery_model_desc,
               a.database_id,
               a.state_desc;
    /*----------- Backup Details -----------------*/
    CREATE TABLE #BackupInformation
    (
        DatabaseName VARCHAR(200),
        backup_type VARCHAR(50),
        backupstartdate DATETIME,
        backupfinishdate DATETIME,
        servername VARCHAR(200),
        backupsize NUMERIC(10, 2),
        BackupUser VARCHAR(250)
    );
    WITH backup_information
    AS
    (
        SELECT database_name,
               CASE type
                   WHEN 'D' THEN
                       'Full backup'
                   WHEN 'I' THEN
                       'Differential backup'
                   WHEN 'L' THEN
                       'Log backup'
                   ELSE
                       'Other or copy only backup'
               END AS backup_type,
               backup_start_date,
               backup_finish_date,
               user_name,
               server_name,
               compressed_backup_size,
               ROW_NUMBER() OVER (PARTITION BY database_name, type ORDER BY backup_finish_date DESC) AS rownum
        FROM   msdb.dbo.backupset
    )
    INSERT INTO #BackupInformation
    SELECT   backup_information.database_name AS [Database Name],
             backup_information.backup_type AS [Backup Type],
             backup_information.backup_start_date AS [Backup start date],
             backup_information.backup_finish_date AS [Backup finish date],
             backup_information.server_name AS [Server Name],
             CONVERT(VARCHAR, CONVERT(NUMERIC(10, 2), backup_information.compressed_backup_size / 1024 / 1024)) AS [Backup size in MB],
             backup_information.user_name AS [Backup taken by]
    FROM     backup_information
    WHERE    backup_information.rownum = 1
    ORDER BY backup_information.database_name;

    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation
          + N'<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="54%" border="1">
	  <tr>
		<td width="27%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Database Name</font></b></td>
		<td width="19%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Backup Type </font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Backup Start Date</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Backup Finsh Date</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Server Name</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Backup Size in MB</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Backup generated by </font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	<p><font face="Verdana" size="4">Backup Details</font></p>';
    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation + N'<tr><td><font face="Verdana" size="1">' + CONVERT(VARCHAR, DatabaseName)
          + N'</font></td>' + N'<td><font face="Verdana" size="1">' + CONVERT(NVARCHAR, backup_type) + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + CONVERT(VARCHAR, backupstartdate, 120) + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + CONVERT(VARCHAR, backupfinishdate, 120) + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + servername + N'</font></td>'
          + N'<td><font face="Verdana" size="1">' + CONVERT(VARCHAR, CONVERT(NUMERIC(10, 2), backupsize))
          + N'</font></td>' + N'<td><font face="Verdana" size="1">' + BackupUser + N'</font></td></tr>'
    FROM   #BackupInformation;


    /*------------------ Job Information ---------------------------*/
    CREATE TABLE #JobInformation
    (
        Servername VARCHAR(100),
        categoryname VARCHAR(100),
        JobName VARCHAR(500),
        ownerID VARCHAR(250),
        Enabled VARCHAR(5),
        NextRunDate DATETIME,
        LastRunDate DATETIME,
        status VARCHAR(50)
    );
    INSERT INTO #JobInformation (Servername, categoryname, JobName, ownerID, Enabled, NextRunDate, LastRunDate, status)
    SELECT          CONVERT(VARCHAR, SERVERPROPERTY('Servername')) AS ServerName,
                    categories.name AS CategoryName,
                    sqljobs.name,
                    SUSER_SNAME(sqljobs.owner_sid) AS OwnerID,
                    CASE sqljobs.enabled
                        WHEN 1 THEN
                            'Yes'
                        ELSE
                            'No'
                    END AS Enabled,
                    CASE job_schedule.next_run_date
                        WHEN 0 THEN
                            CONVERT(DATETIME, '1900/1/1')
                        ELSE
                            CONVERT(
                                DATETIME,
                                CONVERT(CHAR(8), job_schedule.next_run_date, 112) + ' '
                                + STUFF(
                                      STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), job_schedule.next_run_time), 6), 5, 0, ':'),
                                      3,
                                      0,
                                      ':'
                                  )
                            )
                    END AS NextScheduledRunDate,
                    lastrunjobhistory.LastRunDate,
                    ISNULL(lastrunjobhistory.run_status_desc, 'Unknown') AS run_status_desc
    FROM            msdb.dbo.sysjobs AS sqljobs
    LEFT JOIN       msdb.dbo.sysjobschedules AS job_schedule ON sqljobs.job_id = job_schedule.job_id
    LEFT JOIN       msdb.dbo.sysschedules AS schedule ON job_schedule.schedule_id = schedule.schedule_id
    INNER JOIN      msdb.dbo.syscategories AS categories ON sqljobs.category_id = categories.category_id
    LEFT OUTER JOIN (
        SELECT   Jobhistory.job_id
        FROM     msdb.dbo.sysjobhistory AS Jobhistory
        WHERE    Jobhistory.step_id = 0
        GROUP BY Jobhistory.job_id
    ) AS jobhistory ON jobhistory.job_id = sqljobs.job_id -- to get the average duration
    LEFT OUTER JOIN (
        SELECT sysjobhist.job_id,
               CASE sysjobhist.run_date
                   WHEN 0 THEN
                       CONVERT(DATETIME, '1900/1/1')
                   ELSE
                       CONVERT(
                           DATETIME,
                           CONVERT(CHAR(8), sysjobhist.run_date, 112) + ' '
                           + STUFF(
                                 STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), sysjobhist.run_time), 6), 5, 0, ':'),
                                 3,
                                 0,
                                 ':'
                             )
                       )
               END AS LastRunDate,
               sysjobhist.run_status,
               CASE sysjobhist.run_status
                   WHEN 0 THEN
                       'Failed'
                   WHEN 1 THEN
                       'Succeeded'
                   WHEN 2 THEN
                       'Retry'
                   WHEN 3 THEN
                       'Canceled'
                   WHEN 4 THEN
                       'In Progress'
                   ELSE
                       'Unknown'
               END AS run_status_desc,
               sysjobhist.retries_attempted,
               sysjobhist.step_id,
               sysjobhist.step_name,
               sysjobhist.run_duration AS RunTimeInSeconds,
               sysjobhist.message,
               ROW_NUMBER() OVER (PARTITION BY sysjobhist.job_id
                                  ORDER BY CASE sysjobhist.run_date
                                               WHEN 0 THEN
                                                   CONVERT(DATETIME, '1900/1/1')
                                               ELSE
                                                   CONVERT(
                                                       DATETIME,
                                                       CONVERT(CHAR(8), sysjobhist.run_date, 112) + ' '
                                                       + STUFF(
                                                             STUFF(
                                                                 RIGHT('000000'
                                                                       + CONVERT(VARCHAR(8), sysjobhist.run_time), 6),
                                                                 5,
                                                                 0,
                                                                 ':'
                                                             ),
                                                             3,
                                                             0,
                                                             ':'
                                                         )
                                                   )
                                           END DESC
                            ) AS RowOrder
        FROM   msdb.dbo.sysjobhistory AS sysjobhist
        WHERE  sysjobhist.step_id = 0 --to get just the job outcome and not all steps
    ) AS lastrunjobhistory ON lastrunjobhistory.job_id = sqljobs.job_id -- to get the last run details
                              AND lastrunjobhistory.RowOrder = 1;
    --select * from #JobInformation
    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation
          + N'<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="54%" border="1">
	  <tr>
		<td width="17%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Server Name</font></b></td>
		<td width="19%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Job Category </font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Job Name</font></b></td>
		<td width="15%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Job owner</font></b></td>
		<td width="5%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Enabled</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Next Run Date</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Last Run Date</font></b></td>
		<td width="29%" bgColor="#D3D3D3" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Status</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	<p><font face="Verdana" size="4">Job Status</font></p>';
    SELECT @DatabaseServerInformation
        = @DatabaseServerInformation + N'<tr><td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(VARCHAR, Servername), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(NVARCHAR, categoryname), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(VARCHAR, JobName), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(VARCHAR, ownerID), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(Enabled, '') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(VARCHAR, NextRunDate, 120), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(CONVERT(VARCHAR, LastRunDate, 120), '-') + N'</font></td>' + N'<td><font face="Verdana" size="1">'
          + ISNULL(status, '-') + N'</font></td></tr>'
    FROM   #JobInformation;
    --Select @DatabaseServerInformation
    DROP TABLE #JobInformation;
    DROP TABLE #BackupInformation;
    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPNMail',
                                 @recipients = 'mboomaars@gmail.com',
                                 @subject = 'Weekly Database Health Report',
                                 @body = @DatabaseServerInformation,
                                 @body_format = 'HTML';

END;


