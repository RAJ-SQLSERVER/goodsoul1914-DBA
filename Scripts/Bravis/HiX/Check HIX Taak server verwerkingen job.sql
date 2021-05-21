USE [msdb]
GO

/****** Object:  Job [Check HIX Taak server verwerkingen]    Script Date: 21-1-2020 08:07:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 21-1-2020 08:07:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Check HIX Taak server verwerkingen', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'zkh\adm_jmeivogel', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check Taak Servers]    Script Date: 21-1-2020 08:07:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check Taak Servers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	
    Controle op goed lopen van de HIX Taken
	Dit script verzend via database-mail een mail met de informatie over de afloop van de laatste Afspraak herinnering-job.	
	
	20170815, MBL - ULTIMO melding 17036044 - initiele versie
    20170816, MBL - ULTIMO melding 17036044 - definitieve versie met aanpassingen mail adres en informatie voor afhandeling
	20171031, MBL - ULTIMO melding 17048313 - Toevoegen nieuwe taak binnen HIX waardoor flexibel opvragen is gemaakt
	                                          Door aantal in de declares te gebruiken kan maximale check worden gebruikt
	                                          bij aanpassing aantal check hoeft dit aantal aan gepast te worden indien 
	                                          de taak op Taak server begint met ''E-Mail'' 
    20171205, MBL status job toegevoegd 
    20171218, MBL Job voor meerdere taken gemaakt om zo de taken op 1 manier te controleren
    20171219, MBL Aanpassingen gemaakt om de melding goed te vullen waren leeg bij errors
    20180115, MBL Aanpassingen gemaakt om Screeningstaak mee te nemen in de controle
    20180425, MBL Aanpassingen gemaakt om fout herkenning en mailen wat niet altijd juist ging
    20180907, MBL Aanpassing om Jobs waarin meerdere stappen staan af te vangen
    
*/

-- Ontvangers van de Mail

--DECLARE @RecipientsMail    NVARCHAR(MAX) = ''Ultimo_meld@bravis.nl''    
DECLARE @RecipientsMail    NVARCHAR(MAX) = ''m.boomaars@bravis.nl''  

-- Parameter settings

