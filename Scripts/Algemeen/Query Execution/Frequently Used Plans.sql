-- Examining frequently used plans
---------------------------------------------------------------------------------------------------

select top 2 with ties decp.usecounts, 
					   decp.cacheobjtype, 
					   decp.objtype, 
					   deqp.query_plan, 
					   dest.TEXT
from sys.dm_exec_cached_plans as decp
	 cross apply sys.dm_exec_query_plan (decp.plan_handle) as deqp
	 cross apply sys.dm_exec_sql_text (decp.plan_handle) as dest
order by usecounts desc;
go