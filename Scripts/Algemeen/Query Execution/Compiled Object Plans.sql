-- Retrieving the plans for compiled objects
---------------------------------------------------------------------------------------------------

select refcounts, 
	   usecounts, 
	   size_in_bytes, 
	   cacheobjtype, 
	   objtype
from sys.dm_exec_cached_plans
where objtype in ('proc', 'prepared');
go