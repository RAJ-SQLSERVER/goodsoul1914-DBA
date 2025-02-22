/* Controleer dubbelen in eigen tabel */
SELECT TBICODE, COUNT(TBICODE)
  FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
  GROUP BY TBICODE
  HAVING COUNT(TBICODE) > 1

/* Controleer eigen met chipsoft tabellen */
SELECT *
  FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
WHERE TBICODE NOT IN (
SELECT TBICODE COLLATE DATABASE_DEFAULT 
FROM [EZIS_FZR].dbo.CSZISLIB_TBI 
)

SELECT *
  FROM [EZIS_FZR].dbo.CSZISLIB_TBI 
WHERE TBICODE NOT IN (
SELECT TBICODE COLLATE DATABASE_DEFAULT 
FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
)

/* */
SELECT *
  FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
WHERE TBICODE NOT IN (
SELECT TBICODE COLLATE DATABASE_DEFAULT 
FROM [CS_ConversieAanlevering].[dbo].[CSZISLIB_TBI]
)

SELECT *
  FROM [CS_ConversieAanlevering].[dbo].[CSZISLIB_TBI] 
WHERE TBICODE NOT IN (
SELECT TBICODE COLLATE DATABASE_DEFAULT 
FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
)

/* Insert missende FZR */
INSERT INTO [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
SELECT *
FROM [EZIS_FZR].dbo.CSZISLIB_TBI 
WHERE TBICODE NOT IN (
SELECT TBICODE COLLATE DATABASE_DEFAULT 
FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
)

/* Update vraagteken bij VERZVORM  */
UPDATE [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
SET VERZVORM = 'P', TBITYPE = 'G'
WHERE VERZVORM = '?'

/* Controle omnummering FZR, exclusief V */
SELECT COUNT(*) 
FROM FZR_aanlevering.dbo.ALG_omnummering_cszislib_tbi
WHERE OUD_FZR != ''

SELECT COUNT(*) 
FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]

SELECT *
FROM FZR_aanlevering.dbo.ALG_omnummering_cszislib_tbi
WHERE [OUD_FZR] NOT IN (
	SELECT TBICODE COLLATE DATABASE_DEFAULT 
	FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
) AND OUD_FZR != ''

SELECT *
FROM [FZR_aanlevering].[dbo].[FZR_cszislib_tbi]
WHERE TBICODE NOT IN (
	SELECT [OUD_FZR] COLLATE DATABASE_DEFAULT 
	FROM FZR_aanlevering.dbo.ALG_omnummering_cszislib_tbi
	WHERE OUD_FZR != ''
) AND TBITYPE != 'V'


SELECT INSTCODE, COUNT(INSTCODE)
FROM [FZR_aanlevering].[dbo].[LZB_cszislib_tbi]
WHERE VERVALLEN = 0 AND TBITYPE = 'V'
GROUP BY INSTCODE
HAVING COUNT(INSTCODE) > 1

SELECT LEFT(NIEUW, 5), COUNT(LEFT(NIEUW, 5))
FROM [FZR_aanlevering].[dbo].[LZB_omnummering_cszislib_tbi]
WHERE  NIEUW LIKE 'V%'
GROUP BY LEFT(NIEUW, 5)
HAVING COUNT(LEFT(NIEUW, 5)) > 1


SELECT *
FROM FZR_aanlevering.dbo.LZB_omnummering_cszislib_tbi
WHERE  NIEUW IN (
	SELECT NIEUW
	FROM FZR_aanlevering.dbo.FZR_omnummering_cszislib_tbi
)