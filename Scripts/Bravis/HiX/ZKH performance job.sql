USE [msdb]
GO

/****** Object:  Job [ZKH: Performance]    Script Date: 7-1-2020 23:33:51 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Performance]    Script Date: 7-1-2020 23:33:51 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Performance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Performance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: Performance', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Performance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mail Blocked]    Script Date: 7-1-2020 23:33:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mail Blocked', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	Check op block op tabellen en database.
					 
*/
	
	-- Ontvangers van de Mail
DECLARE @RecipientsMail    NVARCHAR(MAX)   = ''m.boomaars@bravis.nl'' 

    -- Parameter settings
DECLARE @tableHTML         NVARCHAR(MAX) = ''''
DECLARE @OmschrijvingMail  NVARCHAR(MAX) = ''[Performance] Blocked GPHIXSQL02'' 

    -- Tabel vullen

SET @tableHTML = N''<H4>Blocked script 1</H4>'' +  
                 N''<table border="1">'' +  
                 N''<tr><th>Session ID</th><th>Blocked Session ID</th><th>Wait Time</th><th>Wait Type</th><th>Last Wait Type</th>
                     <th>Wait Resource</th><th>Transaction Isolation Level</th><th>Lock Timeout</th></tr>'' +  
                 CAST ( ( SELECT td = session_id, '''',
                                 td = blocking_session_id, '''',
                                 td = wait_time, '''',
                                 td = wait_type, '''',
                                 td = last_wait_type, '''',
                                 td = wait_resource, '''',
                                 td = transaction_isolation_level, '''',
                                 td = lock_timeout, '''' 
                            FROM sys.dm_exec_requests
                           WHERE blocking_session_id <> 0
                              FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) + 
                 N''</table>'' + 
    -- Tabel 2             
                 N''<H4>Blocked script 2</H4>'' +  
                 N''<table border="1">'' +  
                 N''<tr><th>DBName</th><th>Request Sesion ID</th><th>Blocking Session ID</th><th>Blocked Onbject Name</th><th>Resource Type</th>
                     <th>Request Tekst</th><th>Blocking Text</th><th>Request Mode</th>'' +   
                 CAST ( ( SELECT td = db.name, '''',
                                 td = tl.request_session_id, '''',
                                 td = wt.blocking_session_id, '''',
                                 td = OBJECT_NAME(p.OBJECT_ID), '''',
                                 td = tl.resource_type, '''',
                                 td = h1.TEXT, '''',
                                 td = h2.TEXT, '''',
                                 td = tl.request_mode, ''''
                            FROM sys.dm_tran_locks AS tl
                      INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
                      INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
                      INNER JOIN sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
                      INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
                      INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
                     CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
                     CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2
                            FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                 N''</table>''    

IF @tableHTML <> ''''
   BEGIN
        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name                =  ''GPHIXSQL02'' ,  
            @subject                     =  @OmschrijvingMail ,
            @recipients                  =  @RecipientsMail ,   
            @body                        =  @tableHTML,  
            @body_format                 =  ''HTML''   

    END

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mail Lang lopende Queries]    Script Date: 7-1-2020 23:33:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mail Lang lopende Queries', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @xml NVARCHAR(max) = NULL
DECLARE @body NVARCHAR(max) = NULL
-- specify long running query duration threshold
DECLARE @longrunningthreshold int = 1
--SET @longrunningthreshold=3 

-- step 1: collect long running query details.
;WITH cte
AS (SELECT [Session_id]=spid
         , [Sessioin_start_time]=(SELECT start_time
		                          FROM sys.dm_exec_requests
								  WHERE spid = session_id)
	     , [Session_status]=Ltrim(Rtrim([status]))
		 , [Session_Duration]=Datediff(mi, (SELECT start_time
		                                    FROM sys.dm_exec_requests
											WHERE spid = session_id), Getdate())
		 , [Session_query] = Substring (st.text, ( qs.stmt_start / 2 ) + 1
		 , ( ( CASE qs.stmt_end WHEN -1 THEN Datalength(st.text) ELSE qs.stmt_end END - qs.stmt_start ) / 2 ) + 1) 
      FROM sys.sysprocesses qs CROSS apply sys.Dm_exec_sql_text(sql_handle) st
	 WHERE 
		SUBSTRING(st.text, 0, 35) NOT LIKE ''WAITFOR(RECEIVE conversation_handle''
	 )

-- step 2: generate html table 
SELECT @xml = Cast((SELECT session_id AS ''td'',
'''',
session_duration AS ''td'',
'''',
session_status AS ''td'',
'''',
[session_query] AS ''td''
FROM cte
WHERE session_duration >= @longrunningthreshold 
FOR xml path(''tr''), elements) AS NVARCHAR(max))
 
-- step 3: do rest of html formatting
SET @body =
''<html><body><H2>Long Running Queries</H2><table border=1 BORDERCOLOR="Black"><tr><th align="centre">Session_id</th><th>Session_Duration(Minute)</th><th>Session_status</th><th>Session_query</th></tr>''
SET @body = @body + @xml + ''</table></body></html>''

-- step 4: send email if a long running query is found.
--SELECT @xml
IF( @xml IS NOT NULL )
BEGIN
EXEC msdb.dbo.Sp_send_dbmail
@profile_name = ''GPHIXSQL02'',
@body = @body,
@body_format =''html'',
@recipients = ''m.boomaars@bravis.nl'',
@subject = ''ALERT: Long Running Queries  \\GPHIXSQL02'';
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mail Herindexering Index]    Script Date: 7-1-2020 23:33:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mail Herindexering Index', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	Check op block op tabellen en database.
					 
*/
	
	-- Ontvangers van de Mail
DECLARE @RecipientsMail    NVARCHAR(MAX)   = ''m.boomaars@bravis.nl'' 

    -- Parameter settings
DECLARE @tableHTML         NVARCHAR(MAX) = ''''
DECLARE @OmschrijvingMail  NVARCHAR(MAX) = ''[Performance] Herindexering GPHIXSQL02'' 

SET @tableHTML = (SELECT GETDATE()) 

    -- Tabel vullen

SET @tableHTML = @tableHTML +
                 N''<H4>Blocked Index Herindexering</H4>'' +
                 N''<table border="1">'' + 
                 N''<tr><th>Table ID</th><th>Indexname</th><th>Index Start</th><th>Nr of Rows</th>'' +  
                 CAST ( (  SELECT td = TableId,  '''',
                                  td = IndexName,  '''', 
                                  td = IndexStart,  '''',
                                  td = NrOfRows,  ''''
                             FROM [HIX_PRODUCTIE].[dbo].[EzisIndexLog]
                            WHERE IndexStart >= GETDATE() - 0.25
                              AND IndexStop is NULL
                              FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) + 
                 N''</table>''
  
IF @tableHTML <> ''''
   BEGIN
        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name                =  ''GPHIXSQL02'' ,  
            @subject                     =  @OmschrijvingMail ,
            @recipients                  =  @RecipientsMail ,   
            @body                        =  @tableHTML,  
            @body_format                 =  ''HTML''   

    END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 3
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


