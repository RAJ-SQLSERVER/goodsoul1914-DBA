-- Plan cache metadata
---------------------------------------------------------------------------------------------------

select usecounts, 
	   cacheobjtype, 
	   objtype, 
	   [text]
from sys.dm_exec_cached_plans as P
	 cross apply sys.dm_exec_sql_text(plan_handle)
where cacheobjtype = 'Compiled Plan'
	  and [text] not like '%dm_exec_cached_plans%';
go