-- An overview of plan reuse
---------------------------------------------------------------------------------------------------

select MAX(case
			   when usecounts between 10 and 100 then '10-100'
			   when usecounts between 101 and 1000 then '101-1000'
			   when usecounts between 1001 and 5000 then '1001-5000'
			   when usecounts between 5001 and 10000 then '5001-10000'
		   else CAST(usecounts as varchar(100))
		   end) as [Use Count], 
	   COUNT(*) as Count
from sys.dm_exec_cached_plans
group by case
			 when usecounts between 10 and 100 then 50
			 when usecounts between 101 and 1000 then 500
			 when usecounts between 1001 and 5000 then 2500
			 when usecounts between 5001 and 10000 then 7500
		 else usecounts
		 end
order by case
			 when usecounts between 10 and 100 then 50
			 when usecounts between 101 and 1000 then 500
			 when usecounts between 1001 and 5000 then 2500
			 when usecounts between 5001 and 10000 then 7500
		 else usecounts
		 end desc;
go