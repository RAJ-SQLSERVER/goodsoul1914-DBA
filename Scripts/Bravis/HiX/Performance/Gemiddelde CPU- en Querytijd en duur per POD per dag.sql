/****************************************************
 Gemiddelde CPU- en Querytijd en duur per POD per dag
****************************************************/

select SUBSTRING(CONVERT(nvarchar(10), Date, 120), 1, 10) as Datum, 
	   'POD' + SUBSTRING(WINSTAT, 5, 2) as POD, 
	   AVG(CpuTime) as AvgCpuTime, 
	   AVG(QueryTime) as AvgQueryTime, 
	   AVG(Duration) as AvgDuration
from dbo.PERF_RESULTATEN
where winstat like 'wovd%'
group by SUBSTRING(CONVERT(nvarchar(10), Date, 120), 1, 10), 
		 'POD' + SUBSTRING(WINSTAT, 5, 2)
order by SUBSTRING(CONVERT(nvarchar(10), Date, 120), 1, 10), 
		 'POD' + SUBSTRING(WINSTAT, 5, 2);