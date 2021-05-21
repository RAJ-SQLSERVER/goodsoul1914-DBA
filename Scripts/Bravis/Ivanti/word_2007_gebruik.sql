USE [RES-OW]
GO

SELECT	struser, count(*)
FROM	TBLhistory
WHERE	strtitle like 'Visio%'
GROUP BY 
		struser
ORDER BY 
		count(*) DESC
GO

