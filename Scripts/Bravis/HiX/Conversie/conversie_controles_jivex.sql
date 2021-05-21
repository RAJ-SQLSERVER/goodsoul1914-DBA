/* JIVEX FZR */
USE EZIS_FZR
SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM UITSLAG5_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)

-- 174118
SELECT DISTINCT(accessionnumber)
FROM FZR_aanlevering.dbo.jivex_accessionnumber b 

-- 201836
SELECT DISTINCT(accessionnumber)
FROM FZR_aanlevering.dbo.jivex_accessionnumber_productie b 

-- 169339
SELECT DISTINCT(ONDERZNR)
FROM EZIS_FZR.dbo.UITSLAG5_PA_OND a

-- 169629
SELECT DISTINCT(accessionnumber)
FROM FZR_aanlevering.dbo.jivex_accessionnumber_aanl b 

SELECT b.accessionNumber, a.ONDERZNR, a.PATIENTNR, a.MONSTERDAT, a.OMSCRHIJV
FROM EZIS_FZR.dbo.UITSLAG5_PA_OND a
LEFT JOIN FZR_aanlevering.dbo.jivex_accessionnumber_productie b 
ON a.ONDERZNR = b.accessionNumber COLLATE DATABASE_DEFAULT
WHERE accessionNumber IS NULL

SELECT b.accessionNumber, a.ONDERZNR, a.PATIENTNR, a.MONSTERDAT, a.OMSCRHIJV
FROM FZR_aanlevering.dbo.jivex_accessionnumber_productie b 
LEFT JOIN EZIS_FZR.dbo.UITSLAG5_PA_OND a
ON a.ONDERZNR = b.accessionNumber COLLATE DATABASE_DEFAULT
WHERE ONDERZNR IS NULL



SELECT b.accessionNumber, a.ONDERZNR, a.PATIENTNR, a.MONSTERDAT, a.OMSCRHIJV
FROM FZR_aanlevering.dbo.jivex_accessionnumber_aanl b 
LEFT JOIN EZIS_FZR.dbo.UITSLAG5_PA_OND a
ON a.ONDERZNR = b.accessionNumber COLLATE DATABASE_DEFAULT
WHERE ONDERZNR IS NULL


SELECT TOP 100 b.accessionNumber, a.ONDERZNR, a.PATIENTNR, a.MONSTERDAT, a.OMSCRHIJV
FROM FZR_aanlevering.dbo.jivex_accessionnumber_productie b 
LEFT JOIN EZIS_FZR.dbo.UITSLAG5_PA_OND a
ON a.ONDERZNR = b.accessionNumber COLLATE DATABASE_DEFAULT
WHERE PATIENTNR IS NOT NULL
ORDER BY PATIENTNR

SELECT a.ONDERZNR, a.PATIENTNR, a.MONSTERDAT, a.OMSCRHIJV
FROM EZIS_FZR.dbo.UITSLAG5_PA_OND a