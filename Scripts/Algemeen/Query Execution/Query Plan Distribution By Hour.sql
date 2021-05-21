-- Query Plan Distribution By Hour
-- ------------------------------------------------------------------------------------------------

select top 50 creation_date = CAST(creation_time as date), 
			  creation_hour = case
								  when CAST(creation_time as date) <> CAST(GETDATE() as date) then 0
								  else DATEPART(hh, creation_time)
							  end, 
			  SUM(1) as plans
from sys.dm_exec_query_stats
group by CAST(creation_time as date),
		 case
			 when CAST(creation_time as date) <> CAST(GETDATE() as date) then 0
			 else DATEPART(hh, creation_time)
		 end
order by 1 desc, 
		 2 desc;
go