if OBJECT_ID('sp_who2_ex', 'P') is not null
	drop proc sp_who2_ex;
go

create proc sp_who2_ex 
	@loginame sysname = null
as
begin
	declare @whotbl table
	(
		SPID        int null, 
		status      varchar(50) null, 
		LOGIN       sysname null, 
		HostName    sysname null, 
		BlkBy       varchar(5) null, 
		DBName      sysname null, 
		Command     varchar(1000) null, 
		CPUTime     int null, 
		DiskIO      int null, 
		LastBatch   varchar(50) null, 
		ProgramName varchar(200) null, 
		SPID2       int null, 
		RequestID   int null);

	insert into @whotbl
	exec sp_who2 @loginame = @loginame;

	select W.*, 
		   CommandText = sql.TEXT, 
		   ExecutionPlan = pln.query_plan, 
		   ObjectName = so.name, 
		   der.percent_complete, 
		   der.estimated_completion_time
	--,CommandType =der.command 
	from @whotbl as W
		 left join sys.dm_exec_requests as der on der.session_id = w.SPID
		 outer apply SYS.dm_exec_sql_text (der.sql_handle) as Sql
		 outer apply sys.dm_exec_query_plan (der.plan_handle) as pln
		 left join sys.objects as so on so.object_id = sql.objectid;
end;
go