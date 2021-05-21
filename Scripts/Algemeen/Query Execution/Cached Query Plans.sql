-- Returns a row for each query plan that is cached by SQL Server for faster query execution. 
-- You can use this dynamic management view to find cached query plans, cached query text, the 
-- amount of memory taken by cached plans, and the reuse count of the cached plans.
---------------------------------------------------------------------------------------------------

select DB_NAME(CAST(db.value as int)) as DBName, 
	   OBJECT_NAME(CAST(obj.value as int), CAST(db.value as int)) as objName, 
	   ecp.plan_handle, 
	   qp.query_plan, 
	   ecp.refcounts, 
	   ecp.usecounts, 
	   ecp.pool_id, 
	   ecp.cacheobjtype, 
	   ecp.bucketid
from sys.dm_exec_cached_plans as ecp(nolock)
	 cross apply sys.dm_exec_query_plan (ecp.plan_handle) as qp
	 cross apply sys.dm_exec_plan_attributes (ecp.plan_handle) as db
	 cross apply sys.dm_exec_plan_attributes (ecp.plan_handle) as obj
where db.attribute = 'dbid'
	  and db.value = DB_ID('AdventureWorks2017')
	  and obj.attribute = 'objectid'
	  and obj.value = OBJECT_ID('uspGetManagerEmployees');
go