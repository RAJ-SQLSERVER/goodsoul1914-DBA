SELECT	DISTINCT SUBSTRING(CONVERT(nvarchar(7), Date, 120), 1, 10) AS Period, 
		WINSTAT, 
		AVG(QueryTime) AS QueryTime, 
		AVG(Duration) AS Duration, 
		AVG(NumberOfQueries) AS NumberOfQueries
FROM	dbo.PERF_RESULTATEN
GROUP BY 
		WINSTAT, 
		SUBSTRING(CONVERT(nvarchar(7), Date, 120), 1, 10)
ORDER BY 
		Period DESC, WINSTAT 