-- Top 50 Logical I/O queries
-- ------------------------------------------------------------------------------------------------

select top (50) DB_NAME(t.dbid) as [Database Name], 
				REPLACE(REPLACE(LEFT(t.[text], 255), CHAR(10), ''), CHAR(13), '') as [Short Query Text], 
				qs.total_logical_reads as [Total Logical Reads], 
				qs.min_logical_reads as [Min Logical Reads], 
				qs.total_logical_reads / qs.execution_count as [Avg Logical Reads], 
				qs.max_logical_reads as [Max Logical Reads], 
				qs.min_worker_time as [Min Worker Time], 
				qs.total_worker_time / qs.execution_count as [Avg Worker Time], 
				qs.max_worker_time as [Max Worker Time], 
				qs.min_elapsed_time as [Min Elapsed Time], 
				qs.total_elapsed_time / qs.execution_count as [Avg Elapsed Time], 
				qs.max_elapsed_time as [Max Elapsed Time], 
				qs.execution_count as [Execution Count],
				case
					when CONVERT(nvarchar(max), qp.query_plan) like N'%<MissingIndexes>%' then 1
					else 0
				end as [Has Missing Index], 
				qs.creation_time as [Creation Time], 
				t.[text] as [Complete Query Text], 
				qp.query_plan as [Query Plan]
from sys.dm_exec_query_stats as qs with(nolock)
	 cross apply sys.dm_exec_sql_text (plan_handle) as t
	 cross apply sys.dm_exec_query_plan (plan_handle) as qp
order by qs.total_logical_reads desc option(recompile);
go

-- Top 50 Fysical I/O queries
-- ------------------------------------------------------------------------------------------------

select top 50 q.query_hash, 
			  SUBSTRING(t.TEXT, q.statement_start_offset / 2 + 1, ( case q.statement_end_offset
																		when -1 then DATALENGTH(t.[text])
																		else q.statement_end_offset
																	end - q.statement_start_offset ) / 2 + 1), 
			  SUM(q.total_physical_reads) as total_physical_reads
from sys.dm_exec_query_stats as q
	 cross apply sys.dm_exec_sql_text (q.sql_handle) as t
group by q.query_hash, 
		 SUBSTRING(t.TEXT, q.statement_start_offset / 2 + 1, ( case q.statement_end_offset
																   when -1 then DATALENGTH(t.[text])
																   else q.statement_end_offset
															   end - q.statement_start_offset ) / 2 + 1)
order by SUM(q.total_physical_reads) desc;
go

-- By Average Logical I/O
---------------------------------------------------------------------------------------------------

declare @MinExecutions int = 5;

select EQS.total_worker_time as TotalWorkerTime, 
	   EQS.total_logical_reads + EQS.total_logical_writes as TotalLogicalIO, 
	   EQS.execution_count as ExeCnt, 
	   EQS.last_execution_time as LastUsage, 
	   EQS.total_worker_time / EQS.execution_count as [AvgCPUTime(ms)], 
	   ( EQS.total_logical_reads + EQS.total_logical_writes ) / EQS.execution_count as AvgLogicalIO, 
	   DB.name as DatabaseName, 
	   SUBSTRING(EST.TEXT, 1 + EQS.statement_start_offset / 2, ( case
																	 when EQS.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), EST.TEXT)) * 2
																	 else EQS.statement_end_offset
																 end - EQS.statement_start_offset ) / 2) as SqlStatement, 
	   EQP.query_plan as QueryPlan -- Optional with Query plan; remove comment to show, but then the query takes !!much longer time!! 
from sys.dm_exec_query_stats as EQS
	 cross apply sys.dm_exec_sql_text (EQS.sql_handle) as EST
	 cross apply sys.dm_exec_query_plan (EQS.plan_handle) as EQP
	 left join sys.databases as DB on EST.dbid = DB.database_id
where EQS.execution_count > @MinExecutions
	  and EQS.last_execution_time > DATEDIFF(MONTH, -1, GETDATE())
order by AvgLogicalIo desc, 
		 [AvgCPUTime(ms)] desc;
go

-- Query Execution Statistics By Average Physical Reads
---------------------------------------------------------------------------------------------------

select top 10 execution_count, 
			  statement_start_offset as stmt_start_offset, 
			  sql_handle, 
			  plan_handle, 
			  total_logical_reads / execution_count as avg_logical_reads, 
			  total_logical_writes / execution_count as avg_logical_writes, 
			  total_physical_reads / execution_count as avg_physical_reads, 
			  t.TEXT
from sys.dm_exec_query_stats as s
	 cross apply sys.dm_exec_sql_text (s.sql_handle) as t
order by avg_physical_reads desc;
go