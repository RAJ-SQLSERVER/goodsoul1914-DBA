
-- Find high compile resource plans in the plan cache
-------------------------------------------------------------------------------

set transaction isolation level read uncommitted;
with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select top 10 CompileTime_ms, 
				   CompileCPU_ms, 
				   CompileMemory_KB, 
				   qs.execution_count, 
				   qs.total_elapsed_time / 1000 as duration_ms, 
				   qs.total_worker_time / 1000 as cputime_ms, 
				   ( qs.total_elapsed_time / qs.execution_count ) / 1000 as avg_duration_ms, 
				   ( qs.total_worker_time / qs.execution_count ) / 1000 as avg_cputime_ms, 
				   qs.max_elapsed_time / 1000 as max_duration_ms, 
				   qs.max_worker_time / 1000 as max_cputime_ms, 
				   SUBSTRING(st.text, qs.statement_start_offset / 2 + 1, ( case qs.statement_end_offset
																			   when -1 then DATALENGTH(st.text)
																		   else qs.statement_end_offset
																		   end - qs.statement_start_offset ) / 2 + 1) as StmtText, 
				   query_hash, 
				   query_plan_hash
	 from
	 (
		 select c.value('xs:hexBinary(substring((@QueryHash)[1],3))', 'varbinary(max)') as QueryHash, 
				c.value('xs:hexBinary(substring((@QueryPlanHash)[1],3))', 'varbinary(max)') as QueryPlanHash, 
				c.value('(QueryPlan/@CompileTime)[1]', 'int') as CompileTime_ms, 
				c.value('(QueryPlan/@CompileCPU)[1]', 'int') as CompileCPU_ms, 
				c.value('(QueryPlan/@CompileMemory)[1]', 'int') as CompileMemory_KB, 
				qp.query_plan
		 from sys.dm_exec_cached_plans as cp
			  cross apply sys.dm_exec_query_plan(cp.plan_handle) as qp
			  cross apply qp.query_plan.nodes('ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') as n(c)
	 ) as tab
	 join sys.dm_exec_query_stats as qs on tab.QueryHash = qs.query_hash
	 cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
	 order by CompileTime_ms desc option(recompile, maxdop 1);