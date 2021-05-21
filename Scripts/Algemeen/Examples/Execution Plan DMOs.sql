use [Credit];
go

-- Clearing the plan cache (don't do this in production)
dbcc freeproccache;
go

-- Execute this query
select payment_wide.member_no
from dbo.payment_wide
where payment_wide.expr_dt = '2000-10-12 10:41:34.757';

-- sys.dm_exec_cached_plans
select size_in_bytes, 
	   cacheobjtype, 
	   objtype, 
	   plan_handle
from sys.dm_exec_cached_plans;

-- Let's find our plan based on query text
select cp.size_in_bytes, 
	   cp.cacheobjtype, 
	   cp.objtype, 
	   cp.plan_handle, 
	   dest.[text]
from sys.dm_exec_cached_plans as cp
	 cross apply sys.dm_exec_sql_text(cp.plan_handle) as dest
where dest.[text] like '%payment_wide%';

-- sys.dm_exec_query_plan 
select dbid, 
	   query_plan
from sys.dm_exec_query_plan(0x060005007583A9125022B9FF0200000001000000000000000000000000000000000000000000000000000000);
go

-- sys.dm_exec_text_query_plan
select dbid, 
	   query_plan
from sys.dm_exec_text_query_plan(0x060005007583A9125022B9FF0200000001000000000000000000000000000000000000000000000000000000, 0, -1);
go