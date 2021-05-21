-----------------------------------------------------------------------------------------
-- sp_PerformanceQueryShaping: Query Shaping tool identifying Performance features of 
-- active SQL Queries
--
-- Copyright (C) 2018, 2019 Edward Haynes
--
-- Stored procedure designed to work with SQL Server 2008 R2 and higher
-- providing on-demand performance detail from DMVs for queries with executing requests
-- 
-- Optional Parameters:
--    @ParamSniff   = Parameter Sniffing sensitivity multiplier
--                    < 1.0 (more hits);  1 or NULL (DEFAULT);  > 1.0 (less hits)
--                    Must be within the range of 0 to 2.0 otherwise will default to 1.0
-- 
--    @SessionLocks = 0 or NULL -- No locking detail (DEFAULT)
--                  = 1         -- Detailed locking  (performance overhead)
-- 
-- Example Usage:
--    EXEC dbo.sp_PerformanceQueryShaping
--    GO
-- 
--    EXEC dbo.sp_PerformanceQueryShaping @ParamSniff=0.75, @SessionLocks=1
--    GO
-- 
-- Email: QueryShape@gmail.com
-- 
-----------------------------------------------------------------------------------------

create procedure dbo.sp_PerformanceQueryShaping 
	@ParamSniff   float = null, 
	@SessionLocks bit   = null
