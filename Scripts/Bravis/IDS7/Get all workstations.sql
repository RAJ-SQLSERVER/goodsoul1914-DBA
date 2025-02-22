/*
	Get all Sectra workstations and their groups
*/
SELECT wg.Name AS [Group]
      ,[HardwareId2]
      ,[Hostname]
      ,w.[PreferredDomain]
      ,[Location]
      ,w.[PreferredDisplayMrnIssuer]
      ,w.[PreferredExportMrnIssuer]
FROM [SectraHealthcareStorage].[dbo].[Workstations] w
JOIN [SectraHealthcareStorage].[dbo].[WorkstationGroup] wg ON wg.Guid = w.WorkstationGroupGuid
