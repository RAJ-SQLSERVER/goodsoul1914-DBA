/**********************************************************
 Gemiddelde Sessietijd en duur per omgeving per dag
**********************************************************/

select distinct 
	   OMGEVING, 
	   VERSION, 
	   LATEST_HF, 
	   SUBSTRING(CONVERT(nvarchar(10), Date, 120), 1, 10) as Datum, 
	   AVG(SessieDuur) as SessieTime, 
	   AVG(Duration) as Duur
from dbo.PERF_RESULTATEN
group by Date, 
		 LATEST_HF, 
		 OMGEVING, 
		 VERSION
order by SUBSTRING(CONVERT(nvarchar(10), Date, 120), 1, 10);