/****** Script for SelectTopNRows command from SSMS  ******/
SELECT a.[Mnemonic], b.EXTERNALCODE
  FROM 
	[FZR_aanlevering].[dbo].[LAB_EXTLABTST_GLIMS] a
  RIGHT JOIN [FZR_aanlevering].[dbo].[LAB_EXTLABTST_HIX] b ON a.[Mnemonic] = b.EXTERNALCODE
  WHERE Mnemonic IS NULL
UNION
SELECT a.[Mnemonic], b.EXTERNALCODE
  FROM 
	[FZR_aanlevering].[dbo].[LAB_EXTLABTST_GLIMS] a
  LEFT JOIN [FZR_aanlevering].[dbo].[LAB_EXTLABTST_HIX] b ON a.[Mnemonic] = b.EXTERNALCODE
  WHERE EXTERNALCODE IS NULL
  
  
  
  SELECT *
  FROM [FZR_aanlevering].[dbo].[LAB_EXTLABTST_GLIMS]