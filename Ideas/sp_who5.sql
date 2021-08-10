USE master
GO

/****** Object:  StoredProcedure [dbo].[sp_who5]    Script Date: 10-8-2021 07:57:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-----------------------------------------------------------------------------------------------------------------------------
--	Stored Procedure Details: Listing Of Standard Details Related To The Stored Procedure
-----------------------------------------------------------------------------------------------------------------------------

--	Purpose: Return Information Regarding Current Users / Sessions / Processes On A SQL Server Instance
--	Create Date (MM/DD/YYYY): 10/27/2009
--	Developer: Sean Smith (s.smith.sql AT gmail DOT com)
--	Latest Release: http://www.sqlservercentral.com/scripts/sp_who/68607/
--	Script Library: http://www.sqlservercentral.com/Authors/Scripts/Sean_Smith/776614/
--	LinkedIn Profile: https://www.linkedin.com/in/seanmsmith/

-----------------------------------------------------------------------------------------------------------------------------
--	Modification History: Listing Of All Modifications Since Original Implementation
-----------------------------------------------------------------------------------------------------------------------------

--	Description: Added "@Database_Name" Filter Variable
--	           : Added "Last_Wait_Type", "Query_Plan", And "Wait_Type" Fields To Output
--	           : Changed Code Formatting
--	           : Converted Script To Dynamic-SQL
--	Date (MM/DD/YYYY): 08/08/2011

--	Description: Added "C" Type "@Filter" Option
--	           : Added "Plan_Cache_Object_Type", "Plan_Object_Type", "Plan_Times_Used", And "Plan_Size_MB" Fields To Output
--	           : Changed Help Output From RAISERROR To PRINT
--	           : Merged "I?" And "O?" Help Parameters Into "?"
--	           : Renamed Input Parameters
--	           : Rewrote Time Calculation Logic
--	Date (MM/DD/YYYY): 11/09/2011

--	Description: Added "SQL_Statement_Current" And "End_Of_Batch" Fields To Output
--	           : Added System Process Indicator To "SPID"
--	           : Expanded "Running" Type Indicators
--	Date (MM/DD/YYYY): 02/01/2012

--	Description: Bug Fixes
--	           : Changed Code Formatting
--	           : Changed Date Calculation Method
--	Date (MM/DD/YYYY): 08/19/2013

--	Description: Added "Batch_Pct", "Command_Completion", "Command_Pct", "Command_Time_Left", "Deadlock_Priority", "Isolation_Level", "Last_Row_Count", "Lock_Details", "Lock_Timeout_Seconds", And "Previous_Error" Fields To Output
--	Date (MM/DD/YYYY): 11/24/2013

--	Description: Massive Rewrite Of Entire Stored Procedure
--	Date (MM/DD/YYYY): 11/28/2015

--	Description: Added "Log_Database_Count", "Log_Details", "Log_Records_All", "Log_Reserved_MB_All", "Log_Used_MB_All", "TempDB_Session_Current_MB", "TempDB_Session_Total_MB", "TempDB_Task_Current_MB", "TempDB_Task_Total_MB", "Threads", "Transaction_ID", "Transaction_State", "Transaction_Time", "Transaction_Type" Fields To Output
--	           : Added Deadlock Detection To "Blocking" Output Field
--	           : No Longer Displays Results At The Execution Context ID (ECID) Level
--	           : Removed "@SQL_Text" Filter Variable
--	           : Removed "Batch_Pct", "End_Of_Batch", "Plan_Cache_Object_Type", "Plan_Object_Type", "Plan_Size_MB", "Plan_Times_Used", "Previous_Error" Fields From Output
--	           : Renamed "SPECID" To "SPID", "Open_Trans" To "Transactions" Output Fields
--	Date (MM/DD/YYYY): 05/07/2016

--	Description: Another Massive Rewrite Of Entire Stored Procedure To Improve Performance
--	Date (MM/DD/YYYY): 01/20/2018

-----------------------------------------------------------------------------------------------------------------------------
--	Main Query: Create Procedure
-----------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_who5] 
	@Filter AS          NVARCHAR(5)   = NULL, 
	@Database_Name AS   NVARCHAR(512) = NULL, 
	@Exclude_Lock AS    BIT           = 1, 
	@Exclude_Log AS     BIT           = 1, 
	@Exclude_Plan AS    BIT           = 1, 
	@Exclude_SQL AS     BIT           = 0, 
	@Exclude_SQL_XML AS BIT           = 1, 
	@Exclude_TXN AS     BIT           = 1, 
	@Login AS           NVARCHAR(128) = NULL, 
	@SPID AS            SMALLINT      = NULL
AS
BEGIN

	set transaction isolation level read uncommitted;
	set nocount on;
	set ansi_warnings off;
	set arithabort off;
	set arithignore on;
	set textsize 2147483647;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Declarations / Sets: Declare And Set Variables
	-----------------------------------------------------------------------------------------------------------------------------

	declare @Ampersand as       nvarchar(1), 
			@CR_LF as           nchar(2), 
			@CR_LF_Tab as       nchar(3), 
			@Database_ID as     int, 
			@Date_Now as        datetime, 
			@Filter_Active as   bit, 
			@Filter_Blocked as  bit, 
			@Filter_Sleeping as bit, 
			@Filter_System as   bit, 
			@Plan_Handle as     varbinary(64), 
			@Print as           nvarchar(max), 
			@SQL_Handle as      varbinary(64), 
			@SQL_String as      nvarchar(max);


	set @Ampersand = N'&';


	set @CR_LF = NCHAR(13) + NCHAR(10);


	set @CR_LF_Tab = @CR_LF + NCHAR(9);


	set @Database_Name = NULLIF(@Database_Name, N'');


	set @Date_Now = GETDATE();


	set @Filter_Active = case
							 when @Filter like N'%A%' then 1
						 else 0
						 end;


	set @Filter_Blocked = case
							  when @Filter like N'%B%' then 1
						  else 0
						  end;


	set @Filter_Sleeping = case
							   when @Filter like N'%S%' then 1
						   else 0
						   end;


	set @Filter_System = case
							 when @Filter like N'%X%' then 1
						 else 0
						 end;


	set @Login = NULLIF(@Login, N'');


	-----------------------------------------------------------------------------------------------------------------------------
	--	Error Trapping: Check If "@Filter" Parameter Is An Input / Output Help Request
	-----------------------------------------------------------------------------------------------------------------------------

	if @Filter = N'?'
	begin

		set @Print = N'
Optional input parameters:

	@Filter          : Limit the result set by passing one or more values listed below (can be combined in any order)

		A - Active sessions only (includes sleeping SPIDs with open transactions)
		B - Blocking / blocked sessions only
		S - Exclude sleeping SPIDs with open transactions
		X - Exclude system processes

	@Database_Name   : Limit the result set to a specific database (use ---------- for NULL database names)
	@Exclude_Lock    : Suppress lock details from the output (can increases procedure performance on busy servers; defaulted to 1)
	@Exclude_Log     : Suppress log details from the output (can increases procedure performance on busy servers; defaulted to 1)
	@Exclude_Plan    : Suppress execution plan details from the output (can increases procedure performance on busy servers; defaulted to 1)
	@Exclude_SQL     : Suppress SQL statement details from the output (can increases procedure performance on busy servers; defaulted to 0)
	@Exclude_SQL_XML : Suppress SQL statement XML details from the output (can increases procedure performance on busy servers; defaulted to 1)
	@Exclude_TXN     : Suppress transaction details from the output (also suppresses log details due to an interdependency; can increases procedure performance on busy servers; defaulted to 1)
	@Login           : Limit the result set to a specific Windows user name (if populated, otherwise by SQL Server login name)
	@SPID            : Limit the result set to a specific session


Notes:

	Blocking / blocked sessions will always be displayed first in the result set (when applicable)


Output:

	SPID                      : System Process ID
	Database_Name             : Database context of the session
	Running                   : Indicates if the session is executing (X), waiting ([]), inactive (blank), inactive with open transactions (•), a background task (--), or not defined (N/A)
	Blocking                  : Blocking indicator (includes type of block, SPID list, and deadlock detection when applicable)
	Status                    : Status of the session -> request
	Object_Name               : Object being referenced (blank for ad hoc and prepared statements)
	Command                   : Command executed
	Threads                   : Process thread count
	SQL_Statement_Batch       : Batch statement of the session
	SQL_Statement_Current     : Current statement of the session
	Isolation_Level           : Isolation level of the session
	Wait_Time                 : Current wait time (DAYS HH:MM:SS)
	Wait_Type                 : Current wait type
	Last_Wait_Type            : Previous wait type
	Elapsed_Time              : Elapsed time since the request began (DAYS HH:MM:SS)
	CPU_Total                 : CPU time used since login (DAYS HH:MM:SS)
	CPU_Current               : CPU time used for the current process (DAYS HH:MM:SS)
	Logical_Reads_Total       : Logical reads performed since login
	Logical_Reads_Current     : Logical reads performed by the current process
	Physical_Reads_Total      : Physical reads performed since login
	Physical_Reads_Current    : Physical reads performed by the current process
	Writes_Total              : Writes performed since login
	Writes_Current            : Writes performed by the current process
	Last_Row_Count            : Row count produced by the last statement executed
	Allocated_Memory_MB       : Memory allocated to the query in megabytes
	Pages_Used                : Pages in the procedure cache allocated to the process
	Transactions              : Open transactions for the process
	Transaction_ID            : Transaction ID
	Transaction_Time          : Elapsed time since the transaction began (DAYS HH:MM:SS)
	Transaction_Type          : Type of transaction
	Transaction_State         : State of the transaction
	Nesting_Level             : Nesting level of the statement executing
	TempDB_Session_Total_MB   : Temp DB space used since login for the session in megabytes
	TempDB_Session_Current_MB : Temp DB space currently used by the session in megabytes
	TempDB_Task_Total_MB      : Temp DB space used by the entire task in megabytes
	TempDB_Task_Current_MB    : Temp DB space currently used by the task in megabytes
	Log_Database_Count        : Databases involved in the transaction
	Log_Records_All           : Log records generated for the transaction (all databases)
	Log_Reserved_MB_All       : Log space reserved for the transaction in megabytes (all databases)
	Log_Used_MB_All           : Log space used for the transaction in megabytes (all databases)
	Log_Details               : Log usage details for the transaction per database (in XML format)
	Lock_Timeout_Seconds      : Lock timeout of the session
	Lock_Details              : Lock details of the session (in XML format)
	Deadlock_Priority         : Deadlock priority of the session
	SQL_Statement_Batch_XML   : Same as "SQL_Statement_Batch" but in XML format
	SQL_Statement_Current_XML : Same as "SQL_Statement_Current" but in XML format
	SQL_Handle                : Identifier for the executing batch or object
	Query_Plan                : Execution plan of the session (in XML format)
	Plan_Handle               : Identifier for the in-memory plan
	Since_SPID_Login          : Elapsed time since the client logged in (DAYS HH:MM:SS)
	Since_Last_Batch_Start    : Elapsed time since the last request began (DAYS HH:MM:SS)
	Since_Last_Batch_End      : Elapsed time since the last completion of a request (DAYS HH:MM:SS)
	Command_Pct               : Percentage of work completed (applies to a limited set of commands)
	Command_Completion        : Estimated completion time for the command
	Command_Time_Left         : Time left before the command completes (DAYS HH:MM:SS)
	Host_Name                 : Name of the client workstation specific to a session
	Login_ID                  : Windows user name (or "Login_Name" if user name is unavailable)
	Login_Name                : Full name of the user associated to the "Login_ID"
	Application_Description   : Application accessing SQL Server
	System_Process            : Indicates if the session is a system process
	SPID                      : System Process ID
		 ';


		print SUBSTRING(@Print, 1, 3931);


		print SUBSTRING(@Print, 3934, 4000);


		RETURN;

	END;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Error Trapping: Check If Temp Table(s) Already Exist(s) And Drop If Applicable
	-----------------------------------------------------------------------------------------------------------------------------

	if OBJECT_ID(N'tempdb.dbo.#temp_core_data', N'U') is not null
	begin

		drop table dbo.#temp_core_data;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_databases', N'U') is not null
	begin

		drop table dbo.#temp_databases;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_deadlocking', N'U') is not null
	begin

		drop table dbo.#temp_deadlocking;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_false_positive_blocking', N'U') is not null
	begin

		drop table dbo.#temp_false_positive_blocking;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_lock_details', N'U') is not null
	begin

		drop table dbo.#temp_lock_details;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_log_details', N'U') is not null
	begin

		drop table dbo.#temp_log_details;

	end;


	if OBJECT_ID(N'tempdb.dbo.#temp_parallelism', N'U') is not null
	begin

		drop table dbo.#temp_parallelism;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Creation: Create Various Temp Tables
	-----------------------------------------------------------------------------------------------------------------------------

	create table dbo.#temp_databases
	(
		database_id   int null, 
		database_name nvarchar(128) null);


	create table dbo.#temp_lock_details
	(
		req_spid      int null, 
		rsc_dbid      smallint null, 
		rsc_objid     int null, 
		rsc_indid     smallint null, 
		object_name   nvarchar(275) null, 
		index_name    nvarchar(128) null, 
		rsc_type      tinyint null, 
		req_mode      tinyint null, 
		req_status    tinyint null, 
		req_ownertype smallint null, 
		req_ecid      int null, 
		req_refcnt    int null);


	create table dbo.#temp_log_details
	(
		transaction_id                                 bigint null, 
		database_id                                    int null, 
		database_transaction_begin_time                datetime null, 
		database_transaction_type                      int null, 
		database_transaction_state                     int null, 
		database_transaction_log_record_count          bigint null, 
		database_transaction_log_bytes_reserved        bigint null, 
		database_transaction_log_bytes_used            bigint null, 
		database_transaction_log_bytes_reserved_system int null, 
		database_transaction_log_bytes_used_system     int null);


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Databases
	-----------------------------------------------------------------------------------------------------------------------------

	set @Database_ID = -2147483648;


	set lock_timeout 5;


	while @Database_ID is not null
	begin

		begin try

			insert into dbo.#temp_databases (database_id, 
											 database_name) 
			select top (1) DB.database_id, 
						   DB.name as database_name
			from master.sys.databases as DB
			where DB.database_id = @Database_ID;
		end try
		begin catch
		end catch;


		BEGIN TRY

			set @Database_ID = (select top (1) DB.database_id
								from master.sys.databases as DB
								where DB.database_id > @Database_ID
								order by DB.database_id);
		END TRY
		BEGIN CATCH

			SET @Database_ID = @Database_ID + 1;
		END CATCH;

	END;


	set lock_timeout-1;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Core Data
	-----------------------------------------------------------------------------------------------------------------------------

	select DXS.session_id, 
		   ttDB.database_name, 
		   DER.blocking_session_id, 
		   DXS.status as status_session, 
		   DER.status as status_request, 
		   CONVERT(int, null) as dbid, 
		   CONVERT(int, null) as objectid, 
		   CONVERT(nvarchar(275), null) as object_name, 
		   DER.command, 
		   sqSP.threads, 
		   CONVERT(nvarchar(max), null) as [text], 
		   sqSP.stmt_start, 
		   sqSP.stmt_end, 
		   DXS.transaction_isolation_level, 
		   DER.wait_time, 
		   DER.wait_type, 
		   DER.last_wait_type, 
		   DER.total_elapsed_time, 
		   DXS.cpu_time as cpu_time_total, 
		   DER.cpu_time as cpu_time_current, 
		   DXS.logical_reads as logical_reads_total, 
		   DER.logical_reads as logical_reads_current, 
		   DXS.reads as reads_total, 
		   DER.reads as reads_current, 
		   DXS.writes as writes_total, 
		   DER.writes as writes_current, 
		   DXS.row_count, 
		   DER.granted_query_memory, 
		   DXS.memory_usage, 
		   sqSP.open_tran, 
		   CONVERT(bigint, null) as transaction_id, 
		   CONVERT(datetime, null) as transaction_begin_time, 
		   CONVERT(int, null) as transaction_type, 
		   CONVERT(int, null) as transaction_state, 
		   DER.nest_level, 
		   sqTS.tempdb_page_allocation_session, 
		   sqTS.tempdb_page_deallocation_session, 
		   sqTT.tempdb_page_allocation_task, 
		   sqTT.tempdb_page_deallocation_task, 
		   DXS.lock_timeout, 
		   DXS.deadlock_priority, 
		   sqSP.sql_handle, 
		   CONVERT(xml, null) as query_plan, 
		   DER.plan_handle, 
		   DXS.login_time as login_time_sessions, 
		   sqSP.login_time as login_time_processes, 
		   DXS.last_request_start_time, 
		   DXS.last_request_end_time, 
		   sqSP.last_batch, 
		   DER.percent_complete, 
		   DER.estimated_completion_time, 
		   DXS.host_name, 
		   DXS.nt_user_name, 
		   DXS.login_name, 
		   DXS.program_name, 
		   DXS.is_user_process
	into dbo.#temp_core_data
	from master.sys.dm_exec_sessions as DXS
		 inner join (select SP.spid, 
							SUM(case
									when SP.kpid = 0 then 0
								else 1
								end) as threads, 
							MAX(SP.stmt_start) as stmt_start, 
							MAX(SP.stmt_end) as stmt_end, 
							MAX(SP.open_tran) as open_tran, 
							MAX(NULLIF(SP.sql_handle, 0x0000000000000000000000000000000000000000)) as sql_handle, 
							MAX(SP.login_time) as login_time, 
							MAX(SP.last_batch) as last_batch, 
							MAX(SP.dbid) as dbid
					 from master.sys.sysprocesses as SP
					 group by SP.spid) as sqSP on sqSP.spid = DXS.session_id
		 left join master.sys.dm_exec_requests as DER on DER.session_id = DXS.session_id
		 left join dbo.#temp_databases as ttDB on ttDB.database_id = sqSP.dbid
		 left join (select DDSSU.session_id, 
						   SUM(DDSSU.user_objects_alloc_page_count + DDSSU.internal_objects_alloc_page_count) as tempdb_page_allocation_session, 
						   SUM(DDSSU.user_objects_dealloc_page_count + DDSSU.internal_objects_dealloc_page_count) as tempdb_page_deallocation_session
					from master.sys.dm_db_session_space_usage as DDSSU
					group by DDSSU.session_id) as sqTS on sqTS.session_id = DXS.session_id
		 left join (select DDTSU.session_id, 
						   SUM(DDTSU.user_objects_alloc_page_count + DDTSU.internal_objects_alloc_page_count) as tempdb_page_allocation_task, 
						   SUM(DDTSU.user_objects_dealloc_page_count + DDTSU.internal_objects_dealloc_page_count) as tempdb_page_deallocation_task
					from master.sys.dm_db_task_space_usage as DDTSU
					group by DDTSU.session_id) as sqTT on sqTT.session_id = DXS.session_id
	where( @Database_Name is null
		   or ISNULL(ttDB.database_name, N'----------') = @Database_Name
		 )
		 and ( @Filter_Active = 0
			   or case
					  when @Filter_Sleeping = 0
						   and sqSP.open_tran > 0 then N''
				  else DXS.status
				  end not in (N'dormant', N'sleeping')
			 )
		 and ( @Filter_Blocked = 0
			   or DER.blocking_session_id <> 0
			 )
		 and ( @Filter_System = 0
			   or DXS.is_user_process = 1
			 )
		 and ( @Login is null
			   or DXS.nt_user_name = @Login
			   or DXS.login_name = @Login
			 )
		 and ( @SPID is null
			   or DXS.session_id = @SPID
			 )
		 or NULLIF(DER.blocking_session_id, 0) is not null
		 or exists (select *
					from master.sys.dm_exec_requests as XDER
					where XDER.blocking_session_id <> 0
						  and XDER.blocking_session_id = DXS.session_id);


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Populate Transaction Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_TXN = 0
	begin

		update ttCD
		set ttCD.transaction_id = DTST.transaction_id, ttCD.transaction_begin_time = DTAT.transaction_begin_time, ttCD.transaction_type = DTAT.transaction_type, ttCD.transaction_state = DTAT.transaction_state
		from dbo.#temp_core_data ttCD
			 inner join master.sys.dm_tran_session_transactions DTST on DTST.session_id = ttCD.session_id
			 left join master.sys.dm_tran_active_transactions DTAT on DTAT.transaction_id = DTST.transaction_id;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Transaction Log Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Log = 0
	   and @Exclude_TXN = 0
	begin

		insert into dbo.#temp_log_details (transaction_id, 
										   database_id, 
										   database_transaction_begin_time, 
										   database_transaction_type, 
										   database_transaction_state, 
										   database_transaction_log_record_count, 
										   database_transaction_log_bytes_reserved, 
										   database_transaction_log_bytes_used, 
										   database_transaction_log_bytes_reserved_system, 
										   database_transaction_log_bytes_used_system) 
		select DTDT.transaction_id, 
			   DTDT.database_id, 
			   DTDT.database_transaction_begin_time, 
			   DTDT.database_transaction_type, 
			   DTDT.database_transaction_state, 
			   DTDT.database_transaction_log_record_count, 
			   DTDT.database_transaction_log_bytes_reserved, 
			   DTDT.database_transaction_log_bytes_used, 
			   DTDT.database_transaction_log_bytes_reserved_system, 
			   DTDT.database_transaction_log_bytes_used_system
		from master.sys.dm_tran_database_transactions as DTDT
		where exists (select *
					  from dbo.#temp_core_data as ttCD
					  where ttCD.transaction_id = DTDT.transaction_id);

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Lock Request Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Lock = 0
	begin

		insert into dbo.#temp_lock_details (req_spid, 
											rsc_dbid, 
											rsc_objid, 
											rsc_indid, 
											object_name, 
											index_name, 
											rsc_type, 
											req_mode, 
											req_status, 
											req_ownertype, 
											req_ecid, 
											req_refcnt) 
		select SLI.req_spid, 
			   SLI.rsc_dbid, 
			   SLI.rsc_objid, 
			   SLI.rsc_indid, 
			   CONVERT(nvarchar(275), null) as object_name, 
			   CONVERT(nvarchar(128), null) as index_name, 
			   SLI.rsc_type, 
			   SLI.req_mode, 
			   SLI.req_status, 
			   SLI.req_ownertype, 
			   SLI.req_ecid, 
			   SUM(SLI.req_refcnt) as req_refcnt
		from master.sys.syslockinfo as SLI
		where exists (select *
					  from dbo.#temp_core_data as ttCD
					  where ttCD.session_id = SLI.req_spid)
		group by SLI.req_spid, 
				 SLI.rsc_dbid, 
				 SLI.rsc_objid, 
				 SLI.rsc_indid, 
				 SLI.rsc_type, 
				 SLI.req_mode, 
				 SLI.req_status, 
				 SLI.req_ownertype, 
				 SLI.req_ecid;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate SQL Text Data And Object Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_SQL = 0
	begin

		set @SQL_Handle = (select top (1) ttCD.sql_handle
						   from dbo.#temp_core_data as ttCD
						   where ttCD.sql_handle is not null
						   order by ttCD.sql_handle);


		WHILE @SQL_Handle IS NOT NULL
		BEGIN

			set lock_timeout 5;


			begin try

				update ttCD
				set ttCD.dbid = case
									when ttCD.dbid is null
										 and ttCD.objectid is null then DEST.dbid
								else ttCD.dbid
								end, ttCD.objectid = case
														 when ttCD.dbid is null
															  and ttCD.objectid is null then DEST.objectid
													 else ttCD.objectid
													 end, ttCD.[text] = DEST.[text]
				from dbo.#temp_core_data ttCD
					 cross apply master.sys.dm_exec_sql_text(ttCD.sql_handle) DEST
				where ttCD.sql_handle = @SQL_Handle;
			end try
			begin catch
			end catch;


			set lock_timeout-1;


			SET @SQL_Handle = (SELECT TOP (1) ttCD.sql_handle
							   FROM dbo.#temp_core_data AS ttCD
							   WHERE ttCD.sql_handle IS NOT NULL
									 AND ttCD.sql_handle > @SQL_Handle
							   ORDER BY ttCD.sql_handle);

		END;

	END;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate Query Plan Data And Object Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Plan = 0
	begin

		set @Plan_Handle = (select top (1) ttCD.plan_handle
							from dbo.#temp_core_data as ttCD
							where ttCD.plan_handle is not null
							order by ttCD.plan_handle);


		WHILE @Plan_Handle IS NOT NULL
		BEGIN

			set lock_timeout 5;


			begin try

				update ttCD
				set ttCD.dbid = case
									when ttCD.dbid is null
										 and ttCD.objectid is null then DEQP.dbid
								else ttCD.dbid
								end, ttCD.objectid = case
														 when ttCD.dbid is null
															  and ttCD.objectid is null then DEQP.objectid
													 else ttCD.objectid
													 end, ttCD.query_plan = DEQP.query_plan
				from dbo.#temp_core_data ttCD
					 cross apply master.sys.dm_exec_query_plan(ttCD.plan_handle) DEQP
				where ttCD.plan_handle = @Plan_Handle;
			end try
			begin catch
			end catch;


			set lock_timeout-1;


			SET @Plan_Handle = (SELECT TOP (1) ttCD.plan_handle
								FROM dbo.#temp_core_data AS ttCD
								WHERE ttCD.plan_handle IS NOT NULL
									  AND ttCD.plan_handle > @Plan_Handle
								ORDER BY ttCD.plan_handle);

		END;

	END;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate Object Name
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Plan = 0
	   or @Exclude_SQL = 0
	begin

		set @Database_ID = (select top (1) ttCD.dbid
							from dbo.#temp_core_data as ttCD
							where ttCD.dbid is not null
								  and ttCD.objectid is not null
							order by ttCD.dbid);


		WHILE @Database_ID IS NOT NULL
		BEGIN

			set @SQL_String = N'
				USE [' + (select ttDB.database_name
						  from dbo.#temp_databases as ttDB
						  where ttDB.database_id = @Database_ID) + N']


				UPDATE
					ttCD
				SET
					ttCD.[object_name] = N''['' + S.name + N''].['' + AO.name + N'']''
				FROM
					dbo.#temp_core_data ttCD
					INNER JOIN sys.all_objects AO ON AO.[object_id] = ttCD.objectid
					INNER JOIN sys.schemas S ON S.[schema_id] = AO.[schema_id]
				WHERE
					ttCD.[dbid] = ' + CONVERT(nvarchar(11), @Database_ID) + N'
			 ';


			if @SQL_String is not null
			begin

				set lock_timeout 5;


				begin try

					execute (@SQL_String);
				end try
				begin catch
				end catch;


				SET LOCK_TIMEOUT-1;

			END;


			SET @Database_ID = (SELECT TOP (1) ttCD.dbid
								FROM dbo.#temp_core_data AS ttCD
								WHERE ttCD.dbid IS NOT NULL
									  AND ttCD.objectid IS NOT NULL
									  AND ttCD.dbid > @Database_ID
								ORDER BY ttCD.dbid);

		END;

	END;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate Lock Details' Database Name / Object Name / Index Name
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Lock = 0
	begin

		set @Database_ID = (select top (1) ttLKD.rsc_dbid
							from dbo.#temp_lock_details as ttLKD
							order by ttLKD.rsc_dbid);


		WHILE @Database_ID IS NOT NULL
		BEGIN

			set @SQL_String = N'
				USE [' + (select ttDB.database_name
						  from dbo.#temp_databases as ttDB
						  where ttDB.database_id = @Database_ID) + N']


				UPDATE
					ttLKD
				SET
					 ttLKD.[object_name] = N''['' + S.name + N''].['' + AO.name + N'']''
					,ttLKD.index_name = I.name
				FROM
					dbo.#temp_lock_details ttLKD
					LEFT JOIN sys.all_objects AO ON AO.[object_id] = ttLKD.rsc_objid
					LEFT JOIN sys.schemas S ON S.[schema_id] = AO.[schema_id]
					LEFT JOIN sys.indexes I ON I.[object_id] = ttLKD.rsc_objid
						AND I.index_id = ttLKD.rsc_indid
				WHERE
					ttLKD.rsc_dbid = ' + CONVERT(nvarchar(11), @Database_ID) + N'
			 ';


			if @SQL_String is not null
			begin

				set lock_timeout 5;


				begin try

					execute (@SQL_String);
				end try
				begin catch
				end catch;


				SET LOCK_TIMEOUT-1;

			END;


			SET @Database_ID = (SELECT TOP (1) ttLKD.rsc_dbid
								FROM dbo.#temp_lock_details AS ttLKD
								WHERE ttLKD.rsc_dbid > @Database_ID
								ORDER BY ttLKD.rsc_dbid);

		END;

	END;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Identify False Positive Blocking Cause By Timing Issues
	-----------------------------------------------------------------------------------------------------------------------------

	select ttCD.session_id,
		   case
			   when caCB.matches_filter_criteria = 0
					and caCB.is_truly_blocked = 0
					and caCB.is_truly_blocking = 0 then N'D'
				else N'U'
		   end as modification_type
	into dbo.#temp_false_positive_blocking
	from dbo.#temp_core_data as ttCD
		 left join dbo.#temp_core_data as ttXCD on ttXCD.session_id = ttCD.blocking_session_id
		 left join (select distinct 
						   ttCD.blocking_session_id
					from dbo.#temp_core_data as ttCD) as sqBS on sqBS.blocking_session_id = ttCD.session_id
		 cross apply (select case
								 when @Filter_Blocked = 1 then 0
								 when ISNULL(ttCD.database_name, N'----------') <> @Database_Name then 0
								 when @Filter_Active = 1
									  and case
											  when @Filter_Sleeping = 0
												   and ttCD.open_tran > 0 then N''
										  else ttCD.status_session
										  end in(N'dormant', N'sleeping') then 0
								 when @Filter_System = 1
									  and ttCD.is_user_process <> 1 then 0
								 when ISNULL(ttCD.nt_user_name, N'') <> @Login
									  and ttCD.login_name <> @Login then 0
								 when ttCD.session_id <> @SPID then 0
							 else 1
							 end as matches_filter_criteria,
							 case
								 when ttXCD.session_id is not null then 1
									else 0
							 end as is_truly_blocked,
							 case
								 when sqBS.blocking_session_id is not null then 1
									else 0
							 end as is_truly_blocking) as caCB
	where caCB.matches_filter_criteria = 0
		  and caCB.is_truly_blocked = 0
		  and caCB.is_truly_blocking = 0
		  or ( caCB.matches_filter_criteria = 1
			   or caCB.is_truly_blocking = 1
			 )
		  and caCB.is_truly_blocked = 0
		  and NULLIF(ttCD.blocking_session_id, 0) is not null;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Delete: Remove False Positives Which Meet Neither Filter Criteria Nor Block Chain Dependencies
	-----------------------------------------------------------------------------------------------------------------------------

	delete ttCD
	from dbo.#temp_core_data ttCD
	where exists (select *
				  from dbo.#temp_false_positive_blocking as ttFPB
				  where ttFPB.modification_type = N'D'
						and ttFPB.session_id = ttCD.session_id);


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Update False Positives Which Meet Either Filter Criteria And / Or Block Chain Dependencies
	-----------------------------------------------------------------------------------------------------------------------------

	update ttCD
	set ttCD.blocking_session_id = null
	from dbo.#temp_core_data ttCD
	where exists (select *
				  from dbo.#temp_false_positive_blocking as ttFPB
				  where ttFPB.modification_type = N'U'
						and ttFPB.session_id = ttCD.session_id);


	if OBJECT_ID(N'tempdb.dbo.#temp_false_positive_blocking', N'U') is not null
	begin

		drop table dbo.#temp_false_positive_blocking;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Identify Blocking SPIDs Which Are Deadlocking
	-----------------------------------------------------------------------------------------------------------------------------

	select sqBL.session_id, 
		   sqBL.blocking_session_id
	into dbo.#temp_deadlocking
	from (select ttCD.session_id, 
				 ttCD.blocking_session_id
		  from dbo.#temp_core_data as ttCD
		  where ttCD.blocking_session_id <> 0
				and ttCD.session_id <> ttCD.blocking_session_id
		  union all
		  select ttCD.blocking_session_id as session_id, 
				 ttCD.session_id as blocking_session_id
		  from dbo.#temp_core_data as ttCD
		  where ttCD.blocking_session_id <> 0
				and ttCD.session_id <> ttCD.blocking_session_id) as sqBL
	group by sqBL.session_id, 
			 sqBL.blocking_session_id
	having COUNT(*) > 1;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Insert: Identify Queries Running In Parallel With Threads Waiting For Others To Complete
	-----------------------------------------------------------------------------------------------------------------------------

	select ttCD.session_id
	into dbo.#temp_parallelism
	from dbo.#temp_core_data as ttCD
	where ttCD.blocking_session_id <> 0
		  and ttCD.session_id = ttCD.blocking_session_id;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Remove Specific Blocking Session IDs From The Main Blocking Group
	-----------------------------------------------------------------------------------------------------------------------------

	update ttCD
	set ttCD.blocking_session_id = null
	from dbo.#temp_core_data ttCD
	where ttCD.blocking_session_id = 0
		  or exists (select *
					 from dbo.#temp_deadlocking as ttD
					 where ttD.session_id = ttCD.session_id)
		  or exists (select *
					 from dbo.#temp_parallelism as ttP
					 where ttP.session_id = ttCD.session_id);


	-----------------------------------------------------------------------------------------------------------------------------
	--	Main Query: Final Display / Output
	-----------------------------------------------------------------------------------------------------------------------------

	SELECT caFL.spid AS SPID, 
		   ISNULL(ttCD.database_name, N'----------') AS Database_Name, 
		   REPLICATE(N' ', 5) + CASE
									WHEN caFL.status_session = N'BACKGROUND' THEN N'---'
									WHEN caFL.status_session IN(N'dormant', N'sleeping')
										 AND ttCD.open_tran = 0 THEN N''
									WHEN caFL.status_session IN(N'dormant', N'sleeping')
										 AND ttCD.open_tran > 0 THEN N'•'
									WHEN caFL.status_session IN(N'PENDING', N'PRECONNECT', N'RUNNABLE', N'SPINLOOP', N'SUSPENDED') THEN N'[]'
									WHEN caFL.status_session IN(N'ROLLBACK', N'RUNNING') THEN N'X'
								ELSE N'N/A'
								END AS Running,
		   CASE
			   WHEN ttD.session_id IS NULL
					AND caFL.blocking IS NULL
					AND ttCD.blocking_session_id IS NULL
					AND ttP.session_id IS NULL THEN N''
									   ELSE ISNULL(caCP.deadlocking_spid + caCP.separator_01, N'') + ISNULL(caCP.blocking_spids + caCP.separator_02, N'') + ISNULL(caCP.blocked_by_spid + caCP.separator_03, N'') + ISNULL(caCP.parallelism_spid, N'')
		   END AS Blocking, 
		   caFL.status_session + N' -> ' + ISNULL(caFL.status_request, N'N/A') AS status, 
		   ISNULL(ISNULL(ttCD.object_name, N'Database ID: ' + CONVERT(NVARCHAR(11), ttCD.dbid) + N', Object ID: ' + CONVERT(NVARCHAR(11), ttCD.objectid)), N'') AS Object_Name, 
		   ISNULL(ttCD.command, N'awaiting command') AS Command, 
		   ISNULL(CONVERT(NVARCHAR(11), ttCD.threads), N'') AS Threads, 
		   ISNULL(ttCD.[text], N'') AS SQL_Statement_Batch, 
		   caCP.sql_statement_current AS SQL_Statement_Current,
		   CASE ttCD.transaction_isolation_level
			   WHEN 0 THEN N'UNSPECIFIED'
			   WHEN 1 THEN N'READ UNCOMMITTED'
			   WHEN 2 THEN N'READ COMMITTED'
			   WHEN 3 THEN N'REPEATABLE READ'
			   WHEN 4 THEN N'SERIALIZABLE'
			   WHEN 5 THEN N'SNAPSHOT'
										 ELSE N'N/A'
		   END AS Isolation_Level, 
		   ISNULL(CONVERT(NVARCHAR(15), ( NULLIF(caFL.wait_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, NULLIF(caFL.wait_time, 0) / 1000, 0), 108), N'') AS Wait_Time, 
		   ISNULL(ttCD.wait_type, N'') AS Wait_Type, 
		   ISNULL(ttCD.last_wait_type, N'') AS Last_Wait_Type, 
		   ISNULL(CONVERT(NVARCHAR(15), ( NULLIF(caFL.total_elapsed_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, NULLIF(caFL.total_elapsed_time, 0) / 1000, 0), 108), N'') AS Elapsed_Time, 
		   ISNULL(CONVERT(NVARCHAR(15), ( NULLIF(ttCD.cpu_time_total, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, NULLIF(ttCD.cpu_time_total, 0) / 1000, 0), 108), N'') AS CPU_Total, 
		   ISNULL(CONVERT(NVARCHAR(15), ( NULLIF(ttCD.cpu_time_current, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, NULLIF(ttCD.cpu_time_current, 0) / 1000, 0), 108), N'') AS CPU_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.logical_reads_total, 0)), 1)), 4, 23)), N'') AS Logical_Reads_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.logical_reads_current, 0)), 1)), 4, 23)), N'') AS Logical_Reads_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.reads_total, 0)), 1)), 4, 23)), N'') AS Physical_Reads_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.reads_current, 0)), 1)), 4, 23)), N'') AS Physical_Reads_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.writes_total, 0)), 1)), 4, 23)), N'') AS Writes_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.writes_current, 0)), 1)), 4, 23)), N'') AS Writes_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttCD.row_count, 0)), 1)), 4, 23)), N'') AS Last_Row_Count, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, ( NULLIF(ttCD.granted_query_memory, 0) * 8 ) / 1024.0), 1), N'') AS Allocated_Memory_MB, 
		   ISNULL(CONVERT(NVARCHAR(11), NULLIF(ttCD.memory_usage, 0)), N'') AS Pages_Used, 
		   ISNULL(CONVERT(NVARCHAR(6), NULLIF(ttCD.open_tran, 0)), N'') AS Transactions, 
		   ISNULL(CONVERT(NVARCHAR(20), NULLIF(ttCD.transaction_id, 0)), N'') AS Transaction_ID, 
		   ISNULL(CASE
					  WHEN ttCD.transaction_begin_time > @Date_Now THEN N'0 Day(s) 00:00:00'
				  ELSE CONVERT(NVARCHAR(15), DATEDIFF(SECOND, ttCD.transaction_begin_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, ttCD.transaction_begin_time, @Date_Now), 0), 108)
				  END, N'') AS Transaction_Time,
		   CASE
			   WHEN ttCD.transaction_type IS NULL THEN N''
			   WHEN ttCD.transaction_type = 1 THEN N'Read / Write'
			   WHEN ttCD.transaction_type = 2 THEN N'Read-Only'
			   WHEN ttCD.transaction_type = 3 THEN N'System'
			   WHEN ttCD.transaction_type = 4 THEN N'Distributed'
							   ELSE N'N/A'
		   END AS Transaction_Type,
		   CASE
			   WHEN ttCD.transaction_state IS NULL THEN N''
			   WHEN ttCD.transaction_state = 0 THEN N'Initializing'
			   WHEN ttCD.transaction_state = 1 THEN N'Initialized / Not Started'
			   WHEN ttCD.transaction_state = 2 THEN N'Active'
			   WHEN ttCD.transaction_state = 3 THEN N'Ended (Read-Only Transaction)'
			   WHEN ttCD.transaction_state = 4 THEN N'Commit Initiated (Distributed Transaction)'
			   WHEN ttCD.transaction_state = 5 THEN N'Prepared / Waiting Resolution'
			   WHEN ttCD.transaction_state = 6 THEN N'Committed'
			   WHEN ttCD.transaction_state = 7 THEN N'Rolling Back'
			   WHEN ttCD.transaction_state = 8 THEN N'Rolled Back'
				  ELSE N'N/A'
		   END AS Transaction_State, 
		   ISNULL(CONVERT(NVARCHAR(11), NULLIF(ttCD.nest_level, 0)), N'') AS Nesting_Level, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, ( NULLIF(ttCD.tempdb_page_allocation_session, 0) * 8 ) / 1024.0), 1), N'') AS TempDB_Session_Total_MB, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, ( ( NULLIF(ttCD.tempdb_page_allocation_session, 0) - ttCD.tempdb_page_deallocation_session ) * 8 ) / 1024.0), 1), N'') AS TempDB_Session_Current_MB, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, ( NULLIF(ttCD.tempdb_page_allocation_task, 0) * 8 ) / 1024.0), 1), N'') AS TempDB_Task_Total_MB, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, ( ( NULLIF(ttCD.tempdb_page_allocation_task, 0) - ttCD.tempdb_page_deallocation_task ) * 8 ) / 1024.0), 1), N'') AS TempDB_Task_Current_MB, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(sqLS.log_database_count, 0)), 1)), 4, 23)), N'') AS Log_Database_Count, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(sqLS.log_record_count_all, 0)), 1)), 4, 23)), N'') AS Log_Records_All, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(sqLS.log_bytes_reserved_all, 0) / 1048576.0), 1), N'') AS Log_Reserved_MB_All, 
		   ISNULL(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(sqLS.log_bytes_used_all, 0) / 1048576.0), 1), N'') AS Log_Used_MB_All, 
		   ISNULL( (SELECT ISNULL(CASE
									  WHEN ttLGD.database_id = 32767 THEN N'mssqlsystemresource (Hidden Resource Database)'
								  ELSE ttDB.database_name
								  END, N'N/A') + ISNULL(@CR_LF_Tab + LEFT(N'Transaction Time' + REPLICATE(N' ', 25), 25) + N': ' + CASE
																																	   WHEN ttLGD.database_transaction_begin_time > @Date_Now THEN N'0 Day(s) 00:00:00'
																																   ELSE CONVERT(NVARCHAR(15), DATEDIFF(SECOND, ttLGD.database_transaction_begin_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, ttLGD.database_transaction_begin_time, @Date_Now), 0), 108)
																																   END, N'') + @CR_LF_Tab + LEFT(N'Transaction Type' + REPLICATE(N' ', 25), 25) + N': ' + CASE ttLGD.database_transaction_type
																																																							  WHEN 1 THEN N'Read / Write'
																																																							  WHEN 2 THEN N'Read-Only'
																																																							  WHEN 3 THEN N'System'
																																																						  ELSE N'N/A'
																																																						  END + @CR_LF_Tab + LEFT(N'Transaction State' + REPLICATE(N' ', 25), 25) + N': ' + CASE ttLGD.database_transaction_state
																																																																												WHEN 1 THEN N'Not Initialized'
																																																																												WHEN 3 THEN N'No Log Records Generated'
																																																																												WHEN 4 THEN N'Log Records Generated'
																																																																												WHEN 5 THEN N'Prepared'
																																																																												WHEN 10 THEN N'Committed'
																																																																												WHEN 11 THEN N'Rolled Back'
																																																																												WHEN 12 THEN N'Committing / Log Records Generating'
																																																																											ELSE N'N/A'
																																																																											END + ISNULL(@CR_LF_Tab + LEFT(N'Log Records Generated' + REPLICATE(N' ', 25), 25) + N': ' + REVERSE(SUBSTRING(REVERSE(CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttLGD.database_transaction_log_record_count, 0)), 1)), 4, 23)), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Reserved' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttLGD.database_transaction_log_bytes_reserved, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Used' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttLGD.database_transaction_log_bytes_used, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Reserved (System)' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttLGD.database_transaction_log_bytes_reserved_system, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Used (System)' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(NVARCHAR(23), CONVERT(MONEY, NULLIF(ttLGD.database_transaction_log_bytes_used_system, 0) / 1048576.0), 1), N'') + @CR_LF + @CR_LF AS [text()]
					FROM dbo.#temp_log_details AS ttLGD
						 LEFT JOIN dbo.#temp_databases AS ttDB ON ttDB.database_id = ttLGD.database_id
					WHERE ttLGD.transaction_id = ttCD.transaction_id
					ORDER BY CASE
								 WHEN ttLGD.database_id = 32767 THEN N'mssqlsystemresource (Hidden Resource Database)'
							 ELSE ttDB.database_name
							 END FOR XML PATH(N''), TYPE), N'') AS Log_Details,
		   CASE
			   WHEN ttCD.lock_timeout = -1 THEN N'Wait Forever'
			   WHEN ttCD.lock_timeout = 0 THEN N'Immediately'
																   ELSE CONVERT(NVARCHAR(11), CONVERT(DECIMAL(18, 2), ROUND(ttCD.lock_timeout / 1000.0, 2)))
		   END AS Lock_Timeout_Seconds, 
		   ISNULL( (SELECT ISNULL(N'Database ' + ISNULL(N'Name: ' + ttDB.database_name, N'ID: ' + CONVERT(NVARCHAR(11), ttLKD.rsc_dbid)), N'') + ISNULL(N' ••• Object ' + ISNULL(N'Name: ' + ttLKD.object_name, N'ID: ' + CONVERT(NVARCHAR(11), NULLIF(ttLKD.rsc_objid, 0))), N'') + ISNULL(N' ••• Index ' + ISNULL(N'Name: ' + ttLKD.index_name, N'ID: ' + CONVERT(NVARCHAR(11), NULLIF(ttLKD.rsc_indid, 0))), N'') + @CR_LF_Tab + N'Resource Type: ' + CASE ttLKD.rsc_type
																																																																																																															 WHEN 1 THEN N'NULL Resource'
																																																																																																															 WHEN 2 THEN N'Database'
																																																																																																															 WHEN 3 THEN N'File'
																																																																																																															 WHEN 4 THEN N'Index'
																																																																																																															 WHEN 5 THEN N'Object'
																																																																																																															 WHEN 6 THEN N'Page'
																																																																																																															 WHEN 7 THEN N'Key'
																																																																																																															 WHEN 8 THEN N'Extent'
																																																																																																															 WHEN 9 THEN N'Row ID (RID)'
																																																																																																															 WHEN 10 THEN N'Application'
																																																																																																															 WHEN 11 THEN N'Metadata'
																																																																																																															 WHEN 12 THEN N'Heap Or B-Tree (HoBt)'
																																																																																																															 WHEN 13 THEN N'Allocation Unit'
																																																																																																														 ELSE N'N/A'
																																																																																																														 END + @CR_LF_Tab + N'Request Mode: ' + CASE ttLKD.req_mode
																																																																																																																									WHEN 0 THEN N'NULL Resource'
																																																																																																																									WHEN 1 THEN N'Sch-S (Schema Stability)'
																																																																																																																									WHEN 2 THEN N'Sch-M (Schema Modification)'
																																																																																																																									WHEN 3 THEN N'S (Shared)'
																																																																																																																									WHEN 4 THEN N'U (Update)'
																																																																																																																									WHEN 5 THEN N'X (Exclusive)'
																																																																																																																									WHEN 6 THEN N'IS (Intent Shared)'
																																																																																																																									WHEN 7 THEN N'IU (Intent Update)'
																																																																																																																									WHEN 8 THEN N'IX (Intent Exclusive)'
																																																																																																																									WHEN 9 THEN N'SIU (Shared Intent Update)'
																																																																																																																									WHEN 10 THEN N'SIX (Shared Intent Exclusive)'
																																																																																																																									WHEN 11 THEN N'UIX (Update Intent Exclusive)'
																																																																																																																									WHEN 12 THEN N'BU (Bulk Update)'
																																																																																																																									WHEN 13 THEN N'RangeS-S (Serializable Range Scan)'
																																																																																																																									WHEN 14 THEN N'RangeS-U (Serializable Update Scan)'
																																																																																																																									WHEN 15 THEN N'RangeI-N (Insert Key-Range / NULL Resource Lock)'
																																																																																																																									WHEN 16 THEN N'RangeI-S (Overlap Of RangeI-N / S Locks)'
																																																																																																																									WHEN 17 THEN N'RangeI-U (Overlap Of RangeI-N / U Locks)'
																																																																																																																									WHEN 18 THEN N'RangeI-X (Overlap Of RangeI-N / X Locks)'
																																																																																																																									WHEN 19 THEN N'RangeX-S (Overlap Of RangeI-N / RangeS-S Locks)'
																																																																																																																									WHEN 20 THEN N'RangeX-U (Overlap Of RangeI-N / RangeS-U Locks)'
																																																																																																																									WHEN 21 THEN N'RangeX-X (Exclusive Key-Range / Exclusive Resource Lock)'
																																																																																																																								ELSE N'N/A'
																																																																																																																								END + @CR_LF_Tab + N'Request Status: ' + CASE ttLKD.req_status
																																																																																																																																			 WHEN 1 THEN N'Granted'
																																																																																																																																			 WHEN 2 THEN N'Convert'
																																																																																																																																			 WHEN 3 THEN N'Wait'
																																																																																																																																			 WHEN 4 THEN N'RELN'
																																																																																																																																			 WHEN 5 THEN N'BLCKN'
																																																																																																																																		 ELSE N'N/A'
																																																																																																																																		 END + @CR_LF_Tab + N'Request Owner Type: ' + CASE ttLKD.req_ownertype
																																																																																																																																														  WHEN 1 THEN N'Transaction'
																																																																																																																																														  WHEN 2 THEN N'Cursor'
																																																																																																																																														  WHEN 3 THEN N'User Session'
																																																																																																																																														  WHEN 4 THEN N'Shared Transaction Workspace'
																																																																																																																																														  WHEN 5 THEN N'Exclusive Transaction Workspace'
																																																																																																																																														  WHEN 6 THEN N'WFR'
																																																																																																																																													  ELSE N'N/A'
																																																																																																																																													  END + @CR_LF_Tab + N'ECID: ' + CONVERT(NVARCHAR(11), ttLKD.req_ecid) + @CR_LF_Tab + N'Request Reference Count: ' + CONVERT(NVARCHAR(6), ttLKD.req_refcnt) + @CR_LF + @CR_LF AS [text()]
					FROM dbo.#temp_lock_details AS ttLKD
						 LEFT JOIN dbo.#temp_databases AS ttDB ON ttDB.database_id = ttLKD.rsc_dbid
					WHERE ttLKD.req_spid = ttCD.session_id
					ORDER BY ttDB.database_name, 
							 ttLKD.object_name, 
							 ttLKD.index_name, 
							 ttLKD.rsc_type, 
							 ttLKD.req_mode, 
							 ttLKD.req_status, 
							 ttLKD.req_ownertype, 
							 ttLKD.req_ecid, 
							 ttLKD.req_refcnt FOR XML PATH(N''), TYPE), N'') AS Lock_Details,
		   CASE
			   WHEN ttCD.deadlock_priority <= -5 THEN N'Low'
			   WHEN ttCD.deadlock_priority >= 5 THEN N'High'
		   ELSE N'Normal'
		   END + N': ' + CONVERT(NVARCHAR(3), ttCD.deadlock_priority) AS Deadlock_Priority, 
		   CONVERT(XML, ISNULL(CASE
								   WHEN @Exclude_SQL = 1
										OR @Exclude_SQL_XML = 1 THEN N''
							   ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ttCD.[text] COLLATE Latin1_General_BIN, NCHAR(0) COLLATE Latin1_General_BIN, N''), N'&', @Ampersand + N'amp;'), N'<', @Ampersand + N'lt;'), N'>', @Ampersand + N'gt;'), N'"', @Ampersand + N'quot;'), N'''', @Ampersand + N'#39;')
							   END, N'')) AS SQL_Statement_Batch_XML, 
		   CONVERT(XML,
				   CASE
					   WHEN @Exclude_SQL = 1
							OR @Exclude_SQL_XML = 1 THEN N''
				   ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(NULLIF(caCP.sql_statement_current, N'<< Derived Statement >>'), N'<< Single Statement >>'), ttCD.[text]) COLLATE Latin1_General_BIN, NCHAR(0) COLLATE Latin1_General_BIN, N''), N'&', @Ampersand + N'amp;'), N'<', @Ampersand + N'lt;'), N'>', @Ampersand + N'gt;'), N'"', @Ampersand + N'quot;'), N'''', @Ampersand + N'#39;')
				   END) AS SQL_Statement_Current_XML, 
		   ISNULL(CONVERT(NVARCHAR(130), ttCD.sql_handle, 1), N'') AS SQL_Handle, 
		   ISNULL(ttCD.query_plan, N'') AS Query_Plan, 
		   ISNULL(CONVERT(NVARCHAR(130), ttCD.plan_handle, 1), N'') AS Plan_Handle, 
		   ISNULL(CASE
					  WHEN caFL.login_time > @Date_Now THEN N'0 Day(s) 00:00:00'
				  ELSE CONVERT(NVARCHAR(15), DATEDIFF(SECOND, caFL.login_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.login_time, @Date_Now), 0), 108)
				  END, N'') AS Since_SPID_Login, 
		   ISNULL(CASE
					  WHEN caFL.last_request_start_time > @Date_Now THEN N'0 Day(s) 00:00:00'
				  ELSE CONVERT(NVARCHAR(15), DATEDIFF(SECOND, caFL.last_request_start_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.last_request_start_time, @Date_Now), 0), 108)
				  END, N'') AS Since_Last_Batch_Start, 
		   ISNULL(CASE
					  WHEN caFL.last_request_end_time > @Date_Now THEN N'0 Day(s) 00:00:00'
				  ELSE CONVERT(NVARCHAR(15), DATEDIFF(SECOND, caFL.last_request_end_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.last_request_end_time, @Date_Now), 0), 108)
				  END, N'') AS Since_Last_Batch_End, 
		   ISNULL(CONVERT(NVARCHAR(7), CONVERT(DECIMAL(5, 2), NULLIF(ttCD.percent_complete, 0))), N'') AS Command_Pct, 
		   ISNULL(CASE
					  WHEN ttCD.percent_complete = 0 THEN N''
				  ELSE CONVERT(NVARCHAR(19), DATEADD(MILLISECOND, ttCD.estimated_completion_time, @Date_Now), 120)
				  END, N'') AS Command_Completion, 
		   ISNULL(CONVERT(NVARCHAR(15), ( NULLIF(ttCD.estimated_completion_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(NVARCHAR(8), DATEADD(SECOND, NULLIF(ttCD.estimated_completion_time, 0) / 1000, 0), 108), N'') AS Command_Time_Left, 
		   ISNULL(ttCD.host_name, N'') AS Host_Name, 
		   caFL.login_id AS Login_ID,
		   CASE
			   WHEN ttCD.login_name = N'sa' THEN N'<< System Administrator >>'
							ELSE ttCD.login_name
		   END AS Login_Name, 
		   ISNULL(REPLACE(REPLACE(ttCD.program_name, N'Microsoft® Windows® Operating System', N'Windows OS'), N'Microsoft', N'MS'), N'') AS Application_Description,
		   CASE ttCD.is_user_process
			   WHEN 1 THEN N''
																																			ELSE N'Yes'
		   END AS System_Process, 
		   caFL.spid AS SPID
	FROM dbo.#temp_core_data AS ttCD
		 LEFT JOIN dbo.#temp_deadlocking AS ttD ON ttD.session_id = ttCD.session_id
		 LEFT JOIN dbo.#temp_parallelism AS ttP ON ttP.session_id = ttCD.session_id
		 LEFT JOIN (SELECT ttLGD.transaction_id, 
						   COUNT(*) AS log_database_count, 
						   SUM(ttLGD.database_transaction_log_record_count) AS log_record_count_all, 
						   SUM(ttLGD.database_transaction_log_bytes_reserved + ttLGD.database_transaction_log_bytes_reserved_system) AS log_bytes_reserved_all, 
						   SUM(ttLGD.database_transaction_log_bytes_used + ttLGD.database_transaction_log_bytes_used_system) AS log_bytes_used_all
					FROM dbo.#temp_log_details AS ttLGD
					GROUP BY ttLGD.transaction_id) AS sqLS ON sqLS.transaction_id = ttCD.transaction_id
		 CROSS APPLY (SELECT CONVERT(NVARCHAR(6), ttCD.session_id) + ISNULL(N' ' + CASE
																					   WHEN ttCD.session_id = @@SPID THEN N'••'
																					   WHEN ttCD.is_user_process = 0 THEN N'•'
																				   END, N'') AS spid, 
							 STUFF( (SELECT N', ' + CONVERT(NVARCHAR(MAX), ttXCD.session_id) AS [text()]
									 FROM dbo.#temp_core_data AS ttXCD
									 WHERE ttXCD.blocking_session_id = ttCD.session_id
									 ORDER BY ttXCD.session_id FOR XML PATH(N'')), 1, 2, N'') AS blocking,
							 CASE
								 WHEN ttCD.status_session NOT IN(N'dormant', N'sleeping') THEN UPPER(ttCD.status_session)
																								 ELSE ttCD.status_session
							 END AS status_session,
							 CASE
								 WHEN ttCD.status_request <> N'sleeping' THEN UPPER(ttCD.status_request)
									ELSE ttCD.status_request
							 END AS status_request, 
							 CONVERT(BIGINT,
									 CASE
										 WHEN ttCD.wait_time < 0 THEN 2147483647 + 2147483649 + ttCD.wait_time
									 ELSE ttCD.wait_time
									 END) AS wait_time, 
							 CONVERT(BIGINT,
									 CASE
										 WHEN ttCD.total_elapsed_time < 0 THEN 2147483647 + 2147483649 + ttCD.total_elapsed_time
									 ELSE ttCD.total_elapsed_time
									 END) AS total_elapsed_time,
							 CASE
								 WHEN ttCD.login_time_sessions = N'1900-01-01 00:00:00.000' THEN ttCD.login_time_processes
											 ELSE ttCD.login_time_sessions
							 END AS login_time,
							 CASE
								 WHEN ttCD.last_request_start_time = N'1900-01-01 00:00:00.000' THEN NULL
									ELSE ttCD.last_request_start_time
							 END AS last_request_start_time,
							 CASE
								 WHEN ttCD.last_request_end_time = N'1900-01-01 00:00:00.000' THEN ttCD.last_batch
									ELSE ttCD.last_request_end_time
							 END AS last_request_end_time, 
							 ISNULL(NULLIF(ttCD.nt_user_name, N''), ttCD.login_name) AS login_id) AS caFL
		 CROSS APPLY (SELECT N'[ Deadlocking ] : ' + CONVERT(NVARCHAR(6), ttD.blocking_session_id) AS deadlocking_spid,
							 CASE
								 WHEN caFL.blocking IS NOT NULL
									  OR ttCD.blocking_session_id IS NOT NULL
									  OR ttP.session_id IS NOT NULL THEN N' •• '
																									  ELSE N''
							 END AS separator_01, 
							 N'< Blocking > : ' + caFL.blocking AS blocking_spids,
							 CASE
								 WHEN ttCD.blocking_session_id IS NOT NULL
									  OR ttP.session_id IS NOT NULL THEN N' •• '
																   ELSE N''
							 END AS separator_02, 
							 N'> Blocked By < : ' + CONVERT(NVARCHAR(6), ttCD.blocking_session_id) AS blocked_by_spid,
							 CASE
								 WHEN ttP.session_id IS NOT NULL THEN N' •• '
																									  ELSE N''
							 END AS separator_03, 
							 N'( Parallelism ) : ' + CONVERT(NVARCHAR(6), ttP.session_id) AS parallelism_spid, 
							 ISNULL(CASE
										WHEN ttCD.[text] IS NULL THEN N''
										WHEN caFL.status_session = N'sleeping'
											 AND caFL.status_request IS NULL THEN N''
										WHEN ttCD.stmt_start < 1
											 AND ttCD.stmt_end = -1 THEN N'<< Single Statement >>'
										WHEN( DATALENGTH(ttCD.[text]) - ttCD.stmt_start ) / 2 < 0
											AND ttCD.stmt_end = -1 THEN N'<< Derived Statement >>'
										WHEN ttCD.stmt_end = -1 THEN SUBSTRING(ttCD.[text], ttCD.stmt_start / 2 + 1, ( DATALENGTH(ttCD.[text]) - ttCD.stmt_start ) / 2 + 1)
									ELSE SUBSTRING(ttCD.[text], ttCD.stmt_start / 2 + 1, ( ttCD.stmt_end - ttCD.stmt_start ) / 2 + 1)
									END, N'') AS sql_statement_current) AS caCP
	ORDER BY CASE
				 WHEN ttD.blocking_session_id IS NOT NULL
					  AND caFL.blocking IS NULL THEN 1
				 WHEN ttD.blocking_session_id IS NOT NULL
					  AND caFL.blocking IS NOT NULL THEN 2
				 WHEN caFL.blocking IS NOT NULL
					  AND ttCD.blocking_session_id IS NULL THEN 3
				 WHEN caFL.blocking IS NOT NULL
					  AND ttCD.blocking_session_id IS NOT NULL THEN 4
				 WHEN ttCD.blocking_session_id IS NOT NULL THEN 5
				 WHEN ttP.session_id IS NOT NULL THEN 6
			 ELSE 7
			 END, 
			 ttCD.session_id;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Cleanup: Drop Any Remaining Temp Tables
	-----------------------------------------------------------------------------------------------------------------------------

	IF OBJECT_ID(N'tempdb.dbo.#temp_core_data', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_core_data;

	END;


	IF OBJECT_ID(N'tempdb.dbo.#temp_databases', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_databases;

	END;


	IF OBJECT_ID(N'tempdb.dbo.#temp_deadlocking', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_deadlocking;

	END;


	IF OBJECT_ID(N'tempdb.dbo.#temp_lock_details', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_lock_details;

	END;


	IF OBJECT_ID(N'tempdb.dbo.#temp_log_details', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_log_details;

	END;


	IF OBJECT_ID(N'tempdb.dbo.#temp_parallelism', N'U') IS NOT NULL
	BEGIN

		DROP TABLE dbo.#temp_parallelism;

	END;
END;
GO


