USE [msdb]
GO

/****** Object:  Job [Restore HIX_ACCEPTATIE]    Script Date: 11-1-2020 15:49:01 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Ziekenhuis]    Script Date: 11-1-2020 15:49:01 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Ziekenhuis' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Ziekenhuis'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Restore HIX_ACCEPTATIE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Ziekenhuis', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'GAHIXSQL01', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Automatisch Onderhoud]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Automatisch Onderhoud', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_update_job @job_name = ''IndexOptimize - USER_DATABASES'', @enabled = 0
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Taak server verwerkingen'', @enabled = 0
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Versie controle'', @enabled = 0
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Verzamel Performance Info'', @enabled = 0
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Performance TESTRESULT kopieren > HIX_LOGGING]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Performance TESTRESULT kopieren > HIX_LOGGING', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME= ''HIX_ACCEPTATIE'')
BEGIN

TRUNCATE TABLE [Performance].[dbo].[TMP_ZISCON_LOGSESSI]


INSERT INTO [Performance].[dbo].[TMP_ZISCON_LOGSESSI]
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
 FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGSESSI] 
WHERE WINUSER like ''sa_%hixperf'' AND STATUS like ''U'' ORDER BY INDATUM, INTIJD


TRUNCATE TABLE [Performance].[dbo].[TMP_ZISCON_LOGUSER]


INSERT INTO [Performance].[dbo].[TMP_ZISCON_LOGUSER]
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
  FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGUSER]
 WHERE [LOGSESS_ID] in ( SELECT [LOGSESS_ID] FROM [Performance].[dbo].[TMP_ZISCON_LOGSESSI] ) ORDER BY INDATUM, INTIJD


TRUNCATE TABLE [Performance].[dbo].[TMP_TESTRESULT]


INSERT INTO [Performance].[dbo].[TMP_TESTRESULT]
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
  FROM [HIX_ACCEPTATIE].[dbo].[LOG_TESTRESULT]
 WHERE [LogUserId] in ( select LOGUSER_ID from [Performance].[dbo].[TMP_ZISCON_LOGUSER] ) 
ORDER by Date, Time
END', 
		@database_name=N'Performance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop database]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop database', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- STAP 1, DROP DATABASE HIX_ACCEPTATIE
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N''HIX_ACCEPTATIE''
GO
USE [master]
GO
IF EXISTS (SELECT * FROM SYS.databases WHERE name = ''HIX_ACCEPTATIE'')
BEGIN
	ALTER DATABASE [HIX_ACCEPTATIE] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
END
GO
USE [master]
GO
/****** Object:  Database [HIX_ACCEPTATIE]    Script Date: 10/27/2013 14:40:35 ******/
IF EXISTS (SELECT * FROM SYS.databases WHERE name = ''HIX_ACCEPTATIE'')
BEGIN
	DROP DATABASE [HIX_ACCEPTATIE]
END
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore database]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- STAP 2, RESTORE DATABASE
RESTORE DATABASE [HIX_ACCEPTATIE] FROM  DISK = N''F:\Share\HIX_BACKUP_VOORTESTACC.bak'' WITH  FILE = 1,  
MOVE N''HIX_PRODUCTIE_Data'' TO N''D:\SQLDATA\HIX_ACCEPTATIE.mdf'',  
MOVE N''HIX_PRODUCTIE_Log'' TO N''E:\SQLLog\HIX_ACCEPTATIE.ldf'',  
MOVE N''HIX_PRODUCTIE_MULTIMEDIA'' TO N''E:\SQLFSData\HIX_ACCEPTATIE.EZIS_PRODUCTIE_MULTIMEDIA'',  
NOUNLOAD,  REPLACE,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Recovery model aanpassen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Recovery model aanpassen', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE [HIX_ACCEPTATIE] SET RECOVERY SIMPLE WITH NO_WAIT
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wijzig naamgeving]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wijzig naamgeving', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE CONFIG_INSTVARS
   SET VALUE = ''CHIX_ACCEPTATIE '' + CONVERT(VARCHAR(10), GETDATE(),105) + ''''
 WHERE NAAM =  ''ALG_ZH_OMGEVING'' 
   AND OWNER = ''CHIPSOFT'' ', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wijzig kleur]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wijzig kleur', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'update CONFIG_INSTVARS 
SET value = ''C'' + ''CSACC'' + ''.'' 
WHERE naam = ''SCHIL_CLRSCH''

insert into config_instvars (naam,owner, insttype, speccode, value, etd_status) 
values (''SCHIL_CLRSCH'', ''CHIPSOFT'', ''G'', '''', ''C'' + ''CSACC'' + ''.'' , '''')', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Opschonen Routeer server en Mail adressen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Opschonen Routeer server en Mail adressen', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
	Change 18038560 Aangevraagd door Ferdi in ''t Groen om tijdens het restore script
	                de velden te legen met email adressen en de confirmation op Nee te zetten
	       01112018 - MBL Initieel script toegevoegd
	       
*/

DELETE FROM [ROUTEER_RREGEL]
 WHERE VERWERKDAT IS NULL

UPDATE [ROUTEER_RADRES] SET CONFIRMATION=2, UITVOERDL='''' 
 WHERE ADRTYPE like ''0000000001'' OR UITVOERDL like ''%@%''

