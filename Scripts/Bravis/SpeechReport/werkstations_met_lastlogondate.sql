/****** Script for SelectTopNRows command from SSMS  ******/
SELECT C.[WorkstationID]
      ,W.[Name]
	  ,C.[KeyName]
      ,C.[KeyValue]
  FROM [G2Speech5].[dbo].[G2WorkstationConfig] C
  INNER JOIN [G2Speech5].[dbo].[G2Workstation] W
  ON W.ID = C.WorkstationID
  WHERE KeyName like '_OrganiserLastLogon'
  ORDER BY CONVERT(DATETIME,CONVERT(VARCHAR,C.[KeyValue]),103)