DECLARE @HTML1             NVARCHAR(MAX) = N''<H2>Voor Technisch Applicatiebeheer</H2>'' 
DECLARE @HTML2  		   NVARCHAR(MAX) = ''''
DECLARE @HTML3  		   NVARCHAR(MAX) = ''''
DECLARE @HTMLBericht       NVARCHAR(MAX) = '''' 
DECLARE @OmschrijvingMail  NVARCHAR(MAX) = ''[HIXtaak] Taakverwerking'' 
DECLARE @STARTMINUUT       INT           =  71   -- MINUTEN
DECLARE @STOPMINUUT        INT           =  10   -- MINUTEN
DECLARE @STARTTIJD		   DATETIME		 =  ( SELECT DATEADD( MINUTE, -@STARTMINUUT, getdate() ) ) 
DECLARE @STOPTIJD		   DATETIME		 =  ( SELECT DATEADD( MINUTE, -@STOPMINUUT, getdate() ) ) 

DECLARE @VERWERKT          NVARCHAR(MAX) = ( SELECT COUNT(*) FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK]  
											                WHERE [STATUS] IN ( ''U'', ''E'', ''V'' ) 
											                  AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
															  AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() ) ) 

DECLARE @AANTAL            NVARCHAR(MAX) = ( SELECT COUNT(*) FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK] 
                                               WHERE [DATUM] + [TIJD] >= DATEADD(MINUTE, -@STARTMINUUT, getdate())
                                                 AND [DATUM] + [TIJD] <= DATEADD(MINUTE, -@STOPMINUUT, getdate())
                                                 AND [TYPTRIGGER] NOT LIKE ''P'' )

DECLARE @TEST             NVARCHAR(MAX) = ( SELECT ''FOUT'' WHERE @AANTAL <> @VERWERKT  )  

PRINT ''@@INFORMATIE@@   Er is in de verwerkings verschil van '' + @TEST + '' taken geconstateerd ''
PRINT ''@@INFORMATIE@@   Geplande aantal taken >>> '' + @AANTAL + ''  vs  Afgehandelde taken >>> '' + @VERWERKT
PRINT ''@@INFORMATIE@@   START CHECK >> '' +  CONVERT(VARCHAR(20),@STARTTIJD ) + '' << STOP CHECK >> '' + CONVERT(VARCHAR(20), @STOPTIJD )

-- Start controle van de HIX Taken


IF EXISTS ( SELECT ''FOUT'' WHERE @AANTAL > @VERWERKT  )                            
BEGIN
     SET @HTML2  =  N''<H4>E-Mail: Taak zijn niet allemaal gestart volgens planning</H4>'' + 
                    N''<table border="1">'' +  
                    N''<tr><th>Taak Machine</th><th>RunID / Taak Naam</th><th>Plan Datum/Tijd</th><th>Status</th></tr>'' +  
                     CAST ( ( SELECT td = [MACHINE] , '''',  
                                     td = RIGHT( [RUNID] , 3 ) + '' / '' + [OMSCHRIJV] , '''' , 
                                     td = CONVERT(VARCHAR(23), [DATUM] + ( CASE TYPTRIGGER  WHEN ''T'' THEN TIJD 
																					        WHEN ''P'' THEN ( CASE STATUS WHEN ''U'' THEN CONVERT(VARCHAR(8), (CONVERT(TIME, TIJD)))
																													    ELSE ( SELECT B.TIJD FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK] B
																																	        WHERE TAAKPADID = B.TAAKPADID
																																		      AND B.TYPTRIGGER LIKE ''T''
																																			  AND B.[DATUM] + B.[TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
																																			  AND B.[DATUM] + B.[TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )  ) END )
																							ELSE ''XX:XX'' END )  , 120), '''' ,
                                     td = CASE STATUS  WHEN ''U'' THEN ''Klaar'' 
                                                       WHEN ''W'' THEN ''Wachtend'' 
                                                       WHEN ''L'' THEN ''Uitgepland'' 
                                                       WHEN ''E'' THEN ''Gestart'' 
                                                       WHEN ''F'' THEN ''VerwerkingsFOUT''
                                                       WHEN ''V'' THEN ''Klaar zie LOG''
			                                           WHEN ''A'' THEN ''Klaar met FOUT''
                                                       ELSE ''Onbekend'' END  ,  '''' 
                               FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK] 
                              WHERE [OMSCHRIJV] NOT LIKE ''Verversen%''
                                AND [STATUS] NOT IN ( ''U'', ''E'', ''V'' ) 
                                AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
                                AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )
                              ORDER BY [DATUM] DESC FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) + 
                               N''</table>''
  END 
                              
-- Zoeken of bij fouten ook resultaten zijn gemeld

IF EXISTS ( SELECT COUNT(*) FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK] 
                                 WHERE [STATUS] NOT IN ( ''U'' , ''W'', ''E'', ''L'', ''V'' ) 
                                   AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
                                   AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() ) )                         
BEGIN                         
     SET @HTML3 =  N''<table border="1">'' +  
                   N''<tr><th>HIX Runid / TaakNaam</th><th>Fout Melding</th></tr>'' +  
                   CAST ( ( SELECT td = RIGHT( A.[RUNID] , 3 ) + '' / '' + A.[OMSCHRIJV] , '''' , 
                                   td = B.[RESULT] , '''' 
                              FROM [HIX_PRODUCTIE].[dbo].[TAAK_TAAK] A,
                                   [HIX_PRODUCTIE].[dbo].[TAAK_TAAKLOG] B
                             WHERE A.[ID] = B.[TAAKID]
                               AND A.[STATUS] NOT IN ( ''U'' , ''W'', ''E'', ''L'', ''V'' ) 
                               AND B.[ERRCODE] not in (000 ,004)
                               AND A.[DATUM] + A.[TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
                               AND A.[DATUM] + A.[TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )  
                             ORDER BY A.[DATUM] DESC FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) + 
                   N''</table>'' 
END              

-- Mailtje versturen met resultaten

IF @HTML2 <> ''''
BEGIN
   SET @HTMLBericht = @HTML1 + @HTML2
END

IF @HTML3 <> ''''
BEGIN
   SET @HTMLBericht = @HTML1 + @HTML2 + @HTML3
END

IF @HTMLBericht <> '''' 
BEGIN
     EXEC msdb.dbo.sp_send_dbmail  
          @profile_name                =  "GPHIXSQL02" ,  
          @subject                     =  @OmschrijvingMail ,
          @recipients                  =  @RecipientsMail ,   
          @body                        =  @HTMLBericht,  
          @body_format                 = ''HTML''   
END	', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Taakservers', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20171218, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=231000, 
		@schedule_uid=N'c2305542-e9ba-47fe-88df-fb0950099e20'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


