set transaction isolation level read uncommitted;
 
with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select n.value('(@StatementText)[1]', 'VARCHAR(4000)') as SqlText, 
			n.query('.') as [StatementXml], 
			i.value('(@PhysicalOp)[1]', 'VARCHAR(128)') as PhysicalOp, 
			i.value('(./IndexScan/Object/@Database)[1]', 'VARCHAR(128)') as DatabaseName, 
			i.value('(./IndexScan/Object/@Schema)[1]', 'VARCHAR(128)') as SchemaName, 
			i.value('(./IndexScan/Object/@Table)[1]', 'VARCHAR(128)') as TableName, 
			i.value('(./IndexScan/Object/@Index)[1]', 'VARCHAR(128)') as IndexName, 
			i.query('.') as [RelOp], 
			STUFF(
			 (
				 select distinct 
						', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
				 from i.nodes('./OutputList/ColumnReference') as t(cg) for xml path('')
			 ), 1, 2, '') as OutputColumns, 
			STUFF(
			 (
				 select distinct 
						', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
				 from i.nodes('./IndexScan/SeekPredicates/SeekPredicateNew//ColumnReference') as t(cg) for xml path('')
			 ), 1, 2, '') as SeekColumns, 
			i.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]', 'VARCHAR(4000)') as Predicate, 
			cp.usecounts as UseCount, 
			query_plan as QueryPlan
	 from
	 (
		 select plan_handle, 
				query_plan
		 from
		 (
			 select distinct 
					plan_handle
			 from sys.dm_exec_query_stats with(nolock)
		 ) as qs
		 outer apply sys.dm_exec_query_plan(qs.plan_handle) as tp
	 ) as tab(plan_handle, query_plan)
	 inner join sys.dm_exec_cached_plans as cp on tab.plan_handle = cp.plan_handle
	 cross apply query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') as q(n)
	 cross apply n.nodes('.//RelOp[IndexScan[@Lookup="1"] and IndexScan/Object[@Schema!="[sys]"]]') as s(i) option(recompile, maxdop 1);