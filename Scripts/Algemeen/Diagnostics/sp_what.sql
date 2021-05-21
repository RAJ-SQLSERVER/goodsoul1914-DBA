/*******************************************************************************************************************************************************************
--Original inspiration: https://simplesqlserver.com/tag/sys-dm_exec_requests/

/// On Blocks and SQL Statements:	///
Sometimes the most *recent* sql cmd does not reflect the source of the actual specific block object. 
If a series of cmds where executed within a batch, I will get the current statement, which may not be the source.
sys.dm_exec_connections / sys.dm_exec_requests (sql_handle).


/// inactive sessions ///
There is less data available (efficiently) for inactive sessions, at least without using sys.sysprocesses.
I have expiermented with a variety of other joins and other options to get the same data - but they sometimes exceed 1 second in duration, which is simply too long.

As sys.sysprocesses is deprecated, I am reluctant to build code around it.

Pity. :( 
*******************************************************************************************************************************************************************/


/*****************************************************************************************************************************************************************
*********************************************************** Permissions Required for Normal users to call sp_what: ***********************************************
--If you want to allow access to other users/developers/specials to execute sp_what and see results, it will be necessary to setup some special permissions first:

--Specifically, VIEW SERVER STATE and xp_logininfo.
--xp_logininfo (recommended through a proxy) to allow sp_what to check if the input is a login.
--VIEW SERVER STATE to allow the user to see active sessions on the SQL instance.
--select permission on the msdb.dbo.sysjobs table.

--creating special snowflake user to test permissions:
USE [master]
GO
CREATE LOGIN [DidYouAssumeMyGender] WITH PASSWORD='ApacheHelicopter', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE USER [DidYouAssumeMyGender] FOR LOGIN [DidYouAssumeMyGender]
GO
GRANT VIEW SERVER STATE TO [DidYouAssumeMyGender]
GO
GRANT EXECUTE ON sp_what TO [DidYouAssumeMyGender] 
GO
CREATE USER SpySpy WITHOUT LOGIN;
GO
GRANT EXECUTE ON xp_logininfo TO SpySpy
GO
USE msdb
GO
CREATE USER [DidYouAssumeMyGender] FOR LOGIN [DidYouAssumeMyGender]
GO
GRANT SELECT ON sysjobs TO [DidYouAssumeMyGender] 


--At this point, to allow your special and totally unique special user the ability to use sp_what, the following modification will need to take place:

Uncomment the EXECUTE AS and REVERT sections of the proc.

************************************************************ End Permissions Required for Normal users to call sp_what: ******************************************
*****************************************************************************************************************************************************************/



--using master for easier reference. 
use master;
go
if OBJECT_ID('sp_what', 'P') is not null
	drop proc dbo.sp_what; 
go
create proc dbo.sp_what --NULL,1,0
--DECLARE
	@nvcWhat nvarchar(1000) = null, 
	@iActive bit            = 1, 
	@iTimes  int            = 1
as
begin

