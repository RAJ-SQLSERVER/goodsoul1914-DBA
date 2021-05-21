-- Find single-use, ad-hoc and prepared queries that are bloating the plan cache
--
-- Gives you the text, type and size of single-use ad-hoc 
-- and prepared queries that waste space in the plan cache
-- Enabling 'optimize for ad hoc workloads' for the instance can help 
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to better control this
-- Enabling forced parameterization for the database can help, but test first!
--
-- Plan cache, adhoc workloads and clearing the single-use plan cache bloat
-- https://bit.ly/2EfYOkl
--
-- ------------------------------------------------------------------------------------------------

select top (50) DB_NAME(t.dbid) as [Database Name], 
				t.[text] as [Query Text], 
				cp.objtype as [Object Type], 
				cp.size_in_bytes / 1024 as [Plan Size in KB]
from sys.dm_exec_cached_plans as cp with(nolock)
	 cross apply sys.dm_exec_sql_text (plan_handle) as t
where cp.cacheobjtype = N'Compiled Plan'
	  and cp.objtype in (N'Adhoc', N'Prepared')
	  and cp.usecounts = 1
order by cp.size_in_bytes desc, 
		 DB_NAME(t.dbid) option(recompile);
go

-- Find single-use, ad hoc queries that are bloating the plan cache
---------------------------------------------------------------------------------------------------

select top (100) [text], 
				 cp.size_in_bytes
from sys.dm_exec_cached_plans as cp
	 cross apply sys.dm_exec_sql_text (plan_handle)
where cp.cacheobjtype = 'Compiled Plan'
	  and cp.objtype = 'Adhoc'
	  and cp.usecounts = 1
order by cp.size_in_bytes desc;
go

