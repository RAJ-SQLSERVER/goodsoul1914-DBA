use [master];
go

if exists
(
	select *
	from sys.objects
	where object_id = OBJECT_ID(N'[dbo].[sp_GetExpensiveQueries]')
		  and TYPE in (N'P', N'PC')
) 
	drop procedure dbo.sp_GetExpensiveQueries;
go

use [master];
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_GetExpensiveQueries 
	@Limit as           int, 
	@Database_Name as   varchar(255), 
	@Expense_Counter int
as
begin

/**************************************************************************************************
 Variables Used
	 
	 1. @Limit -- No of Recoreds to be Retrieved in Int
	 2. @Database_Name -- Database Name for which the Expense queries needs to be Retrieved in Varchar
	 3. @Expense_Counter -- Criteria on Which the Query Expense needs to judged
	 
	 End Variables Used 
**************************************************************************************************/

/*********************
 Expense Counter
	 DurTimeAvgMin 0
	 CPUTimeAvgMin 1
	 TotalCPUTime 2
	 TotalDurTime 3 
	 NoPhysicalReads 4
	 AvgNoPhyscialReads 5
	 NoLogicalReads 6
	 AvgNoLogicalReads 7
*********************/

	select Database_name, 
		   QueryText, 
		   ProcBatTest, 
		   PlanGenerationNumber, 
		   ExecutionCount, 
		   DurTimeAvgMin, 
		   CPUTimeAvgMin, 
		   TotalCPUTime, 
		   TotalDurTime, 
		   NoPhysicalReads, 
		   AvgNoPhyscialReads, 
		   NoLogicalReads, 
		   AvgNoLogicalReads
	from
	(
		select top (@Limit) DB_NAME(CONVERT(int, epa.value)) as Database_Name, 
							SUBSTRING(est.TEXT, eqs.statement_start_offset / 2 + 1, ( case eqs.statement_end_offset
																						  when -1 then DATALENGTH(est.TEXT)
																					  else eqs.statement_end_offset
																					  end - eqs.statement_start_offset ) / 2 + 1) as QueryText, 
							est.TEXT as ProcBatTest, 
							eqs.plan_generation_num as PlanGenerationNumber, 
							eqs.execution_count as ExecutionCount, 
							eqs.total_worker_time / 1000 as TotalCPUTime, 
							( ( eqs.total_worker_time / 1000 ) / eqs.execution_count ) / 3600 as CPUTimeAvgMin, 
							eqs.total_elapsed_time / 1000 as TotalDurTime, 
							( ( eqs.total_elapsed_time / 1000 ) / eqs.execution_count ) / 3600 as DurTimeAvgMin, 
							eqs.total_physical_reads as NoPhysicalReads, 
							eqs.total_physical_reads / eqs.execution_count as AvgNoPhyscialReads, 
							eqs.total_logical_reads as NoLogicalReads, 
							eqs.total_logical_reads / eqs.execution_count as AvgNoLogicalReads, 
							eqs.last_execution_time as LastExecutionTime
		from SYS.DM_EXEC_QUERY_STATS as eqs
			 cross apply SYS.DM_EXEC_SQL_TEXT(sql_handle) as est
			 cross apply SYS.DM_EXEC_QUERY_PLAN(plan_handle) as eqp
			 cross apply SYS.DM_EXEC_PLAN_ATTRIBUTES(eqs.plan_handle) as epa
		where attribute = 'dbid'
			  and DB_NAME(CONVERT(int, epa.value)) = @Database_Name
	) as x --and qs.last_execution_time > '2011-08-09 17:29:33.750'
	--If we want to get queries executed greater than some time
	--and (((qs.total_elapsed_time/1000)/qs.execution_count)/3600) >= 2
	order by
	--Seems to be Problem with Order By working on the same
	--Order By Fixed
	case
		when @Expense_Counter = 0 then DurTimeAvgMin
		when @Expense_Counter = 1 then CPUTimeAvgMin
		when @Expense_Counter = 2 then TotalCPUTime
		when @Expense_Counter = 3 then TotalDurTime
		when @Expense_Counter = 4 then NoPhysicalReads
		when @Expense_Counter = 5 then AvgNoPhyscialReads
		when @Expense_Counter = 6 then NoLogicalReads
		when @Expense_Counter = 7 then AvgNoLogicalReads
	end desc;
end;
go

--EXEC sp_GetExpensiveQueries 
--@Limit = 10
--, @Database_Name = 'IST'
--, @Expense_Counter = 2