--INSERT INTO [Performance].[dbo].[PERF_ZISCON_LOGSESSI]
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
WHERE 
	(WINUSER like 'sa_%hixperf' OR WINUSER like 'AL_RSDIENA%') 
	AND STATUS like 'U'  
	AND INDATUM >= GETDATE() -100 -- later dan 4 dagen geleden
	AND [LOGSESS_ID] not in (
		SELECT [LOGSESS_ID]  
		FROM [Performance].[dbo].[PERF_ZISCON_LOGSESSI]) -- voeg alleen records toe die nog niet bestaan
ORDER BY 
	INDATUM, INTIJD


--INSERT INTO [Performance].[dbo].[PERF_ZISCON_LOGUSER]
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
WHERE 
	[LOGSESS_ID] in (
		SELECT [LOGSESS_ID] 
		FROM [Performance].[dbo].[PERF_ZISCON_LOGSESSI]) 
	AND [LOGSESS_ID] not in (
		SELECT [LOGSESS_ID] 
		FROM [Performance].[dbo].[PERF_ZISCON_LOGUSER]) -- voeg alleen records toe die nog niet bestaan
	AND INDATUM >= GETDATE() -4	-- later dan 4 dagen geleden
ORDER BY 
	INDATUM, INTIJD


--INSERT INTO [Performance].[dbo].[PERF_TESTRESULT]
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
WHERE 
	[LogUserId] in (
		SELECT LOGUSER_ID 
		FROM [Performance].[dbo].[PERF_ZISCON_LOGUSER]) 
	AND [LogUserId] not in (
		SELECT [LogUserId] 
		FROM [Performance].[dbo].[PERF_TESTRESULT])	-- voeg alleen records toe die nog niet bestaan
	AND Date>= GETDATE() -4	-- later dan 4 dagen geleden
ORDER BY 
	[Date], [Time]