/**************************************************************************************************************************************************************************
--Original inspiration: https://simplesqlserver.com/tag/sys-dm_exec_requests/

Author:	Nicholas Williams (nicholashenrywilliams@gmail.com)
Date:	October 2018
Desc:	WHAT JUST HAPPENED? OMG, NOOoooooOOOooooOOO!!!
		Displays helpful info on what is currently happening, with the pain of searching for the blocking root/head and dbcc inputbuffer combined.
		Also allows the filtering of sessions to either a spid, or a login, or a database name. (Active or inactive.)

Limitations:	If a process is a job from another server, the call to search for the job id will fail - hiding this session. Will fix.
				Also... prob need to hard code collation to get around some potential issues.
				Maybe include a min version as standard (with minimal columns returned?) and then a "max" version with more info if required.
				
https://tmblr.co/Z14uHt2ZjEyet


How to use:

Can be called on its own, without input and will display the active sessions, with any blocks.
Other inputs for the first parameter include:
Any valid login
Any Valid SPID
Any valid database

And the results will filter onto those sessions.

EXEC sp_what 'domain\login'		--includes data on all active sessions from this login.
EXEC sp_what 'domain\login',0	--includes data on all sessions (inactive and active) from this login.
EXEC sp_what 115				--includes data on the session id 115
EXEC sp_what 'master'			--includes all active sessions that are connected to the msdb database.
EXEC sp_what 'msdb', 0			--includes all sessions (inactive and active) that are connected to the msdb database.
EXEC sp_what 'msdb', 0, 5		--Executes the search 5 times, with a 0.5 delay per search, then reports on all data captured. (in this case all session for the msdb database.)


Included is the option to include or exclude only active sessions - and the option to run it multiple times and collect the results over a 
period of time.

I like to save sp_what to my keyboard shortcuts of ctrl+3.
Its fun to highlight a string with a login name, or a spid and hit ctrl+3... and watch the developers faces as they try to see how
a string or a spid can be sent to the same input. lol.*

*yes, i know this is sad. I get my laughs where i can.
**************************************************************************************************************************************************************************/

	set nocount on;
	begin try
		declare @iRun          int            = 0, 
				@iSession_id   int            = null, 
				@nvcSQLExec    nvarchar(max), 
				@nvcSQLSuffix  nvarchar(max), 
				@nvcSQLPreffix nvarchar(max), 
				@ncvDatabase   nvarchar(1000), 
				@nvcLogin      nvarchar(1000), 
				@nvcERR_MSG    nvarchar(4000), 
				@iERR_SEV      smallint, 
				@iERR_STA      smallint;

		if OBJECT_ID('tempdb.dbo.#tlb_UnicornsTasteGoodWhenFried', 'U') is not null
			drop table #tlb_UnicornsTasteGoodWhenFried;

		create table #tlb_UnicornsTasteGoodWhenFried
		(
			counter                 int, 
			session_id              int, 
			blocking                int, 
			BlockingHead            int, 
			BlockedBy               int, 
			[DD:HH:MM:SS]           varchar(14), 
			Active                  varchar(3), 
			status                  varchar(20), 
			Threads                 int, 
			Statement               varchar(max), 
			Query                   varchar(max), 
			database_name           varchar(254), 
			Pct_Comp                int, 
			Comp_Time               varchar(20), 
			Wait_Time_Sec           decimal(20, 3), 
			wait_resource           varchar(100), 
			CPU_Sec                 decimal(20, 3), 
			Reads_K                 decimal(20, 3), 
			Writes_K                decimal(20, 3), 
			login_time              datetime, 
			host_name               varchar(100), 
			program_name            varchar(100), 
			login_name              varchar(100), 
			last_request_start_time datetime, 
			last_request_end_time   datetime);

		if @nvcWhat = ''
		   or RTRIM(LTRIM(@nvcWhat)) = ''
		begin
			set @nvcWhat = null;
		end;

		if @nvcWhat is null
		begin
			goto FlyBabyFly;
		end;

		--is input a valid number? (spid)
		if ISNUMERIC(@nvcWhat) >= 1
		begin
			set @iSession_id = CAST(@nvcWhat as int);
			goto FlyBabyFly;
		end; 

		--if there is a string which is both a database and a login... then this code will default to the database as its standard, and ignore the login. cuz databases > people. *totally not anti-social. no, really! *
		if (select top 1 name
			from sys.databases
			where name = @nvcWhat) is not null
		begin
			set @ncvDatabase = @nvcWhat;
			goto FlyBabyFly;
		end;

		--this section is to determine if the input paramater is a valid login. This should only run if the input is not a valid number and if the input is not a database.
		if (select top 1 name
			from sys.server_principals
			where name = @nvcWhat) is null
		begin
			--EXECUTE as user = 'SpySpy'
			declare @tbl table
			(
				[Account name]      sysname null, 
				type                char(8) null, 
				privilege           char(9) null, 
				[mapped login name] sysname null, 
				[permission path]   sysname null);

			insert into @tbl ([Account name], 
							  type, 
							  privilege, 
							  [mapped login name], 
							  [permission path]) 
			exec master..xp_logininfo @nvcWhat, 'all';

			if (select top 1 [Account name]
				from @tbl
				where [Account name] = @nvcWhat) is null
			begin 
				--print 'invalid login, so use null as an entry for checking'
				set @iSession_id = null;
				goto FlyBabyFly;
			end;
			else
			begin
				set @nvcLogin = @nvcWhat;
				--print 'valid login, so check all sessions for that login...'
			end;
			--REVERT
			goto FlyBabyFly;
		end;
		else
		begin
			--valid login from sys.server_principals
			set @nvcLogin = @nvcWhat;
		end;
		
