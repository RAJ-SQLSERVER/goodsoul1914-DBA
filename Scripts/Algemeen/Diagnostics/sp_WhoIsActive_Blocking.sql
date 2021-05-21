
if not exists (select *
			   from sys.indexes
			   where name = 'NCI_WhoIsActive_ResultSets__blocking_session_id'
					 and object_id = OBJECT_ID('dbo.WhoIsActive_ResultSets')) 
	create nonclustered index NCI_WhoIsActive_ResultSets__blocking_session_id on dbo.WhoIsActive_ResultSets
	(blocking_session_id) 
		include (session_id, collection_time, program_name, TimeInMinutes);
go

if OBJECT_ID('dbo.sp_WhoIsActive_Blocking') is null
	exec ('CREATE PROCEDURE dbo.sp_WhoIsActive_Blocking AS SELECT 1 AS Dummy');
go

alter procedure dbo.sp_WhoIsActive_Blocking 
	@p_Collection_time_Start datetime      = null, 
	@p_Collection_time_End   datetime      = null, 
	@p_Program_Name          nvarchar(256) = null, 
	@p_WaitTime_Seconds      bigint        = null, 
	@p_Help                  bit           = 0, 
	@p_Verbose               bit           = 0
as
begin
	
/****************************************************************************************************************************************
	Created By:			Ajay Dwivedi (ajay.dwivedi2007@gmail.com)
		Version:			0.1
		Permission:			https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution/blob/master/sp_HealthCheck/Certificate%20Based%20Authentication.sql
		Updates:			May 12, 2019 - Get Blocking Details
							May 23, 2019 - Add one more parameter to filter on BlockTime(Seconds)
****************************************************************************************************************************************/

	set nocount on;

	declare @_errorMSG varchar(max);
	declare @_errorNumber int;

	if @p_Help = 1
	begin
		if @p_Verbose = 1
			print '
/*	******************** Begin:	@p_Help = 1 *****************************/';

		-- VALUES constructor method does not work in SQL 2005. So using UNION ALL
		select [Parameter Name], 
			   [Data Type], 
			   [Default Value], 
			   [Parameter Description], 
			   [Supporting Parameters]
		from (select '!~~~ Version ~~~~!' as [Parameter Name], 
					 'Information' as [Data Type], 
					 '0.1' as [Default Value], 
					 'Last Updated - 23/May/2019' as [Parameter Description], 
					 'https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_Help' as [Parameter Name], 
					 'BIT' as [Data Type], 
					 '0' as [Default Value], 
					 'Displays this help message.' as [Parameter Description], 
					 '' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_Collection_time_Start', 
					 'datetime', 
					 null, 
					 'Start time in format ''May 17 2019 01:45AM''.', 
					 '[@p_Collection_time_End] [,@p_Program_Name] [,@p_Verbose]' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_Collection_time_End', 
					 'datetime', 
					 null, 
					 'End time in format ''May 17 2019 01:45AM''.', 
					 '[@p_Collection_time_Start] [,@p_Program_Name] [,@p_Verbose]' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_WaitTime_Seconds', 
					 'bigint', 
					 null, 
					 'Lock Time Threshold in seconds to filter the blocking resultset.', 
					 '[@p_Collection_time_Start] [,@p_Collection_time_End] [,@p_Program_Name] [,@p_Verbose]' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_Program_Name', 
					 'VARCHAR(125)', 
					 null, 
					 'value that would match [program_name] column of DBA..whoIsActive_ResultSets table.', 
					 '[@p_Collection_time_Start] [,@p_Collection_time_End] [,@p_Verbose]' as [Supporting Parameters]
			  --
			  union all
			  --
			  select '@p_Verbose', 
					 'BIT', 
					 '0', 
					 'This present all background information that can be used to debug procedure working.', 
					 'All parameters supported' as [Supporting Parameters]) as Params; --([Parameter Name], [Data Type], [Default Value], [Parameter Description], [Supporting Parameters]);


		if @p_Verbose = 1
			print '/*	******************** End:	@p_Help = 1 *****************************/
