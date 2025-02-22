/****** Script for SelectTopNRows command from SSMS  ******/

/* ENDOBASE */
SELECT TOP 1000 *
  FROM [HIX_ACCEPTATIE].[dbo].UITSLAG4_PA_VERR

SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].UITSLAG4_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)


/* JIVEX */
SELECT TOP 1000 *
  FROM [HIX_ACCEPTATIE].[dbo].UITSLAG5_PA_OND

SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].UITSLAG5_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)


/* PALGA */
SELECT TOP 1000 *
  FROM [HIX_ACCEPTATIE].[dbo].[PATHO_PA_OND]

SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].[PATHO_PA_OND]
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)

SELECT YEAR(MONSTERDAT) AS Jaar, MONTH(MONSTERDAT) as Maand, COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].[PATHO_PA_OND]
GROUP BY  YEAR(MONSTERDAT),MONTH(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT),MONTH(MONSTERDAT)


/* MMB */
SELECT TOP 1000 *
  FROM [HIX_ACCEPTATIE].[dbo].[BACLAB_PA_VERR]

SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].[BACLAB_PA_OND]
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)

SELECT YEAR(MONSTERDAT) AS Jaar, MONTH(MONSTERDAT) as Maand, COUNT(*) as Aantal
FROM [HIX_ACCEPTATIE].[dbo].[BACLAB_PA_OND]
GROUP BY  YEAR(MONSTERDAT),MONTH(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT),MONTH(MONSTERDAT)
