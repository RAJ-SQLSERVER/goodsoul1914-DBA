--INSERT [Performance].[dbo].[PERF_RESULTATEN]
SELECT CASE WHEN ZS.[WINSTAT] LIKE 'GPHIXPERF01'  THEN 'VM'
			WHEN ZS.[WINSTAT] LIKE 'GAHIXPERF01'  THEN 'VM'
			WHEN ZS.[WINSTAT] LIKE '%G9'          THEN 'GWO Gen09'
			WHEN ZS.[WINSTAT] LIKE '%G10'         THEN 'GWO Gen10'
			WHEN ZS.[WINSTAT] LIKE 'WOVD%'        THEN 'GWO'
			WHEN ZS.[WINSTAT] LIKE 'PC0%F'		  THEN 'GWO FAT'
			WHEN ZS.[WINSTAT] LIKE 'PC-%'         THEN 'PC Lievensb'
			WHEN ZS.[WINSTAT] LIKE 'PC0%'         THEN 'PC Lievensb'
			WHEN ZS.[WINSTAT] LIKE '16-%'         THEN 'PC Lievensb'
			WHEN ZS.[WINSTAT] LIKE 'VD%'          THEN 'VDI RSD'
			WHEN ZS.[WINSTAT] LIKE 'SCTXD%'       THEN 'EXTRANET'
			ELSE 'ONBEKEND'									
		END as [OMGEVING]
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
      , CASE WHEN TR.[Name] like '%Medicatie benaderen%' THEN 'Medicatie benaderen'
            WHEN TR.[Name] like '%Openen Dossier%' THEN 'Openen Dossier'
            WHEN TR.[Name] like '%Consult bewerken%' THEN 'Consult bewerken' 
            WHEN TR.[Name] like '%Correspondentie openen%' THEN 'Correspondentie openen'
            WHEN TR.[Name] like '%JiveX%' THEN 'JiveX'
            WHEN TR.[Name] like '%Multimedia-overzicht patiënt%' THEN 'Multimedia-overzicht patiënt'
            WHEN TR.[Name] like '%KCHL%' THEN 'KCHL'
            WHEN TR.[Name] like '%Opnamehistorie patiënt%' THEN 'Opnamehistorie patiënt'
            WHEN TR.[Name] like '%Operatiehistorie%' THEN 'Operatiehistorie'
            WHEN TR.[Name] like '%Patiëntgegevens%' THEN 'Patiëntgegevens'
            WHEN TR.[Name] like '%Toedienregistratie%' THEN 'Toedienregistratie'
            WHEN TR.[Name] like '%Activiteitenplan%' THEN 'Activiteitenplan'
            WHEN TR.[Name] like '%Orders voor patiënt%' THEN 'Orders voor patiënt'
            WHEN TR.[Name] like '%Afdelingsbezettingsoverzicht%' THEN 'Afdelingsbezettingsoverzicht'
            WHEN TR.[Name] like '%Arts accordatielijst%' THEN 'Arts accordatielijst'
            WHEN TR.[Name] like '%Inzien multimedia%' THEN 'Inzien multimedia'
            WHEN TR.[Name] like '%Vitale functies%' THEN 'Vitale functies'
            WHEN TR.[Name] like '%Voorbereiden%' THEN 'Voorbereiden'
            WHEN TR.[Name] like '%Protocolleren%' THEN 'Protocolleren'
			ELSE TR.[Name] 
		END  AS [NAME]
      ,TR.[LogUserId]
      ,TR.[TestPlanId]
     , AVG ( TR.[GC0CollectionCount] )
     , AVG ( TR.[GC1CollectionCount] )
     , AVG ( TR.[GC2CollectionCount] )
     , AVG ( TR.[MemoryBeforeTest] )
     , AVG ( TR.[MemoryDeltaDuringTest] )
     , AVG ( TR.[MemoryDeltaAfterTest] )
FROM     
	[Performance].[dbo].[PERF_TESTRESULT] TR WITH (NOLOCK)
INNER JOIN 
	[Performance].[dbo].[PERF_ZISCON_LOGUSER] ZU WITH (NOLOCK) ON ZU.[LOGUSER_ID]  = TR.[LogUserId]
INNER JOIN 
	[Performance].[dbo].[PERF_ZISCON_LOGSESSI] ZS WITH (NOLOCK) ON ZU.[LOGSESS_ID] = ZS.[LOGSESS_ID] 
WHERE 	
	TR.[Name] like '%Performance meting/%' 
	AND ZS.[STATUS] like 'U' 
	AND ZS.[INDATUM] >= GETDATE() -4  -- later dan 4 dagen geleden
	AND ZS.[UITDATUM] is not NULL 
	AND TR.[LogUserId] not in (
		select [LOGUSERID] 
		from [Performance].[dbo].[PERF_RESULTATEN] WITH (NOLOCK))
GROUP BY 
	ZS.[VERSION], ZS.[LATEST_HF], ZS.[WINSTAT], TR.[Date], TR.[Name], ZS.[WINUSER], ZS.[WINSTAT], ZS.[LOGSESS_ID], ZS.[INDATUM], ZS.[INTIJD], ZS.[UITDATUM],
    ZS.[UITTIJD], ZS.[STATUS], ZS.[IPADRES], ZS.[PROCESSID], ZU.[GEBRUIKER], ZU.[MUTGEBRUIK], TR.[ParentResultId], TR.[Time], TR.[LogUserId], TR.[TestPlanId]
ORDER BY 
	ZS.[INDATUM] ASC
	, ZS.[INTIJD] ASC