';
	end;
	else
	begin
		if @p_Verbose = 1
			print 'Evaluating values of @p_Collection_time_Start and @p_Collection_time_End';

		if @p_Collection_time_Start is null
		   and @p_Collection_time_End is null
			select @p_Collection_time_Start = DATEADD(minute, -120, GETDATE()), 
				   @p_Collection_time_End = GETDATE();
		else
			if @p_Collection_time_Start is null
				select @p_Collection_time_Start = DATEADD(minute, -120, @p_Collection_time_End);

		if @p_Collection_time_End is null
		   and @p_Collection_time_Start is not null
			select @p_Collection_time_End = dbo.fn_GetNextCollectionTime(@p_Collection_time_Start);

		if @p_WaitTime_Seconds is not null
		   and @p_WaitTime_Seconds <= 0
		begin
			set @_errorMSG = 'Kindly provide value for following parameters:-' + CHAR(10) + CHAR(13) + '@p_Collection_time_Start, @p_Collection_time_End';
			if (select CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') as varchar(50)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') as varchar(50))) - 1) as int)) >= 12
				execute sp_executesql N'THROW 50000,@_errorMSG,1', N'@_errorMSG VARCHAR(200)', @_errorMSG;
			else
				execute sp_executesql N'RAISERROR (@_errorMSG, 16, 1)', N'@_errorMSG VARCHAR(200)', @_errorMSG;
		end;

		if @p_Verbose = 1
		begin
			print '@p_Collection_time_Start = ''' + CAST(@p_Collection_time_Start as varchar(35)) + '''';
			print '@p_Collection_time_End = ''' + CAST(@p_Collection_time_End as varchar(35)) + '''';
		end;

		if OBJECT_ID('tempdb..#BlockingTree') is not null
			drop table #BlockingTree;;
		with T_BLOCKERS
			 as (
			 -- Find block Leaders
			 select collection_time, 
					TimeInMinutes, 
					session_id, 
					sql_text = REPLACE(REPLACE(REPLACE(REPLACE(CAST(sql_text as varchar(max)), CHAR(13), ''), CHAR(10), ''), '<?query --', ''), '--?>', ''), 
					login_name, 
					wait_info, 
					blocking_session_id, 
					blocking_head = CAST(null as int), 
					status, 
					open_tran_count, 
					host_name, 
					database_name, 
					program_name, 
					r.CPU, 
					r.tempdb_allocations, 
					r.tempdb_current, 
					r.reads, 
					r.writes, 
					r.physical_reads, 
					LEVEL = CAST(REPLICATE('0', 4 - LEN(CAST(r.session_id as varchar))) + CAST(r.session_id as varchar) as varchar(1000))
			 from dbo.WhoIsActive_ResultSets as r
			 where r.collection_time >= @p_Collection_time_Start
				   and r.collection_time <= @p_Collection_time_End
				   and ( r.blocking_session_id is null
						 or r.blocking_session_id = r.session_id
					   )
				   and exists (select R2.session_id
							   from dbo.WhoIsActive_ResultSets as R2
							   where R2.collection_Time = r.collection_Time
									 and R2.blocking_session_id is not null
									 and R2.blocking_session_id = r.session_id
									 and R2.blocking_session_id <> R2.session_id
									 and ( @p_Program_Name is null
										   or R2.program_name = @p_Program_Name
										 ))
			 --	 
			 union all
			 --
			 select r.collection_time, 
					r.TimeInMinutes, 
					r.session_id, 
					sql_text = REPLACE(REPLACE(REPLACE(REPLACE(CAST(r.sql_text as varchar(max)), CHAR(13), ''), CHAR(10), ''), '<?query --', ''), '--?>', ''), 
					r.login_name, 
					r.wait_info, 
					r.blocking_session_id, 
					blocking_head = CAST(COALESCE(B.blocking_head, B.session_id) as int), 
					r.status, 
					r.open_tran_count, 
					r.host_name, 
					r.database_name, 
					r.program_name, 
					r.CPU, 
					r.tempdb_allocations, 
					r.tempdb_current, 
					r.reads, 
					r.writes, 
					r.physical_reads, 
					CAST(B.LEVEL + RIGHT(CAST(1000 + r.session_id as varchar(100)), 4) as varchar(1000)) as LEVEL
			 from dbo.WhoIsActive_ResultSets as r
				  inner join T_BLOCKERS as B on r.collection_time = B.collection_time
												and r.blocking_session_id = B.session_id
			 where r.blocking_session_id <> r.session_id)
			 select collection_time, 
					BLOCKING_TREE = N'    ' + REPLICATE(N'|         ', LEN(LEVEL) / 4 - 1) + case
																								 when LEN(LEVEL) / 4 - 1 = 0 then 'HEAD -  '
																							 else '|------  '
																							 end + CAST(r.session_id as nvarchar(10)) + N' ' + case
																																				   when LEFT(r.sql_text, 1) = '(' then SUBSTRING(r.sql_text, CHARINDEX('exec', r.sql_text), LEN(r.sql_text))
																																			   else r.sql_text
																																			   end, 
					session_id, 
					blocking_session_id, 
					blocking_head, 
					[WaitTime(Seconds)] = COALESCE([lock_time(UnExpected)], [lock_time(1)], [lock_time(2)], [lock_time(x)]) / 1000, 
					w.lock_text, 
					sql_commad = CONVERT(xml, '<?query -- ' + CHAR(13) + case
																			 when LEFT(sql_text, 1) = '(' then SUBSTRING(sql_text, CHARINDEX('exec', sql_text), LEN(sql_text))
																		 else sql_text
																		 end + CHAR(13) + '--?>'), 
					host_name, 
					database_name, 
					login_name, 
					program_name, 
					wait_info, 
					open_tran_count, 
					r.CPU, 
					r.tempdb_allocations, 
					r.tempdb_current, 
					r.reads, 
					r.writes, 
					r.physical_reads
					, --, r.[query_plan]
					--,[Blocking_Order] = DENSE_RANK()OVER(ORDER BY collection_time, LEVEL ASC) 
					LEVEL
			 into #BlockingTree
			 from T_BLOCKERS as r
				  outer apply (select lock_text, 
									  [lock_time(UnExpected)] = case
																	when lock_text is null then null -- When Lock_Test is NULL or Not Valid
																	when lock_text is not null
																		 and CHARINDEX(':', lock_text) = 0 then CAST(SUBSTRING(lock_text, 2, CHARINDEX('ms)', lock_text) - 2) as bigint)
																else null
																end, 
									  [lock_time(1)] = case
														   when lock_text is not null
																and CHARINDEX(':', lock_text) <> 0 then case
																											when CAST(SUBSTRING(lock_text, 2, CHARINDEX('x:', lock_text) - 2) as int) = 1 then CAST(SUBSTRING(lock_text, 6, CHARINDEX('ms)', lock_text) - 6) as bigint)
																										else null
																										end
													   else null
													   end, 
									  [lock_time(2)] = case
														   when lock_text is not null
																and CHARINDEX(':', lock_text) <> 0 then case
																											when CAST(SUBSTRING(lock_text, 2, CHARINDEX('x:', lock_text) - 2) as int) = 2 then case
																																																   when CHARINDEX('/', lock_text) = 0 then CAST(SUBSTRING(lock_text, 6, CHARINDEX('ms)', lock_text) - 6) as bigint)
																																															   else CAST(SUBSTRING(lock_text, CHARINDEX('/', lock_text) + 1, CHARINDEX('ms)', lock_text) - CHARINDEX('/', lock_text) - 1) as bigint)
																																															   end
																										else null
																										end
													   else null
													   end, 
									  [lock_time(x)] = case
														   when lock_text is not null
																and CHARINDEX(':', lock_text) <> 0 then case
																											when CAST(SUBSTRING(lock_text, 2, CHARINDEX('x:', lock_text) - 2) as int) > 2
																												 and CHARINDEX('/', lock_text) = 0 then CAST(SUBSTRING(lock_text, 6, CHARINDEX('ms)', lock_text) - 6) as bigint)
																											when CAST(SUBSTRING(lock_text, 2, CHARINDEX('x:', lock_text) - 2) as int) > 2
																												 and LEN(lock_text) - LEN(REPLACE(lock_text, '/', '')) = 1 then CAST(SUBSTRING(lock_text, CHARINDEX('/', lock_text) + 1, CHARINDEX('ms)', lock_text) - CHARINDEX('/', lock_text) - 1) as bigint)
																											when CAST(SUBSTRING(lock_text, 2, CHARINDEX('x:', lock_text) - 2) as int) > 2
																												 and LEN(lock_text) - LEN(REPLACE(lock_text, '/', '')) = 2 then CAST(SUBSTRING(lock_text, CHARINDEX('/', lock_text, CHARINDEX('/', lock_text) + 1) + 1, CHARINDEX('ms)', lock_text) - CHARINDEX('/', lock_text, CHARINDEX('/', lock_text) + 1) - 1) as bigint)
																										else null
																										end
													   else null
													   end
							   from (select lock_text = case
															when r.wait_info is null
																 or CHARINDEX('LCK', r.wait_info) = 0 then null
															when CHARINDEX(',', r.wait_info) = 0 then r.wait_info
															when CHARINDEX(',', LEFT(r.wait_info, CHARINDEX(',', r.wait_info, CHARINDEX('LCK_', r.wait_info)) - 1)) <> 0 then REVERSE(LEFT(REVERSE(LEFT(r.wait_info, CHARINDEX(',', r.wait_info, CHARINDEX('LCK_', r.wait_info)) - 1)), CHARINDEX(',', REVERSE(LEFT(r.wait_info, CHARINDEX(',', r.wait_info, CHARINDEX('LCK_', r.wait_info)) - 1))) - 1))
														else LEFT(r.wait_info, CHARINDEX(',', r.wait_info, CHARINDEX('LCK_', r.wait_info)) - 1)
														end) as wi) as w;

		select *
		from #BlockingTree as b
		where @p_WaitTime_Seconds is null
			  or case
					 when blocking_session_id is null
						  and not exists (select i.*
										  from #BlockingTree as i
										  where i.collection_time = b.collection_time
												and i.blocking_head = b.session_id
												and i.[WaitTime(Seconds)] >= @p_WaitTime_Seconds) then 0
					 when [WaitTime(Seconds)] < @p_WaitTime_Seconds
						  and not exists (select i.*
										  from #BlockingTree as i
										  where i.collection_time = b.collection_time
												and i.blocking_session_id = b.session_id
												and i.[WaitTime(Seconds)] >= @p_WaitTime_Seconds) then 0
				 else 1
				 end = 1
		order by collection_time, 
				 LEVEL asc;
	end;
end;
go



/**************************************************************************************************************************************
EXEC DBA.dbo.sp_WhoIsActive_Blocking @p_Collection_time_Start = 'May 12 2019 11:30AM', @p_Collection_time_End = 'May 12 2019 01:30PM' 
										,@p_WaitTime_Seconds = 300
										--,@p_Program_Name = 'SQL Job = <job name>';
**************************************************************************************************************************************/