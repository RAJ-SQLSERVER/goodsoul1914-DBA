USE [msdb]
GO

/****** Object:  Job [Controle DataWareHouse Bijwerken]    Script Date: 9-3-2020 07:31:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 9-3-2020 07:31:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Controle DataWareHouse Bijwerken', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fout Controle DHW Bijwerken]    Script Date: 9-3-2020 07:31:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fout Controle DHW Bijwerken', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	Controle op goed lopen van de DataWareHouse bijwerken in het weekend.
	Dit script verzend via database-mail een mail met de informatie over de afloop van de laatste DataWareHouse bijwerken taken.
	Elk weekend worden de taken "Alles behalve Dossier" en "Alleen Dossier gestart"	
	
	20170821 (MBL) - initiele versie
    20170824 (MBL) - definitieve versie met aanpassingen mail adres en informatie voor afhandeling
					 
*/
	
-- Ontvangers van de Mail
DECLARE @RecipientsMail    NVARCHAR(MAX)   = ''tab@bravis.nl'' 


-- Parameter settings
DECLARE @tableHTML         NVARCHAR(MAX) = ''''
DECLARE @OmschrijvingMail  NVARCHAR(MAX) = ''[HIXTaak] DataWareHouse Fouten'' 

-- Opvragen Status
IF EXISTS (SELECT ''KLAAR'' WHERE 2 = 
               (SELECT COUNT (*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                        WHERE (Verversing) > = (SELECT MAX(Verversing) - 1
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat])
                          AND Datum >= (GETDATE() - 7)
                          AND EindDatum IS NOT NULL ) )
BEGIN

     IF EXISTS ( SELECT ''FOUTJE BEDANKT'' WHERE 1 <= 
                    (SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingslog]
                      WHERE VERVERSING > = (SELECT MAX(Verversing) - 1
                       FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat])
                        AND STATUS like ''Error'' ) )
    	BEGIN
              SET @tableHTML = N''<H1>Voor Technisch Applicatiebeheer (TAB)</H1>'' +  
                               N''<H4>Vewerkingsstatus DataWareHouse bijwerken</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Machine</th><th>Start</th><th>Stop</th><th>ZHOmgeving</th><th>DWHVersie</th></tr>'' +  
                                CAST ( ( SELECT td = Machine,       '''', 
                           td = CAST((CONVERT(VARCHAR(10),Datum,110)) + '' '' + Tijd  AS CHAR(20)) ,     '''',
                           td = ISNULL(CAST((CONVERT(VARCHAR(10),EindDatum,110))  + '' '' + EindTijd  AS CHAR(20)), ''XX-XX-XXXX'')  ,      '''', 
                           td = ZHOmgeving,    '''',
                           td = DWHVersie
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                        WHERE (Verversing) > = (SELECT MAX(Verversing) - 1
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat])
                          AND Datum >= (GETDATE() - 7) FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) + 
                               N''</table>'' + 
                               N''<H4>DataWareHouse Fout in Stap</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Stap Naam</th><th>Start</th><th>Stop</th>'' +  
                                CAST ( ( SELECT td = OMSCHRIJVING,  '''', 
                           td = CAST((CONVERT(VARCHAR(10),STARTDATE,110)) + '' '' + STARTTIME AS VARCHAR(20)),     '''',
                           td = CAST((CONVERT(VARCHAR(10),ENDDATE,110)) + '' '' + ENDTIME AS VARCHAR(20)),     ''''
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingslog]
                        WHERE VERVERSING > = (SELECT MAX(Verversing) - 1
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat])
                          AND STATUS like ''Error'' FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                               N''</table>'' +
                               N''<H4>DataWareHouse Foutmelding bij Stap</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th WIDTH="125">Stap Naam</th><th>Details</th>'' +  
                                CAST ( ( SELECT td = OMSCHRIJVING,  '''', td = DETAILS,       ''''
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingslog]
                        WHERE VERVERSING > = (SELECT MAX(Verversing) - 1
                         FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat])
                          AND STATUS like ''Error'' FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                               N''</table>''    

      END
