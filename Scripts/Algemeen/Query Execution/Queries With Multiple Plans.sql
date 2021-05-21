/*********************************
 Find queries with multiple plans 
*********************************/

with cte_MultiPlanQueries
	 as (select *, 
				ROW_NUMBER() over(partition by qs.query_plan_hash
				order by qs.creation_time) as RowID, 
				COUNT(qs.sql_handle) over(partition by qs.query_plan_hash) as occurrences
		 from sys.dm_exec_query_stats as qs
		 where qs.query_plan_hash in (select qsi.query_plan_hash
									  from sys.dm_exec_query_stats as qsi
									  group by qsi.query_plan_hash
									  having COUNT(*) > 1) )
	 select qs.query_hash, 
			qs.query_plan_hash, 
			occurrences as PlanCounts, 
			qs.sql_handle, 
			qs.statement_start_offset, 
			qs.statement_end_offset, 
			qs.plan_handle, 
			qs.execution_count, 
			st.text as BatchText, 
			statement_text = SUBSTRING(st.TEXT, qs.statement_start_offset / 2 + 1, ( case qs.statement_end_offset
																						 when -1 then DATALENGTH(st.TEXT)
																					 else qs.statement_end_offset
																					 end - qs.statement_start_offset ) / 2 + 1)
	 from cte_MultiPlanQueries as qs
		  outer apply sys.dm_exec_sql_text(qs.sql_handle) as st
	 where qs.RowID <= 2
	 order by PlanCounts desc, 
			  qs.query_plan_hash;
go

/*********************************
 Find queries with multiple plans 
*********************************/

with tt
	 as (select q.PlanCount, 
				q.DistinctPlanCount, 
				st.text as QueryText, 
				qp.query_plan as QueryPlan
		 from (select query_hash, 
					  COUNT(distinct query_hash) as DistinctPlanCount, 
					  COUNT(query_hash) as PlanCount
			   from sys.dm_exec_query_stats
			   group by query_hash) as q
			  join sys.dm_exec_query_stats as qs on q.query_hash = qs.query_hash
			  cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
			  cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp
		 where PlanCount > 1)
	 select *
	 from tt
	 where tt.QueryText not like 'select name as objectName from source where source_id%'
		   and tt.QueryText not like 'INSERT INTO #group1_search_results (ROW_ID, master_title ,program_id,parent_program_id)%'
		   and tt.QueryText not like 'INSERT INTO #group1_search_results_tv_source (source_id) SELECT TOP%'
		   and tt.QueryText not like 'INSERT INTO #record_count SELECT COUNT(source_base.source_id)%'
		   and tt.QueryText not like 'SELECT         program_base.[program_id] AS %'
	 order by PlanCount desc;
