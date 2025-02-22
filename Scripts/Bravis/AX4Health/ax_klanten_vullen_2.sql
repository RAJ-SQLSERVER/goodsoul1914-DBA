/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
      [AccountNum], [Name], COUNT(*)
  FROM [FZR_AANLEVERING].[dbo].[custtable_patienten]
  GROUP BY [AccountNum],[Name]
  HAVING COUNT(*) > 1
  ORDER BY AccountNum
  
  SELECT * FROM [FZR_AANLEVERING].[dbo].[custtable_patienten] 
  
  SELECT * FROM [FZR_AANLEVERING].[dbo].[custtable_patienten] WHERE AUTOID NOT IN (SELECT MIN(AUTOID) _
	FROM [FZR_AANLEVERING].[dbo].[custtable_patienten]  GROUP BY [AccountNum],[Name]) 
  

DELETE FROM [FZR_AANLEVERING].[dbo].[custtable_patienten] WHERE AUTOID NOT IN (SELECT MIN(AUTOID) _
	FROM [FZR_AANLEVERING].[dbo].[custtable_patienten] GROUP BY [AccountNum],[Name]) 
  
  
  ALTER TABLE [FZR_AANLEVERING].[dbo].[custtable_patienten] ADD AUTOID INT IDENTITY(1,1) 
  
  
SELECT [LastName]
  FROM [FZR_AANLEVERING].[dbo].[custtable_patienten]
  WHERE [LastName] like '%-'
  
UPDATE [FZR_AANLEVERING].[dbo].[custtable_patienten]
set [LastName] = REPLACE([LastName],'-','')
  WHERE [LastName] like '%-'