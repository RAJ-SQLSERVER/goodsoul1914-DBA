-- Examining plan reuse for a single procedure
---------------------------------------------------------------------------------------------------

select usecounts, 
	   cacheobjtype, 
	   objtype, 
	   OBJECT_NAME(dest.objectid)
from sys.dm_exec_cached_plans as decp
	 cross apply sys.dm_exec_sql_text(decp.plan_handle) as dest
where dest.objectid = OBJECT_ID('sp_BlitzFirst')
	  and dest.dbid = DB_ID()
order by usecounts desc;
go