/*
	Wijzigen AAN adres van eoverdracht@bravis.nl naar eoverdracht_acc@bravis.nl
*/
UPDATE [OUTPUT_ACTIE] SET AAN = ''eoverdracht_acc@bravis.nl'' WHERE AAN = ''eoverdracht@bravis.nl''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Zorgportalen bijwerken]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Zorgportalen bijwerken', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Zorgdomein instellingen
UPDATE [ZP_SPAPPAUTH]
SET CONFIG = ''<?xml version="1.0" encoding="utf-8"?>
<authenticationConfiguration xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <settings>
    <setting>
      <name>SSOGroup</name>
      <value>ZD</value>
    </setting>
    <setting>
      <name>IdentityProvider</name>
      <value>https://ttt.zorgdomein.nl/zorgdomein/verwijzen/cszorgportaal/cszorgportaal.jsf</value>
    </setting>
    <setting>
      <name>RequireInitialRequest</name>
      <value>True</value>
    </setting>
    <setting>
      <name>CryptographicKeyName</name>
      <value>CSZDKEY</value>
    </setting>
    <setting>
      <name>NoAccessText</name>
      <value>Gebruik a.u.b. uw ZorgDomein applicatie om deze site te starten.</value>
    </setting>
    <setting>
      <name>ClientAddressFilter</name>
      <value></value>
    </setting>
    <setting>
      <name>ProxyHeaderForClientIpAddress</name>
      <value></value>
    </setting>
    <setting>
      <name>UserType</name>
      <value>Physician</value>
    </setting>
  </settings>
</authenticationConfiguration>''
WHERE [ID] = ''0000000005''


-- Digid instellingen
UPDATE [ZP_SPAPPAUTH]
SET [CONFIG] = ''<?xml version="1.0" encoding="utf-8"?>
<authenticationConfiguration xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <settings>
    <setting>
      <name>ComezConfig</name>
      <value>Address=GPHIXCOMEZ01.zkh.local,portnr=990,portname=BSNQRY2,timeout=20000,function=BSNQUERY</value>
    </setting>
    <setting>
      <name>EnablePatientQuery</name>
      <value>False</value>
    </setting>
    <setting>
      <name>MinimumSecurityLevel</name>
      <value>5</value>
    </setting>
    <setting>
      <name>ASelectServer</name>
      <value>digidasdemo1</value>
    </setting>
    <setting>
      <name>DigiDUrl</name>
      <value>https://was-preprod1.digid.nl/was/server</value>
    </setting>
    <setting>
      <name>AppId</name>
      <value>stbz01</value>
    </setting>
    <setting>
      <name>SharedSecret</name>
      <value>A83D-F637-F252-F588-IAHY-6VYB</value>
    </setting>
    <setting>
      <name>PatientServiceNumberType</name>
      <value>NL</value>
    </setting>
    <setting>
      <name>Organization</name>
      <value>Stichting Bravis Ziekenhuis</value>
    </setting>
    <setting>
      <name>AutoInitiateAuthetication</name>
      <value>False</value>
    </setting>
    <setting>
      <name>ClientAddressFilter</name>
      <value></value>
    </setting>
    <setting>
      <name>ProxyHeaderForClientIpAddress</name>
      <value></value>
    </setting>
    <setting>
      <name>SupportsRememberMe</name>
      <value>Never</value>
    </setting>
  </settings>
</authenticationConfiguration>''
WHERE ID = ''0000000009''
', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Comez bijwerken]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Comez bijwerken', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE CONFIG_INSTVARS
   SET VALUE = ''CAddress=GAHIXCOMEZ02.zkh.local,portnr=990,portname=BSNQRY2,timeout=20000,function=BSNQUERY''
 WHERE NAAM = ''BSN_QUERY'' AND OWNER = ''CHIPSOFT'' AND INSTTYPE = ''G''
GO
UPDATE CONFIG_INSTVARS
   SET VALUE = ''CAddress=GAHIXCOMEZ02.zkh.local,portnr=990,portname=BSNQRY2,timeout=20000,function=BSNQUERYBSN_NP''
 WHERE NAAM = ''BSN_QRYBSNNP'' AND OWNER = ''CHIPSOFT'' AND INSTTYPE = ''G''
GO
UPDATE CONFIG_INSTVARS
   SET VALUE = ''CAddress=GPHIXCOMEZ01.zkh.local,portnr=990,portname=BSNQRY2,timeout=20000,function=BSNQUERY''
 WHERE NAAM = ''WID_QUERY'' AND OWNER = ''CHIPSOFT'' AND INSTTYPE = ''G''
GO
/* Poortnummer = 552 */
UPDATE CONFIG_INSTVARS
SET VALUE = ''Caddress=GAHIXCOMEZ02.zkh.local,portname=GRPR_QRY,timeout=20000,function=GROUPERQUERY,portnr=552''
WHERE NAAM = ''VAL_GRPCOMEZ'' AND OWNER = ''CHIPSOFT''
GO
UPDATE CONFIG_INSTVARS 
SET VALUE = ''CAddress=GAHIXCOMEZ02.ZKH.LOCAL,portname=DICOM_QUERY,function=DICOM_QUERY,portnr=59341''
WHERE NAAM = ''CMZDICQR'' AND OWNER = ''CHIPSOFT''
GO
UPDATE CONFIG_INSTVARS 
SET VALUE = ''CLEMM,FEMM,MEMM,BEMM,LEKC,ETBD,LEIC,FEIC,LEPA,FEPA,LEDI''
WHERE NAAM = ''FAKT_IMPBRONB'' AND OWNER = ''CHIPSOFT''
GO', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Versiecontrole starten]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Versiecontrole starten', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*
update CONFIG_INSTVARS set VALUE = ''C6.1 HF51.0''
where NAAM = ''zc_hfcheck'' and OWNER = ''chipsoft''
*/

UPDATE [dbo].[CONFIG_INSTVARS]
    SET [VALUE] = ''C''+ ( SELECT SUBSTRING ( (SELECT MAX(LATEST_HF) FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGSESSI] 
                      WHERE APPLICATIE = ''CHIPSOFT.DATABAS'' ), 1, 9 ) + ''0'' ) 
  WHERE [NAAM] = ''zc_hfcheck'' and [OWNER] = ''chipsoft''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanpassen multimedia paden]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanpassen multimedia paden', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE MULTIMED_MAPCONFIG
   SET OUTPUTMAP = ''\\zkh.local\zkh\multimedia\chipsoft\Media\Acceptatie''
 WHERE MAPCONFID = ''CS00000001''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanpassen paden financieel]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanpassen paden financieel', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--update van config_instvars voor het wijzigen van de paden verwijzend naar \\zkh.local\zkh\Financieel