as
begin
	set nocount on;

	declare @Version nvarchar(20);
	set @Version = N'4.5.17';

	declare @tmpSchedulers table
	(
		RunnableCountAvg  int null, 
		PendingIOCountAvg int null, 
		ThreadShortageAvg int null, 
		CPUAllocation     nvarchar(50) null);

	declare @ProcessMemLow     int, 
			@SystemMemLow      int, 
			@MaxServerMemory   int, 
			@PhysicalMemory    bigint, 
			@PhysicalMemInUse  bigint, 
			@KernelNonPaged    bigint, 
			@RunnableCountAvg  int, 
			@PendingIOCountAvg int, 
			@ThreadShortageAvg int, 
			@CPUAllocation     nvarchar(50), 
			@VerCleanupRatio   float, 
			@Runtime           datetime, 
			@CmdLine           nvarchar(100), 
			@SQLVersion        nvarchar(500);

	set @ParamSniff = case
						  when @ParamSniff < CONVERT(float, 0.0)
							   or @ParamSniff > CONVERT(float, 2.0) then CONVERT(float, 1.0)
					  else ISNULL(@ParamSniff, CONVERT(float, 1.0))
					  end;
	set @SessionLocks = ISNULL(@SessionLocks, CONVERT(bit, 0));
	set @CmdLine = N'EXEC sp_PerformanceQueryShaping ' + N'@ParamSniff=' + CONVERT(nvarchar(20), @ParamSniff) + N', @SessionLocks=' + CONVERT(nvarchar(1), @SessionLocks) + N'  --v' + @Version;
	set @Runtime = GETDATE();

	set @SQLVersion = CONVERT(nvarchar(500), @@Version);
	set @SQLVersion = LEFT(@SQLVersion, CHARINDEX(N'COPY', UPPER(@SQLVersion)) - 1);

	set @ProcessMemLow =
	(
		select COUNT(1)
		from sys.dm_os_process_memory with(nolock)
		where process_physical_memory_low = CONVERT(bit, 1)
	);

	set @SystemMemLow =
	(
		select COUNT(1)
		from sys.dm_os_sys_memory with(nolock)
		where system_high_memory_signal_state = CONVERT(bit, 0)
			  and system_low_memory_signal_state = CONVERT(bit, 1)
	);

	set @MaxServerMemory =
	(
		select top 1 CONVERT(int, value_in_use)
		from sys.configurations with(nolock)
		where name = 'max server memory (MB)'
	);

	set @PhysicalMemory =
	(
		select top 1 total_physical_memory_kb / 1024
		from sys.dm_os_sys_memory with(nolock)
	);

	set @PhysicalMemInUse =
	(
		select top 1 physical_memory_in_use_kb / 1024
		from sys.dm_os_process_memory with(nolock)
	);

	set @KernelNonPaged =
	(
		select top 1 kernel_nonpaged_pool_kb / 1024
		from sys.dm_os_sys_memory with(nolock)
	);

	insert into @tmpSchedulers (RunnableCountAvg, 
								PendingIOCountAvg, 
								ThreadShortageAvg, 
								CPUAllocation) 
	select AVG(os.runnable_tasks_count) as RunnableCountAvg, 
		   AVG(os.pending_disk_io_count) as PendingIOCountAvg, 
		   AVG(os.work_queue_count) as ThreadShortageAvg, 
		   CONVERT(nvarchar(20), COUNT(1)) + N' of ' + CONVERT(nvarchar(20), SUM(CONVERT(int, os.is_online))) as CPUAllocation
	from sys.dm_os_schedulers as os with(nolock)
	where os.scheduler_id < 1048576;

	set @RunnableCountAvg =
	(
		select top 1 RunnableCountAvg
		from @tmpSchedulers
	);

	set @PendingIOCountAvg =
	(
		select top 1 PendingIOCountAvg
		from @tmpSchedulers
	);

	set @ThreadShortageAvg =
	(
		select top 1 ThreadShortageAvg
		from @tmpSchedulers
	);

	set @CPUAllocation =
	(
		select top 1 CPUAllocation
		from @tmpSchedulers
	);

	set @VerCleanupRatio =
	(
		select top 1 CONVERT(float, ( cntr_value / 1024.0 ) * 100.0)
		from sys.dm_os_performance_counters with(nolock)
		where counter_name = N'Version Cleanup rate (KB/s)'
			  and 0 < CHARINDEX(N'Transactions', object_name)
	) /
	(
		select top 1 CONVERT(float, cntr_value / 1024.0)
		from sys.dm_os_performance_counters with(nolock)
		where counter_name = N'Version Generation rate (KB/s)'
			  and 0 < CONVERT(float, cntr_value / 1024.0)
			  and 0 < CHARINDEX(N'Transactions', object_name)
	);

	print @CmdLine;
	print N'';
	print @SQLVersion;
	print N'Memory';
	print N'    Total Physical Memory : ' + CONVERT(nvarchar(20), @PhysicalMemory) + N' MB';
	print N'    Max SQL Server Memory : ' + CONVERT(nvarchar(20), @MaxServerMemory) + N' MB';
	print N'    Physical Memory In Use: ' + CONVERT(nvarchar(20), @PhysicalMemInUse) + N' MB' + case
																									when @ProcessMemLow + @SystemMemLow > 0 then N' (memory pressure)'
																								else N''
																								end;
	print N'    Kernel Non-Paged Pool : ' + CONVERT(nvarchar(20), @KernelNonPaged) + N' MB';
	print N'Schedulers';
	print N'    Avg CPU Queue Length  : ' + CONVERT(nvarchar(20), @RunnableCountAvg);
	print N'    Avg IO Pending Count  : ' + CONVERT(nvarchar(20), @PendingIOCountAvg);
	print N'    Avg Thread Shortage   : ' + CONVERT(nvarchar(20), @ThreadShortageAvg);
	print N'    CPU Allocation        : ' + @CPUAllocation;
	print N'Version Store';
	print N'    Version Cleanup Ratio : ' + ISNULL(CONVERT(nvarchar(20), CONVERT(numeric(16, 2), @VerCleanupRatio)) + N'%', N'NA');
	print N'';

	with xmlnamespaces(default N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
		 cteQRequests(SPID, 
					  DatabaseName, 
					  status, 
					  RuntimeSec, 
					  BlockedBy, 
					  DatabaseMaint, 
					  EstFinishTime, 
					  MemRequestMB, 
					  MemGrantMB, 
					  MemGrantWait, 
					  DOP, 
					  query_cost, 
					  PAGEIOLATCHms, 
					  PAGELATCHms, 
					  RunnableCount, 
					  SpinLoopFlag, 
					  ThreadShortageFlag, 
					  ProgramName, 
					  OriginalLogin, 
					  sql_handle, 
					  statement_start_offset, 
					  statement_end_offset, 
					  plan_handle)
		 as (select r.session_id as SPID, 
					DB_NAME(s.database_id) as DatabaseName,
					case UPPER(r.status)
						when N'BACKGROUND' then CONVERT(int, 1)
						when N'RUNNING' then CONVERT(int, 2)
						when N'RUNNABLE' then CONVERT(int, 3)
						when N'SLEEPING' then CONVERT(int, 4)
						when N'SUSPENDED' then CONVERT(int, 5)
											  else CONVERT(int, null)
					end as status, 
					CONVERT(int, r.total_elapsed_time / 1000) as RuntimeSec,
					case
						when r.blocking_session_id = 0 then CONVERT(smallint, null)
																 else r.blocking_session_id
					end as BlockedBy, 
					r.command as DatabaseMaint, 
					r.estimated_completion_time as EstFinishTime, 
					CONVERT(float, m.requested_memory_kb / 1024.0) as MemRequestMB, 
					CONVERT(float, m.granted_memory_kb / 1024.0) as MemGrantMB,
					case
						when m.session_id = r.session_id
							 and m.request_id = r.request_id
							 and m.grant_time is null then CONVERT(int, 1)
																	else CONVERT(int, 0)
					end as MemGrantWait, 
					m.dop as DOP, 
					m.query_cost as query_cost,
					case
						when r.wait_type like N'PAGEIOLATCH_%' then r.wait_time
									else CONVERT(int, null)
					end as PAGEIOLATCHms,
					case
						when r.wait_type like N'PAGELATCH_%' then r.wait_time
						   else CONVERT(int, null)
					end as PAGELATCHms, 
					st.RunnableCount as RunnableCount, 
					st.SpinloopFlag as SpinLoopFlag, 
					st.ThreadShortageFlag as ThreadShortageFlag, 
					s.program_name as ProgramName, 
					s.original_login_name as OriginalLogin, 
					r.sql_handle, 
					r.statement_start_offset, 
					r.statement_end_offset, 
					r.plan_handle
			 from sys.dm_exec_requests as r
				  left join sys.dm_exec_sessions as s with(nolock) on s.session_id = r.session_id
				  left join sys.dm_exec_query_memory_grants as m with(nolock) on m.session_id = r.session_id
																				 and m.request_id = r.request_id
				  left join
			 (
				 select ot.session_id, 
						MAX(case
								when ot.task_state = N'RUNNABLE' then os.runnable_tasks_count
							else CONVERT(int, 0)
							end) as RunnableCount, 
						MAX(case
								when ot.task_state = N'SPINLOOP' then CONVERT(int, 1)
							else CONVERT(int, 0)
							end) as SpinLoopFlag, 
						MAX(case
								when ot.task_state = N'PENDING' then CONVERT(int, 1)
							else CONVERT(int, 0)
							end) as ThreadShortageFlag
				 from sys.dm_os_schedulers as os with(nolock)
					  inner join sys.dm_os_tasks as ot with(nolock) on ot.scheduler_id = os.scheduler_id
																	   and ot.task_state in(N'RUNNABLE', N'SPINLOOP', N'PENDING')
																	   and ot.scheduler_id < 1048576
				 group by ot.session_id
			 ) as st on st.session_id = r.session_id
			 where r.database_id <> 32767
				   and r.session_id > 0
				   and r.session_id <> @@SPID
				   and r.sql_handle =
			 (
				 select top 1 r2.sql_handle
				 from sys.dm_exec_requests as r2 with(nolock)
				 where r2.session_id = r.session_id
				 order by r2.start_time desc
			 )
				   and r.statement_start_offset =
			 (
				 select top 1 r3.statement_start_offset
				 from sys.dm_exec_requests as r3 with(nolock)
				 where r3.session_id = r.session_id
					   and r3.sql_handle = r.sql_handle
				 order by r3.start_time desc
			 ) ),
		 cteSLocks(SPID, 
				   SessionLocks)
		 as (select qr.SPID, 
					CONVERT(nvarchar(max), ISNULL(STUFF(
			 (
				 select N',' + ISNULL(CONVERT(nvarchar(200), tl.request_mode + N' (' + tl.request_status + N':' + tl.resource_type + case tl.resource_type
																																		 when N'DATABASE' then N':' + ISNULL(DB_NAME(tl.resource_database_id), N'')
																																		 when N'OBJECT' then N':' + ISNULL(OBJECT_NAME(tl.resource_associated_entity_id, tl.resource_database_id), N'') + ISNULL(N'[' + CONVERT(nvarchar(10), i.UnusedIndexCount) + N']', N'')
																																	 else N''
																																	 end + N')') + N'x' + CONVERT(nvarchar(10), COUNT(1)), N'')
				 from sys.dm_tran_locks as tl with(nolock)
					  outer apply
				 (
					 select ius.database_id, 
							ius.object_id, 
							COUNT(1) as UnusedIndexCount
					 from sys.dm_db_index_usage_stats as ius with(nolock)
					 where ius.database_id = tl.resource_database_id
						   and ius.object_id = tl.resource_associated_entity_id
						   and ius.user_updates > ius.user_seeks + ius.user_lookups + ius.user_scans
						   and tl.resource_type = N'OBJECT'
					 group by ius.database_id, 
							  ius.object_id
				 ) as i
				 where tl.request_session_id = qr.SPID
					   and N'NULL' <> ISNULL(tl.request_mode, N'NULL')
				 group by CONVERT(nvarchar(200), tl.request_mode + N' (' + tl.request_status + N':' + tl.resource_type + case tl.resource_type
																															 when N'DATABASE' then N':' + ISNULL(DB_NAME(tl.resource_database_id), N'')
																															 when N'OBJECT' then N':' + ISNULL(OBJECT_NAME(tl.resource_associated_entity_id, tl.resource_database_id), N'') + ISNULL(N'[' + CONVERT(nvarchar(10), i.UnusedIndexCount) + N']', N'')
																														 else N''
																														 end + N')') for xml path('')
			 ), 1, 1, N''), N'')) as SessionLocks
			 from
			 (
				 select SPID
				 from cteQRequests
				 where @SessionLocks = CONVERT(bit, 1)
				 group by SPID
			 ) as qr),
		 cteTempdb(SPID, 
				   TempdbWaitms, 
				   CursorOpen, 
				   CursorDormantms, 
				   TempdbDeallocMB, 
				   TempdbAllocMB, 
				   VerActive, 
				   VerDuration)
		 as (select qr.SPID, 
			 (
				 select MAX(wt.wait_duration_ms)
				 from sys.dm_os_waiting_tasks as wt with(nolock)
				 where wt.session_id = qr.SPID
					   and wt.wait_type like 'PAGE%LATCH_%'
					   and wt.resource_description like CONVERT(nvarchar(10), DB_ID(N'tempdb')) + N':%'
			 ) as TempdbWaitms, 
			 (
				 select COUNT(1)
				 from sys.dm_exec_cursors(qr.SPID)
				 where is_open = CONVERT(bit, 1)
			 ) as CursorOpen, 
			 (
				 select MAX(dormant_duration)
				 from sys.dm_exec_cursors(qr.SPID)
				 where is_open = CONVERT(bit, 1)
			 ) as CursorDormantms, 
			 (
				 select CONVERT(float, SUM(tsu.internal_objects_dealloc_page_count + tsu.user_objects_dealloc_page_count) / 128.0)
				 from tempdb.sys.dm_db_task_space_usage as tsu with(nolock)
				 where tsu.session_id = qr.SPID
			 ) as TempdbDeallocMB, 
			 (
				 select CONVERT(float, SUM(tsu.internal_objects_alloc_page_count + tsu.user_objects_alloc_page_count) / 128.0)
				 from tempdb.sys.dm_db_task_space_usage as tsu with(nolock)
				 where tsu.session_id = qr.SPID
			 ) as TempdbAllocMB, 
			 (
				 select COUNT(1)
				 from sys.dm_tran_active_snapshot_database_transactions as v with(nolock)
				 where v.session_id = qr.SPID
					   and v.commit_sequence_num is null
			 ) as VerActive, 
			 (
				 select MAX(v.elapsed_time_seconds)
				 from sys.dm_tran_active_snapshot_database_transactions as v with(nolock)
				 where v.session_id = qr.SPID
					   and v.commit_sequence_num is null
			 ) as VerDuration
			 from cteQRequests as qr
			 group by qr.SPID),
		 cteQPlan(plan_handle, 
				  PlanType, 
				  ObjectName, 
				  ParameterList, 
				  Cardinality, 
				  [AvgMissingIndex%], 
				  SortRows, 
				  TableScanRows, 
				  MissingJoin)
		 as (select qr.plan_handle, 
			 (
				 select top 1 RTRIM(cp.objtype)
				 from sys.dm_exec_cached_plans as cp with(nolock)
				 where cp.plan_handle = qr.plan_handle
			 ) as PlanType, 
					CONVERT(nvarchar(129), ISNULL(N':' + OBJECT_NAME(qp.objectid, qp.dbid), N'')) as ObjectName, 
					CONVERT(nvarchar(max), STUFF(
			 (
				 select N',' + l.value('@Column', 'nvarchar(128)') + N'=' + l.value('@ParameterCompiledValue', 'nvarchar(4000)')
				 from qp.query_plan.nodes('//ParameterList/ColumnReference') as prm(l) for xml path('')
			 ), 1, 1, N'')) as ParameterList, 
			 (
				 select CONVERT(float, MAX(s.value('@StatementEstRows', 'float')))
				 from qp.query_plan.nodes('//StmtSimple') as stmt(s)
			 ) as Cardinality, 
			 (
				 select CONVERT(float, AVG(i.value('@Impact', 'float')))
				 from qp.query_plan.nodes('.//MissingIndexGroup') as midx(i)
			 ) as [AvgMissingIndex%], 
			 (
				 select CONVERT(float, SUM(op.value('@EstimateRows', 'float')))
				 from qp.query_plan.nodes('//RelOp') as rel(op)
				 where N'Sort' = op.value('@PhysicalOp', 'nvarchar(60)')
			 ) as SortRows, 
			 (
				 select CONVERT(float, SUM(op.value('@EstimateRows', 'float')))
				 from qp.query_plan.nodes('//RelOp') as rel(op)
				 where N'Table Scan' = op.value('@PhysicalOp', 'nvarchar(60)')
			 ) as TableScanRows, 
			 (
				 select COUNT(1)
				 from qp.query_plan.nodes('//Warnings[(@NoJoinPredicate[.="1"])]') as nojoin(p)
			 ) as MissingJoin
			 from
			 (
				 select plan_handle
				 from cteQRequests
				 where plan_handle is not null
				 group by plan_handle
			 ) as qr
			 cross apply sys.dm_exec_query_plan(qr.plan_handle) as qp),
		 cteQStats(sql_handle, 
				   plan_handle, 
				   RunCount, 
				   MinTimeSec, 
				   MaxTimeSec, 
				   MinRows, 
				   MaxRows, 
				   AvgCpuLowms, 
				   CpuHighms, 
				   AvgLogicalReadsMB, 
				   [PhyReads%])
		 as (select qr.sql_handle, 
					qr.plan_handle, 
					MAX(qs.execution_count) as RunCount, 
					CONVERT(bigint, ( MIN(qs.min_elapsed_time) / 1000 ) / 1000) as MinTimeSec, 
					CONVERT(bigint, ( MAX(qs.max_elapsed_time) / 1000 ) / 1000) as MaxTimeSec, 
					MIN(qs.min_rows) as MinRows, 
					MAX(qs.max_rows) as MaxRows, 
					CONVERT(bigint, AVG(qs.min_worker_time) / 1000) as AvgCpuLowms, 
					CONVERT(bigint, MAX(qs.max_worker_time) / 1000) as CpuHighms, 
					CONVERT(float, ( MAX(qs.total_logical_reads) / MAX(qs.execution_count) ) / 128.0) as AvgLogicalReadsMB,
					case
						when MAX(qs.total_logical_reads) >= CONVERT(bigint, 1) then CONVERT(float, MAX(qs.total_physical_reads) * 100.0) / CONVERT(float, MAX(qs.total_logical_reads))
																										 else CONVERT(float, 0.0)
					end as [PhyReads%]
			 from
			 (
				 select sql_handle, 
						plan_handle
				 from cteQRequests
				 group by sql_handle, 
						  plan_handle
			 ) as qr
			 left join sys.dm_exec_query_stats as qs with(nolock) on qs.sql_handle = qr.sql_handle
																	 and qs.plan_handle = qr.plan_handle
			 group by qr.sql_handle, 
					  qr.plan_handle)
		 select qr.SPID, 
				MAX(qr.DatabaseName) as DatabaseName,
				case MIN(qr.status)
					when 1 then CONVERT(nvarchar(10), N'Background')
					when 2 then CONVERT(nvarchar(10), N'Running')
					when 3 then CONVERT(nvarchar(10), N'Runnable')
					when 4 then CONVERT(nvarchar(10), N'Sleeping')
					when 5 then CONVERT(nvarchar(10), N'Suspended')
										else CONVERT(nvarchar(10), null)
				end as status,
				case
					when UPPER(MAX(qp.PlanType)) = N'PROC' then CONVERT(nvarchar(133), N'Proc' + MAX(qp.ObjectName))
					   else CONVERT(nvarchar(133), MAX(qp.PlanType))
				end as PlanType,
				case
					when MAX(qr.query_cost) < 10 then CONVERT(nvarchar(10), N'Low')
					when MAX(qr.query_cost) < 100 then CONVERT(nvarchar(10), N'Medium')
					when MAX(qr.query_cost) < 1000 then CONVERT(nvarchar(10), N'Med-High')
					when MAX(qr.query_cost) < 10000 then CONVERT(nvarchar(10), N'High')
					when MAX(qr.query_cost) >= 10000 then CONVERT(nvarchar(10), N'VHigh')
					   else CONVERT(nvarchar(10), null)
				end as QueryCost, 
				CONVERT(nvarchar(200), REPLACE(REPLACE(RTRIM(case
																 when MIN(qr.status) <> 2
																	  and MAX(qr.RunnableCount) > 2
																	  and @RunnableCountAvg > 1 then CONVERT(nvarchar(8), N'CPUWait ')
															 else N''
															 end + case
																	   when MAX(t.CursorOpen) > 0
																			and MAX(t.CursorDormantms) >= 1 then CONVERT(nvarchar(27), N'Cursor(' + CONVERT(nvarchar(16), MAX(t.CursorDormantms)) + N'ms) ')
																   else N''
																   end + case
																			 when MAX(qr.EstFinishTime) >= 1 then CONVERT(nvarchar(41), REPLACE(MAX(qr.DatabaseMaint), N' ', N'~')) + N'(' + case
																																																 when MAX(qr.EstFinishTime) / 60000 > 600 then N'>10hr) '
																																															 else CONVERT(nvarchar(3), MAX(qr.EstFinishTime) / 60000) + N'min) '
																																															 end
																		 else N''
																		 end + case
																				   when MAX(qr.query_cost) >= 10
																						and MAX(qp.[AvgMissingIndex%]) > 20 then CONVERT(nvarchar(7), N'IdxGap ')
																			   else N''
																			   end + case
																						 when CHARINDEX(N'[', MAX(sl.SessionLocks)) > 0 then CONVERT(nvarchar(8), N'IdxIdle ')
																					 else N''
																					 end + case
																							   when SUM(qr.MemGrantMB) > CONVERT(float, SUM(qr.MemRequestMB) + 0.00001) then CONVERT(nvarchar(32), N'InitialMem(') + CONVERT(nvarchar(17), CONVERT(numeric(16, 2), SUM(qr.MemRequestMB))) + N'MB) '
																						   else N''
																						   end + case
																									 when MAX([PhyReads%]) > CONVERT(float, 20.0)
																										  or MAX(qr.query_cost) >= 10
																										  and @PendingIOCountAvg > 1
																										  and ( MAX([PhyReads%]) > CONVERT(float, 5.0)
																												or MAX(qr.PAGEIOLATCHms) > 50
																											  ) then case
																														 when @ProcessMemLow + @SystemMemLow > 0 then CONVERT(nvarchar(9), N'IO(MemP) ')
																													 else CONVERT(nvarchar(9), N'IO ')
																													 end
																								 else N''
																								 end + case
																										   when 0 < CHARINDEX(N'(WAIT', MAX(sl.SessionLocks)) then CONVERT(nvarchar(9), N'LockWait ')
																									   else N''
																									   end + case
																												 when MAX(qr.MemGrantWait) = 1 then CONVERT(nvarchar(8), N'MemWait ')
																											 else N''
																											 end + case
																													   when MAX(qp.MissingJoin) > 0 then CONVERT(nvarchar(9), N'MissJoin ')
																												   else N''
																												   end + case
																															 when MAX(qr.PAGELATCHms) >= 1 then CONVERT(nvarchar(23), N'PageWait(' + CONVERT(nvarchar(10), MAX(qr.PAGELATCHms)) + N'ms) ')
																														 else N''
																														 end + case
																																   when MAX(qp.ParameterList) <> N''
																																		and UPPER(MAX(qp.PlanType)) in(N'PROC', N'ADHOC')
																																		and MAX(qs.RunCount) > 1
																																		and ( CONVERT(float, MAX(qs.MaxRows) / 10.0) > CONVERT(float, ( MAX(qs.MinRows) / 10.0 ) * 4.0 * @ParamSniff + POWER(CONVERT(float, 10.0), @ParamSniff))
																																			  or MAX([PhyReads%]) > CONVERT(float, 20.0)
																																			  or MAX(qr.query_cost) >= 10
																																			  and @PendingIOCountAvg > 1
																																			  and ( MAX([PhyReads%]) > CONVERT(float, 5.0)
																																					or MAX(qr.PAGEIOLATCHms) > 50
																																				  )
																																			  or MAX(t.TempdbAllocMB) - MAX(t.TempdbDeallocMB) > case
																																																	 when CONVERT(int, ( SUM(qr.MemGrantMB) / 10 ) * ( 100 - ISNULL(MAX(qp.[AvgMissingIndex%]), 0) ) / 100) > 49 then CONVERT(int, 50)
																																																 else 1 + CONVERT(int, ( SUM(qr.MemGrantMB) / 10 ) * ( 100 - ISNULL(MAX(qp.[AvgMissingIndex%]), 0) ) / 100)
																																																 end
																																			)
																																		and CONVERT(float, MAX(qs.CpuHighms) / 10.0) > CONVERT(float, ( MAX(qs.AvgCpuLowms) / 10.0 ) * 4.0 * @ParamSniff + POWER(CONVERT(float, 10.0), @ParamSniff))
																																		and case
																																				when MAX(qr.RuntimeSec) > MAX(qs.MaxTimeSec) then MAX(qr.RuntimeSec)
																																			else MAX(qs.MaxTimeSec)
																																			end - MAX(qs.MinTimeSec) > MAX(qs.MinTimeSec) / 10 + POWER(CONVERT(bigint, 10), @ParamSniff) then CONVERT(nvarchar(37), N'ParamSniff(') + CONVERT(nvarchar(10), MAX(qs.MinTimeSec)) + N'-' + CONVERT(nvarchar(10),
																																																																																							case
																																																																																								when MAX(qr.RuntimeSec) > MAX(qs.MaxTimeSec) then MAX(qr.RuntimeSec)
																																																																																							else MAX(qs.MaxTimeSec)
																																																																																							end) + N'Sec) '
																															   else N''
																															   end + case
																																		 when MAX(qr.SpinloopFlag) = 1 then CONVERT(nvarchar(9), N'SpinLoop ')
																																	 else N''
																																	 end + case
																																			   when MAX(t.TempdbAllocMB) - MAX(t.TempdbDeallocMB) > case
																																																		when CONVERT(int, ( SUM(qr.MemGrantMB) / 10 ) * ( 100 - ISNULL(MAX(qp.[AvgMissingIndex%]), 0) ) / 100) > 49 then CONVERT(int, 50)
																																																	else 1 + CONVERT(int, ( SUM(qr.MemGrantMB) / 10 ) * ( 100 - ISNULL(MAX(qp.[AvgMissingIndex%]), 0) ) / 100)
																																																	end then CONVERT(nvarchar(27), N'Tempdb') + case
																																																													when MAX(t.TempdbWaitms) >= 1 then N'(' + CONVERT(nvarchar(16), MAX(t.TempdbWaitms)) + N'ms) '
																																																												else N' '
																																																												end
																																		   else N''
																																		   end + case
																																					 when MAX(qr.ThreadShortageFlag) = 1
																																						  and @ThreadShortageAvg > 0 then CONVERT(nvarchar(15), N'ThreadShortage ')
																																				 else N''
																																				 end + case
																																						   when @VerCleanupRatio < CONVERT(float, 80.0)
																																								and MAX(t.VerDuration) >= 1 then CONVERT(nvarchar(25), N'Ver(') + CONVERT(nvarchar(16), MAX(t.VerDuration)) + N'sec) '
																																					   else N''
																																					   end), N' ', N','), N'~', N' ')) as ThrottlePotential, 
				MAX(qr.RuntimeSec) as RuntimeSec, 
				CONVERT(nvarchar(50), STUFF(
		 (
			 select N',' + CONVERT(nvarchar(50), qr2.BlockedBy)
			 from cteQRequests as qr2
			 where qr2.SPID = qr.SPID
				   and qr2.BlockedBy is not null
			 group by CONVERT(nvarchar(50), qr2.BlockedBy) for xml path('')
		 ), 1, 1, N'')) as BlockedBy, 
		 (
			 select CONVERT(nvarchar(max), SUBSTRING(qt.text + ' ', MAX(qr.statement_start_offset) / 2 + 1, ( case
																												  when MAX(qr.statement_end_offset) = -1 then DATALENGTH(qt.text)
																											  else MAX(qr.statement_end_offset)
																											  end - MAX(qr.statement_start_offset) ) / 2 + 1))
			 from sys.dm_exec_sql_text(qr.sql_handle) as qt
		 ) as Query, 
				MAX(qr.MemGrantMB) as MemGrantMB, 
				MAX(qs.RunCount) as RunCount, 
				MAX(qs.MinRows) as MinRows, 
				MAX(qs.MaxRows) as MaxRows, 
				MAX(qs.AvgCpuLowms) as AvgCpuLowms, 
				MAX(qs.CpuHighms) as CpuHighms, 
				MAX(qr.DOP) as DOP, 
				MAX(qs.AvgLogicalReadsMB) as AvgLogicalReadsMB,
				case
					when MAX(qs.RunCount) is not null then MAX(qs.[PhyReads%])
											 else CONVERT(float, null)
				end as [PhyReads%], 
				MAX(qr.PAGEIOLATCHms) as PAGEIOLATCHms, 
				MAX(sl.SessionLocks) as SessionLocks, 
				MAX(t.VerActive) as VerActive, 
				MAX(t.TempdbAllocMB) as TempdbAllocMB, 
				MAX(t.TempdbDeallocMB) as TempdbDeallocMB, 
				MAX(qp.Cardinality) as Cardinality, 
				MAX(qp.[AvgMissingIndex%]) as [AvgMissingIndex%], 
				MAX(qp.SortRows) as SortRows, 
				MAX(qp.TableScanRows) as TableScanRows, 
				MAX(qp.ParameterList) as CachedParam, 
		 (
			 select top 1 query_plan
			 from sys.dm_exec_query_plan(qr.plan_handle)
		 ) as CachedPlan, 
				MAX(qr.ProgramName) as ProgramName, 
				MAX(qr.OriginalLogin) as OriginalLogin, 
				@Runtime as LogDateTime
		 from cteQRequests as qr
			  left join cteQPlan as qp on qp.plan_handle = qr.plan_handle
			  left join cteQStats as qs on qs.sql_handle = qr.sql_handle
										   and qs.plan_handle = qr.plan_handle
			  left join cteSLocks as sl on sl.SPID = qr.SPID
			  left join cteTempdb as t on t.SPID = qr.SPID
		 group by qr.SPID, 
				  qr.sql_handle, 
				  qr.plan_handle
		 having
		 (
			 select CONVERT(nvarchar(max), SUBSTRING(qt.text + ' ', MAX(qr.statement_start_offset) / 2 + 1, ( case
																												  when MAX(qr.statement_end_offset) = -1 then DATALENGTH(qt.text)
																											  else MAX(qr.statement_end_offset)
																											  end - MAX(qr.statement_start_offset) ) / 2 + 1))
			 from sys.dm_exec_sql_text(qr.sql_handle) as qt
		 ) is not null
		 order by qr.SPID;
end;

go