END

IF @tableHTML <> ''''
   BEGIN
        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name                =  ''GPHIXSQL02'' ,  
            @subject                     =  @OmschrijvingMail ,
            @recipients                  =  @RecipientsMail ,   
            @body                        =  @tableHTML,  
            @body_format                 = ''HTML''   
    END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [HIX Tellingen]    Script Date: 9-3-2020 07:31:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'HIX Tellingen', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	Controle op goed lopen van de DataWareHouse bijwerken in het weekend.
	Dit script verzend via database-mail een mail met de informatie over de afloop van de laatste DataWareHouse bijwerken taken.
	Elk weekend worden de taken "Alles behalve Dossier" en "Alleen Dossier gestart"	
	
	20171030 (MBL) - initiele versie zie melding Ultimo 17049241
					 
*/
	
	-- Ontvangers van de Mail
DECLARE @RecipientsMail    NVARCHAR(MAX)   = ''managementinformatie@bravis.nl'' 
DECLARE @OmschrijvingMail  NVARCHAR(MAX)   = ''[HIX Tellingen} Records tellingen.'' 

     -- Parameter settings
DECLARE @tableHTML         NVARCHAR(MAX)  = ''''

   -- Script Paramaters

DECLARE @ndVerversing INTEGER      
DECLARE @ddControle4wStart DATETIME     
DECLARE @ddControle4wEinde DATETIME     


   -- Script
          
SET @ndVerversing = (SELECT MAX(Verversing)     
 FROM CSDW_Productie.[dbo].[DWHHlpVerversingsResultaat]   
 WHERE CHOSENMODELS <> ''DDR'')  

SET @ddControle4wStart =  (SELECT DATEADD(mm, DATEDIFF(mm, 0, Datum) - 1, 0) --Eerste vorige maand 
                             FROM CSDW_Productie.[dbo].[DWHHlpVerversingsResultaat]  
                            WHERE VERVERSING = @ndVerversing)    
         
SET @ddControle4wEinde  = getdate()  

