/************************************************************
 Gemiddelde querytime en duration per HiX onderdeel per maand
************************************************************/

select distinct 
	   SUBSTRING(CONVERT(nvarchar(7), Date, 120), 1, 10) as Period, 
	   Name, 
	   AVG(QueryTime) as QueryTime, 
	   AVG(Duration) as Duration, 
	   AVG(NumberOfQueries) as NumberOfQueries
from dbo.PERF_RESULTATEN
group by Name, 
		 SUBSTRING(CONVERT(nvarchar(7), Date, 120), 1, 10)
order by SUBSTRING(CONVERT(nvarchar(7), Date, 120), 1, 10);