use [master];
go

/******************************************************************************************************************************************************
Author: Adrian Buckman
Revision date: 14/09/2017
Version: 1

www.sqlundercover.com 

http://sqlundercover.com/2017/09/14/undercover-toolbox-sp_changeagentjoboperator-scripting-out-change-of-notification-operator-deleting-andor-creating/
******************************************************************************************************************************************************/

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_ChangeAgentJobOperator
(
	@OldOperatorName              nvarchar(128), 
	@NewOperatorName              nvarchar(128), 
	@CreateNewOperatorIfNotExists bit           = 0, 
	@EmailAddress                 nvarchar(128) = null, 
	@DeleteOldOperator            bit           = 0) 
as
begin
	set nocount on;

	if exists (select Name
			   from msdb.dbo.sysoperators
			   where name = @OldOperatorName) 
	begin
		if exists (select Name
				   from msdb.dbo.sysoperators
				   where name = @NewOperatorName)
		   or @NewOperatorName is null
		begin

			if OBJECT_ID('TempDB..#AgentJobs') is not null
				drop table #AgentJobs;

			create table #AgentJobs
			(
				job_id               uniqueidentifier not null, 
				name                 nvarchar(128) not null, 
				notify_level_email   int not null, 
				notify_level_netsend int not null, 
				notify_level_page    int not null);

			insert into #AgentJobs
			exec msdb.dbo.sp_help_operator_jobs @Operator_name = @OldOperatorName;

			if @DeleteOldOperator = 1
			begin

				declare @FailSafeOperator nvarchar(128);
				exec SYS.XP_INSTANCE_REGREAD N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeOperator', @FailSafeOperator output;

				if @FailSafeOperator != @OldOperatorName
				   or @FailSafeOperator is null
				begin
					insert into #AgentJobs (job_id, 
											name, 
											notify_level_email, 
											notify_level_netsend, 
											notify_level_page) 
					values(
						'00000000-0000-0000-0000-000000000000', '', '', '', '');
				end;
				else
				begin
					raiserror('@OldOperatorName Specified is set as the Failsafe Operator - change this in SQL Server Agent &amp;gt; Properties &amp;gt; Alert system. SET @DeleteOldOperator = 0 if you do not want to output the Delete Operator Statement', 11, 0);
				end;
			end;
			select #AgentJobs.name as JobName,
				   case
					   when @NewOperatorName is null then 'EXEC msdb.dbo.sp_update_job @job_id=N''' + CAST(#AgentJobs.Job_id as varchar(36)) + ''',
            @notify_level_netsend=0,
            @notify_level_page=0,
            @notify_level_email=0,
            @notify_email_operator_name=N''''' + CHAR(13) + CHAR(10)
					   when @NewOperatorName is not null then 'EXEC msdb.dbo.sp_update_job @job_id=N''' + CAST(#AgentJobs.Job_id as varchar(36)) + ''',
                    @notify_email_operator_name=N''' + @NewOperatorName + '''' + CHAR(13) + CHAR(10)
				   end as ChangeToNewOperator, 
				   'EXEC msdb.dbo.sp_update_job @job_id=N''' + CAST(#AgentJobs.Job_id as varchar(36)) + ''',
                    @notify_email_operator_name=N''' + @OldOperatorName + '''' + CHAR(13) + CHAR(10) as RevertBackToOldOperator,
				   case #AgentJobs.Notify_Level_email
					   when 0 then 'Never'
					   when 1 then 'On success'
					   when 2 then 'On failure'
					   when 3 then 'Always'
				   end as EmailNotification,
				   case #AgentJobs.Notify_Level_netsend
					   when 0 then 'Never'
					   when 1 then 'On success'
					   when 2 then 'On failure'
					   when 3 then 'Always'
				   end as NetSendNotification,
				   case #AgentJobs.Notify_Level_page
					   when 0 then 'Never'
					   when 1 then 'On success'
					   when 2 then 'On failure'
					   when 3 then 'Always'
				   end as PageNotification, 
				   CAST(sysjobs.Enabled as char(1)) as Enabled
			from #AgentJobs
				 inner join msdb..sysjobs on #AgentJobs.job_id = sysjobs.job_id
			where #AgentJobs.job_id != '00000000-0000-0000-0000-000000000000'
			union all
			select '',
				   case
					   when @DeleteOldOperator = 1 then '--EXEC msdb.dbo.sp_delete_operator @name=N''' + @OldOperatorName + ''''
				   else ''
				   end, 
				   '', 
				   '', 
				   '', 
				   '', 
				   ''
			from #AgentJobs
			where #AgentJobs.job_id = '00000000-0000-0000-0000-000000000000'
			order by JobName asc;
		end;
		else
			if @NewOperatorName is not null
			begin
				raiserror('@NewOperatorName Specified does not exist SET @CreateNewOperatorIfNotExists = 1 or create via the Operators folder', 1, 0);
				if @CreateNewOperatorIfNotExists = 1
				   and @NewOperatorName is not null
				begin
					select '/** Run the following Add Operator command then run the procedure again to see the list of agent jobs associated with the Old Operator **/' as Create_NewOperator
					union all
					select 'EXEC msdb.dbo.sp_add_operator @name=N''' + @NewOperatorName + ''',
        @enabled=1,
        @weekday_pager_start_time=90000,
        @weekday_pager_end_time=180000,
        @saturday_pager_start_time=90000,
        @saturday_pager_end_time=180000,
        @sunday_pager_start_time=90000,
        @sunday_pager_end_time=180000,
        @pager_days=0,
        @category_name=N''[Uncategorized]''
        ' + case
				when @EmailAddress is not null then ',@email_address=N''' + @EmailAddress + ''''
			else ''
			end as Create_NewOperator;
				end;
			end;
	end;
	else
	begin
		raiserror('@OldOperatorName Specified does not exist', 1, 0);
	end;
end;
go