IF EXISTS ( SELECT ''Klaar'' WHERE 2 = 
                 ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                    WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                                 FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                      AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                      AND ( CHOSENMODELS like ''%DDR%'' OR CHOSENMODELS like ''%REF%'' ) ) )

	BEGIN

              SET @tableHTML = N''<H4>DBC Tellingen</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Module</th><th>Jaar</th><th>DBCNummer</th></tr>'' +  
                               CAST ( ( SELECT td = ''DBC'', '''', 
                                               td = year(BEGINDAT), '''',
                                               td = COUNT([DBCNummer]), ''''                                                     
                                         FROM [HIX_PRODUCTIE].[dbo].[EPISODE_DBCPER]                                                     
                                        WHERE Begindat>= ''20140101''       
                                        GROUP BY year(BEGINDAT)       
                                        ORDER BY year(BEGINDAT)
                                   FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +  
                               N''</table>'' +
                               N''<H4>VER Tellingen</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Module</th><th>Jaar</th><th>Aantal</th></tr>'' +  
                               CAST ( ( SELECT td = ''VER'', '''',
                                               td = year(datum), '''', 
                                               td = COUNT(ID), ''''                                                     
                                         FROM [HIX_PRODUCTIE].[dbo].[FAKTUUR_VERRVIEW]                                                    
                                        WHERE DATUM>= ''20140101''       
                                        GROUP BY year(DATUM)       
                                        ORDER BY year(DATUM)  
                                    FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                               N''</table>''  +
                               N''<H4>DBC Begindatum</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Module</th><th>Begindatum</th><th>Aantal</th></tr>'' +  
                               CAST ( ( SELECT td = ''DBC'', '''', 
                                               td = convert(char(10),BEGINDAT,126), '''', 
                                               td = COUNT([DBCNummer]), ''''                                                     
                                          FROM [HIX_PRODUCTIE].[dbo].[EPISODE_DBCPER]                                                     
                                         WHERE Begindat>= @ddControle4wStart AND Begindat < @ddControle4wEinde  
                                      GROUP BY convert(char(10),BEGINDAT,126)     
                                      ORDER BY convert(char(10),BEGINDAT,126) desc
                                    FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                                    N''</table>''  +
                               N''<H4>DBC Begindatum</H4>'' +  
                               N''<table border="1">'' +  
                               N''<tr><th>Module</th><th>VERRdatum</th><th>Aantal</th></tr>'' +  
                               CAST ( ( SELECT td = ''VER'', '''', 
                                               td = convert(char(10),datum,126) , '''', 
                                               td = COUNT(ID), ''''                                                     
                                          FROM [HIX_PRODUCTIE].[dbo].[FAKTUUR_VERRVIEW]                                                    
                                         WHERE DATUM >= @ddControle4wStart AND DATUM < @ddControle4wEinde  
                                      GROUP BY convert(char(10),datum,126)      
                                      ORDER BY convert(char(10),datum,126) desc
                                    FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX) ) +
                               N''</table>''      
END

IF @tableHTML <> ''''
   BEGIN

        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name                =  ''''GPHIXSQL02'' ,  
            @subject                     =  @OmschrijvingMail ,
            @recipients                  =  @RecipientsMail ,   
            @body                        =  @tableHTML,  
            @body_format                 = ''HTML''   

    END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Logship]    Script Date: 9-3-2020 07:31:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Logship', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*	
    Controle op DataWareHouse bijwerken in het weekend.
	Als Datawarehouse is bijgewerkt job "ZKH: Controle DWH Verversing" disable 
	Job "ZKH: Controle DWH Verversing" wordt weer ge-enabled in "ZKH: Fouten Controle DataWareHouse Bijwerken"
	De job "LSRestore_GPHIXSQL01_HIX_PRODUCTIE" wordt gestart om alles bij te werken
	
	20171023 (MBL) - initiele versie
	20171218 (MBL) - aangepast om ook de LSRestore_GPHIXSQL01_HIX_PRODUCTIE te disable indien de DWH job nog werkend
	                 is. Dit om een herstel punt nog mogelijk te maken en logship later te starten.
	20181015 (MBL) - Mailing eruit gehaald
					 
*/
	
-- Mail
/*
DECLARE @RecipientsMail    NVARCHAR(MAX)   = ''''  
DECLARE @OmschrijvingMail  NVARCHAR(MAX)   = ''[HIXTaak] Logship DWH server'' 
DECLARE @tableHTML         NVARCHAR(MAX)   = ''''
*/
DECLARE @StatusREF		   NVARCHAR(MAX)   = ''''
DECLARE @StatusDDR		   NVARCHAR(MAX)   = ''''

-- Parameter settings

/* Te gebruiken commando''s 
--Enabled Job
EXEC msdb.dbo.sp_update_job @job_name=''ZKH: Controle DWH verversing'',@enabled = 1 

-- Disabled Job
EXEC msdb.dbo.sp_update_job @job_name=''ZKH: Controle DWH verversing'''',@enabled = 0 

-- Start Job
EXEC msdb.dbo.sp_start_job @job_name=''LSRestore_GPHIXSQL01_HIX_PRODUCTIE''

-- Stop Job
EXEC msdb.dbo.sp_stop_job @job_name=''LSRestore_GPHIXSQL01_HIX_PRODUCTIE''

*/

-- Script

-- Enable

IF EXISTS ( SELECT ''Klaar'' WHERE 2 = 
                ( ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                   WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                    FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                     AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                     AND CHOSENMODELS like ''%DDR%'' 
				                     AND Duration >= 35000 ) 
		  + 
				  ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                   WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                    FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                     AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                     AND CHOSENMODELS like ''%REF%'' 
					                 AND Duration >= 35000 )) )

    BEGIN

             EXEC msdb.dbo.sp_update_job @job_name = ''LSRestore_GPHIXSQL01_HIX_PRODUCTIE'', @enabled = 1

             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Verzamel Performance Info'', @enabled = 1 
             
             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Controle DataWareHouse Bijwerken'', @enabled = 0

             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Controle DWH verversing'', @enabled = 0

             PRINT ''DWH is Klaar. ENABLE Logship''  
