select CAST(textdata as varchar(max)) as query, 
	   SPID, 
	   ClientProcessID, 
	   ApplicationName, 
	   AVG(duration) as avg_duration, 
	   SUM(duration) as total_duration, 
	   COUNT(*) as aantal, 
	   DATEDIFF(ms, MIN(starttime), MAX(starttime)) / 1000.0 as periode, 
	   CAST(1.0 * COUNT(*) / NULLIF(DATEDIFF(ms, MIN(starttime), MAX(starttime)), 0) * 1000 as int) as [aantal per seconde]
from dbo.test
where EventClass = 13
	  and ApplicationName = 'ChipSoft.FCL.Base'
group by CAST(textdata as varchar(max)), 
		 SPID, 
		 ClientProcessID, 
		 ApplicationName, 
		 DATEPART(hh, starttime), 
		 DATEPART(mi, starttime), 
		 DATEPART(ss, starttime)
having 1.0 * COUNT(*) / NULLIF(DATEDIFF(ms, MIN(starttime), MAX(starttime)), 0) * 1000 > 1
order by aantal desc;