USE [msdb]
GO

/****** Object:  Job [ZKH: Update statistics]    Script Date: 7-1-2020 23:32:51 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7-1-2020 23:32:51 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: Update statistics', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Update statistics HIX_Productie 1/2]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Update statistics HIX_Productie 1/2', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize
@Databases = ''HIX_PRODUCTIE'',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@MinNumberOfPages=0,
@UpdateStatistics = ''ALL'',
@OnlyModifiedStatistics = ''Y'',
@MaxDop = 12,
@TimeLimit= 7200,
@LogToTable= ''Y'',
@Indexes = ''ALL_INDEXES, -%.dbo.LAB_HUIDIGE_UITSLAG, -%.dbo.MEDICAT_DEELLST, -%.dbo.MEDICAT_RECDEEL, -%.dbo.OPNAME_OPNAME, -%.dbo.OPNAME_OPNMUT, -%.dbo.ORDERCOM_ACTIE, -%.dbo.ORDERCOM_ORDDEF, -%.dbo.ORDERCOM_ORDER, -%.dbo.ORDERCOM_ORDPLUG, -%.dbo.VRLIJST_LSTOPSLG, -%.dbo.VRLIJST_VROPSLG''', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Update statistics HIX_Productie 2/2]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Update statistics HIX_Productie 2/2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize
@Databases = ''HIX_PRODUCTIE'',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@MinNumberOfPages=0,
@UpdateStatistics = ''ALL'',
@OnlyModifiedStatistics = ''Y'',
@StatisticsSample = 100,
@MaxDop = 12,
@TimeLimit= 7200,
@LogToTable= ''Y'',
@Indexes = ''%.dbo.LAB_HUIDIGE_UITSLAG, %.dbo.MEDICAT_DEELLST, %.dbo.MEDICAT_RECDEEL, %.dbo.OPNAME_OPNAME, %.dbo.OPNAME_OPNMUT, %.dbo.ORDERCOM_ACTIE, %.dbo.ORDERCOM_ORDDEF, %.dbo.ORDERCOM_ORDER, %.dbo.ORDERCOM_ORDPLUG, %.dbo.ROUTEER_RCONTACT, %.dbo.VRLIJST_LSTOPSLG, %.dbo.VRLIJST_VROPSLG''
', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Remove query plans HIX_Productie]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Remove query plans HIX_Productie', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO', 
		@database_name=N'HIX_PRODUCTIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Recompile HIX_Productie]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Recompile HIX_Productie', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
	Recompile all tables on which maintenance was performed last night
*/