/*            
             SET @RecipientsMail  = ''tab@bravis.nl'' 
             
             SET @tableHTML =  N''<H1>Voor Technisch Applicatiebeheer (TAB)</H1>'' +  
                               N''<H4>LSRestore (Logship bijwerken) op de RPHIXDWH01 is gestart en is weer enabled omdat het bijwerken DWH klaar is.</H4>'' 
*/
      END

----- Disable

IF EXISTS ( SELECT ''Fout'' WHERE 2 > 
                ( ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                   WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                    FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                     AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                     AND CHOSENMODELS like ''%DDR%'' 
				                     AND Duration >= 35000 ) 
		  + 
				  ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                   WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                    FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                     AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                     AND CHOSENMODELS like ''%REF%'' 
					                 AND Duration >= 35000 )) )

    BEGIN

             EXEC msdb.dbo.sp_update_job @job_name = ''LSRestore_GPHIXSQL02_HIX_PRODUCTIE'', @enabled = 0
             
             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Verzamel Performance Info'', @enabled = 0  
             
             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Controle DataWareHouse Bijwerken'', @enabled = 1

             EXEC msdb.dbo.sp_update_job @job_name = ''ZKH: Controle DWH verversing'', @enabled = 1

             PRINT ''DWH is NIET Klaar. Disable Logship'' 
		  
             SET @StatusREF  = ( SELECT ''REF (Bijwerken DWH NIET Dossier) is nog niet klaar'' WHERE 0 = 		  
		  	                         ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                             WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                              FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                               AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                               AND CHOSENMODELS like ''%REF%'' 
					                           AND Duration >= 35000 ))
					                 
			 PRINT @StatusREF
			 
             SET @StatusDDR  = ( SELECT ''DDR (Bijwerken DWH Dossier) is nog niet klaar'' WHERE 0 = 
                                    ( SELECT COUNT(*) FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat]
                                            WHERE ( Verversing ) > = ( SELECT MAX(Verversing) - 3
                                             FROM [CSDW_Productie].[dbo].[DWHHlpVerversingsResultaat] )
                                              AND Datum >= ( GETDATE() - 6 ) AND EindDatum is not NULL
                                              AND CHOSENMODELS like ''%DDR%'' 
				                              AND Duration >= 35000 ))
		     PRINT @StatusDDR
/*
			 SET @RecipientsMail  = ''tab@bravis.nl'' 
                      
             SET @tableHTML =  N''<H1>Voor Technisch Applicatiebeheer (TAB)</H1>'' +  
                               N''<H4>LSRestore (Logship bijwerken) op de RPHIXDWH01 is niet gestart en is gedisabled omdat het bijwerken DWH niet klaar is.</H4>'' 
*/
      END
/*    
IF @tableHTML <> ''''
   BEGIN

        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name                =  ''GPHIXSQL02'' ,  
            @subject                     =  @OmschrijvingMail ,
            @recipients                  =  @RecipientsMail ,   
            @body                        =  @tableHTML,  
            @body_format                 = ''HTML''   

    END
 */', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Controle DWH', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=7, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180604, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235900, 
		@schedule_uid=N'3a12c54f-51b0-4954-99d0-7fb2ce825535'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Controle DWH', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=6, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180604, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=140100, 
		@schedule_uid=N'd49a7586-7bda-4538-9c7f-7beedfd48ea9'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Controle DWH', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190218, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=175900, 
		@schedule_uid=N'e9174db4-1468-4d3c-8518-3de75b9318fa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


