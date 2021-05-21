/*******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************
It can be run as is (example: EXECUTE dbo.sp_who5) or with optional input filter parameters:

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
	@Exclude_TXN     : Suppress transaction details from the output (also suppresses log details due to an interdependency; can increases 
						procedure performance on busy servers; defaulted to 1)
	@Login           : Limit the result set to a specific Windows user name (if populated, otherwise by SQL Server login name)
	@SPID            : Limit the result set to a specific session


Notes:

	Blocking / blocked sessions will always be displayed first in the result set (when applicable)

Output:

	SPID                      : System Process ID
	Database_Name             : Database context of the session
	Running                   : Indicates if the session is executing (X), waiting ([]), inactive (blank), inactive with open transactions (•), 
								a background task (--), or not defined (N/A)
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
*******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/

set transaction isolation level read uncommitted;
set nocount on;

-----------------------------------------------------------------------------------------------------------------------------
--	Error Trapping: Check If Procedure Already Exists And Create Shell If Applicable
-----------------------------------------------------------------------------------------------------------------------------

if OBJECT_ID(N'dbo.sp_who5', N'P') is null
begin

	execute (N'CREATE PROCEDURE dbo.sp_who5 AS SELECT 1 AS shell');

end;
go

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

alter procedure dbo.sp_who5 
	@Filter as          nvarchar(5)   = null, 
	@Database_Name as   nvarchar(512) = null, 
	@Exclude_Lock as    bit           = 1, 
	@Exclude_Log as     bit           = 1, 
	@Exclude_Plan as    bit           = 1, 
	@Exclude_SQL as     bit           = 0, 
	@Exclude_SQL_XML as bit           = 1, 
	@Exclude_TXN as     bit           = 1, 
	@Login as           nvarchar(128) = null, 
	@SPID as            smallint      = null
as
begin

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


		return;

	end;


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


		begin try

			set @Database_ID = (select top (1) DB.database_id
								from master.sys.databases as DB
								where DB.database_id > @Database_ID
								order by DB.database_id);
		end try
		begin catch

			set @Database_ID = @Database_ID + 1;
		end catch;

	end;


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


		while @SQL_Handle is not null
		begin

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


			set @SQL_Handle = (select top (1) ttCD.sql_handle
							   from dbo.#temp_core_data as ttCD
							   where ttCD.sql_handle is not null
									 and ttCD.sql_handle > @SQL_Handle
							   order by ttCD.sql_handle);

		end;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate Query Plan Data And Object Details
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Plan = 0
	begin

		set @Plan_Handle = (select top (1) ttCD.plan_handle
							from dbo.#temp_core_data as ttCD
							where ttCD.plan_handle is not null
							order by ttCD.plan_handle);


		while @Plan_Handle is not null
		begin

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


			set @Plan_Handle = (select top (1) ttCD.plan_handle
								from dbo.#temp_core_data as ttCD
								where ttCD.plan_handle is not null
									  and ttCD.plan_handle > @Plan_Handle
								order by ttCD.plan_handle);

		end;

	end;


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


		while @Database_ID is not null
		begin

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


				set lock_timeout-1;

			end;


			set @Database_ID = (select top (1) ttCD.dbid
								from dbo.#temp_core_data as ttCD
								where ttCD.dbid is not null
									  and ttCD.objectid is not null
									  and ttCD.dbid > @Database_ID
								order by ttCD.dbid);

		end;

	end;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Table Update: Attempt To Populate Lock Details' Database Name / Object Name / Index Name
	-----------------------------------------------------------------------------------------------------------------------------

	if @Exclude_Lock = 0
	begin

		set @Database_ID = (select top (1) ttLKD.rsc_dbid
							from dbo.#temp_lock_details as ttLKD
							order by ttLKD.rsc_dbid);


		while @Database_ID is not null
		begin

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


				set lock_timeout-1;

			end;


			set @Database_ID = (select top (1) ttLKD.rsc_dbid
								from dbo.#temp_lock_details as ttLKD
								where ttLKD.rsc_dbid > @Database_ID
								order by ttLKD.rsc_dbid);

		end;

	end;


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

	select caFL.spid as SPID, 
		   ISNULL(ttCD.database_name, N'----------') as Database_Name, 
		   REPLICATE(N' ', 5) + case
									when caFL.status_session = N'BACKGROUND' then N'---'
									when caFL.status_session in(N'dormant', N'sleeping')
										 and ttCD.open_tran = 0 then N''
									when caFL.status_session in(N'dormant', N'sleeping')
										 and ttCD.open_tran > 0 then N'•'
									when caFL.status_session in(N'PENDING', N'PRECONNECT', N'RUNNABLE', N'SPINLOOP', N'SUSPENDED') then N'[]'
									when caFL.status_session in(N'ROLLBACK', N'RUNNING') then N'X'
								else N'N/A'
								end as Running,
		   case
			   when ttD.session_id is null
					and caFL.blocking is null
					and ttCD.blocking_session_id is null
					and ttP.session_id is null then N''
									   else ISNULL(caCP.deadlocking_spid + caCP.separator_01, N'') + ISNULL(caCP.blocking_spids + caCP.separator_02, N'') + ISNULL(caCP.blocked_by_spid + caCP.separator_03, N'') + ISNULL(caCP.parallelism_spid, N'')
		   end as Blocking, 
		   caFL.status_session + N' -> ' + ISNULL(caFL.status_request, N'N/A') as status, 
		   ISNULL(ISNULL(ttCD.object_name, N'Database ID: ' + CONVERT(nvarchar(11), ttCD.dbid) + N', Object ID: ' + CONVERT(nvarchar(11), ttCD.objectid)), N'') as Object_Name, 
		   ISNULL(ttCD.command, N'awaiting command') as Command, 
		   ISNULL(CONVERT(nvarchar(11), ttCD.threads), N'') as Threads, 
		   ISNULL(ttCD.[text], N'') as SQL_Statement_Batch, 
		   caCP.sql_statement_current as SQL_Statement_Current,
		   case ttCD.transaction_isolation_level
			   when 0 then N'UNSPECIFIED'
			   when 1 then N'READ UNCOMMITTED'
			   when 2 then N'READ COMMITTED'
			   when 3 then N'REPEATABLE READ'
			   when 4 then N'SERIALIZABLE'
			   when 5 then N'SNAPSHOT'
										 else N'N/A'
		   end as Isolation_Level, 
		   ISNULL(CONVERT(nvarchar(15), ( NULLIF(caFL.wait_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, NULLIF(caFL.wait_time, 0) / 1000, 0), 108), N'') as Wait_Time, 
		   ISNULL(ttCD.wait_type, N'') as Wait_Type, 
		   ISNULL(ttCD.last_wait_type, N'') as Last_Wait_Type, 
		   ISNULL(CONVERT(nvarchar(15), ( NULLIF(caFL.total_elapsed_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, NULLIF(caFL.total_elapsed_time, 0) / 1000, 0), 108), N'') as Elapsed_Time, 
		   ISNULL(CONVERT(nvarchar(15), ( NULLIF(ttCD.cpu_time_total, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, NULLIF(ttCD.cpu_time_total, 0) / 1000, 0), 108), N'') as CPU_Total, 
		   ISNULL(CONVERT(nvarchar(15), ( NULLIF(ttCD.cpu_time_current, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, NULLIF(ttCD.cpu_time_current, 0) / 1000, 0), 108), N'') as CPU_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.logical_reads_total, 0)), 1)), 4, 23)), N'') as Logical_Reads_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.logical_reads_current, 0)), 1)), 4, 23)), N'') as Logical_Reads_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.reads_total, 0)), 1)), 4, 23)), N'') as Physical_Reads_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.reads_current, 0)), 1)), 4, 23)), N'') as Physical_Reads_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.writes_total, 0)), 1)), 4, 23)), N'') as Writes_Total, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.writes_current, 0)), 1)), 4, 23)), N'') as Writes_Current, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttCD.row_count, 0)), 1)), 4, 23)), N'') as Last_Row_Count, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, ( NULLIF(ttCD.granted_query_memory, 0) * 8 ) / 1024.0), 1), N'') as Allocated_Memory_MB, 
		   ISNULL(CONVERT(nvarchar(11), NULLIF(ttCD.memory_usage, 0)), N'') as Pages_Used, 
		   ISNULL(CONVERT(nvarchar(6), NULLIF(ttCD.open_tran, 0)), N'') as Transactions, 
		   ISNULL(CONVERT(nvarchar(20), NULLIF(ttCD.transaction_id, 0)), N'') as Transaction_ID, 
		   ISNULL(case
					  when ttCD.transaction_begin_time > @Date_Now then N'0 Day(s) 00:00:00'
				  else CONVERT(nvarchar(15), DATEDIFF(SECOND, ttCD.transaction_begin_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, DATEDIFF(SECOND, ttCD.transaction_begin_time, @Date_Now), 0), 108)
				  end, N'') as Transaction_Time,
		   case
			   when ttCD.transaction_type is null then N''
			   when ttCD.transaction_type = 1 then N'Read / Write'
			   when ttCD.transaction_type = 2 then N'Read-Only'
			   when ttCD.transaction_type = 3 then N'System'
			   when ttCD.transaction_type = 4 then N'Distributed'
							   else N'N/A'
		   end as Transaction_Type,
		   case
			   when ttCD.transaction_state is null then N''
			   when ttCD.transaction_state = 0 then N'Initializing'
			   when ttCD.transaction_state = 1 then N'Initialized / Not Started'
			   when ttCD.transaction_state = 2 then N'Active'
			   when ttCD.transaction_state = 3 then N'Ended (Read-Only Transaction)'
			   when ttCD.transaction_state = 4 then N'Commit Initiated (Distributed Transaction)'
			   when ttCD.transaction_state = 5 then N'Prepared / Waiting Resolution'
			   when ttCD.transaction_state = 6 then N'Committed'
			   when ttCD.transaction_state = 7 then N'Rolling Back'
			   when ttCD.transaction_state = 8 then N'Rolled Back'
				  else N'N/A'
		   end as Transaction_State, 
		   ISNULL(CONVERT(nvarchar(11), NULLIF(ttCD.nest_level, 0)), N'') as Nesting_Level, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, ( NULLIF(ttCD.tempdb_page_allocation_session, 0) * 8 ) / 1024.0), 1), N'') as TempDB_Session_Total_MB, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, ( ( NULLIF(ttCD.tempdb_page_allocation_session, 0) - ttCD.tempdb_page_deallocation_session ) * 8 ) / 1024.0), 1), N'') as TempDB_Session_Current_MB, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, ( NULLIF(ttCD.tempdb_page_allocation_task, 0) * 8 ) / 1024.0), 1), N'') as TempDB_Task_Total_MB, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, ( ( NULLIF(ttCD.tempdb_page_allocation_task, 0) - ttCD.tempdb_page_deallocation_task ) * 8 ) / 1024.0), 1), N'') as TempDB_Task_Current_MB, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(sqLS.log_database_count, 0)), 1)), 4, 23)), N'') as Log_Database_Count, 
		   ISNULL(REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(sqLS.log_record_count_all, 0)), 1)), 4, 23)), N'') as Log_Records_All, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, NULLIF(sqLS.log_bytes_reserved_all, 0) / 1048576.0), 1), N'') as Log_Reserved_MB_All, 
		   ISNULL(CONVERT(nvarchar(23), CONVERT(money, NULLIF(sqLS.log_bytes_used_all, 0) / 1048576.0), 1), N'') as Log_Used_MB_All, 
		   ISNULL( (select ISNULL(case
									  when ttLGD.database_id = 32767 then N'mssqlsystemresource (Hidden Resource Database)'
								  else ttDB.database_name
								  end, N'N/A') + ISNULL(@CR_LF_Tab + LEFT(N'Transaction Time' + REPLICATE(N' ', 25), 25) + N': ' + case
																																	   when ttLGD.database_transaction_begin_time > @Date_Now then N'0 Day(s) 00:00:00'
																																   else CONVERT(nvarchar(15), DATEDIFF(SECOND, ttLGD.database_transaction_begin_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, DATEDIFF(SECOND, ttLGD.database_transaction_begin_time, @Date_Now), 0), 108)
																																   end, N'') + @CR_LF_Tab + LEFT(N'Transaction Type' + REPLICATE(N' ', 25), 25) + N': ' + case ttLGD.database_transaction_type
																																																							  when 1 then N'Read / Write'
																																																							  when 2 then N'Read-Only'
																																																							  when 3 then N'System'
																																																						  else N'N/A'
																																																						  end + @CR_LF_Tab + LEFT(N'Transaction State' + REPLICATE(N' ', 25), 25) + N': ' + case ttLGD.database_transaction_state
																																																																												when 1 then N'Not Initialized'
																																																																												when 3 then N'No Log Records Generated'
																																																																												when 4 then N'Log Records Generated'
																																																																												when 5 then N'Prepared'
																																																																												when 10 then N'Committed'
																																																																												when 11 then N'Rolled Back'
																																																																												when 12 then N'Committing / Log Records Generating'
																																																																											else N'N/A'
																																																																											end + ISNULL(@CR_LF_Tab + LEFT(N'Log Records Generated' + REPLICATE(N' ', 25), 25) + N': ' + REVERSE(SUBSTRING(REVERSE(CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttLGD.database_transaction_log_record_count, 0)), 1)), 4, 23)), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Reserved' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttLGD.database_transaction_log_bytes_reserved, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Used' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttLGD.database_transaction_log_bytes_used, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Reserved (System)' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttLGD.database_transaction_log_bytes_reserved_system, 0) / 1048576.0), 1), N'') + ISNULL(@CR_LF_Tab + LEFT(N'Log MB Used (System)' + REPLICATE(N' ', 25), 25) + N': ' + CONVERT(nvarchar(23), CONVERT(money, NULLIF(ttLGD.database_transaction_log_bytes_used_system, 0) / 1048576.0), 1), N'') + @CR_LF + @CR_LF as [text()]
					from dbo.#temp_log_details as ttLGD
						 left join dbo.#temp_databases as ttDB on ttDB.database_id = ttLGD.database_id
					where ttLGD.transaction_id = ttCD.transaction_id
					order by case
								 when ttLGD.database_id = 32767 then N'mssqlsystemresource (Hidden Resource Database)'
							 else ttDB.database_name
							 end for xml path(N''), type), N'') as Log_Details,
		   case
			   when ttCD.lock_timeout = -1 then N'Wait Forever'
			   when ttCD.lock_timeout = 0 then N'Immediately'
																   else CONVERT(nvarchar(11), CONVERT(decimal(18, 2), ROUND(ttCD.lock_timeout / 1000.0, 2)))
		   end as Lock_Timeout_Seconds, 
		   ISNULL( (select ISNULL(N'Database ' + ISNULL(N'Name: ' + ttDB.database_name, N'ID: ' + CONVERT(nvarchar(11), ttLKD.rsc_dbid)), N'') + ISNULL(N' ••• Object ' + ISNULL(N'Name: ' + ttLKD.object_name, N'ID: ' + CONVERT(nvarchar(11), NULLIF(ttLKD.rsc_objid, 0))), N'') + ISNULL(N' ••• Index ' + ISNULL(N'Name: ' + ttLKD.index_name, N'ID: ' + CONVERT(nvarchar(11), NULLIF(ttLKD.rsc_indid, 0))), N'') + @CR_LF_Tab + N'Resource Type: ' + case ttLKD.rsc_type
																																																																																																															 when 1 then N'NULL Resource'
																																																																																																															 when 2 then N'Database'
																																																																																																															 when 3 then N'File'
																																																																																																															 when 4 then N'Index'
																																																																																																															 when 5 then N'Object'
																																																																																																															 when 6 then N'Page'
																																																																																																															 when 7 then N'Key'
																																																																																																															 when 8 then N'Extent'
																																																																																																															 when 9 then N'Row ID (RID)'
																																																																																																															 when 10 then N'Application'
																																																																																																															 when 11 then N'Metadata'
																																																																																																															 when 12 then N'Heap Or B-Tree (HoBt)'
																																																																																																															 when 13 then N'Allocation Unit'
																																																																																																														 else N'N/A'
																																																																																																														 end + @CR_LF_Tab + N'Request Mode: ' + case ttLKD.req_mode
																																																																																																																									when 0 then N'NULL Resource'
																																																																																																																									when 1 then N'Sch-S (Schema Stability)'
																																																																																																																									when 2 then N'Sch-M (Schema Modification)'
																																																																																																																									when 3 then N'S (Shared)'
																																																																																																																									when 4 then N'U (Update)'
																																																																																																																									when 5 then N'X (Exclusive)'
																																																																																																																									when 6 then N'IS (Intent Shared)'
																																																																																																																									when 7 then N'IU (Intent Update)'
																																																																																																																									when 8 then N'IX (Intent Exclusive)'
																																																																																																																									when 9 then N'SIU (Shared Intent Update)'
																																																																																																																									when 10 then N'SIX (Shared Intent Exclusive)'
																																																																																																																									when 11 then N'UIX (Update Intent Exclusive)'
																																																																																																																									when 12 then N'BU (Bulk Update)'
																																																																																																																									when 13 then N'RangeS-S (Serializable Range Scan)'
																																																																																																																									when 14 then N'RangeS-U (Serializable Update Scan)'
																																																																																																																									when 15 then N'RangeI-N (Insert Key-Range / NULL Resource Lock)'
																																																																																																																									when 16 then N'RangeI-S (Overlap Of RangeI-N / S Locks)'
																																																																																																																									when 17 then N'RangeI-U (Overlap Of RangeI-N / U Locks)'
																																																																																																																									when 18 then N'RangeI-X (Overlap Of RangeI-N / X Locks)'
																																																																																																																									when 19 then N'RangeX-S (Overlap Of RangeI-N / RangeS-S Locks)'
																																																																																																																									when 20 then N'RangeX-U (Overlap Of RangeI-N / RangeS-U Locks)'
																																																																																																																									when 21 then N'RangeX-X (Exclusive Key-Range / Exclusive Resource Lock)'
																																																																																																																								else N'N/A'
																																																																																																																								end + @CR_LF_Tab + N'Request Status: ' + case ttLKD.req_status
																																																																																																																																			 when 1 then N'Granted'
																																																																																																																																			 when 2 then N'Convert'
																																																																																																																																			 when 3 then N'Wait'
																																																																																																																																			 when 4 then N'RELN'
																																																																																																																																			 when 5 then N'BLCKN'
																																																																																																																																		 else N'N/A'
																																																																																																																																		 end + @CR_LF_Tab + N'Request Owner Type: ' + case ttLKD.req_ownertype
																																																																																																																																														  when 1 then N'Transaction'
																																																																																																																																														  when 2 then N'Cursor'
																																																																																																																																														  when 3 then N'User Session'
																																																																																																																																														  when 4 then N'Shared Transaction Workspace'
																																																																																																																																														  when 5 then N'Exclusive Transaction Workspace'
																																																																																																																																														  when 6 then N'WFR'
																																																																																																																																													  else N'N/A'
																																																																																																																																													  end + @CR_LF_Tab + N'ECID: ' + CONVERT(nvarchar(11), ttLKD.req_ecid) + @CR_LF_Tab + N'Request Reference Count: ' + CONVERT(nvarchar(6), ttLKD.req_refcnt) + @CR_LF + @CR_LF as [text()]
					from dbo.#temp_lock_details as ttLKD
						 left join dbo.#temp_databases as ttDB on ttDB.database_id = ttLKD.rsc_dbid
					where ttLKD.req_spid = ttCD.session_id
					order by ttDB.database_name, 
							 ttLKD.object_name, 
							 ttLKD.index_name, 
							 ttLKD.rsc_type, 
							 ttLKD.req_mode, 
							 ttLKD.req_status, 
							 ttLKD.req_ownertype, 
							 ttLKD.req_ecid, 
							 ttLKD.req_refcnt for xml path(N''), type), N'') as Lock_Details,
		   case
			   when ttCD.deadlock_priority <= -5 then N'Low'
			   when ttCD.deadlock_priority >= 5 then N'High'
		   else N'Normal'
		   end + N': ' + CONVERT(nvarchar(3), ttCD.deadlock_priority) as Deadlock_Priority, 
		   CONVERT(xml, ISNULL(case
								   when @Exclude_SQL = 1
										or @Exclude_SQL_XML = 1 then N''
							   else REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ttCD.[text] collate Latin1_General_BIN, NCHAR(0) collate Latin1_General_BIN, N''), N'&', @Ampersand + N'amp;'), N'<', @Ampersand + N'lt;'), N'>', @Ampersand + N'gt;'), N'"', @Ampersand + N'quot;'), N'''', @Ampersand + N'#39;')
							   end, N'')) as SQL_Statement_Batch_XML, 
		   CONVERT(xml,
				   case
					   when @Exclude_SQL = 1
							or @Exclude_SQL_XML = 1 then N''
				   else REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(NULLIF(caCP.sql_statement_current, N'<< Derived Statement >>'), N'<< Single Statement >>'), ttCD.[text]) collate Latin1_General_BIN, NCHAR(0) collate Latin1_General_BIN, N''), N'&', @Ampersand + N'amp;'), N'<', @Ampersand + N'lt;'), N'>', @Ampersand + N'gt;'), N'"', @Ampersand + N'quot;'), N'''', @Ampersand + N'#39;')
				   end) as SQL_Statement_Current_XML, 
		   ISNULL(CONVERT(nvarchar(130), ttCD.sql_handle, 1), N'') as SQL_Handle, 
		   ISNULL(ttCD.query_plan, N'') as Query_Plan, 
		   ISNULL(CONVERT(nvarchar(130), ttCD.plan_handle, 1), N'') as Plan_Handle, 
		   ISNULL(case
					  when caFL.login_time > @Date_Now then N'0 Day(s) 00:00:00'
				  else CONVERT(nvarchar(15), DATEDIFF(SECOND, caFL.login_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.login_time, @Date_Now), 0), 108)
				  end, N'') as Since_SPID_Login, 
		   ISNULL(case
					  when caFL.last_request_start_time > @Date_Now then N'0 Day(s) 00:00:00'
				  else CONVERT(nvarchar(15), DATEDIFF(SECOND, caFL.last_request_start_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.last_request_start_time, @Date_Now), 0), 108)
				  end, N'') as Since_Last_Batch_Start, 
		   ISNULL(case
					  when caFL.last_request_end_time > @Date_Now then N'0 Day(s) 00:00:00'
				  else CONVERT(nvarchar(15), DATEDIFF(SECOND, caFL.last_request_end_time, @Date_Now) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, DATEDIFF(SECOND, caFL.last_request_end_time, @Date_Now), 0), 108)
				  end, N'') as Since_Last_Batch_End, 
		   ISNULL(CONVERT(nvarchar(7), CONVERT(decimal(5, 2), NULLIF(ttCD.percent_complete, 0))), N'') as Command_Pct, 
		   ISNULL(case
					  when ttCD.percent_complete = 0 then N''
				  else CONVERT(nvarchar(19), DATEADD(MILLISECOND, ttCD.estimated_completion_time, @Date_Now), 120)
				  end, N'') as Command_Completion, 
		   ISNULL(CONVERT(nvarchar(15), ( NULLIF(ttCD.estimated_completion_time, 0) / 1000 ) / 86400) + N' Day(s) ' + CONVERT(nvarchar(8), DATEADD(SECOND, NULLIF(ttCD.estimated_completion_time, 0) / 1000, 0), 108), N'') as Command_Time_Left, 
		   ISNULL(ttCD.host_name, N'') as Host_Name, 
		   caFL.login_id as Login_ID,
		   case
			   when ttCD.login_name = N'sa' then N'<< System Administrator >>'
							else ttCD.login_name
		   end as Login_Name, 
		   ISNULL(REPLACE(REPLACE(ttCD.program_name, N'Microsoft® Windows® Operating System', N'Windows OS'), N'Microsoft', N'MS'), N'') as Application_Description,
		   case ttCD.is_user_process
			   when 1 then N''
																																			else N'Yes'
		   end as System_Process, 
		   caFL.spid as SPID
	from dbo.#temp_core_data as ttCD
		 left join dbo.#temp_deadlocking as ttD on ttD.session_id = ttCD.session_id
		 left join dbo.#temp_parallelism as ttP on ttP.session_id = ttCD.session_id
		 left join (select ttLGD.transaction_id, 
						   COUNT(*) as log_database_count, 
						   SUM(ttLGD.database_transaction_log_record_count) as log_record_count_all, 
						   SUM(ttLGD.database_transaction_log_bytes_reserved + ttLGD.database_transaction_log_bytes_reserved_system) as log_bytes_reserved_all, 
						   SUM(ttLGD.database_transaction_log_bytes_used + ttLGD.database_transaction_log_bytes_used_system) as log_bytes_used_all
					from dbo.#temp_log_details as ttLGD
					group by ttLGD.transaction_id) as sqLS on sqLS.transaction_id = ttCD.transaction_id
		 cross apply (select CONVERT(nvarchar(6), ttCD.session_id) + ISNULL(N' ' + case
																					   when ttCD.session_id = @@SPID then N'••'
																					   when ttCD.is_user_process = 0 then N'•'
																				   end, N'') as spid, 
							 STUFF( (select N', ' + CONVERT(nvarchar(max), ttXCD.session_id) as [text()]
									 from dbo.#temp_core_data as ttXCD
									 where ttXCD.blocking_session_id = ttCD.session_id
									 order by ttXCD.session_id for xml path(N'')), 1, 2, N'') as blocking,
							 case
								 when ttCD.status_session not in(N'dormant', N'sleeping') then UPPER(ttCD.status_session)
																								 else ttCD.status_session
							 end as status_session,
							 case
								 when ttCD.status_request <> N'sleeping' then UPPER(ttCD.status_request)
									else ttCD.status_request
							 end as status_request, 
							 CONVERT(bigint,
									 case
										 when ttCD.wait_time < 0 then 2147483647 + 2147483649 + ttCD.wait_time
									 else ttCD.wait_time
									 end) as wait_time, 
							 CONVERT(bigint,
									 case
										 when ttCD.total_elapsed_time < 0 then 2147483647 + 2147483649 + ttCD.total_elapsed_time
									 else ttCD.total_elapsed_time
									 end) as total_elapsed_time,
							 case
								 when ttCD.login_time_sessions = N'1900-01-01 00:00:00.000' then ttCD.login_time_processes
											 else ttCD.login_time_sessions
							 end as login_time,
							 case
								 when ttCD.last_request_start_time = N'1900-01-01 00:00:00.000' then null
									else ttCD.last_request_start_time
							 end as last_request_start_time,
							 case
								 when ttCD.last_request_end_time = N'1900-01-01 00:00:00.000' then ttCD.last_batch
									else ttCD.last_request_end_time
							 end as last_request_end_time, 
							 ISNULL(NULLIF(ttCD.nt_user_name, N''), ttCD.login_name) as login_id) as caFL
		 cross apply (select N'[ Deadlocking ] : ' + CONVERT(nvarchar(6), ttD.blocking_session_id) as deadlocking_spid,
							 case
								 when caFL.blocking is not null
									  or ttCD.blocking_session_id is not null
									  or ttP.session_id is not null then N' •• '
																									  else N''
							 end as separator_01, 
							 N'< Blocking > : ' + caFL.blocking as blocking_spids,
							 case
								 when ttCD.blocking_session_id is not null
									  or ttP.session_id is not null then N' •• '
																   else N''
							 end as separator_02, 
							 N'> Blocked By < : ' + CONVERT(nvarchar(6), ttCD.blocking_session_id) as blocked_by_spid,
							 case
								 when ttP.session_id is not null then N' •• '
																									  else N''
							 end as separator_03, 
							 N'( Parallelism ) : ' + CONVERT(nvarchar(6), ttP.session_id) as parallelism_spid, 
							 ISNULL(case
										when ttCD.[text] is null then N''
										when caFL.status_session = N'sleeping'
											 and caFL.status_request is null then N''
										when ttCD.stmt_start < 1
											 and ttCD.stmt_end = -1 then N'<< Single Statement >>'
										when( DATALENGTH(ttCD.[text]) - ttCD.stmt_start ) / 2 < 0
											and ttCD.stmt_end = -1 then N'<< Derived Statement >>'
										when ttCD.stmt_end = -1 then SUBSTRING(ttCD.[text], ttCD.stmt_start / 2 + 1, ( DATALENGTH(ttCD.[text]) - ttCD.stmt_start ) / 2 + 1)
									else SUBSTRING(ttCD.[text], ttCD.stmt_start / 2 + 1, ( ttCD.stmt_end - ttCD.stmt_start ) / 2 + 1)
									end, N'') as sql_statement_current) as caCP
	order by case
				 when ttD.blocking_session_id is not null
					  and caFL.blocking is null then 1
				 when ttD.blocking_session_id is not null
					  and caFL.blocking is not null then 2
				 when caFL.blocking is not null
					  and ttCD.blocking_session_id is null then 3
				 when caFL.blocking is not null
					  and ttCD.blocking_session_id is not null then 4
				 when ttCD.blocking_session_id is not null then 5
				 when ttP.session_id is not null then 6
			 else 7
			 end, 
			 ttCD.session_id;


	-----------------------------------------------------------------------------------------------------------------------------
	--	Cleanup: Drop Any Remaining Temp Tables
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
end;
go