IF EXISTS(SELECT * FROM tempdb.sys.tables WHERE name = ''##tableList'')
	DROP TABLE ##tableList;

SELECT DISTINCT [SchemaName] AS schemaname,[ObjectName] AS tableName 
INTO ##tableList
FROM [ZKH_Maintenance].[dbo].[CommandLog]
WHERE DatabaseName = ''HIX_PRODUCTIE'' AND DATEDIFF(day, StartTime, GETDATE()) < 1
ORDER BY ObjectName;

DECLARE @tableName NVARCHAR(128) = (SELECT TOP 1 tableName FROM ##tableList);
DECLARE @startTime DATETIME;

WHILE EXISTS(SELECT TOP 1 * FROM ##tableList)
BEGIN
	SET @startTime = GETDATE();	
    
	EXEC sp_recompile @tableName;
	
	INSERT INTO [ZKH_Maintenance].[dbo].[CommandLog] (DatabaseName, SchemaName, ObjectName, CommandType, Command, StartTime, EndTime) 
		VALUES (''HIX_PRODUCTIE'', ''dbo'', @tableName, ''RECOMPILE_TABLE'', CONCAT(''sp_recompile'', '' '', @tableName), @startTime, GETDATE());
    
    DELETE FROM ##tableList WHERE tableName = @tableName;
    SET @tableName = (SELECT TOP 1 tableName FROM ##tableList);
END;


/* -- mb2o@20191224
EXEC sp_recompile AGENDA_AFSPRAAK
GO
EXEC sp_recompile AGENDA_MUTATIE
GO

EXEC sp_recompile CSZISLIB_ARTS
GO

exec sp_recompile CONTACT_CONTACT
GO
exec sp_recompile CONTACT_TYPETEL
GO

EXEC sp_recompile LAB_HUIDIGE_UITSLAG
GO

EXEC sp_recompile LOGISTK_BESTELRUN_TABEL
GO
EXEC sp_recompile LOGISTK_BESTELTYPE
GO
EXEC sp_recompile LOGISTK_BESTKOP_TABEL
GO
EXEC sp_recompile LOGISTK_BESTKORT
GO
EXEC sp_recompile LOGISTK_BESTKRTD
GO
EXEC sp_recompile LOGISTK_BESTWYZ
GO
EXEC sp_recompile LOGISTK_BESTYPEEAN
GO

EXEC sp_recompile MAPS_BOUWSTEENSTIJL
GO
EXEC sp_recompile MAPS_MAP
GO
EXEC sp_recompile MAPS_REGEL
GO
EXEC sp_recompile MAPS_SECTIE
GO
EXEC sp_recompile MAPS_SECTIETYPE
GO
EXEC sp_recompile MAPS_STIJL
GO

EXEC sp_recompile MEDICAT_DEELLST
GO
EXEC sp_recompile MEDICAT_MEDICIJN
GO
EXEC sp_recompile MEDICAT_RECDEEL
GO
EXEC sp_recompile MEDICAT_SCHEMA
GO


EXEC sp_recompile OPNAME_OPNAME
GO
EXEC sp_recompile OPNAME_OPNMUT
GO

EXEC sp_recompile ORDERCOM_ACTIE
GO
EXEC sp_recompile ORDERCOM_ORDDEF
GO
EXEC sp_recompile ORDERCOM_ORDER
GO
EXEC sp_recompile ORDERCOM_ORDPLUG
GO

EXEC sp_recompile PATIENT_PATIENT
GO

EXEC sp_recompile RECENTE_RECENTE
GO

EXEC sp_recompile RONTGEN_RONTGEN
GO
EXEC sp_recompile RONTGEN_RONTVERR
GO

EXEC sp_recompile UITSLAG5_PA_OND
GO
EXEC sp_recompile UITSLAG5_PA_VERR
GO

EXEC sp_recompile VRLIJST_KEUZELST
GO
EXEC sp_recompile VRLIJST_LSTOPSLG
GO
EXEC sp_recompile VRLIJST_VROPSLG
GO
EXEC sp_recompile VRLIJST_VTRIGGER
GO

EXEC sp_recompile WEBAGEN_VERWIJS
GO

EXEC sp_recompile WEBPORTA_PATBIBITEM
GO

EXEC sp_recompile WHATSNEW_POSTVKIN
GO
EXEC sp_recompile WHATSNEW_WHATSNEW
GO

EXEC sp_recompile WI_ARTSDOC
GO
EXEC sp_recompile WI_DOCHIST
GO
EXEC sp_recompile WI_DOCLIST
GO
EXEC sp_recompile WI_DOCUMENT
GO

EXEC sp_recompile ZISCON_AUTHLOG
GO
EXEC sp_recompile ZISCON_INVCONROL
GO
EXEC sp_recompile ZISCON_LOGSESSI
GO
EXEC sp_recompile ZISCON_LOGUSER
GO

EXEC sp_recompile ZISMUT_ZISMUT
GO

*/


/*
EXEC sp_recompile [DOSSIER_ATTAIT]
GO
EXEC sp_recompile [DOSSIER_ATTCH]
GO
EXEC sp_recompile [DOSSIER_ATTCHSJ]
GO
EXEC sp_recompile [DOSSIER_ATTSJIT]
GO
EXEC sp_recompile [DOSSIER_CATSPEC]
GO
EXEC sp_recompile [DOSSIER_CMPABST]
GO
EXEC sp_recompile [DOSSIER_CMPDOOD]
GO
EXEC sp_recompile [DOSSIER_CMPERNST]
GO
EXEC sp_recompile [DOSSIER_CMPOBD]
GO
EXEC sp_recompile [DOSSIER_CODETMPL]
GO
EXEC sp_recompile [DOSSIER_CODETPMB]
GO
EXEC sp_recompile [DOSSIER_DBLACTDEF]
GO
EXEC sp_recompile [DOSSIER_DCRIFORM]
GO
EXEC sp_recompile [DOSSIER_DCRLNKREG]
GO
EXEC sp_recompile [DOSSIER_DCRLNKTP]
GO
EXEC sp_recompile [DOSSIER_DIAGRELS]
GO
EXEC sp_recompile [DOSSIER_DOSFCUSE]
GO
EXEC sp_recompile [DOSSIER_DOSSAANT]
GO
EXEC sp_recompile [DOSSIER_DOSSAGEN]
GO
EXEC sp_recompile [DOSSIER_DOSSINFO]
GO
EXEC sp_recompile [DOSSIER_DOSSPRBLM]
GO
EXEC sp_recompile [DOSSIER_DOSSPRN]
GO
EXEC sp_recompile [DOSSIER_DOSSREGTYPE]
GO
EXEC sp_recompile [DOSSIER_DOSSVLD]
GO
EXEC sp_recompile [DOSSIER_DOSVIEWUSE]
GO
EXEC sp_recompile [DOSSIER_DRMASTER]
GO
EXEC sp_recompile [DOSSIER_DYNPARTEMPL]
GO
EXEC sp_recompile [DOSSIER_EPDDIAG]
GO
EXEC sp_recompile [DOSSIER_EPDDIAGB]
GO
EXEC sp_recompile [DOSSIER_EPDDIAGG]
GO
EXEC sp_recompile [DOSSIER_EPDDIAGP]
GO
EXEC sp_recompile [DOSSIER_EPDLAMPSJAB]
GO
EXEC sp_recompile [DOSSIER_EPDLAMPSJITM]
GO
EXEC sp_recompile [DOSSIER_FAVORITES]
GO
EXEC sp_recompile [DOSSIER_FUNC]
GO
EXEC sp_recompile [DOSSIER_GENDOSS]
GO
EXEC sp_recompile [DOSSIER_GENDPRAC]
GO
EXEC sp_recompile [DOSSIER_GENDPRAT]
GO
EXEC sp_recompile [DOSSIER_GUIDKOPPEL]
GO
EXEC sp_recompile [DOSSIER_INHOUDSJAB]
GO
EXEC sp_recompile [DOSSIER_INHOUDSJIT]
GO
EXEC sp_recompile [DOSSIER_INSPWID]
GO
EXEC sp_recompile [DOSSIER_KERNGROEP]
GO
EXEC sp_recompile [DOSSIER_LIJST]
GO
EXEC sp_recompile [DOSSIER_LIJSTCAT]
GO
EXEC sp_recompile [DOSSIER_LIJSTGEB]
GO
EXEC sp_recompile [DOSSIER_LIJSTOBJ]
GO
EXEC sp_recompile [DOSSIER_MULTIREG]
GO
EXEC sp_recompile [DOSSIER_MULTIREG_B]
GO
EXEC sp_recompile [DOSSIER_MULTITYPE]
GO
EXEC sp_recompile [DOSSIER_NOTE]
GO
EXEC sp_recompile [DOSSIER_OBJAANT]
GO
EXEC sp_recompile [DOSSIER_OBJDOSS]
GO
EXEC sp_recompile [DOSSIER_OBJMARK]
GO
EXEC sp_recompile [DOSSIER_PATSDOSS]
GO
EXEC sp_recompile [DOSSIER_PATSDOSSAANT]
GO
EXEC sp_recompile [DOSSIER_PATSELCOMBI]
GO
EXEC sp_recompile [DOSSIER_PATSELFAV]
GO
EXEC sp_recompile [DOSSIER_PATSELGROUP]
GO
EXEC sp_recompile [DOSSIER_PRINTBIND]
GO
EXEC sp_recompile [DOSSIER_PRINTSOURCE]
GO
EXEC sp_recompile [DOSSIER_PRINTSUMMARY]
GO
EXEC sp_recompile [DOSSIER_PRINTTEMPLAT]
GO
EXEC sp_recompile [DOSSIER_PRINTTMPBIND]
GO
EXEC sp_recompile [DOSSIER_REGTPLST]
GO
EXEC sp_recompile [DOSSIER_REMCOMPL]
GO
EXEC sp_recompile [DOSSIER_RIGHTS]
GO
EXEC sp_recompile [DOSSIER_SHOWOPT]
GO
EXEC sp_recompile [DOSSIER_SJABITMS]
GO
EXEC sp_recompile [DOSSIER_SJABLOON]
GO
EXEC sp_recompile [DOSSIER_SJABREG]
GO
EXEC sp_recompile [DOSSIER_STADIUM]
GO
EXEC sp_recompile [DOSSIER_SUBDOSS]
GO
EXEC sp_recompile [DOSSIER_TOTAALPARAM]
GO
EXEC sp_recompile [DOSSIER_TOTSJAB]
GO
EXEC sp_recompile [DOSSIER_TYPESJAB]
GO
EXEC sp_recompile [DOSSIER_USROBJSTAT]
GO
EXEC sp_recompile [DOSSIER_VFDF]
GO
EXEC sp_recompile [DOSSIER_VFDS]
GO
EXEC sp_recompile [DOSSIER_VFVW]
GO
EXEC sp_recompile [DOSSIER_VIEW]
GO
EXEC sp_recompile [DOSSIER_VIEWDYNGRP]
GO
EXEC sp_recompile [DOSSIER_VIEWFNCGROEP]
GO
EXEC sp_recompile [DOSSIER_VIEWFUNCTIE]
GO
EXEC sp_recompile [DOSSIER_VIEWITEMS]
GO
EXEC sp_recompile [DOSSIER_WERKSETTING]
GO
EXEC sp_recompile [DOSSIER_WSETTINGCAT]
GO
EXEC sp_recompile [DOSSIER_WSETTINGITM]
GO
*/

/*
DECLARE @schema VARCHAR(20),
        @spName VARCHAR(MAX),
        @fullName VARCHAR(MAX)

DECLARE storedProcedureCursor CURSOR FOR
    SELECT ''dbo'', name
    FROM HIX_PRODUCTIE.sys.objects
    WHERE TYPE = ''u''

OPEN storedProcedureCursor
FETCH NEXT FROM storedProcedureCursor INTO @schema, @spName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @fullName = @schema + ''.'' + @spName
    EXEC sp_recompile @objname = @fullName
	    FETCH NEXT FROM storedProcedureCursor INTO @schema, @spName
END 

CLOSE storedProcedureCursor
DEALLOCATE storedProcedureCursor

GO
*/', 
		@database_name=N'HIX_PRODUCTIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Update statistics NIET HIX_Productie]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Update statistics NIET HIX_Productie', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize
@Databases = ''USER_DATABASES, -HIX_PRODUCTIE'',
@FragmentationLow = NULL,
@FragmentationMedium = ''INDEX_REBUILD_ONLINE,INDEX_REORGANIZE'',
@FragmentationHigh = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 40,
--@PageCountLevel=8,
@UpdateStatistics = ''ALL'',
@OnlyModifiedStatistics = ''Y'',
--@StatisticsSample = 100,
@MaxDop = 0,
@Indexes = ''ALL_INDEXES'',
@TimeLimit = 600,
@LogToTable=''Y''', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH : Remove Queryplans NIET Productie]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH : Remove Queryplans NIET Productie', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_LOGGING
GO
IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

USE ZKH_Maintenance
GO
IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH : Recompile Alleen HIX_Logging]    Script Date: 7-1-2020 23:32:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH : Recompile Alleen HIX_Logging', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @schema VARCHAR(20),
        @spName VARCHAR(MAX),
        @fullName VARCHAR(MAX)

DECLARE storedProcedureCursor CURSOR FOR
    SELECT ''dbo'', name
    FROM HIX_Logging.sys.objects
    WHERE TYPE = ''u''

OPEN storedProcedureCursor
FETCH NEXT FROM storedProcedureCursor INTO @schema, @spName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @fullName = @schema + ''.'' + @spName
    EXEC sp_recompile @objname = @fullName
	    FETCH NEXT FROM storedProcedureCursor INTO @schema, @spName
END 

CLOSE storedProcedureCursor
DEALLOCATE storedProcedureCursor

GO', 
		@database_name=N'HIX_LOGGING', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Update statistics', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160309, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'34088d54-c523-4d65-92c2-3007bf751900'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


