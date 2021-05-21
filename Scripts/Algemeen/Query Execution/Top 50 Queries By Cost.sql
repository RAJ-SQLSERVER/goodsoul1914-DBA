-- Show Top 50 Most Expensive Queries
-- ------------------------------------------------------------------------------------------------

select top 50 SUBSTRING(qt.text, qs.statement_start_offset / 2 + 1, ( case qs.statement_end_offset
																		  when -1 then DATALENGTH(qt.text)
																	  else qs.statement_end_offset
																	  end - qs.statement_start_offset ) / 2 + 1) as Sql, 
			  qs.execution_count as [Exec Cnt], 
			  ( qs.total_logical_reads + qs.total_logical_writes ) / qs.execution_count as [Avg IO], 
			  qp.query_plan as [Plan], 
			  qs.total_logical_reads as [Total Reads], 
			  qs.last_logical_reads as [Last Reads], 
			  qs.total_logical_writes as [Total Writes], 
			  qs.last_logical_writes as [Last Writes], 
			  qs.total_worker_time as [Total Worker Time], 
			  qs.last_worker_time as [Last Worker Time], 
			  qs.total_elapsed_time / 1000 as [Total Elps Time], 
			  qs.last_elapsed_time / 1000 as [Last Elps Time], 
			  qs.creation_time as [Compile Time], 
			  qs.last_execution_time as [Last Exec Time]
from sys.dm_exec_query_stats as qs with(nolock)
	 cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
	 cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp
order by [Avg IO] desc option(recompile);
go


-- Expensive Queries using cursor
-- ------------------------------------------------------------------------------------------------

with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select top 1000 DB_NAME(qt.dbid) as DbName, 
					 SUBSTRING(qt.TEXT, qs.statement_start_offset / 2 + 1, ( case qs.statement_end_offset
																				 when -1 then DATALENGTH(qt.TEXT)
																			 else qs.statement_end_offset
																			 end - qs.statement_start_offset ) / 2 + 1) as SQLStatement, 
					 qt.TEXT as BatchStatement, 
					 qs.execution_count, 
					 qs.total_logical_reads, 
					 qs.last_logical_reads, 
					 qs.total_logical_writes, 
					 qs.last_logical_writes, 
					 qs.total_worker_time, 
					 qs.last_worker_time, 
					 qs.total_elapsed_time / 1000000 as total_elapsed_time_in_S, 
					 qs.last_elapsed_time / 1000000 as last_elapsed_time_in_S, 
					 qs.last_execution_time, 
					 qp.query_plan, 
					 c.value('@StatementText', 'varchar(255)') as StatementText, 
					 c.value('@StatementType', 'varchar(255)') as StatementType, 
					 c.value('CursorPlan[1]/@CursorName', 'varchar(255)') as CursorName, 
					 c.value('CursorPlan[1]/@CursorActualType', 'varchar(255)') as CursorActualType, 
					 c.value('CursorPlan[1]/@CursorRequestedType', 'varchar(255)') as CursorRequestedType, 
					 c.value('CursorPlan[1]/@CursorConcurrency', 'varchar(255)') as CursorConcurrency, 
					 c.value('CursorPlan[1]/@ForwardOnly', 'varchar(255)') as ForwardOnly
	 from sys.dm_exec_query_stats as qs
		  cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
		  cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp
		  inner join sys.dm_exec_cached_plans as cp on cp.plan_handle = qs.plan_handle
		  cross apply qp.query_plan.nodes('//StmtCursor') as t(c)
	 where qp.query_plan.exist('//StmtCursor') = 1
		   --and DB_NAME(qt.dbid) not in ('uhtdba', 'msdb')
		   and ( qt.dbid is null
				 or DB_NAME(qt.dbid) not in ('uhtdba', 'msdb')
			   )
	 --order by qs.total_logical_reads desc; -- logical reads
	 --order by qs.total_logical_writes desc; -- logical writes
	 order by qs.total_worker_time desc; -- CPU time