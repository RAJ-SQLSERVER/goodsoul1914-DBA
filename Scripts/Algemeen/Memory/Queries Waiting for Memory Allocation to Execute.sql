-- Queries Waiting for Memory Allocation to Execute
select TEXT, 
	   query_plan, 
	   requested_memory_kb, 
	   granted_memory_kb, 
	   used_memory_kb, 
	   wait_order
from sys.dm_exec_query_memory_grants as MG
cross apply sys.dm_exec_sql_text(sql_handle)
cross apply sys.dm_exec_query_plan(MG.plan_handle);
go