/*****************************************************************************************************************************************
Did you know that the joke about a chicken crossing the road.... (to get to the other *SIDE*) is about suicide? True story. Life Changed.*
*this was also a joke.
*****************************************************************************************************************************************/

		FlyBabyFly:
		--PRINT 'Baby did fly. no input, so default to null and skip other checks.'

		set @nvcSQLExec = N'
;WITH a AS 
	(
	SELECT 
		 es.session_id
		,es.is_user_process
		,CASE 
			WHEN er.sql_handle IS NULL 
			THEN cn.[most_recent_sql_handle]
			ELSE er.sql_handle 
			END sql_handle
		,ot.Threads
		,er.percent_complete	Pct_Comp 
		,CASE er.estimated_completion_time 
			WHEN 0 
			THEN NULL 
			ELSE dateadd(ms,er.estimated_completion_time,GETDATE()) 
			END  Comp_Time
		,es.status
		,CASE 
			WHEN es.[status] IN (''sleeping'',''dormant'') 
			THEN ''No*'' 
			ELSE ''Yes'' 
			END as [Active]
		,ISNULL(er.blocking_session_id, 0) BlockedBy
		,er.command
		,sd.name database_name 
		,CAST(er.wait_time/1000.0 as DEC(20,3))	Wait_Time_Sec
		,er.wait_resource
		,CASE 
			WHEN er.[total_elapsed_time] IS NULL
			THEN CONVERT(varchar,CAST(((DATEDIFF(ss, login_time, GETDATE())) / 86400) as INT )) + '':'' + CONVERT(varchar,DATEADD(ss,(DATEDIFF(ss, login_time, GETDATE())),0),108) 
			ELSE CONVERT(varchar,CAST(((er.[total_elapsed_time] / 1000.0) / 86400) as INT )) + '':'' + CONVERT(varchar,DATEADD(ss,(er.[total_elapsed_time] / 1000.0),0),108) 
		 END [DD:HH:MM:SS]
		,CAST(er.cpu_time/1000.0 as DEC(20,3))	CPU_Sec
		,CAST(er.reads/1000.0 as DEC(20,3))	Reads_K
		,CAST(er.writes/1000.0 as DEC(20,3))	Writes_K
		,es.login_time
		,es.host_name
		,CASE LEFT(es.program_name,29)
			WHEN ''SQLAgent - TSQL JobStep (Job ''
			THEN ''SQLAgent Job: '' + (SELECT name FROM msdb..sysjobs sj WHERE SUBSTRING(es.program_name,32,32)=(SUBSTRING(sys.fn_varbintohexstr(sj.job_id),3,100))) + '' - '' + SUBSTRING(es.program_name,67,len(es.program_name)-67)
			ELSE es.program_name
			END  program_name
		,es.client_interface_name
		,es.login_name
		,es.total_scheduled_time
		,es.total_elapsed_time
		,er.start_time
		,es.last_request_start_time
		,es.last_request_end_time
		,er.database_id  
		,er.statement_end_offset 
		,er.statement_start_offset
	FROM		sys.dm_exec_sessions	es
	LEFT JOIN	sys.dm_exec_requests	er	ON	es.session_id	=	er.session_id
	LEFT JOIN	sys.databases			sd	ON	er.database_id	=	sd.database_id
	LEFT JOIN	sys.dm_exec_connections	cn	ON	es.session_id	=	cn.session_id
	LEFT JOIN	(SELECT session_id,COUNT(1) Threads FROM sys.dm_os_tasks GROUP BY session_id) ot ON er.session_id=ot.session_id
	WHERE		es.session_id <> @@SPID
	AND			es.is_user_process = 1
	)
,b AS 
	(
	SELECT 
		CASE 
			WHEN session_id IN (SELECT DISTINCT BlockedBy FROM a WHERE a.BlockedBy IS NOT NULL AND BlockedBy <> 0)
			THEN 1
			ELSE 0
		 END blocking
		,a.*
	FROM a
	)
,c AS
	(
	SELECT 
		 NULL counter
		,session_id
		,blocking
		,CASE 
			WHEN blocking = 1 AND BlockedBy = 0
			THEN session_id
			ELSE NULL
		 END BlockingHead
		,BlockedBy
		,[DD:HH:MM:SS]
		,Active
		,status
		,Threads
		,SUBSTRING	(st.text, b.statement_start_offset/2,
					ABS(CASE 
						WHEN b.statement_end_offset = -1
						THEN LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2 
						ELSE b.statement_end_offset 
						END - b.statement_start_offset
					)/2
					) [Statement] 
		,st.text Query
		,database_name
		,Pct_Comp
		,Comp_Time
		,Wait_Time_Sec
		,wait_resource
		,CPU_Sec
		,Reads_K
		,Writes_K
		,login_time
		,host_name
		,program_name
		,login_name
		,last_request_start_time
		,last_request_end_time
	FROM b 
	CROSS APPLY	sys.dm_exec_sql_text(b.[sql_handle]) AS st  
	WHERE 1=1 --makes it easier to add/remove conditions within dynamic SQL.
';

/********************************************
These if clauses... exactly what I intended. 
*cough* 
https://9gag.com/gag/a4Q4RXZ
********************************************/

		if @ncvDatabase is not null
		   and ( @iActive <> 0
				 or @iActive is null
			   )
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND database_name = ''' + CAST(@ncvDatabase as nvarchar(255)) + '''
	AND (Active <> ''No*'' OR blocking = 1) ';
			print @nvcSQLExec;
		end;

		if @ncvDatabase is not null
		   and @iActive = 0
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND database_name = ''' + CAST(@ncvDatabase as nvarchar(255)) + '''';
			print @nvcSQLExec;
		end;

		if @nvcLogin is not null
		   and ( @iActive <> 0
				 or @iActive is null
			   )
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND login_name = ''' + CAST(@nvcLogin as nvarchar(255)) + '''
	AND (Active <> ''No*'' OR blocking = 1) ';
			print @nvcSQLExec;
		end;

		if @nvcLogin is not null
		   and @iActive = 0
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND login_name = ''' + CAST(@nvcLogin as nvarchar(255)) + '''';
			--PRINT @nvcSQLExec
		end;

		if @iSession_id is not null
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND session_id = ' + CAST(@iSession_id as nvarchar(255));
			--PRINT @nvcSQLExec
		end;

		if @iSession_id is null
		   and ( @iActive <> 0
				 or @iActive is null
			   )
		begin
			set @nvcSQLExec = @nvcSQLExec + N' AND (Active <> ''No*'' OR blocking = 1) '; 
			--PRINT @nvcSQLExec
		end;

		if @iSession_id is null
		   and @iActive = 0
		begin
			set @nvcSQLExec = @nvcSQLExec + ' '; 
			--PRINT @nvcSQLExec
		end;

		--suffix
		set @nvcSQLExec = @nvcSQLExec + N' ) INSERT INTO #tlb_UnicornsTasteGoodWhenFried SELECT * FROM c';


		if @iTimes < 1
		   or @iTimes > 100
		   or @iTimes is null
			set @iTimes = 1;

		if @iTimes > 1
		begin
			while @iRun < @iTimes
			begin
				set @iRun = @iRun + 1;

				--PRINT @nvcSQLExec
				exec sp_executesql @nvcSQLExec;

				update #tlb_UnicornsTasteGoodWhenFried
				set counter = @iRun
				where counter is null;

				waitfor delay '00:00:00.5';
			end;
		end;

		if @iTimes = 1
		begin
			--PRINT @nvcSQLExec
			exec sp_executesql @nvcSQLExec;
		end;

		select GETDATE() as [Time], 
			   @@SERVERNAME as SQLInstance, 
			   SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as Node;

/***************************
https://9gag.com/gag/a9Kdj56
***************************/

		if exists (select top 1 *
				   from #tlb_UnicornsTasteGoodWhenFried) 
		begin
			if @iTimes = 1
			begin
				if exists (select top 1 *
						   from #tlb_UnicornsTasteGoodWhenFried
						   where BlockingHead is not null) 
				begin
					select distinct 
						   session_id, 
						   blocking, 
						   BlockingHead, 
						   BlockedBy, 
						   [DD:HH:MM:SS], 
						   Active, 
						   status, 
						   [Statement], 
						   Query, 
						   database_name, 
						   login_name, 
						   CPU_Sec, 
						   Reads_K, 
						   Writes_K, 
						   host_name, 
						   program_name, 
						   login_time
						   ,
						   --		,last_request_start_time 
						   last_request_end_time, 
						   Threads, 
						   Wait_Time_Sec, 
						   wait_resource, 
						   Pct_Comp
					--		,Comp_Time
					from #tlb_UnicornsTasteGoodWhenFried;
				end;
				else
				begin
					select distinct 
						   session_id
						   ,
						   --,blocking
						   --,BlockingHead
						   --,BlockedBy 
						   [DD:HH:MM:SS], 
						   Active, 
						   status, 
						   [Statement], 
						   Query, 
						   database_name, 
						   login_name, 
						   CPU_Sec, 
						   Reads_K, 
						   Writes_K, 
						   host_name, 
						   program_name, 
						   login_time
						   ,
						   --		,last_request_start_time 
						   last_request_end_time, 
						   Threads, 
						   Wait_Time_Sec, 
						   wait_resource, 
						   Pct_Comp
					--		,Comp_Time
					from #tlb_UnicornsTasteGoodWhenFried;
				end;
			end;
			else
			begin
				select counter, 
					   session_id, 
					   blocking, 
					   BlockingHead, 
					   BlockedBy, 
					   [DD:HH:MM:SS], 
					   Active, 
					   status, 
					   [Statement], 
					   Query, 
					   database_name, 
					   login_name, 
					   CPU_Sec, 
					   Reads_K, 
					   Writes_K, 
					   host_name, 
					   program_name, 
					   login_time
					   ,
					   --		,last_request_start_time 
					   last_request_end_time, 
					   Threads, 
					   Wait_Time_Sec, 
					   wait_resource, 
					   Pct_Comp
				--		,Comp_Time
				from #tlb_UnicornsTasteGoodWhenFried;

			end;
		end;

		if (select top 1 blocking
			from #tlb_UnicornsTasteGoodWhenFried
			where blocking <> 0) is not null
		begin
			select distinct 
				   session_id, 
				   BlockingHead, 
				   [DD:HH:MM:SS], 
				   login_time, 
				   Query, 
				   Statement, 
				   database_name, 
				   login_name, 
				   program_name, 
				   host_name
			from #tlb_UnicornsTasteGoodWhenFried
			where BlockingHead is not null;
		end;

		if @iSession_id < 0
		begin
			if exists (select top 1 *
					   from sys.dm_tran_locks
					   where request_session_id < 0) 
			begin
				select 'KILL ' + CAST(request_owner_guid as varchar) as KillCmd, 
					   *
				from sys.dm_tran_locks
				where request_session_id < 0
					  and request_owner_guid <> '00000000-0000-0000-0000-000000000000';
			end;
		end;

/*****************************
https://tmblr.co/Z14uHt2ZfI-kN
*****************************/

		drop table #tlb_UnicornsTasteGoodWhenFried;
	end try
	begin catch
		select @iERR_SEV = ERROR_SEVERITY(), 
			   @iERR_STA = ERROR_STATE(), 
			   @nvcERR_MSG = ERROR_MESSAGE();
		--	THROW
		raiserror(@nvcERR_MSG, @iERR_SEV, @iERR_STA) with nowait;
	end catch;

	set nocount off;
end;