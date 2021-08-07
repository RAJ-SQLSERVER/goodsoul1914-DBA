USE [msdb]
GO

/****** Object:  Job [ZKH: Verzamel Performance Info]    Script Date: 10-2-2020 10:24:46 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10-2-2020 10:24:46 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: Verzamel Performance Info', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Verzamel Verschillende Performance Info]    Script Date: 10-2-2020 10:24:46 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Verzamel Verschillende Performance Info', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO [Performance].[dbo].[PERF_ZISCON_LOGSESSI]
SELECT [LOGSESS_ID]
	 , [WINUSER] 
	 , [INDATUM] 
	 , [INTIJD] 
	 , [UITDATUM] 
	 , [UITTIJD]
	 , [STATUS] 
	 , [IPADRES]
	 , [IPSOCKET]
	 , [APPLICATIE]
	 , [VERSION]
	 , [LATEST_HF]
	 , [PROCESSID]
	 , [WINSTAT]
	 , [REMOTESTAT]
FROM [HIX_PRODUCTIE].[dbo].[ZISCON_LOGSESSI] 
WHERE ( WINUSER like ''sa_%hixperf'' OR WINUSER like ''AL_RSDIENA%'' ) AND STATUS like ''U''  AND INDATUM >= GETDATE() -4
  AND [LOGSESS_ID] not in ( SELECT [LOGSESS_ID]  FROM [Performance].[dbo].[PERF_ZISCON_LOGSESSI] )
ORDER BY INDATUM, INTIJD

INSERT INTO [Performance].[dbo].[PERF_ZISCON_LOGUSER]
SELECT [LOGUSER_ID]
      ,[GEBRUIKER]
      ,[MUTGEBRUIK]
      ,[AUTOLOGIN]
      ,[INDATUM]
      ,[INTIJD]
      ,[UITDATUM]
      ,[UITTIJD]
      ,[STATUS]
      ,[EXTRAINFO]
      ,[LOGSESS_ID]
      ,[LOGUSERGUID]
  FROM [HIX_PRODUCTIE].[dbo].[ZISCON_LOGUSER]
WHERE [LOGSESS_ID] in ( SELECT [LOGSESS_ID] FROM [Performance].[dbo].[PERF_ZISCON_LOGSESSI] ) 
   AND [LOGSESS_ID] not in ( SELECT [LOGSESS_ID]  FROM [Performance].[dbo].[PERF_ZISCON_LOGUSER] )
   AND INDATUM >= GETDATE() -4
ORDER BY INDATUM, INTIJD

 INSERT INTO [Performance].[dbo].[PERF_TESTRESULT]
SELECT [TestId] 
      ,[ParentResultId]
      ,[JipId]
      ,[Date]
      ,[Time]
      ,[CpuTime]
      ,[QueryTime]
      ,[Duration]
      ,[NumberOfQueries]
      ,[Tag]
      ,[Name]
      ,[Message]
      ,[IsComparable]
      ,[LogUserId]
      ,[TestPlanId]
      ,[GC0CollectionCount]
      ,[GC1CollectionCount]
      ,[GC2CollectionCount]
      ,[MemoryBeforeTest]
      ,[MemoryDeltaDuringTest]
      ,[MemoryDeltaAfterTest]
  FROM [HIX_PRODUCTIE].[dbo].[LOG_TESTRESULT]
WHERE [LogUserId] in ( select LOGUSER_ID from [Performance].[dbo].[PERF_ZISCON_LOGUSER] ) 
   AND [LogUserId] not in ( SELECT [LogUserId] FROM [Performance].[dbo].[PERF_TESTRESULT] )
   AND Date>= GETDATE() -4
ORDER by Date, Time', 
		@database_name=N'HIX_PRODUCTIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Verzamel Totaal Performance Info]    Script Date: 10-2-2020 10:24:46 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Verzamel Totaal Performance Info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT [Performance].[dbo].[PERF_RESULTATEN]
SELECT CASE WHEN ZS.[WINSTAT] LIKE ''GPHIXPERF01''  THEN ''VM''
			WHEN ZS.[WINSTAT] LIKE ''GAHIXPERF01''  THEN ''VM''
			WHEN ZS.[WINSTAT] LIKE ''%G9''          THEN ''GWO Gen09''
			WHEN ZS.[WINSTAT] LIKE ''%G10''         THEN ''GWO Gen10''
			WHEN ZS.[WINSTAT] LIKE ''WOVD%''        THEN ''GWO''
			WHEN ZS.[WINSTAT] LIKE ''PC0%F''		  THEN ''GWO FAT''
			WHEN ZS.[WINSTAT] LIKE ''PC-%''         THEN ''PC Lievensb''
			WHEN ZS.[WINSTAT] LIKE ''PC0%''         THEN ''PC Lievensb''
			WHEN ZS.[WINSTAT] LIKE ''16-%''         THEN ''PC Lievensb''
			WHEN ZS.[WINSTAT] LIKE ''VD%''          THEN ''VDI RSD''
			WHEN ZS.[WINSTAT] LIKE ''SCTXD%''       THEN ''EXTRANET''
		ELSE ''ONBEKEND''									END as [OMGEVING]
      , ZS.[LOGSESS_ID]
      , ZS.[WINUSER]
      , ZS.[INDATUM]
      , ZS.[INTIJD]
      , ZS.[UITDATUM]
      , ZS.[UITTIJD]
      , DATEDIFF (ss, ( ZS.[INDATUM] + ZS.[INTIJD] ),( ZS.[UITDATUM] + ZS.[UITTIJD] ) ) as [SessieDuur]
      , ZS.[STATUS]
      , ZS.[IPADRES]
      , ZS.[VERSION]
      , ZS.[LATEST_HF]
      , ZS.[PROCESSID]
      , ZS.[WINSTAT]
      -----------------
      , ZU.[GEBRUIKER]
      , ZU.[MUTGEBRUIK]
	  -----------------
      , TR.[ParentResultId]
      , TR.[Date] -- Datum
      , TR.[Time] -- StartTijd
      , AVG ( TR.[CpuTime] ) -- CpuTime
      , AVG ( TR.[QueryTime] ) -- QueryTime
      , AVG ( TR.[Duration] ) -- Duration
      , AVG ( TR.[NumberOfQueries] ) -- NumberOfQueries
      , CASE WHEN TR.[Name] like ''%Medicatie benaderen%'' THEN ''Medicatie benaderen''
            WHEN TR.[Name] like ''%Openen Dossier%'' THEN ''Openen Dossier''
            WHEN TR.[Name] like ''%Consult bewerken%'' THEN ''Consult bewerken'' 
            WHEN TR.[Name] like ''%Correspondentie openen%'' THEN ''Correspondentie openen''
            WHEN TR.[Name] like ''%JiveX%'' THEN ''JiveX''
            WHEN TR.[Name] like ''%Multimedia-overzicht patiënt%'' THEN ''Multimedia-overzicht patiënt''
            WHEN TR.[Name] like ''%KCHL%'' THEN ''KCHL''
            WHEN TR.[Name] like ''%Opnamehistorie patiënt%'' THEN ''Opnamehistorie patiënt''
            WHEN TR.[Name] like ''%Operatiehistorie%'' THEN ''Operatiehistorie''
            WHEN TR.[Name] like ''%Patiëntgegevens%'' THEN ''Patiëntgegevens''
            WHEN TR.[Name] like ''%Toedienregistratie%'' THEN ''Toedienregistratie''
            WHEN TR.[Name] like ''%Activiteitenplan%'' THEN ''Activiteitenplan''
            WHEN TR.[Name] like ''%Orders voor patiënt%'' THEN ''Orders voor patiënt''
            WHEN TR.[Name] like ''%Afdelingsbezettingsoverzicht%'' THEN ''Afdelingsbezettingsoverzicht''
            WHEN TR.[Name] like ''%Arts accordatielijst%'' THEN ''Arts accordatielijst''
            WHEN TR.[Name] like ''%Inzien multimedia%'' THEN ''Inzien multimedia''
            WHEN TR.[Name] like ''%Vitale functies%'' THEN ''Vitale functies''
            WHEN TR.[Name] like ''%Voorbereiden%'' THEN ''Voorbereiden''
            WHEN TR.[Name] like ''%Protocolleren%'' THEN ''Protocolleren''
        ELSE TR.[Name] END  AS [NAME]
      ,TR.[LogUserId]
      ,TR.[TestPlanId]
     , AVG ( TR.[GC0CollectionCount] )
     , AVG ( TR.[GC1CollectionCount] )
     , AVG ( TR.[GC2CollectionCount] )
     , AVG ( TR.[MemoryBeforeTest] )
     , AVG ( TR.[MemoryDeltaDuringTest] )
     , AVG ( TR.[MemoryDeltaAfterTest] )
  FROM     [Performance].[dbo].[PERF_TESTRESULT] TR WITH (NOLOCK)
INNER JOIN [Performance].[dbo].[PERF_ZISCON_LOGUSER] ZU WITH (NOLOCK) ON ZU.[LOGUSER_ID]  = TR.[LogUserId]
INNER JOIN [Performance].[dbo].[PERF_ZISCON_LOGSESSI] ZS WITH (NOLOCK) ON ZU.[LOGSESS_ID] = ZS.[LOGSESS_ID] 
 WHERE TR.[Name] like ''%Performance meting/%'' AND ZS.[STATUS] like ''U'' AND ZS.[INDATUM] >= GETDATE() -4 AND ZS.[UITDATUM] is not NULL
   AND TR.[LogUserId] not in ( select [LOGUSERID] from [Performance].[dbo].[PERF_RESULTATEN] WITH (NOLOCK) )
GROUP BY ZS.[VERSION], ZS.[LATEST_HF], ZS.[WINSTAT], TR.[Date], TR.[Name], ZS.[WINUSER], ZS.[WINSTAT], ZS.[LOGSESS_ID], ZS.[INDATUM], ZS.[INTIJD], ZS.[UITDATUM],
         ZS.[UITTIJD], ZS.[STATUS], ZS.[IPADRES], ZS.[PROCESSID], ZU.[GEBRUIKER], ZU.[MUTGEBRUIK], TR.[ParentResultId], TR.[Time], TR.[LogUserId], TR.[TestPlanId]
ORDER BY ZS.[INDATUM] ASC, ZS.[INTIJD] ASC', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ZKH: Verzamel Performance Info', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190215, 
		@active_end_date=99991231, 
		@active_start_time=63500, 
		@active_end_time=172500, 
		@schedule_uid=N'ecd11da8-5f34-48a9-8c61-a301ac280495'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


