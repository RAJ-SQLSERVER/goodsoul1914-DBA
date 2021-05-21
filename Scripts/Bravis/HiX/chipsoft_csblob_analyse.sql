/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
	[type],
	count([type]) AS aantal,
	(SUM(CAST(DATALENGTH([BLOB]) as float))) AS bytes,
	CAST(SUM(CAST(DATALENGTH([BLOB]) as float)) / 1024 / 1024 as decimal(38,2)) AS mb,
	MONTH([DATE]) AS maand,
	YEAR([DATE]) AS jaar
FROM 
	[HIX_ACCEPTATIE].[dbo].[CSBLOB_PASBLOB]
GROUP BY 
	[type],
	MONTH([DATE]),
	YEAR([DATE])
ORDER BY
	YEAR([DATE]) DESC,
	MONTH([DATE]) DESC,
	[type] ASC