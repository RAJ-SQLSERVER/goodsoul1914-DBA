/* PALGA FZR */
USE EZIS_FZR
SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM PATHO_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)

/* PALGA LZB */
USE EZIS_LZB
SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM UITSLAG9_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)
 
/* JIVEX FZR */
USE EZIS_FZR
SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM UITSLAG5_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)

/* GLIMS KCL FZR */
USE EZIS_FZR
SELECT YEAR(AFDATUM) AS Jaar,COUNT(*) as Aantal
FROM LAB_L_AANVRG
WHERE BRONCODE = 'LABBR1'
GROUP BY  YEAR(AFDATUM)
ORDER BY YEAR(AFDATUM)

/* GLIMS MMB FZR */
USE EZIS_FZR
SELECT YEAR(MONSTERDAT) AS Jaar,COUNT(*) as Aantal
FROM BACLAB_PA_OND
GROUP BY  YEAR(MONSTERDAT)
ORDER BY YEAR(MONSTERDAT)