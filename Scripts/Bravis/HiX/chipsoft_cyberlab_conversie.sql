/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 *
  FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab]


-- Selecteer onderzoeksnummer
-- Aantal 1.470.369
SELECT onderzoeksnummer
  FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab]

-- Selecteer uniek onderzoeksnummer
-- Aantal 1.470.368
SELECT onderzoeksnummer
  FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab]
  GROUP BY onderzoeksnummer

-- Selecteer uniek onderzoeksnummer voor HiX
-- Aantal 1.470.368
SELECT MAX(LEN(REPLACE(SUBSTRING(onderzoeksnummer,8,(LEN(onderzoeksnummer)-5)),'_','')))
  FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab]
  GROUP BY REPLACE(SUBSTRING(onderzoeksnummer,8,(LEN(onderzoeksnummer)-5)),'_','')


-- Selecteer unieke patientnummers
-- Aantal 157978
SELECT DISTINCT([patientnummer])
FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab]


-- Welke patientnummers van onderzoeken kunnen we niet matchen aan nieuwe
-- Aantal 152.185
SELECT c.[patientnummer],p.[PATIENTNR_NEW]
FROM [FZR_aanlevering].[dbo].[aanlevering_cyberlab] c
LEFT JOIN [CS_MAPPING].[dbo].[PATIENT_MERGE_TABEL] p ON c.[patientnummer] = p. [PATIENTNR_FZR] COLLATE DATABASE_DEFAULT
GROUP BY c.[patientnummer],p.[PATIENTNR_NEW]
HAVING PATIENTNR_NEW > 0


-- Selecteer welke bestanden geimporteerd zijn
SELECT 
	DISTINCT([bestand])
FROM 
	[FZR_aanlevering].[dbo].[aanlevering_cyberlab]
ORDER BY [bestand] DESC


-- Selecteer aantal berichten per bestand
SELECT 
	count([bestand]) as 'aantal',
	[bestand]
FROM 
	[FZR_aanlevering].[dbo].[aanlevering_cyberlab]
GROUP BY
	[bestand]
ORDER BY [bestand]


-- Selecteer aantal berichten per jaar
SELECT 
	count([onderzoeksdatum]) as 'aantal',
	year([onderzoeksdatum]) as 'jaar'
FROM 
	[FZR_aanlevering].[dbo].[aanlevering_cyberlab]
GROUP BY
	year([onderzoeksdatum])
ORDER BY year([onderzoeksdatum])


-- TRUNCATE TABLE [FZR_aanlevering].[dbo].[aanlevering_cyberlab]