SSQL03 - RES_WorkspaceManager
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLserver]
WHERE
  strserver LIKE 'PC-03008%'
ORDER BY
  lngdate DESC
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLapp]
WHERE
  struser LIKE '%mboomaa%'
ORDER BY
  lngyrwk DESC
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[tblLogs]
WHERE
  strComputerName LIKE 'PC-03008%'
ORDER BY
  strDateTimeUTC DESC -- Alle acties uitgevoerd door een persoon op RES client
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[tblAudits]
WHERE
  strUserName LIKE '%mboomaa1%'
ORDER BY
  strDateTimeUTC DESC -- Alle acties uitgevoerd op een RES client
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[tblAudits]
WHERE
  strClientName LIKE 'RAD-0%'
ORDER BY
  strDateTimeUTC DESC -- Huidige activiteit
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[tblCurrentAct]
WHERE
  strUser LIKE '%mboomaa1%'
ORDER BY
  lngDate DESC -- Alle geopende vensters op een RES client
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLhistory]
WHERE
  strclientname LIKE 'PC-03008%'
ORDER BY
  lngstart DESC -- Alle geopende vensters door een gebruiker
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLhistory]
WHERE
  struser LIKE '%mboomaa1%'
ORDER BY
  lngstart DESC -- Sessie historie
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLsession]
ORDER BY
  lngstart DESC,
  lngstarttime DESC -- User activiteit
SELECT
  *
FROM
  [RES_WorkspaceManager].[dbo].[TBLuser]
WHERE
  struser LIKE '%pfeskens%'
ORDER BY
  lngyrwk DESC SSQL03 - RES_AutomationManager -- Agent informatie
SELECT
  *
FROM
  [RES_AutomationManager].[dbo].[tblAgents]
WHERE
  strName = 'PC-03008' -- Jobs
SELECT
  *
FROM
  [RES_AutomationManager].[dbo].[tblJobs]
ORDER BY
  dtmStartDateTime DESC