update CONFIG_INSTVARS
set value = replace(cast(value as varchar(max)), ''\\zkh.local\zkh\Financieel\'', ''\\zkh.local\zkh\Financieel\Acceptatie\'')
      where (value like ''%\%'' or value like ''%{$%}'' or value like ''%${%}'') 
            and value not like ''C<opmaak%'' 
            and naam <> ''RBUILDERINI'' 
            and  substring(cast(value as varchar(8000)),2,len(cast(value as varchar(8000)))-2) like ''\\zkh.local\zkh\Financieel%''
            -- onderstaande zou nog toegevoegd kunnen worden zodat een eventeel reeds bestaande verwijzing naar het juist path wordt uitgesloten. 
            -- momenteel niet in productie aanwezig, maar zou je het testen op acceptatie dan zijn ze wel aanwezig. 
            --and substring(cast(value as varchar(8000)),2,len(cast(value as varchar(8000)))-2) not like  ''\\zkh.local\zkh\financieel\Acceptatie\%''
', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanpassen postcodetabellen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanpassen postcodetabellen', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* 20191010 BVS RMR: Ultimo 19044867 */
UPDATE CONFIG_INSTVARS
   SET VALUE = ''CL:\I_en_A\FAB\SECTIE BEHEER\10.  Postcodetabel HIX\Logbestanden\ACC''
 WHERE NAAM = ''ZO_PAD_PCLOG'' AND OWNER = ''CHIPSOFT''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Zorgportaal BSN patiënten t.b.v. DigiD test]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Zorgportaal BSN patiënten t.b.v. DigiD test', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* In ieder geval tenbehoeve van Zorgportaal 2010: RMR */
UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900065059''
WHERE PATIENTNR = ''11580916''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900065084''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''12081272''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900065072''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''12394101''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900065060''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''14179454''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900065096''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''14496843''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900093092''
WHERE PATIENTNR = ''12487072''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900093109''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''14734569''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900093110''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''15584590''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900093122''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''15790111''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900093134''
, BSNDATUM = ''2013-10-25''
WHERE PATIENTNR = ''30041236''

/* Testpatienten ten behoeve van Zorgportaal 2013: RMR */
UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900169515''
, BSNDATUM = ''2019-01-01''
WHERE PATIENTNR = ''30840794''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900169527''
, BSNDATUM = ''2019-01-01''
WHERE PATIENTNR = ''15915857''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900169539''
, BSNDATUM = ''2019-01-01''
WHERE PATIENTNR = ''11866894''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900169540''
, BSNDATUM = ''2019-01-01''
WHERE PATIENTNR = ''30923565''

UPDATE [HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT 
SET BSN = ''900169552''
, BSNDATUM = ''2019-01-01''
WHERE PATIENTNR = ''10075831''
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanpassen taken tbv Taakserver]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanpassen taken tbv Taakserver', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE [HIX_ACCEPTATIE].[dbo].[TAAK_TAAKRUN]
SET [ENABLED] = 0
WHERE ( OMSCHRIJV NOT LIKE ''Automatisch%'' and OMSCHRIJV NOT LIKE ''Schonen HIX%'' and OMSCHRIJV NOT LIKE ''Verversen Data%'' 
  and OMSCHRIJV NOT LIKE ''Verversen DWH%'' and OMSCHRIJV NOT LIKE ''Controle workflow%'' )

-------- GPHIXTAAK01 --> GAHIXTAAK01

UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAK
   SET MACHINE = ''GAHIXTAAK01'', GEBRUIKER = ''DWTAAK''
 WHERE MACHINE = ''GPHIXTAAK01'' 
   AND DATUM >= GETDATE() AND ( OMSCHRIJV LIKE ''Verversen Data%'' OR OMSCHRIJV LIKE ''Verversen DWH%'' )

UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAKDEF
   SET MACHINE = ''GAHIXTAAK01''
 WHERE MACHINE = ''GPHIXTAAK01'' 
   AND ( OMSCHRIJV LIKE ''Verversen Data%'' OR OMSCHRIJV LIKE ''Verversen DWH%'' )

UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAKTEMP
   SET MACHINE = ''GAHIXTAAK01'', GEBRUIKER = ''DWTAAK''
 WHERE MACHINE = ''GPHIXTAAK01''
   AND ( OMSCHRIJV LIKE ''Verversen Data%'' OR OMSCHRIJV LIKE ''Verversen DWH%'' )

-------- GPHIXTAAK02/3/4 --> GAHIXTAAK02   

UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAK
   SET MACHINE = ''GAHIXTAAK02'', GEBRUIKER = ''TAAK''
 WHERE ( MACHINE = ''GPHIXTAAK02'' OR  MACHINE = ''GPHIXTAAK03'' OR  MACHINE = ''GPHIXTAAK04'' )
   AND DATUM >= GETDATE() AND EINDDATUM IS NULL 
   AND ( OMSCHRIJV LIKE ''Automatisch%'' OR OMSCHRIJV LIKE ''Schonen HIX%'' OR OMSCHRIJV LIKE ''Controle workflow%'' )

UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAKDEF
   SET MACHINE = ''GAHIXTAAK02''
 WHERE ( MACHINE = ''GPHIXTAAK02'' OR  MACHINE = ''GPHIXTAAK03'' OR  MACHINE = ''GPHIXTAAK04'' )
   AND ( OMSCHRIJV LIKE ''Automatisch%'' OR OMSCHRIJV LIKE ''Schonen HIX%'' OR OMSCHRIJV LIKE ''Controle workflow%'' )
   
UPDATE HIX_ACCEPTATIE.dbo.TAAK_TAAKTEMP
   SET MACHINE = ''GAHIXTAAK02'', GEBRUIKER = ''TAAK''
 WHERE ( MACHINE = ''GPHIXTAAK02'' OR  MACHINE = ''GPHIXTAAK03'' OR  MACHINE = ''GPHIXTAAK04'' )
   AND ( OMSCHRIJV LIKE ''Automatisch%'' OR OMSCHRIJV LIKE ''Schonen HIX%'' OR OMSCHRIJV LIKE ''Controle workflow%'' )
', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verander DWH instellingen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verander DWH instellingen', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE CONFIG_INSTVARS SET [VALUE] = ''CGAHIXDWH02'' WHERE [NAAM] = ''DWH_AS'' AND [INSTTYPE] = ''G''
UPDATE CONFIG_INSTVARS SET [VALUE] = ''CCSDW_Acceptatie'' WHERE [NAAM] = ''DWH_CATALOG'' AND [INSTTYPE] = ''G''
UPDATE CONFIG_INSTVARS SET [VALUE] = ''Chttp://GAHIXDWH02/Reportserver'' WHERE [NAAM] = ''DWH_REPSRV'' AND [INSTTYPE] = ''G''
UPDATE CONFIG_INSTVARS SET [VALUE] = ''C\\gahixdwh02\udl$\CSDW_Acceptatie.UDL'' WHERE [NAAM] = ''DWH_UDL'' AND [INSTTYPE] = ''G''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Rechten aan gebruikers toekennen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Rechten aan gebruikers toekennen', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Zet diverse gebruikers als systeembeheerders
  UPDATE [HIX_ACCEPTATIE].[dbo].[ZISCON_USER]
  SET [BEHEERDER] = 1
  WHERE [NAAM]  IN (''AVDKAR'',''MHAVERMA'',''NHEILIGE'',''SJOORE'',''LOOMEN'',''BJACOBS'',''CVBAVEL'',''JWILLEMS'',''CRUPERT1'', ''VHOUT'', ''GDEBBAUD'', ''MMINHEER'', ''EVDZANDE'', ''IVWINGEN'', ''SDBRUIJN'', ''MMEEUWIS'', ''SSTOLK2'', ''MVGILS1'',''AHEIJNEN'')

  -- Voeg Silvia IJzermans toe aan de groep APBOVZ als dit nog niet gedaan is
  IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPLNK]   WHERE [GROEPCODE] = ''APBOVZ'' AND [LINKCODE] = ''SIJZERMA'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPLNK] ([GROEPCODE],[LINKCODE],[ISLID],[VOLGORDE],[BEHEERNIVO],[LINKBLOKIMAGE]) VALUES (''APBOVZ'',''SIJZERMA'',''1'','''',''0'',''0'')
    END

  -- Voeg Ria Koot toe aan de inloggroep APBCB als dit nog niet gedaan is
  IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''APBCB'' AND [USERCODE] = ''RKOOT'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''APBCB'',''RKOOT'',''1'',''0'')
    END

-- Voeg François Sijnave toe aan de inloggroep APBCB als dit nog niet gedaan is
  IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''APBCB'' AND [USERCODE] = ''FSIJNAVE'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''APBCB'',''FSIJNAVE'',''1'',''0'')
    END

-- Voeg FAB toe aan de inloggroep SYSBH+ als dit nog niet gedaan is
IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''IGIESBER'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''IGIESBER'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''SVDBROE1'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''SVDBROE1'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''JSZABLEW'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''JSZABLEW'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''RVDAMME'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''RVDAMME'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''HDCOCQ'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''HDCOCQ'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''EBAATEN'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''EBAATEN'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''RVHEES'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''RVHEES'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''PVERSLUI'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''PVERSLUI'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''IHUIJBRE'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''IHUIJBRE'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''FITGROEN'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''FITGROEN'',''0'',''0'')
    END

IF NOT EXISTS (SELECT * FROM [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR]   WHERE [GRPUSRCODE] = ''SYSBH+'' AND [USERCODE] = ''ABKOOIJ1'')    
    BEGIN
       INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_GROEPUSR] ([GRPUSRCODE],[USERCODE],[USERBLOKIMAGE],[GROUPBLOKIMAGE]) VALUES (''SYSBH+'',''ABKOOIJ1'',''0'',''0'')
    END

UPDATE [HIX_ACCEPTATIE].[dbo].[CONFIG_INSTVARS]
SET VALUE = ''CTTTTFF''
where OWNER = ''@GPTHADM''
and NAAM = ''ond_rechten''
and INSTTYPE = ''U''
and SPECCODE = ''OCorder''
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Script opsporen locks]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Script opsporen locks', 
		@step_id=19, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @DatabaseName  				varchar(50)		=''HIX_ACCEPTATIE''
DECLARE @TableName     				varchar(50)		=''zkh_blocklog''

DECLARE @ProcedureName				varchar(50)		=''zkh_blockdetection''

DECLARE @AgentCategoryName     		varchar(50)		=''Ziekenhuis''
DECLARE @AgentJobName     			varchar(50)		=''ZKH: Block Detection''
DECLARE @AgentJobDescription		varchar(200)	=''Automatic Block-Detection by zkh''
DECLARE @AgentJobMode				varchar(50)		=''once''
DECLARE @AgentJobThreshold			varchar(50)		=1
DECLARE @AgentJobFrequency			varchar(50)		=1
DECLARE @AgentJobSave				varchar(50)		=1

DECLARE @AlertName					varchar(50)		=''ZKH: Block Detection''

/*
	Step 1 – Block Log Table
*/

-- check if table exists
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].''+@TableName) AND type in (N''U''))
BEGIN
	PRINT ''Creating table: [''+@DatabaseName+''].[dbo].[''+@TableName+'']''
	EXEC(''CREATE TABLE [''+@DatabaseName+''].[dbo].[''+@TableName+''] (
		[entry_no] bigint identity constraint [''+@TableName+''_Tab$pk_ci] primary key clustered,
		[timestamp] datetime,
		[db] varchar(128) collate database_default,
		[waitresource] varchar(128),
		[table_name] varchar(128) collate database_default,
		[index_name] varchar(128) collate database_default,
		[waittime] bigint,
		[lastwaittype] varchar(128),
		[spid] int,
		[loginame] varchar(128) collate database_default,
		[hostname] varchar(128) collate database_default,
		[program_name] varchar(128) collate database_default,
		[cmd] nvarchar(max) collate database_default,
		[query_plan] xml,
		[status] varchar(128) collate database_default,
		[cpu] bigint,
		[lock_timeout] int,
		[blocked by] int,
		[spid 2] int,
		[loginame 2] varchar(128) collate database_default,
		[hostname 2] varchar(128) collate database_default,
		[program_name 2] varchar(128) collate database_default,
		[cmd 2] nvarchar(max) collate database_default,
		[query_plan 2] xml,
		[status 2] varchar(128) collate database_default,
		[cpu 2] bigint, 
		[block_orig_id] int,
		[block_orig_loginame] varchar(128) collate database_default
	)'')
END


/*
	Step 2 – Stored Procedure to save the data 
*/

-- If procedure exists drop it
IF (OBJECT_ID(@ProcedureName) IS NOT NULL)
BEGIN
	PRINT ''Deleting procedure: [dbo].[''+@ProcedureName+'']''
	EXEC(''DROP PROCEDURE [dbo].[''+@ProcedureName+'']'')
END

-- Create procedure
PRINT ''Creating procedure: [dbo].[''+@ProcedureName+'']''
EXEC(''
CREATE PROCEDURE [dbo].[''+@ProcedureName+'']
  @mode varchar(10) = ''''loop'''',         -- "loop" or "once"
  @threshold int = 1000,              -- Block threshold in milliseconds 
  @frequency int = 3,                 -- Check frequency in milliseconds
  @save tinyint = 0                   -- save output to table ''+@TableName+'' (0 = no, 1 = yes)
with encryption
as

if @mode <> ''''once'''' begin
  print ''''*********************************************************''''
  print ''''***                  System Improvement               ***''''
  print ''''***    Performance Optimization & Troubleshooting     ***''''
  print ''''*********************************************************''''
  print ''''              Version 1.00, Date: 24.02.2013             ''''
  print ''''''''
end

if (@mode not in (''''loop'''', ''''once'''')) begin
  raiserror (''''ERROR: Invalid Parameter @mode: %s'''', 15, 1, @mode)
  return
end
if (@threshold < 1) begin
  raiserror (''''ERROR: Invalid Parameter @threshold: %i'''', 15, 1, @threshold)
  return
end
if (@frequency < 1) begin
  raiserror (''''ERROR: Invalid Parameter @frequency: %i'''', 15, 1, @frequency)
  return
end
if (@save not in (0,1)) begin
  raiserror (''''ERROR: Invalid Parameter @save: %i'''', 15, 1, @save)
  return
end

set nocount on
set statistics io off
declare @spid int, @spid2 int, @loginame varchar(128), @blocked_by int, @blocked_by_name varchar(128), @orig_id int, @orig_name varchar(128), @timestmp datetime, @i int

if @mode = ''''once''''
  goto start_check

while 1 = 1 begin

  start_check:

  if exists (select * from sys.dm_exec_requests where [blocking_session_id] <> 0) begin
    print ''''Checkpoint '''' + convert(varchar(30), getdate())
       
    if @save = 0 begin

     select 
             [db] = db_name(s1.[database_id]), 
             [waitresource] = ltrim(rtrim(s1.[wait_resource])),
             [table_name] = object_name(sl.rsc_objid),            
             [index_name] = si.[name],
             s1.[wait_time], 
             s1.[last_wait_type], 
             s1.[session_id],
             session1.[login_name], 
             session1.[host_name], 
             session1.[program_name], 
             [cmd] = isnull(st1.[text], ''''''''),
             [query_plan] = isnull(qp1.[query_plan], ''''''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id],             
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''''''),
             session2.[status],
             session2.[cpu_time]          
       -- Process Requests
       from sys.dm_exec_requests (nolock) s1 
       outer apply sys.dm_exec_sql_text(s1.sql_handle) st1
       outer apply sys.dm_exec_query_plan(s1.plan_handle) qp1
       left outer join sys.dm_exec_requests (nolock) s2 on s2.[session_id] = s1.[blocking_session_id]
       outer apply sys.dm_exec_sql_text(s2.sql_handle) st2
       outer apply sys.dm_exec_query_plan(s2.plan_handle) qp2
       -- Sessions
       left outer join sys.dm_exec_sessions (nolock) session1 on session1.[session_id] = s1.[session_id]
       left outer join sys.dm_exec_sessions (nolock) session2 on session2.[session_id] = s1.[blocking_session_id]
       -- Lock-Info
       left outer join  master.dbo.syslockinfo (nolock) sl on s1.[session_id] = sl.req_spid
       -- Indexes
       left outer join sys.indexes (nolock) si on sl.rsc_objid = si.[object_id] and sl.rsc_indid = si.[index_id]
       where s1.[blocking_session_id] <> 0 
             and (sl.rsc_type in (2,3,4,5,6,7,8,9)) and sl.req_status = 3
             and s1.[wait_time] >= @threshold

    end else begin

      set @timestmp = getdate()

      insert into [''+@TableName+'']
      ([timestamp],[db],[waitresource],[table_name],[index_name],[waittime],[lastwaittype],[spid],[loginame],[hostname],[program_name],[cmd],[query_plan],[status],[cpu],[lock_timeout],[blocked by],[spid 2],[loginame 2],[hostname 2],[program_name 2],[cmd 2],[query_plan 2],[status 2],[cpu 2],[block_orig_id],[block_orig_loginame])
      select @timestmp,
             [db] = db_name(s1.[database_id]), 
             [waitresource] = ltrim(rtrim(s1.[wait_resource])),
             [table_name] = object_name(sl.rsc_objid),            
             [index_name] = si.[name],
             s1.[wait_time], 
             s1.[last_wait_type], 
             s1.[session_id],
             session1.[login_name], 
             session1.[host_name], 
             session1.[program_name], 
             [cmd] = isnull(st1.[text], ''''''''),
             [query_plan] = isnull(qp1.[query_plan], ''''''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id], 
			 s2.[session_id],
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''''''),
             session2.[status],
             session2.[cpu_time],
             [block_orig_id] = null, 
             [block_orig_id] = null
       -- Process Requests
       from sys.dm_exec_requests (nolock) s1 
       outer apply sys.dm_exec_sql_text(s1.sql_handle) st1
       outer apply sys.dm_exec_query_plan(s1.plan_handle) qp1
       left outer join sys.dm_exec_requests (nolock) s2 on s2.[session_id] = s1.[blocking_session_id]
       outer apply sys.dm_exec_sql_text(s2.sql_handle) st2
       outer apply sys.dm_exec_query_plan(s2.plan_handle) qp2
       -- Sessions
       left outer join sys.dm_exec_sessions (nolock) session1 on session1.[session_id] = s1.[session_id]
       left outer join sys.dm_exec_sessions (nolock) session2 on session2.[session_id] = s1.[blocking_session_id]
       -- Lock-Info
       left outer join  master.dbo.syslockinfo (nolock) sl on s1.[session_id] = sl.req_spid
       -- Indexes
       left outer join sys.indexes (nolock) si on sl.rsc_objid = si.[object_id] and sl.rsc_indid = si.[index_id]
       where s1.[blocking_session_id] <> 0 
             and (sl.rsc_type in (2,3,4,5,6,7,8,9)) and sl.req_status = 3
             and s1.[wait_time] >= @threshold
    
      update [''+@DatabaseName+''].[dbo].[''+@TableName+''] set [table_name] = ''''- unknown -'''' where [table_name] is null

      -- get block originator
      declare originator_cur cursor for select [blocked by], [loginame 2]
        from [''+@DatabaseName+''].[dbo].[''+@TableName+'']
        where [timestamp] = @timestmp
        for update
      open originator_cur
      fetch next from originator_cur into @blocked_by, @blocked_by_name
      while @@fetch_status = 0 begin
        set @i = 0
        set @orig_id = @blocked_by   
        set @orig_name = @blocked_by_name 
        set @spid2 = @blocked_by
        while (@spid2 <> 0) and (@i < 100) begin
          if exists(select top 1 [blocked by] from [''+@DatabaseName+''].[dbo].[''+@TableName+''] where ([timestamp] = @timestmp) and ([spid] = @spid2)) begin
            select top 1 @spid = [blocked by], @loginame = [loginame 2] from [''+@DatabaseName+''].[dbo].[''+@TableName+''] where ([timestamp] = @timestmp) and ([spid] = @spid2)
            set @orig_id = @spid
            set @orig_name = @loginame                       
            set @spid2 = @spid         
          end else
            set @spid2 = 0
          set @i = @i + 1   -- "Emergency Exit", to avoid recursive loop
        end 
        update [''+@DatabaseName+''].[dbo].[''+@TableName+''] set [block_orig_id] = @orig_id, [block_orig_loginame] = @orig_name where current of originator_cur
        fetch next from originator_cur into @blocked_by, @blocked_by_name
      end
      close originator_cur
      deallocate originator_cur

    end
  end

  end_check:

  if @mode = ''''once''''
    return

  waitfor delay @frequency
end
'')


/*
	Step 3 – SQL Server Agent Job that will then execute the procedure 
*/

-- If agent job exists, then drop
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @AgentJobName)
BEGIN
	PRINT ''Deleting agent job: ''+@AgentJobName
	EXEC msdb.dbo.sp_delete_job @job_name=@AgentJobName, @delete_unused_schedule=1
END

-- Create agent job to execute the procedure
PRINT ''Creating agent job: ''+@AgentJobName
BEGIN TRANSACTION 
	DECLARE @ReturnCode INT 
	SELECT @ReturnCode = 0 
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@AgentCategoryName AND category_class=1) 
	BEGIN 
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=@AgentCategoryName 
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			GOTO QuitWithRollback 
	END 

	DECLARE @jobId BINARY(16) 

	EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=@AgentJobName, 
			@enabled=1, 
			@description=@AgentJobDescription, 
			@category_name=@AgentCategoryName, 
			@owner_login_name=N''sa'', @job_id = @jobId OUTPUT 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		DECLARE @SQL VARCHAR(200) = ''EXECUTE ''+@ProcedureName+'' @mode=''''''+@AgentJobMode+'''''', @threshold=''+@AgentJobThreshold+'', @frequency=''+@AgentJobFrequency+'', @save=''+@AgentJobSave
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''blockdetection'', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_fail_action=2, 
			@subsystem=N''TSQL'', 
			@command=@SQL, 
			@database_name=@DatabaseName        
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)'' 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
COMMIT TRANSACTION 
GOTO EndSave 

QuitWithRollback: 
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 

EndSave:


/*
	Step 4 – Alert to monitor "Processes Blocked"
*/

-- If alert exists then drop
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @AlertName) 
BEGIN 
	PRINT ''Deleting Alert: ''+@AlertName 
	EXEC msdb.dbo.sp_delete_alert @name=@AlertName 
END 

-- Create alert for SQL Server Performance Counter "SQLServer::General Statistics – Processes blocked"
PRINT ''Creating alert: ''+@AlertName
declare @instance varchar(128), @perfcon varchar(256)
if @@servicename = ''MSSQLSERVER'' -- Standard-Instance
  set @instance = ''SQLServer''
else -- Named Instance
  set @instance = ''MSSQL$'' + @@servicename
set @perfcon = @instance + N'':General Statistics|Processes blocked||>|0''

EXEC msdb.dbo.sp_add_alert @name=@AlertName, 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=10, 
  @include_event_description_in=0, 
  @performance_condition= @perfcon, 
  @job_name=@AgentJobName
GO
', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extra views]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extra views', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0000'')
BEGIN
	DROP VIEW ZKH_V0000
END
GO
CREATE VIEW ZKH_V0000
AS
SELECT ''ZKH_V0000''               AS sdNaam
     , ''Overzicht alle views''    AS sdOmchrijving
     , ''Robert Meijer''           AS sdAuteur
     , ''2014-01-21''              AS ddGemaakt
     , ''0.1''                     AS ndVersie
     , ''Robert Meijer''           AS sdGewijzigdDoor
     , ''2014-01-21''              AS ddLaatsteWijziging
UNION
SELECT ''ZKH_V0001'' 
     , ''Omgeving met hotfixversie''
     , ''Robert Meijer''
     , ''2014-01-21''
     , ''0.1''
     , ''Robert Meijer''
     , ''2014-01-21''
UNION
SELECT ''ZKH_V0002'' 
     , ''Historie alle hotfixes''
     , ''Robert Meijer''
     , ''2014-01-21''
     , ''0.1''
     , ''Robert Meijer''
     , ''2014-01-21''
UNION
SELECT ''ZKH_V0003'' 
     , ''Laatste locks per database''
     , ''Maico Pijnen''
     , ''2014-02-20''
     , ''0.2''
     , ''Maico Pijnen''
     , ''2014-03-04''
UNION
SELECT ''ZKH_V0004'' 
     , ''Activity monitor''
     , ''Maico Pijnen''
     , ''2014-02-27''
     , ''0.1''
     , ''Maico Pijnen''
     , ''2014-02-27''
UNION
SELECT ''ZKH_V0005'' 
     , ''SQL PerfCounters''
     , ''Maico Pijnen''
     , ''2014-03-01''
     , ''0.2''
     , ''Maico Pijnen''
     , ''2014-04-16''
UNION
SELECT ''ZKH_V0006'' 
     , ''Table sizes''
     , ''Maico Pijnen''
     , ''2014-08-11''
     , ''0.0''
     , ''Maico Pijnen''
     , ''2014-08-11''
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0001'')
BEGIN
	DROP VIEW ZKH_V0001
END
GO
CREATE VIEW ZKH_V0001
AS
SELECT TOP 1 b.name AS Omgeving
     , b.create_date AS DatumOmgeving
     , INDATUM AS Datum
     , LATEST_HF AS HOTFIX
  FROM ZISCON_LOGSESSI
     , sys.databases b
 WHERE APPLICATIE = ''CHIPSOFT.DATABAS'' AND INDATUM =
                          (SELECT     MAX(INDATUM)
                            FROM          ZISCON_LOGSESSI
                            WHERE      APPLICATIE = ''CHIPSOFT.DATABAS'') AND b.name LIKE ''HIX_%''
GO
                       
IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0002'')
BEGIN
	DROP VIEW ZKH_V0002
END
GO
CREATE VIEW ZKH_V0002
AS
SELECT DISTINCT INDATUM
     , LATEST_HF
  FROM ZISCON_LOGSESSI AS a
 WHERE APPLICATIE = ''CHIPSOFT.DATABAS''
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0003'')
BEGIN
	DROP VIEW ZKH_V0003
END
GO
CREATE VIEW ZKH_V0003
AS
SELECT      timestamp, block_orig_id AS spid, [loginame 2] AS loginname, [hostname 2] AS hostname, [program_name 2] AS programname, [cmd 2] AS query
FROM          zkh_blocklog
WHERE      (block_orig_id = [spid 2]) OR
                        (block_orig_id = spid)
GROUP BY timestamp, block_orig_id, [loginame 2], [hostname 2], [program_name 2], [cmd 2]
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0004'')
BEGIN
	DROP VIEW ZKH_V0004
END
GO
CREATE VIEW [dbo].[ZKH_V0004]
AS
SELECT 
   SessionId    = s.session_id, 
   UserProcess  = CONVERT(CHAR(1), s.is_user_process),
   LoginInfo    = s.login_name,   
   DbInstance   = ISNULL(db_name(r.database_id), N''''), 
   TaskState    = ISNULL(t.task_state, N''''), 
   Command      = ISNULL(r.command, N''''), 
   App            = ISNULL(s.program_name, N''''), 
   WaitTime_ms  = ISNULL(w.wait_duration_ms, 0),
   WaitType     = ISNULL(w.wait_type, N''''),
   WaitResource = ISNULL(w.resource_description, N''''), 
   BlockBy        = ISNULL(CONVERT (varchar, w.blocking_session_id), ''''),
   HeadBlocker  = 
        CASE 
            -- session has active request; is blocked; blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN ''1'' 
            -- session idle; has an open tran; blocking others
            WHEN r.session_id IS NULL THEN ''1'' 
            ELSE ''''
        END, 
   TotalCPU_ms        = s.cpu_time, 
   TotalPhyIO_mb    = (s.reads + s.writes) * 8 / 1024, 
   MemUsage_kb        = s.memory_usage * 8192 / 1024, 
   OpenTrans        = ISNULL(r.open_transaction_count,0), 
   LoginTime        = s.login_time, 
   LastReqStartTime = s.last_request_start_time,
   HostName            = ISNULL(s.host_name, N''''),
   NetworkAddr        = ISNULL(c.client_net_address, N''''), 
   ExecContext        = ISNULL(t.exec_context_id, 0),
   ReqId            = ISNULL(r.request_id, 0),
   WorkLoadGrp        = N'''',
   LastCommandBatch = (select text from sys.dm_exec_sql_text(c.most_recent_sql_handle)) 
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- Using row_number to select longest wait for each thread, 
    -- should be representative of other wait relationships if thread has multiple involvements. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as st

WHERE s.session_Id > 50                         -- ignore anything pertaining to the system spids.

AND s.session_Id NOT IN (@@SPID)     -- let''s avoid our own query! :)

GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0005'')
BEGIN
	DROP VIEW ZKH_V0005
END
GO
CREATE VIEW [dbo].[ZKH_V0005]
AS
SELECT      object_name, counter_name, instance_name, cntr_value, cntr_type
FROM          master.dbo.sysperfinfo
UNION
SELECT 
	''SQLServer:Custom'',
	''Total memory usage %'',
	'''',
	round(100 - (cast([available_physical_memory_kb] as decimal) / cast([total_physical_memory_kb] as decimal) * 100),2),
	''''
FROM 
	[master].[sys].[dm_os_sys_memory]
UNION
SELECT 
	''SQLServer:Custom'',
	''Total cpu usage %'',
	'''',
	cast((
		SELECT sum(cntr_value) 
		FROM sys.dm_os_performance_counters 
		WHERE object_name = ''SQLServer:Resource Pool Stats'' 
		and cntr_type = 537003264
	) as float) 
	/ 
	nullif(cast((
		select distinct cntr_value 
		from sys.dm_os_performance_counters 
		where object_name = ''SQLServer:Resource Pool Stats'' 
		and cntr_type = 1073939712
	) as float), 0)*100,
	''''
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0006'')
BEGIN
	DROP VIEW ZKH_V0006
END
GO
CREATE VIEW [dbo].[ZKH_V0006]
AS
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE ''dt%'' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
GO

GRANT SELECT ON ZKH_V0001 TO SQLReport
GRANT SELECT ON ZKH_V0002 TO SQLReport
GRANT SELECT ON ZKH_V0003 TO SQLReport
GRANT SELECT ON ZKH_V0004 TO SQLReport
GRANT SELECT ON ZKH_V0005 TO SQLReport
GRANT SELECT ON ZKH_V0006 TO SQLReport', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Corrigeren Radiologie testomgeving]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Corrigeren Radiologie testomgeving', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE CONFIG_INSTVARS SET VALUE = ''CWISETEST '' WHERE NAAM = ''RAD_IDSACCNGRP'' AND OWNER = ''CHIPSOFT'' AND INSTTYPE = ''G'' AND SPECCODE = ''CS000006''
UPDATE CONFIG_INSTVARS SET VALUE = ''Chttps://gtidspacs01.zkh.local/ids7/3pstart.aspx'' WHERE NAAM = ''RAD_WEBSERVER'' and OWNER = ''CHIPSOFT'' and SPECCODE = ''CS000006''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Corrigeren ZISMUT_ZISMUT]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Corrigeren ZISMUT_ZISMUT', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ZISMUTID int
DECLARE @SQL_Statement_Select nvarchar(100)
DECLARE @SQL_Statement_Update nvarchar(100)
DECLARE @TestOrAcceptationDB varchar(30)

SET @TestOrAcceptationDB = ''HIX_ACCEPTATIE''

SET @SQL_Statement_Select = N''SELECT TOP 1 @ZISMUTID = AutoID FROM '' + @TestOrAcceptationDB + ''..ZISMUT_ZISMUT ORDER BY AutoID DESC''
SET @SQL_Statement_Update = N''UPDATE '' + @TestOrAcceptationDB + ''..COMEZ_ROOTING SET ZMID = @ZISMUTID WHERE ZMID IS NOT NULL''

EXECUTE sp_executesql @SQL_Statement_Select, N''@ZISMUTID int OUTPUT'', @ZISMUTID OUTPUT
EXECUTE sp_executesql @SQL_Statement_Update, N''@ZISMUTID int'', @ZISMUTID', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Schonen tabel EzisIndexLog]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Schonen tabel EzisIndexLog', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'TRUNCATE TABLE EZISINDEXLOG', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Bijwerken HIX_JIP_LOGGING]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Bijwerken HIX_JIP_LOGGING', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE CONFIG_INSTVARS
   SET VALUE = ''CUser ID=Logging;Initial Catalog=HIX_LOGGING;Data Source=GAHIXSQL01''
 WHERE NAAM = ''LOG_PERFCS''
   AND OWNER = ''CHIPSOFT''
   AND INSTTYPE = ''G''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Oplossen orphaned user sysBVSDWHuser]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Oplossen orphaned user sysBVSDWHuser', 
		@step_id=25, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_change_users_login ''Auto_Fix'', ''sysBVSDWHuser''', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ChipsoftWinzis enablen]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ChipsoftWinzis enablen', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_change_users_login ''Auto_Fix'', ''ChipSoftWinZis''
GO
EXEC sp_change_users_login ''Auto_Fix'', ''zorgportaal''
GO
EXEC sp_change_users_login ''Auto_Fix'', ''SQLReport''
GO
', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Performance TESTRESULT kopieren > HIX_ACCEPTATIE]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Performance TESTRESULT kopieren > HIX_ACCEPTATIE', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'TRUNCATE TABLE [HIX_ACCEPTATIE].[dbo].[LOG_TESTRESULT]  
GO

TRUNCATE TABLE [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGUSER] 
GO

TRUNCATE TABLE [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGSESSI] 
GO

INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGSESSI]
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
 FROM [Performance].[dbo].[TMP_ZISCON_LOGSESSI] 
GO

INSERT INTO [HIX_ACCEPTATIE].[dbo].[ZISCON_LOGUSER]
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
  FROM [Performance].[dbo].[TMP_ZISCON_LOGUSER]
GO

INSERT INTO [HIX_ACCEPTATIE].[dbo].[LOG_TESTRESULT]
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
  FROM [Performance].[dbo].[TMP_TESTRESULT]  
GO

', 
		@database_name=N'HIX_ACCEPTATIE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Automatisch Onderhoud]    Script Date: 11-1-2020 15:49:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Automatisch Onderhoud', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC msdb.dbo.sp_update_job @job_name = ''IndexOptimize - USER_DATABASES'', @enabled = 1
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Taak server verwerkingen'', @enabled = 1
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Versie controle'', @enabled = 1
GO
EXEC msdb.dbo.sp_update_job @job_name = ''Verzamel Performance Info'', @enabled = 1
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Extra', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190609, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'5c73499d-9e71-4e60-ac69-29708863d67e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Verversing', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=6, 
		@active_start_date=20190113, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'a9fbf2c7-bb32-41f8-bf33-79984cd60be1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


