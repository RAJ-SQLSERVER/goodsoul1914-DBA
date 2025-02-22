SELECT COUNT(*) FROM UITSLAG4_PA_OND
SELECT COUNT(*) FROM UITSLAG4_PA_VERR

TRUNCATE TABLE UITSLAG4_PA_OND1
TRUNCATE TABLE UITSLAG4_PA_VERR1

SELECT COUNT(*) FROM UITSLAG5_PA_OND
SELECT COUNT(*) FROM UITSLAG5_PA_VERR

TRUNCATE TABLE UITSLAG5_PA_OND1
TRUNCATE TABLE UITSLAG5_PA_VERR1

SELECT YEAR(MONSTERDAT), COUNT(*) FROM dbo.PATHO_PA_OND GROUP BY YEAR(MONSTERDAT)

SELECT SUBSTRING(ONDERZNR, 5,9), * FROM dbo.PATHO_PA_OND 
WHERE YEAR(MONSTERDAT) = '2008' AND SUBSTRING(ONDERZNR, 5,9) > 30000
ORDER BY ONDERZNR

SELECT SUBSTRING(ONDERZNR, 5,9), * FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2004' 
SELECT SUBSTRING(ONDERZNR, 5,9), * FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2008' 



SELECT COUNT(*) FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2004'

SELECT COUNT(*) FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2004' AND SUBSTRING(ONDERZNR, 5,9) < 10000

DELETE FROM dbo.PATHO_PA_VERR WHERE ONDERZNR IN (
	SELECT ONDERZNR FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2004' AND SUBSTRING(ONDERZNR, 5,9) < 10000
)

DELETE FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2004' AND SUBSTRING(ONDERZNR, 5,9) < 10000



SELECT COUNT(*) FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2008'

SELECT COUNT(*) FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2008' AND SUBSTRING(ONDERZNR, 5,9) < 30000

DELETE FROM dbo.PATHO_PA_VERR WHERE ONDERZNR IN (
	SELECT ONDERZNR FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2008' AND SUBSTRING(ONDERZNR, 5,9) < 30000
)

DELETE FROM dbo.PATHO_PA_OND WHERE YEAR(MONSTERDAT) = '2008' AND SUBSTRING(ONDERZNR, 5,9) < 30000



