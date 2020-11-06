set quoted_identifier on;

set ansi_padding on;

set concat_null_yields_null on;

set ansi_warnings on;

set numeric_roundabort off;

set arithabort on;
go

if not exists
(
	select *
	from INFORMATION_SCHEMA.ROUTINES
	where ROUTINE_NAME = 'sp_WhoIsActive'
) 
	exec ('CREATE PROC dbo.sp_WhoIsActive AS SELECT ''stub version, to be replaced''');
go

/*****************************************************************************************
Who Is Active? v11.33 (2019-07-28)
(C) 2007-2019, Adam Machanic

Feedback: mailto:adam@dataeducation.com
Updates: http://whoisactive.com
Blog: http://dataeducation.com

License: 
	https://github.com/amachanic/sp_whoisactive/blob/master/LICENSE
*****************************************************************************************/

alter proc dbo.sp_WhoIsActive (
--~
	--Filters--Both inclusive and exclusive
	--Set either filter to '' to disable
	--Valid filter types are: session, program, database, login, and host
	--Session is a session ID, and either 0 or '' can be used to indicate "all" sessions
	--All other filter types support % or _ as wildcards
	@filter               sysname       = '', 
@filter_type          varchar(10)   = 'session', 
@not_filter           sysname       = '', 
@not_filter_type      varchar(10)   = 'session',

--Retrieve data about the calling session?
	@show_own_spid        bit           = 0,

--Retrieve data about system sessions?
	@show_system_spids    bit           = 0,

--Controls how sleeping SPIDs are handled, based on the idea of levels of interest
	--0 does not pull any sleeping SPIDs
	--1 pulls only those sleeping SPIDs that also have an open transaction
	--2 pulls all sleeping SPIDs
	@show_sleeping_spids  tinyint       = 1,

--If 1, gets the full stored procedure or running batch, when available
	--If 0, gets only the actual statement that is currently running in the batch or procedure
	@get_full_inner_text  bit           = 0,

--Get associated query plans for running tasks, if available
	--If @get_plans = 1, gets the plan based on the request's statement offset
	--If @get_plans = 2, gets the entire plan based on the request's plan_handle
	@get_plans            tinyint       = 0,

--Get the associated outer ad hoc query or stored procedure call, if available
	@get_outer_command    bit           = 0,

--Enables pulling transaction log write info and transaction duration
	@get_transaction_info bit           = 0,

--Get information on active tasks, based on three interest levels
	--Level 0 does not pull any task-related information
	--Level 1 is a lightweight mode that pulls the top non-CXPACKET wait, giving preference to blockers
	--Level 2 pulls all available task-based metrics, including: 
	--number of active tasks, current wait stats, physical I/O, context switches, and blocker information
	@get_task_info        tinyint       = 1,

--Gets associated locks for each request, aggregated in an XML format
	@get_locks            bit           = 0,

--Get average time for past runs of an active query
	--(based on the combination of plan handle, sql handle, and offset)
	@get_avg_time         bit           = 0,

--Get additional non-performance-related information about the session or request
	--text_size, language, date_format, date_first, quoted_identifier, arithabort, ansi_null_dflt_on, 
	--ansi_defaults, ansi_warnings, ansi_padding, ansi_nulls, concat_null_yields_null, 
	--transaction_isolation_level, lock_timeout, deadlock_priority, row_count, command_type
	--
	--If a SQL Agent job is running, an subnode called agent_info will be populated with some or all of
	--the following: job_id, job_name, step_id, step_name, msdb_query_error (in the event of an error)
	--
	--If @get_task_info is set to 2 and a lock wait is detected, a subnode called block_info will be
	--populated with some or all of the following: lock_type, database_name, object_id, file_id, hobt_id, 
	--applock_hash, metadata_resource, metadata_class_id, object_name, schema_name
	@get_additional_info  bit           = 0,

--Walk the blocking chain and count the number of 
	--total SPIDs blocked all the way down by a given session
	--Also enables task_info Level 1, if @get_task_info is set to 0
	@find_block_leaders   bit           = 0,

--Pull deltas on various metrics
	--Interval in seconds to wait before doing the second data pull
	@delta_interval       tinyint       = 0,

--List of desired output columns, in desired order
	--Note that the final output will be the intersection of all enabled features and all 
	--columns in the list. Therefore, only columns associated with enabled features will 
	--actually appear in the output. Likewise, removing columns from this list may effectively
	--disable features, even if they are turned on
	--
	--Each element in this list must be one of the valid output column names. Names must be
	--delimited by square brackets. White space, formatting, and additional characters are
	--allowed, as long as the list contains exact matches of delimited valid column names.
	@output_column_list   varchar(8000) = '[dd%][session_id][sql_text][sql_command][login_name][wait_info][tasks][tran_log%][cpu%][temp%][block%][reads%][writes%][context%][physical%][query_plan][locks][%]',

--Column(s) by which to sort output, optionally with sort directions. 
		--Valid column choices:
		--session_id, physical_io, reads, physical_reads, writes, tempdb_allocations, 
		--tempdb_current, CPU, context_switches, used_memory, physical_io_delta, reads_delta, 
		--physical_reads_delta, writes_delta, tempdb_allocations_delta, tempdb_current_delta, 
		--CPU_delta, context_switches_delta, used_memory_delta, tasks, tran_start_time, 
		--open_tran_count, blocking_session_id, blocked_session_count, percent_complete, 
		--host_name, login_name, database_name, start_time, login_time, program_name
		--
		--Note that column names in the list must be bracket-delimited. Commas and/or white
		--space are not required. 
	@sort_order           varchar(500)  = '[start_time] ASC',

--Formats some of the output columns in a more "human readable" form
	--0 disables outfput format
	--1 formats the output for variable-width fonts
	--2 formats the output for fixed-width fonts
	@format_output        tinyint       = 1,

--If set to a non-blank value, the script will attempt to insert into the specified 
	--destination table. Please note that the script will not verify that the table exists, 
	--or that it has the correct schema, before doing the insert.
	--Table can be specified in one, two, or three-part format
	@destination_table    varchar(4000) = '',

--If set to 1, no data collection will happen and no result set will be returned; instead,
	--a CREATE TABLE statement will be returned via the @schema parameter, which will match 
	--the schema of the result set that would be returned by using the same collection of the
	--rest of the parameters. The CREATE TABLE statement will have a placeholder token of 
	--<table_name> in place of an actual table name.
	@return_schema        bit           = 0, 
@schema               varchar(max)  = null output,

--Help! What do I do?
	@help                 bit           = 0
--~
)

/************************************************************************************************
OUTPUT COLUMNS
--------------
Formatted/Non:	[session_id] [smallint] NOT NULL
	Session ID (a.k.a. SPID)

Formatted:		[dd hh:mm:ss.mss] [varchar](15) NULL
Non-Formatted:	<not returned>
	For an active request, time the query has been running
	For a sleeping session, time since the last batch completed

Formatted:		[dd hh:mm:ss.mss (avg)] [varchar](15) NULL
Non-Formatted:	[avg_elapsed_time] [int] NULL
	(Requires @get_avg_time option)
	How much time has the active portion of the query taken in the past, on average?

Formatted:		[physical_io] [varchar](30) NULL
Non-Formatted:	[physical_io] [bigint] NULL
	Shows the number of physical I/Os, for active requests

Formatted:		[reads] [varchar](30) NULL
Non-Formatted:	[reads] [bigint] NULL
	For an active request, number of reads done for the current query
	For a sleeping session, total number of reads done over the lifetime of the session

Formatted:		[physical_reads] [varchar](30) NULL
Non-Formatted:	[physical_reads] [bigint] NULL
	For an active request, number of physical reads done for the current query
	For a sleeping session, total number of physical reads done over the lifetime of the session

Formatted:		[writes] [varchar](30) NULL
Non-Formatted:	[writes] [bigint] NULL
	For an active request, number of writes done for the current query
	For a sleeping session, total number of writes done over the lifetime of the session

Formatted:		[tempdb_allocations] [varchar](30) NULL
Non-Formatted:	[tempdb_allocations] [bigint] NULL
	For an active request, number of TempDB writes done for the current query
	For a sleeping session, total number of TempDB writes done over the lifetime of the session

Formatted:		[tempdb_current] [varchar](30) NULL
Non-Formatted:	[tempdb_current] [bigint] NULL
	For an active request, number of TempDB pages currently allocated for the query
	For a sleeping session, number of TempDB pages currently allocated for the session

Formatted:		[CPU] [varchar](30) NULL
Non-Formatted:	[CPU] [int] NULL
	For an active request, total CPU time consumed by the current query
	For a sleeping session, total CPU time consumed over the lifetime of the session

Formatted:		[context_switches] [varchar](30) NULL
Non-Formatted:	[context_switches] [bigint] NULL
	Shows the number of context switches, for active requests

Formatted:		[used_memory] [varchar](30) NOT NULL
Non-Formatted:	[used_memory] [bigint] NOT NULL
	For an active request, total memory consumption for the current query
	For a sleeping session, total current memory consumption

Formatted:		[physical_io_delta] [varchar](30) NULL
Non-Formatted:	[physical_io_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of physical I/Os reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[reads_delta] [varchar](30) NULL
Non-Formatted:	[reads_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of reads reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[physical_reads_delta] [varchar](30) NULL
Non-Formatted:	[physical_reads_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of physical reads reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[writes_delta] [varchar](30) NULL
Non-Formatted:	[writes_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of writes reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[tempdb_allocations_delta] [varchar](30) NULL
Non-Formatted:	[tempdb_allocations_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of TempDB writes reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[tempdb_current_delta] [varchar](30) NULL
Non-Formatted:	[tempdb_current_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the number of allocated TempDB pages reported on the first and second 
	collections. If the request started after the first collection, the value will be NULL

Formatted:		[CPU_delta] [varchar](30) NULL
Non-Formatted:	[CPU_delta] [int] NULL
	(Requires @delta_interval option)
	Difference between the CPU time reported on the first and second collections. 
	If the request started after the first collection, the value will be NULL

Formatted:		[context_switches_delta] [varchar](30) NULL
Non-Formatted:	[context_switches_delta] [bigint] NULL
	(Requires @delta_interval option)
	Difference between the context switches count reported on the first and second collections
	If the request started after the first collection, the value will be NULL

Formatted:		[used_memory_delta] [varchar](30) NULL
Non-Formatted:	[used_memory_delta] [bigint] NULL
	Difference between the memory usage reported on the first and second collections
	If the request started after the first collection, the value will be NULL

Formatted:		[tasks] [varchar](30) NULL
Non-Formatted:	[tasks] [smallint] NULL
	Number of worker tasks currently allocated, for active requests

Formatted/Non:	[status] [varchar](30) NOT NULL
	Activity status for the session (running, sleeping, etc)

Formatted/Non:	[wait_info] [nvarchar](4000) NULL
	Aggregates wait information, in the following format:
		(Ax: Bms/Cms/Dms)E
	A is the number of waiting tasks currently waiting on resource type E. B/C/D are wait
	times, in milliseconds. If only one thread is waiting, its wait time will be shown as B.
	If two tasks are waiting, each of their wait times will be shown (B/C). If three or more 
	tasks are waiting, the minimum, average, and maximum wait times will be shown (B/C/D).
	If wait type E is a page latch wait and the page is of a "special" type (e.g. PFS, GAM, SGAM), 
	the page type will be identified.
	If wait type E is CXPACKET, the nodeId from the query plan will be identified

Formatted/Non:	[locks] [xml] NULL
	(Requires @get_locks option)
	Aggregates lock information, in XML format.
	The lock XML includes the lock mode, locked object, and aggregates the number of requests. 
	Attempts are made to identify locked objects by name

Formatted/Non:	[tran_start_time] [datetime] NULL
	(Requires @get_transaction_info option)
	Date and time that the first transaction opened by a session caused a transaction log 
	write to occur.

Formatted/Non:	[tran_log_writes] [nvarchar](4000) NULL
	(Requires @get_transaction_info option)
	Aggregates transaction log write information, in the following format:
	A:wB (C kB)
	A is a database that has been touched by an active transaction
	B is the number of log writes that have been made in the database as a result of the transaction
	C is the number of log kilobytes consumed by the log records

Formatted:		[open_tran_count] [varchar](30) NULL
Non-Formatted:	[open_tran_count] [smallint] NULL
	Shows the number of open transactions the session has open

Formatted:		[sql_command] [xml] NULL
Non-Formatted:	[sql_command] [nvarchar](max) NULL
	(Requires @get_outer_command option)
	Shows the "outer" SQL command, i.e. the text of the batch or RPC sent to the server, 
	if available

Formatted:		[sql_text] [xml] NULL
Non-Formatted:	[sql_text] [nvarchar](max) NULL
	Shows the SQL text for active requests or the last statement executed
	for sleeping sessions, if available in either case.
	If @get_full_inner_text option is set, shows the full text of the batch.
	Otherwise, shows only the active statement within the batch.
	If the query text is locked, a special timeout message will be sent, in the following format:
		<timeout_exceeded />
	If an error occurs, an error message will be sent, in the following format:
		<error message="message" />

Formatted/Non:	[query_plan] [xml] NULL
	(Requires @get_plans option)
	Shows the query plan for the request, if available.
	If the plan is locked, a special timeout message will be sent, in the following format:
		<timeout_exceeded />
	If an error occurs, an error message will be sent, in the following format:
		<error message="message" />

Formatted/Non:	[blocking_session_id] [smallint] NULL
	When applicable, shows the blocking SPID

Formatted:		[blocked_session_count] [varchar](30) NULL
Non-Formatted:	[blocked_session_count] [smallint] NULL
	(Requires @find_block_leaders option)
	The total number of SPIDs blocked by this session,
	all the way down the blocking chain.

Formatted:		[percent_complete] [varchar](30) NULL
Non-Formatted:	[percent_complete] [real] NULL
	When applicable, shows the percent complete (e.g. for backups, restores, and some rollbacks)

Formatted/Non:	[host_name] [sysname] NOT NULL
	Shows the host name for the connection

Formatted/Non:	[login_name] [sysname] NOT NULL
	Shows the login name for the connection

Formatted/Non:	[database_name] [sysname] NULL
	Shows the connected database

Formatted/Non:	[program_name] [sysname] NULL
	Shows the reported program/application name

Formatted/Non:	[additional_info] [xml] NULL
	(Requires @get_additional_info option)
	Returns additional non-performance-related session/request information
	If the script finds a SQL Agent job running, the name of the job and job step will be reported
	If @get_task_info = 2 and the script finds a lock wait, the locked object will be reported

Formatted/Non:	[start_time] [datetime] NOT NULL
	For active requests, shows the time the request started
	For sleeping sessions, shows the time the last batch completed

Formatted/Non:	[login_time] [datetime] NOT NULL
	Shows the time that the session connected

Formatted/Non:	[request_id] [int] NULL
	For active requests, shows the request_id
	Should be 0 unless MARS is being used

Formatted/Non:	[collection_time] [datetime] NOT NULL
	Time that this script's final SELECT ran
************************************************************************************************/
as
begin
set nocount on;
set transaction isolation level read uncommitted;
set quoted_identifier on;
set ansi_padding on;
set concat_null_yields_null on;
set ansi_warnings on;
set numeric_roundabort off;
set arithabort on;

if @filter is null
or @filter_type is null
or @not_filter is null
or @not_filter_type is null
or @show_own_spid is null
or @show_system_spids is null
or @show_sleeping_spids is null
or @get_full_inner_text is null
or @get_plans is null
or @get_outer_command is null
or @get_transaction_info is null
or @get_task_info is null
or @get_locks is null
or @get_avg_time is null
or @get_additional_info is null
or @find_block_leaders is null
or @delta_interval is null
or @format_output is null
or @output_column_list is null
or @sort_order is null
or @return_schema is null
or @destination_table is null
or @help is null
begin
raiserror('Input parameters cannot be NULL', 16, 1);
return;
end;

if @filter_type not in('session', 'program', 'database', 'login', 'host')
begin
raiserror('Valid filter types are: session, program, database, login, host', 16, 1);
return;
end;

if @filter_type = 'session'
and @filter like '%[^0123456789]%'
begin
raiserror('Session filters must be valid integers', 16, 1);
return;
end;

if @not_filter_type not in('session', 'program', 'database', 'login', 'host')
begin
raiserror('Valid filter types are: session, program, database, login, host', 16, 1);
return;
end;

if @not_filter_type = 'session'
and @not_filter like '%[^0123456789]%'
begin
raiserror('Session filters must be valid integers', 16, 1);
return;
end;

if @show_sleeping_spids not in(0, 1, 2)
begin
raiserror('Valid values for @show_sleeping_spids are: 0, 1, or 2', 16, 1);
return;
end;

if @get_plans not in(0, 1, 2)
begin
raiserror('Valid values for @get_plans are: 0, 1, or 2', 16, 1);
return;
end;

if @get_task_info not in(0, 1, 2)
begin
raiserror('Valid values for @get_task_info are: 0, 1, or 2', 16, 1);
return;
end;

if @format_output not in(0, 1, 2)
begin
raiserror('Valid values for @format_output are: 0, 1, or 2', 16, 1);
return;
end;

if @help = 1
begin
declare @header  varchar(max), 
@params  varchar(max), 
@outputs varchar(max);

select @header = REPLACE(REPLACE(CONVERT(varchar(max), SUBSTRING(t.text, CHARINDEX('/' + REPLICATE('*', 93), t.text) + 94, CHARINDEX(REPLICATE('*', 93) + '/', t.text) - ( CHARINDEX('/' + REPLICATE('*', 93), t.text) + 94 ))), CHAR(13) + CHAR(10), CHAR(13)), '	', ''), 
@params = CHAR(13) + REPLACE(REPLACE(CONVERT(varchar(max), SUBSTRING(t.text, CHARINDEX('--~', t.text) + 5, CHARINDEX('--~', t.text, CHARINDEX('--~', t.text) + 5) - ( CHARINDEX('--~', t.text) + 5 ))), CHAR(13) + CHAR(10), CHAR(13)), '	', ''), 
@outputs = CHAR(13) + REPLACE(REPLACE(REPLACE(CONVERT(varchar(max), SUBSTRING(t.text, CHARINDEX('OUTPUT COLUMNS' + CHAR(13) + CHAR(10) + '--------------', t.text) + 32, CHARINDEX('*/', t.text, CHARINDEX('OUTPUT COLUMNS' + CHAR(13) + CHAR(10) + '--------------', t.text) + 32) - ( CHARINDEX('OUTPUT COLUMNS' + CHAR(13) + CHAR(10) + '--------------', t.text) + 32 ))), CHAR(9), CHAR(255)), CHAR(13) + CHAR(10), CHAR(13)), '	', '') + CHAR(13)
from sys.dm_exec_requests as r
cross apply sys.dm_exec_sql_text (r.sql_handle) as t
where r.session_id = @@SPID;

with a0
as (select 1 as n
union all
select 1),
a1
as (select 1 as n
from a0 as a, a0 as b),
a2
as (select 1 as n
from a1 as a, a1 as b),
a3
as (select 1 as n
from a2 as a, a2 as b),
a4
as (select 1 as n
from a3 as a, a3 as b),
numbers
as (select top (LEN(@header) - 1) ROW_NUMBER() over(
order by (select null) ) as number
from a4
order by number)
select RTRIM(LTRIM(SUBSTRING(@header, number + 1, CHARINDEX(CHAR(13), @header, number + 1) - number - 1))) as [------header---------------------------------------------------------------------------------------------------------------]
from numbers
where SUBSTRING(@header, number, 1) = CHAR(13);

with a0
as (select 1 as n
union all
select 1),
a1
as (select 1 as n
from a0 as a, a0 as b),
a2
as (select 1 as n
from a1 as a, a1 as b),
a3
as (select 1 as n
from a2 as a, a2 as b),
a4
as (select 1 as n
from a3 as a, a3 as b),
numbers
as (select top (LEN(@params) - 1) ROW_NUMBER() over(
order by (select null) ) as number
from a4
order by number),
tokens
as (select RTRIM(LTRIM(SUBSTRING(@params, number + 1, CHARINDEX(CHAR(13), @params, number + 1) - number - 1))) as token, 
number,
case
when SUBSTRING(@params, number + 1, 1) = CHAR(13) then number
else COALESCE(NULLIF(CHARINDEX(',' + CHAR(13) + CHAR(13), @params, number), 0), LEN(@params))
end as param_group, 
ROW_NUMBER() over(partition by CHARINDEX(',' + CHAR(13) + CHAR(13), @params, number), 
SUBSTRING(@params, number + 1, 1)
order by number) as group_order
from numbers
where SUBSTRING(@params, number, 1) = CHAR(13)),
parsed_tokens
as (select MIN(case
when token like '@%' then token
else null
end) as parameter, 
MIN(case
when token like '--%' then RIGHT(token, LEN(token) - 2)
else null
end) as description, 
param_group, 
group_order
from tokens
where not( token = ''
and group_order > 1 )
group by param_group, 
group_order)
select case
when description is null
and parameter is null then '-------------------------------------------------------------------------'
when param_group = MAX(param_group) over() then parameter
else COALESCE(LEFT(parameter, LEN(parameter) - 1), '')
end as [------parameter----------------------------------------------------------],
case
when description is null
and parameter is null then '----------------------------------------------------------------------------------------------------------------------'
else COALESCE(description, '')
end as [------description-----------------------------------------------------------------------------------------------------]
from parsed_tokens
order by param_group, 
group_order;

with a0
as (select 1 as n
union all
select 1),
a1
as (select 1 as n
from a0 as a, a0 as b),
a2
as (select 1 as n
from a1 as a, a1 as b),
a3
as (select 1 as n
from a2 as a, a2 as b),
a4
as (select 1 as n
from a3 as a, a3 as b),
numbers
as (select top (LEN(@outputs) - 1) ROW_NUMBER() over(
order by (select null) ) as number
from a4
order by number),
tokens
as (select RTRIM(LTRIM(SUBSTRING(@outputs, number + 1,
case
when COALESCE(NULLIF(CHARINDEX(CHAR(13) + 'Formatted', @outputs, number + 1), 0), LEN(@outputs)) < COALESCE(NULLIF(CHARINDEX(CHAR(13) + CHAR(255) collate Latin1_General_Bin2, @outputs, number + 1), 0), LEN(@outputs)) then COALESCE(NULLIF(CHARINDEX(CHAR(13) + 'Formatted', @outputs, number + 1), 0), LEN(@outputs)) - number - 1
else COALESCE(NULLIF(CHARINDEX(CHAR(13) + CHAR(255) collate Latin1_General_Bin2, @outputs, number + 1), 0), LEN(@outputs)) - number - 1
end))) as token, 
number, 
COALESCE(NULLIF(CHARINDEX(CHAR(13) + 'Formatted', @outputs, number + 1), 0), LEN(@outputs)) as output_group, 
ROW_NUMBER() over(partition by COALESCE(NULLIF(CHARINDEX(CHAR(13) + 'Formatted', @outputs, number + 1), 0), LEN(@outputs))
order by number) as output_group_order
from numbers
where SUBSTRING(@outputs, number, 10) = CHAR(13) + 'Formatted'
or SUBSTRING(@outputs, number, 2) = CHAR(13) + CHAR(255) collate Latin1_General_Bin2),
output_tokens
as (select *,
case output_group_order
when 2 then MAX(case output_group_order
when 1 then token
else null
end) over(partition by output_group)
else ''
end collate Latin1_General_Bin2 as column_info
from tokens)
select case output_group_order
when 1 then '-----------------------------------'
when 2 then case
when CHARINDEX('Formatted/Non:', column_info) = 1 then SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info) + 1, CHARINDEX(']', column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info) + 2) - CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info))
else SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info) + 2, CHARINDEX(']', column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info) + 2) - CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info) - 1)
end
else ''
end as formatted_column_name,
case output_group_order
when 1 then '-----------------------------------'
when 2 then case
when CHARINDEX('Formatted/Non:', column_info) = 1 then SUBSTRING(column_info, CHARINDEX(']', column_info) + 2, LEN(column_info))
else SUBSTRING(column_info, CHARINDEX(']', column_info) + 2, CHARINDEX('Non-Formatted:', column_info, CHARINDEX(']', column_info) + 2) - CHARINDEX(']', column_info) - 3)
end
else ''
end as formatted_column_type,
case output_group_order
when 1 then '---------------------------------------'
when 2 then case
when CHARINDEX('Formatted/Non:', column_info) = 1 then ''
else case
when SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1, 1) = '<' then SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1, CHARINDEX('>', column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1) - CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)))
else SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1, CHARINDEX(']', column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1) - CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)))
end
end
else ''
end as unformatted_column_name,
case output_group_order
when 1 then '---------------------------------------'
when 2 then case
when CHARINDEX('Formatted/Non:', column_info) = 1 then ''
else case
when SUBSTRING(column_info, CHARINDEX(CHAR(255) collate Latin1_General_Bin2, column_info, CHARINDEX('Non-Formatted:', column_info)) + 1, 1) = '<' then ''
else SUBSTRING(column_info, CHARINDEX(']', column_info, CHARINDEX('Non-Formatted:', column_info)) + 2, CHARINDEX('Non-Formatted:', column_info, CHARINDEX(']', column_info) + 2) - CHARINDEX(']', column_info) - 3)
end
end
else ''
end as unformatted_column_type,
case output_group_order
when 1 then '----------------------------------------------------------------------------------------------------------------------'
else REPLACE(token, CHAR(255) collate Latin1_General_Bin2, '')
end as [------description-----------------------------------------------------------------------------------------------------]
from output_tokens
where not( output_group_order = 1
and output_group = LEN(@outputs) )
order by output_group,
case output_group_order
when 1 then 99
else output_group_order
end;

return;
end;

with a0
as (select 1 as n
union all
select 1),
a1
as (select 1 as n
from a0 as a, a0 as b),
a2
as (select 1 as n
from a1 as a, a1 as b),
a3
as (select 1 as n
from a2 as a, a2 as b),
a4
as (select 1 as n
from a3 as a, a3 as b),
numbers
as (select top (LEN(@output_column_list)) ROW_NUMBER() over(
order by (select null) ) as number
from a4
order by number),
tokens
as (select '|[' + SUBSTRING(@output_column_list, number + 1, CHARINDEX(']', @output_column_list, number) - number - 1) + '|]' as token, 
number
from numbers
where SUBSTRING(@output_column_list, number, 1) = '['),
ordered_columns
as (select x.column_name, 
ROW_NUMBER() over(partition by x.column_name
order by tokens.number, 
x.default_order) as r, 
ROW_NUMBER() over(
order by tokens.number, 
x.default_order) as s
from tokens
join (select '[session_id]' as column_name, 
1 as default_order
union all
select '[dd hh:mm:ss.mss]', 
2
where @format_output in (1, 2) 
union all
select '[dd hh:mm:ss.mss (avg)]', 
3
where @format_output in (1, 2)
and @get_avg_time = 1
union all
select '[avg_elapsed_time]', 
4
where @format_output = 0
and @get_avg_time = 1
union all
select '[physical_io]', 
5
where @get_task_info = 2
union all
select '[reads]', 
6
union all
select '[physical_reads]', 
7
union all
select '[writes]', 
8
union all
select '[tempdb_allocations]', 
9
union all
select '[tempdb_current]', 
10
union all
select '[CPU]', 
11
union all
select '[context_switches]', 
12
where @get_task_info = 2
union all
select '[used_memory]', 
13
union all
select '[physical_io_delta]', 
14
where @delta_interval > 0
and @get_task_info = 2
union all
select '[reads_delta]', 
15
where @delta_interval > 0
union all
select '[physical_reads_delta]', 
16
where @delta_interval > 0
union all
select '[writes_delta]', 
17
where @delta_interval > 0
union all
select '[tempdb_allocations_delta]', 
18
where @delta_interval > 0
union all
select '[tempdb_current_delta]', 
19
where @delta_interval > 0
union all
select '[CPU_delta]', 
20
where @delta_interval > 0
union all
select '[context_switches_delta]', 
21
where @delta_interval > 0
and @get_task_info = 2
union all
select '[used_memory_delta]', 
22
where @delta_interval > 0
union all
select '[tasks]', 
23
where @get_task_info = 2
union all
select '[status]', 
24
union all
select '[wait_info]', 
25
where @get_task_info > 0
or @find_block_leaders = 1
union all
select '[locks]', 
26
where @get_locks = 1
union all
select '[tran_start_time]', 
27
where @get_transaction_info = 1
union all
select '[tran_log_writes]', 
28
where @get_transaction_info = 1
union all
select '[open_tran_count]', 
29
union all
select '[sql_command]', 
30
where @get_outer_command = 1
union all
select '[sql_text]', 
31
union all
select '[query_plan]', 
32
where @get_plans >= 1
union all
select '[blocking_session_id]', 
33
where @get_task_info > 0
or @find_block_leaders = 1
union all
select '[blocked_session_count]', 
34
where @find_block_leaders = 1
union all
select '[percent_complete]', 
35
union all
select '[host_name]', 
36
union all
select '[login_name]', 
37
union all
select '[database_name]', 
38
union all
select '[program_name]', 
39
union all
select '[additional_info]', 
40
where @get_additional_info = 1
union all
select '[start_time]', 
41
union all
select '[login_time]', 
42
union all
select '[request_id]', 
43
union all
select '[collection_time]', 
44) as x on x.column_name like token escape '|')
select @output_column_list = STUFF( (select ',' + column_name as [text()]
from ordered_columns
where r = 1
order by s for xml path('')), 1, 1, '');

if COALESCE(RTRIM(@output_column_list), '') = ''
begin
raiserror('No valid column matches found in @output_column_list or no columns remain due to selected options.', 16, 1);
return;
end;

if @destination_table <> ''
begin
set @destination_table = --database
			COALESCE(QUOTENAME(PARSENAME(@destination_table, 3)) + '.', '') + --schema
			COALESCE(QUOTENAME(PARSENAME(@destination_table, 2)) + '.', '') + --table
			COALESCE(QUOTENAME(PARSENAME(@destination_table, 1)), '');

if COALESCE(RTRIM(@destination_table), '') = ''
begin
raiserror('Destination table not properly formatted.', 16, 1);
return;
end;
end;

with a0
as (select 1 as n
union all
select 1),
a1
as (select 1 as n
from a0 as a, a0 as b),
a2
as (select 1 as n
from a1 as a, a1 as b),
a3
as (select 1 as n
from a2 as a, a2 as b),
a4
as (select 1 as n
from a3 as a, a3 as b),
numbers
as (select top (LEN(@sort_order)) ROW_NUMBER() over(
order by (select null) ) as number
from a4
order by number),
tokens
as (select '|[' + SUBSTRING(@sort_order, number + 1, CHARINDEX(']', @sort_order, number) - number - 1) + '|]' as token, 
SUBSTRING(@sort_order, CHARINDEX(']', @sort_order, number) + 1, COALESCE(NULLIF(CHARINDEX('[', @sort_order, CHARINDEX(']', @sort_order, number)), 0), LEN(@sort_order)) - CHARINDEX(']', @sort_order, number)) as next_chunk, 
number
from numbers
where SUBSTRING(@sort_order, number, 1) = '['),
ordered_columns
as (select x.column_name + case
when tokens.next_chunk like '%asc%' then ' ASC'
when tokens.next_chunk like '%desc%' then ' DESC'
else ''
end as column_name, 
ROW_NUMBER() over(partition by x.column_name
order by tokens.number) as r, 
tokens.number
from tokens
join (select '[session_id]' as column_name
union all
select '[physical_io]'
union all
select '[reads]'
union all
select '[physical_reads]'
union all
select '[writes]'
union all
select '[tempdb_allocations]'
union all
select '[tempdb_current]'
union all
select '[CPU]'
union all
select '[context_switches]'
union all
select '[used_memory]'
union all
select '[physical_io_delta]'
union all
select '[reads_delta]'
union all
select '[physical_reads_delta]'
union all
select '[writes_delta]'
union all
select '[tempdb_allocations_delta]'
union all
select '[tempdb_current_delta]'
union all
select '[CPU_delta]'
union all
select '[context_switches_delta]'
union all
select '[used_memory_delta]'
union all
select '[tasks]'
union all
select '[tran_start_time]'
union all
select '[open_tran_count]'
union all
select '[blocking_session_id]'
union all
select '[blocked_session_count]'
union all
select '[percent_complete]'
union all
select '[host_name]'
union all
select '[login_name]'
union all
select '[database_name]'
union all
select '[start_time]'
union all
select '[login_time]'
union all
select '[program_name]') as x on x.column_name like token escape '|')
select @sort_order = COALESCE(z.sort_order, '')
from (select STUFF( (select ',' + column_name as [text()]
from ordered_columns
where r = 1
order by number for xml path('')), 1, 1, '') as sort_order) as z;

create table #sessions (
recursion               smallint not null, 
session_id              smallint not null, 
request_id              int not null, 
session_number          int not null, 
elapsed_time            int not null, 
avg_elapsed_time        int null, 
physical_io             bigint null, 
reads                   bigint null, 
physical_reads          bigint null, 
writes                  bigint null, 
tempdb_allocations      bigint null, 
tempdb_current          bigint null, 
CPU                     int null, 
thread_CPU_snapshot     bigint null, 
context_switches        bigint null, 
used_memory             bigint not null, 
tasks                   smallint null, 
status                  varchar(30) not null, 
wait_info               nvarchar(4000) null, 
locks                   xml null, 
transaction_id          bigint null, 
tran_start_time         datetime null, 
tran_log_writes         nvarchar(4000) null, 
open_tran_count         smallint null, 
sql_command             xml null, 
sql_handle              varbinary(64) null, 
statement_start_offset  int null, 
statement_end_offset    int null, 
sql_text                xml null, 
plan_handle             varbinary(64) null, 
query_plan              xml null, 
blocking_session_id     smallint null, 
blocked_session_count   smallint null, 
percent_complete        real null, 
host_name               sysname null, 
login_name              sysname not null, 
database_name           sysname null, 
program_name            sysname null, 
additional_info         xml null, 
start_time              datetime not null, 
login_time              datetime null, 
last_request_start_time datetime null, 
primary key clustered(session_id, request_id, recursion)
with(ignore_dup_key = on), 
unique nonclustered(transaction_id, session_id, request_id, recursion)
with(ignore_dup_key = on));

if @return_schema = 0
begin
		--Disable unnecessary autostats on the table
create statistics s_session_id on #sessions (session_id) with sample 0 rows, norecompute;
create statistics s_request_id on #sessions (request_id) with sample 0 rows, norecompute;
create statistics s_transaction_id on #sessions (transaction_id) with sample 0 rows, norecompute;
create statistics s_session_number on #sessions (session_number) with sample 0 rows, norecompute;
create statistics s_status on #sessions (status) with sample 0 rows, norecompute;
create statistics s_start_time on #sessions (start_time) with sample 0 rows, norecompute;
create statistics s_last_request_start_time on #sessions (last_request_start_time) with sample 0 rows, norecompute;
create statistics s_recursion on #sessions (recursion) with sample 0 rows, norecompute;

declare @recursion smallint;
set @recursion = case @delta_interval
when 0 then 1
else-1
end;

declare @first_collection_ms_ticks bigint;
declare @last_collection_start datetime;
declare @sys_info bit;
set @sys_info = ISNULL(CONVERT(bit, SIGN(OBJECT_ID('sys.dm_os_sys_info'))), 0);

--Used for the delta pull
REDO:

if @get_locks = 1
and @recursion = 1
and @output_column_list like '%|[locks|]%' escape '|'
begin
select y.resource_type, 
y.database_name, 
y.object_id, 
y.file_id, 
y.page_type, 
y.hobt_id, 
y.allocation_unit_id, 
y.index_id, 
y.schema_id, 
y.principal_id, 
y.request_mode, 
y.request_status, 
y.session_id, 
y.resource_description, 
y.request_count, 
s.request_id, 
s.start_time, 
CONVERT(sysname, null) as object_name, 
CONVERT(sysname, null) as index_name, 
CONVERT(sysname, null) as schema_name, 
CONVERT(sysname, null) as principal_name, 
CONVERT(nvarchar(2048), null) as query_error
into #locks
from (select sp.spid as session_id,
case sp.status
when 'sleeping' then CONVERT(int, 0)
else sp.request_id
end as request_id,
case sp.status
when 'sleeping' then sp.last_batch
else COALESCE(req.start_time, sp.last_batch)
end as start_time, 
sp.dbid
from sys.sysprocesses as sp
outer apply (select top (1) case
when sp.hostprocess > ''
or r.total_elapsed_time < 0 then r.start_time
else DATEADD(ms, 1000 * ( DATEPART(ms, DATEADD(second, -( r.total_elapsed_time / 1000 ), GETDATE())) / 500 ) - DATEPART(ms, DATEADD(second, -( r.total_elapsed_time / 1000 ), GETDATE())), DATEADD(second, -( r.total_elapsed_time / 1000 ), GETDATE()))
end as start_time
from sys.dm_exec_requests as r
where r.session_id = sp.spid
and r.request_id = sp.request_id) as req
where
					--Process inclusive filter
					1 = case
when @filter <> '' then case @filter_type
when 'session' then case
when CONVERT(smallint, @filter) = 0
or sp.spid = CONVERT(smallint, @filter) then 1
else 0
end
when 'program' then case
when sp.program_name like @filter then 1
else 0
end
when 'login' then case
when sp.loginame like @filter then 1
else 0
end
when 'host' then case
when sp.hostname like @filter then 1
else 0
end
when 'database' then case
when DB_NAME(sp.dbid) like @filter then 1
else 0
end
else 0
end
else 1
end
					--Process exclusive filter
					and 0 = case
when @not_filter <> '' then case @not_filter_type
when 'session' then case
when sp.spid = CONVERT(smallint, @not_filter) then 1
else 0
end
when 'program' then case
when sp.program_name like @not_filter then 1
else 0
end
when 'login' then case
when sp.loginame like @not_filter then 1
else 0
end
when 'host' then case
when sp.hostname like @not_filter then 1
else 0
end
when 'database' then case
when DB_NAME(sp.dbid) like @not_filter then 1
else 0
end
else 0
end
else 0
end
and ( @show_own_spid = 1
or sp.spid <> @@SPID )
and ( @show_system_spids = 1
or sp.hostprocess > '' )
and sp.ecid = 0) as s
inner hash join (select x.resource_type, 
x.database_name, 
x.object_id, 
x.file_id,
case
when x.page_no = 1
or x.page_no % 8088 = 0 then 'PFS'
when x.page_no = 2
or x.page_no % 511232 = 0 then 'GAM'
when x.page_no = 3
or ( x.page_no - 1 ) % 511232 = 0 then 'SGAM'
when x.page_no = 6
or ( x.page_no - 6 ) % 511232 = 0 then 'DCM'
when x.page_no = 7
or ( x.page_no - 7 ) % 511232 = 0 then 'BCM'
when x.page_no is not null then '*'
else null
end as page_type, 
x.hobt_id, 
x.allocation_unit_id, 
x.index_id, 
x.schema_id, 
x.principal_id, 
x.request_mode, 
x.request_status, 
x.session_id, 
x.request_id,
case
when COALESCE(x.object_id, x.file_id, x.hobt_id, x.allocation_unit_id, x.index_id, x.schema_id, x.principal_id) is null then NULLIF(resource_description, '')
else null
end as resource_description, 
COUNT(*) as request_count
from (select tl.resource_type + case
when tl.resource_subtype = '' then ''
else '.' + tl.resource_subtype
end as resource_type, 
COALESCE(DB_NAME(tl.resource_database_id), N'(null)') as database_name, 
CONVERT(int,
case
when tl.resource_type = 'OBJECT' then tl.resource_associated_entity_id
when tl.resource_description like '%object_id = %' then SUBSTRING(tl.resource_description, CHARINDEX('object_id = ', tl.resource_description) + 12, COALESCE(NULLIF(CHARINDEX(',', tl.resource_description, CHARINDEX('object_id = ', tl.resource_description) + 12), 0), DATALENGTH(tl.resource_description) + 1) - ( CHARINDEX('object_id = ', tl.resource_description) + 12 ))
else null
end) as object_id, 
CONVERT(int,
case
when tl.resource_type = 'FILE' then CONVERT(int, tl.resource_description)
when tl.resource_type in('PAGE', 'EXTENT', 'RID') then LEFT(tl.resource_description, CHARINDEX(':', tl.resource_description) - 1)
else null
end) as file_id, 
CONVERT(int,
case
when tl.resource_type in('PAGE', 'EXTENT', 'RID') then SUBSTRING(tl.resource_description, CHARINDEX(':', tl.resource_description) + 1, COALESCE(NULLIF(CHARINDEX(':', tl.resource_description, CHARINDEX(':', tl.resource_description) + 1), 0), DATALENGTH(tl.resource_description) + 1) - ( CHARINDEX(':', tl.resource_description) + 1 ))
else null
end) as page_no,
case
when tl.resource_type in('PAGE', 'KEY', 'RID', 'HOBT') then tl.resource_associated_entity_id
else null
end as hobt_id,
case
when tl.resource_type = 'ALLOCATION_UNIT' then tl.resource_associated_entity_id
else null
end as allocation_unit_id, 
CONVERT(int,
case
when

/********************************
TODO: Deal with server principals
********************************/
tl.resource_subtype <> 'SERVER_PRINCIPAL'
and tl.resource_description like '%index_id or stats_id = %' then SUBSTRING(tl.resource_description, CHARINDEX('index_id or stats_id = ', tl.resource_description) + 23, COALESCE(NULLIF(CHARINDEX(',', tl.resource_description, CHARINDEX('index_id or stats_id = ', tl.resource_description) + 23), 0), DATALENGTH(tl.resource_description) + 1) - ( CHARINDEX('index_id or stats_id = ', tl.resource_description) + 23 ))
else null
end) as index_id, 
CONVERT(int,
case
when tl.resource_description like '%schema_id = %' then SUBSTRING(tl.resource_description, CHARINDEX('schema_id = ', tl.resource_description) + 12, COALESCE(NULLIF(CHARINDEX(',', tl.resource_description, CHARINDEX('schema_id = ', tl.resource_description) + 12), 0), DATALENGTH(tl.resource_description) + 1) - ( CHARINDEX('schema_id = ', tl.resource_description) + 12 ))
else null
end) as schema_id, 
CONVERT(int,
case
when tl.resource_description like '%principal_id = %' then SUBSTRING(tl.resource_description, CHARINDEX('principal_id = ', tl.resource_description) + 15, COALESCE(NULLIF(CHARINDEX(',', tl.resource_description, CHARINDEX('principal_id = ', tl.resource_description) + 15), 0), DATALENGTH(tl.resource_description) + 1) - ( CHARINDEX('principal_id = ', tl.resource_description) + 15 ))
else null
end) as principal_id, 
tl.request_mode, 
tl.request_status, 
tl.request_session_id as session_id, 
tl.request_request_id as request_id,

/******************************************
TODO: Applocks, other resource_descriptions
******************************************/
RTRIM(tl.resource_description) as resource_description, 
tl.resource_associated_entity_id
						/*********************************************/
					from(select request_session_id, CONVERT(VARCHAR(120), resource_type) collate Latin1_General_Bin2 as resource_type, CONVERT(VARCHAR(120), resource_subtype) collate Latin1_General_Bin2 as resource_subtype, resource_database_id, CONVERT(VARCHAR(512), resource_description) collate Latin1_General_Bin2 as resource_description, resource_associated_entity_id, CONVERT(VARCHAR(120), request_mode) collate Latin1_General_Bin2 as request_mode, CONVERT(VARCHAR(120), request_status) collate Latin1_General_Bin2 as request_status, request_request_id from sys.dm_tran_locks) as tl) as x group by x.resource_type, x.database_name, x.object_id, x.file_id,
case when x.page_no=1 or x.page_no%8088=0 then 'PFS' when x.page_no=2 or x.page_no%511232=0 then 'GAM' when x.page_no=3 or(x.page_no-1)%511232=0 then 'SGAM' when x.page_no=6 or(x.page_no-6)%511232=0 then 'DCM' when x.page_no=7 or(x.page_no-7)%511232=0 then 'BCM' when x.page_no is not null then '*' else null end, x.hobt_id, x.allocation_unit_id, x.index_id, x.schema_id, x.principal_id, x.request_mode, x.request_status, x.session_id, x.request_id,
case when COALESCE(x.object_id, x.file_id, x.hobt_id, x.allocation_unit_id, x.index_id, x.schema_id, x.principal_id) is null then NULLIF(resource_description, '') else null end) as y on y.session_id=s.session_id and y.request_id=s.request_id option(hash group);

			--Disable unnecessary autostats on the table
create statistics s_database_name on #locks(database_name) with sample 0 rows, norecompute;
create statistics s_object_id on #locks(object_id) with sample 0 rows, norecompute;
create statistics s_hobt_id on #locks(hobt_id) with sample 0 rows, norecompute;
create statistics s_allocation_unit_id on #locks(allocation_unit_id) with sample 0 rows, norecompute;
create statistics s_index_id on #locks(index_id) with sample 0 rows, norecompute;
create statistics s_schema_id on #locks(schema_id) with sample 0 rows, norecompute;
create statistics s_principal_id on #locks(principal_id) with sample 0 rows, norecompute;
create statistics s_request_id on #locks(request_id) with sample 0 rows, norecompute;
create statistics s_start_time on #locks(start_time) with sample 0 rows, norecompute;
create statistics s_resource_type on #locks(resource_type) with sample 0 rows, norecompute;
create statistics s_object_name on #locks(object_name) with sample 0 rows, norecompute;
create statistics s_schema_name on #locks(schema_name) with sample 0 rows, norecompute;
create statistics s_page_type on #locks(page_type) with sample 0 rows, norecompute;
create statistics s_request_mode on #locks(request_mode) with sample 0 rows, norecompute;
create statistics s_request_status on #locks(request_status) with sample 0 rows, norecompute;
create statistics s_resource_description on #locks(resource_description) with sample 0 rows, norecompute;
create statistics s_index_name on #locks(index_name) with sample 0 rows, norecompute;
create statistics s_principal_name on #locks(principal_name) with sample 0 rows, norecompute;
end;

declare @sql VARCHAR(MAX), @sql_n NVARCHAR(MAX);

set @sql=CONVERT(VARCHAR(MAX), '')+'DECLARE @blocker BIT;
			SET @blocker = 0;
			DECLARE @i INT;
			SET @i = 2147483647;

			DECLARE @sessions TABLE
			(
				session_id SMALLINT NOT NULL,
				request_id INT NOT NULL,
				login_time DATETIME,
				last_request_end_time DATETIME,
				status VARCHAR(30),
				statement_start_offset INT,
				statement_end_offset INT,
				sql_handle BINARY(20),
				host_name NVARCHAR(128),
				login_name NVARCHAR(128),
				program_name NVARCHAR(128),
				database_id SMALLINT,
				memory_usage INT,
				open_tran_count SMALLINT, 
				'+case when @get_task_info<>0 or @find_block_leaders=1 then 'wait_type NVARCHAR(32),
						wait_resource NVARCHAR(256),
						wait_time BIGINT, 
						' else '' end+'blocked SMALLINT,
				is_user_process BIT,
				cmd VARCHAR(32),
				PRIMARY KEY CLUSTERED (session_id, request_id) WITH (IGNORE_DUP_KEY = ON)
			);

			DECLARE @blockers TABLE
			(
				session_id INT NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON)
			);

			BLOCKERS:;

			INSERT @sessions
			(
				session_id,
				request_id,
				login_time,
				last_request_end_time,
				status,
				statement_start_offset,
				statement_end_offset,
				sql_handle,
				host_name,
				login_name,
				program_name,
				database_id,
				memory_usage,
				open_tran_count, 
				'+case when @get_task_info<>0 or @find_block_leaders=1 then 'wait_type,
						wait_resource,
						wait_time, 
						' else '' end+'blocked,
				is_user_process,
				cmd 
			)
			SELECT TOP(@i)
				spy.session_id,
				spy.request_id,
				spy.login_time,
				spy.last_request_end_time,
				spy.status,
				spy.statement_start_offset,
				spy.statement_end_offset,
				spy.sql_handle,
				spy.host_name,
				spy.login_name,
				spy.program_name,
				spy.database_id,
				spy.memory_usage,
				spy.open_tran_count,
				'+case when @get_task_info<>0 or @find_block_leaders=1 then 'spy.wait_type,
						CASE
							WHEN
								spy.wait_type LIKE N''PAGE%LATCH_%''
								OR spy.wait_type = N''CXPACKET''
								OR spy.wait_type LIKE N''LATCH[_]%''
								OR spy.wait_type = N''OLEDB'' THEN
									spy.wait_resource
							ELSE
								NULL
						END AS wait_resource,
						spy.wait_time, 
						' else '' end+'spy.blocked,
				spy.is_user_process,
				spy.cmd
			FROM
			(
				SELECT TOP(@i)
					spx.*, 
					'+case when @get_task_info<>0 or @find_block_leaders=1 then 'ROW_NUMBER() OVER
							(
								PARTITION BY
									spx.session_id,
									spx.request_id
								ORDER BY
									CASE
										WHEN spx.wait_type LIKE N''LCK[_]%'' THEN 
											1
										ELSE
											99
									END,
									spx.wait_time DESC,
									spx.blocked DESC
							) AS r 
							' else '1 AS r 
							' end+'FROM
				(
					SELECT TOP(@i)
						sp0.session_id,
						sp0.request_id,
						sp0.login_time,
						sp0.last_request_end_time,
						LOWER(sp0.status) AS status,
						CASE
							WHEN sp0.cmd = ''CREATE INDEX'' THEN
								0
							ELSE
								sp0.stmt_start
						END AS statement_start_offset,
						CASE
							WHEN sp0.cmd = N''CREATE INDEX'' THEN
								-1
							ELSE
								COALESCE(NULLIF(sp0.stmt_end, 0), -1)
						END AS statement_end_offset,
						sp0.sql_handle,
						sp0.host_name,
						sp0.login_name,
						sp0.program_name,
						sp0.database_id,
						sp0.memory_usage,
						sp0.open_tran_count, 
						'+case when @get_task_info<>0 or @find_block_leaders=1 then 'CASE
									WHEN sp0.wait_time > 0 AND sp0.wait_type <> N''CXPACKET'' THEN
										sp0.wait_type
									ELSE
										NULL
								END AS wait_type,
								CASE
									WHEN sp0.wait_time > 0 AND sp0.wait_type <> N''CXPACKET'' THEN 
										sp0.wait_resource
									ELSE
										NULL
								END AS wait_resource,
								CASE
									WHEN sp0.wait_type <> N''CXPACKET'' THEN
										sp0.wait_time
									ELSE
										0
								END AS wait_time, 
								' else '' end+'sp0.blocked,
						sp0.is_user_process,
						sp0.cmd
					FROM
					(
						SELECT TOP(@i)
							sp1.session_id,
							sp1.request_id,
							sp1.login_time,
							sp1.last_request_end_time,
							sp1.status,
							sp1.cmd,
							sp1.stmt_start,
							sp1.stmt_end,
							MAX(NULLIF(sp1.sql_handle, 0x00)) OVER (PARTITION BY sp1.session_id, sp1.request_id) AS sql_handle,
							sp1.host_name,
							MAX(sp1.login_name) OVER (PARTITION BY sp1.session_id, sp1.request_id) AS login_name,
							sp1.program_name,
							sp1.database_id,
							MAX(sp1.memory_usage)  OVER (PARTITION BY sp1.session_id, sp1.request_id) AS memory_usage,
							MAX(sp1.open_tran_count)  OVER (PARTITION BY sp1.session_id, sp1.request_id) AS open_tran_count,
							sp1.wait_type,
							sp1.wait_resource,
							sp1.wait_time,
							sp1.blocked,
							sp1.hostprocess,
							sp1.is_user_process
						FROM
						(
							SELECT TOP(@i)
								sp2.spid AS session_id,
								CASE sp2.status
									WHEN ''sleeping'' THEN
										CONVERT(INT, 0)
									ELSE
										sp2.request_id
								END AS request_id,
								MAX(sp2.login_time) AS login_time,
								MAX(sp2.last_batch) AS last_request_end_time,
								MAX(CONVERT(VARCHAR(30), RTRIM(sp2.status)) COLLATE Latin1_General_Bin2) AS status,
								MAX(CONVERT(VARCHAR(32), RTRIM(sp2.cmd)) COLLATE Latin1_General_Bin2) AS cmd,
								MAX(sp2.stmt_start) AS stmt_start,
								MAX(sp2.stmt_end) AS stmt_end,
								MAX(sp2.sql_handle) AS sql_handle,
								MAX(CONVERT(sysname, RTRIM(sp2.hostname)) COLLATE SQL_Latin1_General_CP1_CI_AS) AS host_name,
								MAX(CONVERT(sysname, RTRIM(sp2.loginame)) COLLATE SQL_Latin1_General_CP1_CI_AS) AS login_name,
								MAX
								(
									CASE
										WHEN blk.queue_id IS NOT NULL THEN
											N''Service Broker
												database_id: '' + CONVERT(NVARCHAR, blk.database_id) +
												N'' queue_id: '' + CONVERT(NVARCHAR, blk.queue_id)
										ELSE
											CONVERT
											(
												sysname,
												RTRIM(sp2.program_name)
											)
									END COLLATE SQL_Latin1_General_CP1_CI_AS
								) AS program_name,
								MAX(sp2.dbid) AS database_id,
								MAX(sp2.memusage) AS memory_usage,
								MAX(sp2.open_tran) AS open_tran_count,
								RTRIM(sp2.lastwaittype) AS wait_type,
								RTRIM(sp2.waitresource) AS wait_resource,
								MAX(sp2.waittime) AS wait_time,
								COALESCE(NULLIF(sp2.blocked, sp2.spid), 0) AS blocked,
								MAX
								(
									CASE
										WHEN blk.session_id = sp2.spid THEN
											''blocker''
										ELSE
											RTRIM(sp2.hostprocess)
									END
								) AS hostprocess,
								CONVERT
								(
									BIT,
									MAX
									(
										CASE
											WHEN sp2.hostprocess > '''' THEN
												1
											ELSE
												0
										END
									)
								) AS is_user_process
							FROM
							(
								SELECT TOP(@i)
									session_id,
									CONVERT(INT, NULL) AS queue_id,
									CONVERT(INT, NULL) AS database_id
								FROM @blockers

								UNION ALL

								SELECT TOP(@i)
									CONVERT(SMALLINT, 0),
									CONVERT(INT, NULL) AS queue_id,
									CONVERT(INT, NULL) AS database_id
								WHERE
									@blocker = 0

								UNION ALL

								SELECT TOP(@i)
									CONVERT(SMALLINT, spid),
									queue_id,
									database_id
								FROM sys.dm_broker_activated_tasks
								WHERE
									@blocker = 0
							) AS blk
							INNER JOIN sys.sysprocesses AS sp2 ON
								sp2.spid = blk.session_id
								OR
								(
									blk.session_id = 0
									AND @blocker = 0
								)
							'+case when @get_task_info=0 and @find_block_leaders=0 then 'WHERE
										sp2.ecid = 0 
									' else '' end+'GROUP BY
								sp2.spid,
								CASE sp2.status
									WHEN ''sleeping'' THEN
										CONVERT(INT, 0)
									ELSE
										sp2.request_id
								END,
								RTRIM(sp2.lastwaittype),
								RTRIM(sp2.waitresource),
								COALESCE(NULLIF(sp2.blocked, sp2.spid), 0)
						) AS sp1
					) AS sp0
					WHERE
						@blocker = 1
						OR
						(1=1 
						'+
							--inclusive filter
							case when @filter<>'' then case @filter_type when 'session' then case when CONVERT(SMALLINT, @filter)<>0 then 'AND sp0.session_id = CONVERT(SMALLINT, @filter) 
													' else '' end when 'program' then 'AND sp0.program_name LIKE @filter 
											' when 'login' then 'AND sp0.login_name LIKE @filter 
											' when 'host' then 'AND sp0.host_name LIKE @filter 
											' when 'database' then 'AND DB_NAME(sp0.database_id) LIKE @filter 
											' else '' end else '' end+
							--exclusive filter
							case when @not_filter<>'' then case @not_filter_type when 'session' then case when CONVERT(SMALLINT, @not_filter)<>0 then 'AND sp0.session_id <> CONVERT(SMALLINT, @not_filter) 
													' else '' end when 'program' then 'AND sp0.program_name NOT LIKE @not_filter 
											' when 'login' then 'AND sp0.login_name NOT LIKE @not_filter 
											' when 'host' then 'AND sp0.host_name NOT LIKE @not_filter 
											' when 'database' then 'AND DB_NAME(sp0.database_id) NOT LIKE @not_filter 
											' else '' end else '' end+case @show_own_spid when 1 then '' else 'AND sp0.session_id <> @@spid 
									' end+case when @show_system_spids=0 then 'AND sp0.hostprocess > '''' 
									' else '' end+case @show_sleeping_spids when 0 then 'AND sp0.status <> ''sleeping'' 
									' when 1 then 'AND
									(
										sp0.status <> ''sleeping''
										OR sp0.open_tran_count > 0
									)
									' else '' end+')
				) AS spx
			) AS spy
			WHERE
				spy.r = 1; 
			'+case @recursion when 1 then 'IF @@ROWCOUNT > 0
					BEGIN;
						INSERT @blockers
						(
							session_id
						)
						SELECT TOP(@i)
							blocked
						FROM @sessions
						WHERE
							NULLIF(blocked, 0) IS NOT NULL

						EXCEPT

						SELECT TOP(@i)
							session_id
						FROM @sessions; 
						'+case when @get_task_info>0 or @find_block_leaders=1 then 'IF @@ROWCOUNT > 0
								BEGIN;
									SET @blocker = 1;
									GOTO BLOCKERS;
								END; 
								' else '' end+'END; 
					' else '' end+'SELECT TOP(@i)
				@recursion AS recursion,
				x.session_id,
				x.request_id,
				DENSE_RANK() OVER
				(
					ORDER BY
						x.session_id
				) AS session_number,
				'+case when @output_column_list like '%|[dd hh:mm:ss.mss|]%' escape '|' then 'x.elapsed_time ' else '0 ' end+'AS elapsed_time, 
					'+case when(@output_column_list like '%|[dd hh:mm:ss.mss (avg)|]%' escape '|' or @output_column_list like '%|[avg_elapsed_time|]%' escape '|') and @recursion=1 then 'x.avg_elapsed_time / 1000 ' else 'NULL ' end+'AS avg_elapsed_time, 
					'+case when @output_column_list like '%|[physical_io|]%' escape '|' or @output_column_list like '%|[physical_io_delta|]%' escape '|' then 'x.physical_io ' else 'NULL ' end+'AS physical_io, 
					'+case when @output_column_list like '%|[reads|]%' escape '|' or @output_column_list like '%|[reads_delta|]%' escape '|' then 'x.reads ' else '0 ' end+'AS reads, 
					'+case when @output_column_list like '%|[physical_reads|]%' escape '|' or @output_column_list like '%|[physical_reads_delta|]%' escape '|' then 'x.physical_reads ' else '0 ' end+'AS physical_reads, 
					'+case when @output_column_list like '%|[writes|]%' escape '|' or @output_column_list like '%|[writes_delta|]%' escape '|' then 'x.writes ' else '0 ' end+'AS writes, 
					'+case when @output_column_list like '%|[tempdb_allocations|]%' escape '|' or @output_column_list like '%|[tempdb_allocations_delta|]%' escape '|' then 'x.tempdb_allocations ' else '0 ' end+'AS tempdb_allocations, 
					'+case when @output_column_list like '%|[tempdb_current|]%' escape '|' or @output_column_list like '%|[tempdb_current_delta|]%' escape '|' then 'x.tempdb_current ' else '0 ' end+'AS tempdb_current, 
					'+case when @output_column_list like '%|[CPU|]%' escape '|' or @output_column_list like '%|[CPU_delta|]%' escape '|' then 'x.CPU ' else '0 ' end+'AS CPU, 
					'+case when @output_column_list like '%|[CPU_delta|]%' escape '|' and @get_task_info=2 and @sys_info=1 then 'x.thread_CPU_snapshot ' else '0 ' end+'AS thread_CPU_snapshot, 
					'+case when @output_column_list like '%|[context_switches|]%' escape '|' or @output_column_list like '%|[context_switches_delta|]%' escape '|' then 'x.context_switches ' else 'NULL ' end+'AS context_switches, 
					'+case when @output_column_list like '%|[used_memory|]%' escape '|' or @output_column_list like '%|[used_memory_delta|]%' escape '|' then 'x.used_memory ' else '0 ' end+'AS used_memory, 
					'+case when @output_column_list like '%|[tasks|]%' escape '|' and @recursion=1 then 'x.tasks ' else 'NULL ' end+'AS tasks, 
					'+case when(@output_column_list like '%|[status|]%' escape '|' or @output_column_list like '%|[sql_command|]%' escape '|') and @recursion=1 then 'x.status ' else ''''' ' end+'AS status, 
					'+case when @output_column_list like '%|[wait_info|]%' escape '|' and @recursion=1 then case @get_task_info when 2 then 'COALESCE(x.task_wait_info, x.sys_wait_info) ' else 'x.sys_wait_info ' end else 'NULL ' end+'AS wait_info, 
					'+case when(@output_column_list like '%|[tran_start_time|]%' escape '|' or @output_column_list like '%|[tran_log_writes|]%' escape '|') and @recursion=1 then 'x.transaction_id ' else 'NULL ' end+'AS transaction_id, 
					'+case when @output_column_list like '%|[open_tran_count|]%' escape '|' and @recursion=1 then 'x.open_tran_count ' else 'NULL ' end+'AS open_tran_count, 
					'+case when @output_column_list like '%|[sql_text|]%' escape '|' and @recursion=1 then 'x.sql_handle ' else 'NULL ' end+'AS sql_handle, 
					'+case when(@output_column_list like '%|[sql_text|]%' escape '|' or @output_column_list like '%|[query_plan|]%' escape '|') and @recursion=1 then 'x.statement_start_offset ' else 'NULL ' end+'AS statement_start_offset, 
					'+case when(@output_column_list like '%|[sql_text|]%' escape '|' or @output_column_list like '%|[query_plan|]%' escape '|') and @recursion=1 then 'x.statement_end_offset ' else 'NULL ' end+'AS statement_end_offset, 
					'+'NULL AS sql_text, 
					'+case when @output_column_list like '%|[query_plan|]%' escape '|' and @recursion=1 then 'x.plan_handle ' else 'NULL ' end+'AS plan_handle, 
					'+case when @output_column_list like '%|[blocking_session_id|]%' escape '|' and @recursion=1 then 'NULLIF(x.blocking_session_id, 0) ' else 'NULL ' end+'AS blocking_session_id, 
					'+case when @output_column_list like '%|[percent_complete|]%' escape '|' and @recursion=1 then 'x.percent_complete ' else 'NULL ' end+'AS percent_complete, 
					'+case when @output_column_list like '%|[host_name|]%' escape '|' and @recursion=1 then 'x.host_name ' else ''''' ' end+'AS host_name, 
					'+case when @output_column_list like '%|[login_name|]%' escape '|' and @recursion=1 then 'x.login_name ' else ''''' ' end+'AS login_name, 
					'+case when @output_column_list like '%|[database_name|]%' escape '|' and @recursion=1 then 'DB_NAME(x.database_id) ' else 'NULL ' end+'AS database_name, 
					'+case when @output_column_list like '%|[program_name|]%' escape '|' and @recursion=1 then 'x.program_name ' else ''''' ' end+'AS program_name, 
					'+case when @output_column_list like '%|[additional_info|]%' escape '|' and @recursion=1 then '(
									SELECT TOP(@i)
										x.text_size,
										x.language,
										x.date_format,
										x.date_first,
										CASE x.quoted_identifier
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS quoted_identifier,
										CASE x.arithabort
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS arithabort,
										CASE x.ansi_null_dflt_on
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS ansi_null_dflt_on,
										CASE x.ansi_defaults
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS ansi_defaults,
										CASE x.ansi_warnings
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS ansi_warnings,
										CASE x.ansi_padding
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS ansi_padding,
										CASE ansi_nulls
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS ansi_nulls,
										CASE x.concat_null_yields_null
											WHEN 0 THEN ''OFF''
											WHEN 1 THEN ''ON''
										END AS concat_null_yields_null,
										CASE x.transaction_isolation_level
											WHEN 0 THEN ''Unspecified''
											WHEN 1 THEN ''ReadUncomitted''
											WHEN 2 THEN ''ReadCommitted''
											WHEN 3 THEN ''Repeatable''
											WHEN 4 THEN ''Serializable''
											WHEN 5 THEN ''Snapshot''
										END AS transaction_isolation_level,
										x.lock_timeout,
										x.deadlock_priority,
										x.row_count,
										x.command_type, 
										'+case when OBJECT_ID('master.dbo.fn_varbintohexstr') is not null then 'master.dbo.fn_varbintohexstr(x.sql_handle) AS sql_handle,
												master.dbo.fn_varbintohexstr(x.plan_handle) AS plan_handle,' else 'CONVERT(VARCHAR(256), x.sql_handle, 1) AS sql_handle,
												CONVERT(VARCHAR(256), x.plan_handle, 1) AS plan_handle,' end+'
										x.statement_start_offset,
										x.statement_end_offset,
										'+case when @output_column_list like '%|[program_name|]%' escape '|' then '(
													SELECT TOP(1)
														CONVERT(uniqueidentifier, CONVERT(XML, '''').value(''xs:hexBinary( substring(sql:column("agent_info.job_id_string"), 0) )'', ''binary(16)'')) AS job_id,
														agent_info.step_id,
														(
															SELECT TOP(1)
																NULL
															FOR XML
																PATH(''job_name''),
																TYPE
														),
														(
															SELECT TOP(1)
																NULL
															FOR XML
																PATH(''step_name''),
																TYPE
														)
													FROM
													(
														SELECT TOP(1)
															SUBSTRING(x.program_name, CHARINDEX(''0x'', x.program_name) + 2, 32) AS job_id_string,
															SUBSTRING(x.program_name, CHARINDEX('': Step '', x.program_name) + 7, CHARINDEX('')'', x.program_name, CHARINDEX('': Step '', x.program_name)) - (CHARINDEX('': Step '', x.program_name) + 7)) AS step_id
														WHERE
															x.program_name LIKE N''SQLAgent - TSQL JobStep (Job 0x%''
													) AS agent_info
													FOR XML
														PATH(''agent_job_info''),
														TYPE
												),
												' else '' end+case when @get_task_info=2 then 'CONVERT(XML, x.block_info) AS block_info, 
												' else '' end+'
										x.host_process_id,
										x.group_id
									FOR XML
										PATH(''additional_info''),
										TYPE
								) ' else 'NULL ' end+'AS additional_info, 
				x.start_time, 
					'+case when @output_column_list like '%|[login_time|]%' escape '|' and @recursion=1 then 'x.login_time ' else 'NULL ' end+'AS login_time, 
				x.last_request_start_time
			FROM
			(
				SELECT TOP(@i)
					y.*,
					CASE
						WHEN DATEDIFF(hour, y.start_time, GETDATE()) > 576 THEN
							DATEDIFF(second, GETDATE(), y.start_time)
						ELSE DATEDIFF(ms, y.start_time, GETDATE())
					END AS elapsed_time,
					COALESCE(tempdb_info.tempdb_allocations, 0) AS tempdb_allocations,
					COALESCE
					(
						CASE
							WHEN tempdb_info.tempdb_current < 0 THEN 0
							ELSE tempdb_info.tempdb_current
						END,
						0
					) AS tempdb_current, 
					'+case when @get_task_info<>0 or @find_block_leaders=1 then 'N''('' + CONVERT(NVARCHAR, y.wait_duration_ms) + N''ms)'' +
									y.wait_type +
										CASE
											WHEN y.wait_type LIKE N''PAGE%LATCH_%'' THEN
												N'':'' +
												COALESCE(DB_NAME(CONVERT(INT, LEFT(y.resource_description, CHARINDEX(N'':'', y.resource_description) - 1))), N''(null)'') +
												N'':'' +
												SUBSTRING(y.resource_description, CHARINDEX(N'':'', y.resource_description) + 1, LEN(y.resource_description) - CHARINDEX(N'':'', REVERSE(y.resource_description)) - CHARINDEX(N'':'', y.resource_description)) +
												N''('' +
													CASE
														WHEN
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) = 1 OR
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) % 8088 = 0
																THEN 
																	N''PFS''
														WHEN
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) = 2 OR
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) % 511232 = 0
																THEN 
																	N''GAM''
														WHEN
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) = 3 OR
															(CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) - 1) % 511232 = 0
																THEN
																	N''SGAM''
														WHEN
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) = 6 OR
															(CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) - 6) % 511232 = 0 
																THEN 
																	N''DCM''
														WHEN
															CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) = 7 OR
															(CONVERT(INT, RIGHT(y.resource_description, CHARINDEX(N'':'', REVERSE(y.resource_description)) - 1)) - 7) % 511232 = 0 
																THEN 
																	N''BCM''
														ELSE 
															N''*''
													END +
												N'')''
											WHEN y.wait_type = N''CXPACKET'' THEN
												N'':'' + SUBSTRING(y.resource_description, CHARINDEX(N''nodeId'', y.resource_description) + 7, 4)
											WHEN y.wait_type LIKE N''LATCH[_]%'' THEN
												N'' ['' + LEFT(y.resource_description, COALESCE(NULLIF(CHARINDEX(N'' '', y.resource_description), 0), LEN(y.resource_description) + 1) - 1) + N'']''
											WHEN
												y.wait_type = N''OLEDB''
												AND y.resource_description LIKE N''%(SPID=%)'' THEN
													N''['' + LEFT(y.resource_description, CHARINDEX(N''(SPID='', y.resource_description) - 2) +
														N'':'' + SUBSTRING(y.resource_description, CHARINDEX(N''(SPID='', y.resource_description) + 6, CHARINDEX(N'')'', y.resource_description, (CHARINDEX(N''(SPID='', y.resource_description) + 6)) - (CHARINDEX(N''(SPID='', y.resource_description) + 6)) + '']''
											ELSE
												N''''
										END COLLATE Latin1_General_Bin2 AS sys_wait_info, 
										' else '' end+case when @get_task_info=2 then 'tasks.physical_io,
								tasks.context_switches,
								tasks.tasks,
								tasks.block_info,
								tasks.wait_info AS task_wait_info,
								tasks.thread_CPU_snapshot,
								' else '' end+case when not(@get_avg_time=1 and @recursion=1) then 'CONVERT(INT, NULL) ' else 'qs.total_elapsed_time / qs.execution_count ' end+'AS avg_elapsed_time 
				FROM
				(
					SELECT TOP(@i)
						sp.session_id,
						sp.request_id,
						COALESCE(r.logical_reads, s.logical_reads) AS reads,
						COALESCE(r.reads, s.reads) AS physical_reads,
						COALESCE(r.writes, s.writes) AS writes,
						COALESCE(r.CPU_time, s.CPU_time) AS CPU,
						sp.memory_usage + COALESCE(r.granted_query_memory, 0) AS used_memory,
						LOWER(sp.status) AS status,
						COALESCE(r.sql_handle, sp.sql_handle) AS sql_handle,
						COALESCE(r.statement_start_offset, sp.statement_start_offset) AS statement_start_offset,
						COALESCE(r.statement_end_offset, sp.statement_end_offset) AS statement_end_offset,
						'+case when @get_task_info<>0 or @find_block_leaders=1 then 'sp.wait_type COLLATE Latin1_General_Bin2 AS wait_type,
								sp.wait_resource COLLATE Latin1_General_Bin2 AS resource_description,
								sp.wait_time AS wait_duration_ms, 
								' else '' end+'NULLIF(sp.blocked, 0) AS blocking_session_id,
						r.plan_handle,
						NULLIF(r.percent_complete, 0) AS percent_complete,
						sp.host_name,
						sp.login_name,
						sp.program_name,
						s.host_process_id,
						COALESCE(r.text_size, s.text_size) AS text_size,
						COALESCE(r.language, s.language) AS language,
						COALESCE(r.date_format, s.date_format) AS date_format,
						COALESCE(r.date_first, s.date_first) AS date_first,
						COALESCE(r.quoted_identifier, s.quoted_identifier) AS quoted_identifier,
						COALESCE(r.arithabort, s.arithabort) AS arithabort,
						COALESCE(r.ansi_null_dflt_on, s.ansi_null_dflt_on) AS ansi_null_dflt_on,
						COALESCE(r.ansi_defaults, s.ansi_defaults) AS ansi_defaults,
						COALESCE(r.ansi_warnings, s.ansi_warnings) AS ansi_warnings,
						COALESCE(r.ansi_padding, s.ansi_padding) AS ansi_padding,
						COALESCE(r.ansi_nulls, s.ansi_nulls) AS ansi_nulls,
						COALESCE(r.concat_null_yields_null, s.concat_null_yields_null) AS concat_null_yields_null,
						COALESCE(r.transaction_isolation_level, s.transaction_isolation_level) AS transaction_isolation_level,
						COALESCE(r.lock_timeout, s.lock_timeout) AS lock_timeout,
						COALESCE(r.deadlock_priority, s.deadlock_priority) AS deadlock_priority,
						COALESCE(r.row_count, s.row_count) AS row_count,
						COALESCE(r.command, sp.cmd) AS command_type,
						COALESCE
						(
							CASE
								WHEN
								(
									s.is_user_process = 0
									AND r.total_elapsed_time >= 0
								) THEN
									DATEADD
									(
										ms,
										1000 * (DATEPART(ms, DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())) / 500) - DATEPART(ms, DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())),
										DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())
									)
							END,
							NULLIF(COALESCE(r.start_time, sp.last_request_end_time), CONVERT(DATETIME, ''19000101'', 112)),
							sp.login_time
						) AS start_time,
						sp.login_time,
						CASE
							WHEN s.is_user_process = 1 THEN
								s.last_request_start_time
							ELSE
								COALESCE
								(
									DATEADD
									(
										ms,
										1000 * (DATEPART(ms, DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())) / 500) - DATEPART(ms, DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())),
										DATEADD(second, -(r.total_elapsed_time / 1000), GETDATE())
									),
									s.last_request_start_time
								)
						END AS last_request_start_time,
						r.transaction_id,
						sp.database_id,
						sp.open_tran_count,
						'+case when exists(select * from sys.all_columns as ac where ac.object_id=OBJECT_ID('sys.dm_exec_sessions') and ac.name='group_id') then 's.group_id' else 'CONVERT(INT, NULL) AS group_id' end+'
					FROM @sessions AS sp
					LEFT OUTER LOOP JOIN sys.dm_exec_sessions AS s ON
						s.session_id = sp.session_id
						AND s.login_time = sp.login_time
					LEFT OUTER LOOP JOIN sys.dm_exec_requests AS r ON
						sp.status <> ''sleeping''
						AND r.session_id = sp.session_id
						AND r.request_id = sp.request_id
						AND
						(
							(
								s.is_user_process = 0
								AND sp.is_user_process = 0
							)
							OR
							(
								r.start_time = s.last_request_start_time
								AND s.last_request_end_time <= sp.last_request_end_time
							)
						)
				) AS y
				'+case when @get_task_info=2 then CONVERT(VARCHAR(MAX), '')+'LEFT OUTER HASH JOIN
						(
							SELECT TOP(@i)
								task_nodes.task_node.value(''(session_id/text())[1]'', ''SMALLINT'') AS session_id,
								task_nodes.task_node.value(''(request_id/text())[1]'', ''INT'') AS request_id,
								task_nodes.task_node.value(''(physical_io/text())[1]'', ''BIGINT'') AS physical_io,
								task_nodes.task_node.value(''(context_switches/text())[1]'', ''BIGINT'') AS context_switches,
								task_nodes.task_node.value(''(tasks/text())[1]'', ''INT'') AS tasks,
								task_nodes.task_node.value(''(block_info/text())[1]'', ''NVARCHAR(4000)'') AS block_info,
								task_nodes.task_node.value(''(waits/text())[1]'', ''NVARCHAR(4000)'') AS wait_info,
								task_nodes.task_node.value(''(thread_CPU_snapshot/text())[1]'', ''BIGINT'') AS thread_CPU_snapshot
							FROM
							(
								SELECT TOP(@i)
									CONVERT
									(
										XML,
										REPLACE
										(
											CONVERT(NVARCHAR(MAX), tasks_raw.task_xml_raw) COLLATE Latin1_General_Bin2,
											N''</waits></tasks><tasks><waits>'',
											N'', ''
										)
									) AS task_xml
								FROM
								(
									SELECT TOP(@i)
										CASE waits.r
											WHEN 1 THEN
												waits.session_id
											ELSE
												NULL
										END AS [session_id],
										CASE waits.r
											WHEN 1 THEN
												waits.request_id
											ELSE
												NULL
										END AS [request_id],											
										CASE waits.r
											WHEN 1 THEN
												waits.physical_io
											ELSE
												NULL
										END AS [physical_io],
										CASE waits.r
											WHEN 1 THEN
												waits.context_switches
											ELSE
												NULL
										END AS [context_switches],
										CASE waits.r
											WHEN 1 THEN
												waits.thread_CPU_snapshot
											ELSE
												NULL
										END AS [thread_CPU_snapshot],
										CASE waits.r
											WHEN 1 THEN
												waits.tasks
											ELSE
												NULL
										END AS [tasks],
										CASE waits.r
											WHEN 1 THEN
												waits.block_info
											ELSE
												NULL
										END AS [block_info],
										REPLACE
										(
											REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
												CONVERT
												(
													NVARCHAR(MAX),
													N''('' +
														CONVERT(NVARCHAR, num_waits) + N''x: '' +
														CASE num_waits
															WHEN 1 THEN
																CONVERT(NVARCHAR, min_wait_time) + N''ms''
															WHEN 2 THEN
																CASE
																	WHEN min_wait_time <> max_wait_time THEN
																		CONVERT(NVARCHAR, min_wait_time) + N''/'' + CONVERT(NVARCHAR, max_wait_time) + N''ms''
																	ELSE
																		CONVERT(NVARCHAR, max_wait_time) + N''ms''
																END
															ELSE
																CASE
																	WHEN min_wait_time <> max_wait_time THEN
																		CONVERT(NVARCHAR, min_wait_time) + N''/'' + CONVERT(NVARCHAR, avg_wait_time) + N''/'' + CONVERT(NVARCHAR, max_wait_time) + N''ms''
																	ELSE 
																		CONVERT(NVARCHAR, max_wait_time) + N''ms''
																END
														END +
													N'')'' + wait_type COLLATE Latin1_General_Bin2
												),
												NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''),
												NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''),
												NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''),
											NCHAR(0),
											N''''
										) AS [waits]
									FROM
									(
										SELECT TOP(@i)
											w1.*,
											ROW_NUMBER() OVER
											(
												PARTITION BY
													w1.session_id,
													w1.request_id
												ORDER BY
													w1.block_info DESC,
													w1.num_waits DESC,
													w1.wait_type
											) AS r
										FROM
										(
											SELECT TOP(@i)
												task_info.session_id,
												task_info.request_id,
												task_info.physical_io,
												task_info.context_switches,
												task_info.thread_CPU_snapshot,
												task_info.num_tasks AS tasks,
												CASE
													WHEN task_info.runnable_time IS NOT NULL THEN
														''RUNNABLE''
													ELSE
														wt2.wait_type
												END AS wait_type,
												NULLIF(COUNT(COALESCE(task_info.runnable_time, wt2.waiting_task_address)), 0) AS num_waits,
												MIN(COALESCE(task_info.runnable_time, wt2.wait_duration_ms)) AS min_wait_time,
												AVG(COALESCE(task_info.runnable_time, wt2.wait_duration_ms)) AS avg_wait_time,
												MAX(COALESCE(task_info.runnable_time, wt2.wait_duration_ms)) AS max_wait_time,
												MAX(wt2.block_info) AS block_info
											FROM
											(
												SELECT TOP(@i)
													t.session_id,
													t.request_id,
													SUM(CONVERT(BIGINT, t.pending_io_count)) OVER (PARTITION BY t.session_id, t.request_id) AS physical_io,
													SUM(CONVERT(BIGINT, t.context_switches_count)) OVER (PARTITION BY t.session_id, t.request_id) AS context_switches, 
													'+case when @output_column_list like '%|[CPU_delta|]%' escape '|' and @sys_info=1 then 'SUM(tr.usermode_time + tr.kernel_time) OVER (PARTITION BY t.session_id, t.request_id) ' else 'CONVERT(BIGINT, NULL) ' end+' AS thread_CPU_snapshot, 
													COUNT(*) OVER (PARTITION BY t.session_id, t.request_id) AS num_tasks,
													t.task_address,
													t.task_state,
													CASE
														WHEN
															t.task_state = ''RUNNABLE''
															AND w.runnable_time > 0 THEN
																w.runnable_time
														ELSE
															NULL
													END AS runnable_time
												FROM sys.dm_os_tasks AS t
												CROSS APPLY
												(
													SELECT TOP(1)
														sp2.session_id
													FROM @sessions AS sp2
													WHERE
														sp2.session_id = t.session_id
														AND sp2.request_id = t.request_id
														AND sp2.status <> ''sleeping''
												) AS sp20
												LEFT OUTER HASH JOIN
												( 
												'+case when @sys_info=1 then 'SELECT TOP(@i)
																(
																	SELECT TOP(@i)
																		ms_ticks
																	FROM sys.dm_os_sys_info
																) -
																	w0.wait_resumed_ms_ticks AS runnable_time,
																w0.worker_address,
																w0.thread_address,
																w0.task_bound_ms_ticks
															FROM sys.dm_os_workers AS w0
															WHERE
																w0.state = ''RUNNABLE''
																OR @first_collection_ms_ticks >= w0.task_bound_ms_ticks' else 'SELECT
																CONVERT(BIGINT, NULL) AS runnable_time,
																CONVERT(VARBINARY(8), NULL) AS worker_address,
																CONVERT(VARBINARY(8), NULL) AS thread_address,
																CONVERT(BIGINT, NULL) AS task_bound_ms_ticks
															WHERE
																1 = 0' end+'
												) AS w ON
													w.worker_address = t.worker_address 
												'+case when @output_column_list like '%|[CPU_delta|]%' escape '|' and @sys_info=1 then 'LEFT OUTER HASH JOIN sys.dm_os_threads AS tr ON
																tr.thread_address = w.thread_address
																AND @first_collection_ms_ticks >= w.task_bound_ms_ticks
															' else '' end+') AS task_info
											LEFT OUTER HASH JOIN
											(
												SELECT TOP(@i)
													wt1.wait_type,
													wt1.waiting_task_address,
													MAX(wt1.wait_duration_ms) AS wait_duration_ms,
													MAX(wt1.block_info) AS block_info
												FROM
												(
													SELECT DISTINCT TOP(@i)
														wt.wait_type +
															CASE
																WHEN wt.wait_type LIKE N''PAGE%LATCH_%'' THEN
																	'':'' +
																	COALESCE(DB_NAME(CONVERT(INT, LEFT(wt.resource_description, CHARINDEX(N'':'', wt.resource_description) - 1))), N''(null)'') +
																	N'':'' +
																	SUBSTRING(wt.resource_description, CHARINDEX(N'':'', wt.resource_description) + 1, LEN(wt.resource_description) - CHARINDEX(N'':'', REVERSE(wt.resource_description)) - CHARINDEX(N'':'', wt.resource_description)) +
																	N''('' +
																		CASE
																			WHEN
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) = 1 OR
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) % 8088 = 0
																					THEN 
																						N''PFS''
																			WHEN
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) = 2 OR
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) % 511232 = 0 
																					THEN 
																						N''GAM''
																			WHEN
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) = 3 OR
																				(CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) - 1) % 511232 = 0 
																					THEN 
																						N''SGAM''
																			WHEN
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) = 6 OR
																				(CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) - 6) % 511232 = 0 
																					THEN 
																						N''DCM''
																			WHEN
																				CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) = 7 OR
																				(CONVERT(INT, RIGHT(wt.resource_description, CHARINDEX(N'':'', REVERSE(wt.resource_description)) - 1)) - 7) % 511232 = 0
																					THEN 
																						N''BCM''
																			ELSE
																				N''*''
																		END +
																	N'')''
																WHEN wt.wait_type = N''CXPACKET'' THEN
																	N'':'' + SUBSTRING(wt.resource_description, CHARINDEX(N''nodeId'', wt.resource_description) + 7, 4)
																WHEN wt.wait_type LIKE N''LATCH[_]%'' THEN
																	N'' ['' + LEFT(wt.resource_description, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description), 0), LEN(wt.resource_description) + 1) - 1) + N'']''
																ELSE 
																	N''''
															END COLLATE Latin1_General_Bin2 AS wait_type,
														CASE
															WHEN
															(
																wt.blocking_session_id IS NOT NULL
																AND wt.wait_type LIKE N''LCK[_]%''
															) THEN
																(
																	SELECT TOP(@i)
																		x.lock_type,
																		REPLACE
																		(
																			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
																			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
																			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
																				DB_NAME
																				(
																					CONVERT
																					(
																						INT,
																						SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''dbid='', wt.resource_description), 0) + 5, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''dbid='', wt.resource_description) + 5), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''dbid='', wt.resource_description) - 5)
																					)
																				),
																				NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''),
																				NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''),
																				NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''),
																			NCHAR(0),
																			N''''
																		) AS database_name,
																		CASE x.lock_type
																			WHEN N''objectlock'' THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''objid='', wt.resource_description), 0) + 6, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''objid='', wt.resource_description) + 6), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''objid='', wt.resource_description) - 6)
																			ELSE
																				NULL
																		END AS object_id,
																		CASE x.lock_type
																			WHEN N''filelock'' THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''fileid='', wt.resource_description), 0) + 7, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''fileid='', wt.resource_description) + 7), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''fileid='', wt.resource_description) - 7)
																			ELSE
																				NULL
																		END AS file_id,
																		CASE
																			WHEN x.lock_type in (N''pagelock'', N''extentlock'', N''ridlock'') THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''associatedObjectId='', wt.resource_description), 0) + 19, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''associatedObjectId='', wt.resource_description) + 19), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''associatedObjectId='', wt.resource_description) - 19)
																			WHEN x.lock_type in (N''keylock'', N''hobtlock'', N''allocunitlock'') THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''hobtid='', wt.resource_description), 0) + 7, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''hobtid='', wt.resource_description) + 7), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''hobtid='', wt.resource_description) - 7)
																			ELSE
																				NULL
																		END AS hobt_id,
																		CASE x.lock_type
																			WHEN N''applicationlock'' THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''hash='', wt.resource_description), 0) + 5, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''hash='', wt.resource_description) + 5), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''hash='', wt.resource_description) - 5)
																			ELSE
																				NULL
																		END AS applock_hash,
																		CASE x.lock_type
																			WHEN N''metadatalock'' THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''subresource='', wt.resource_description), 0) + 12, COALESCE(NULLIF(CHARINDEX(N'' '', wt.resource_description, CHARINDEX(N''subresource='', wt.resource_description) + 12), 0), LEN(wt.resource_description) + 1) - CHARINDEX(N''subresource='', wt.resource_description) - 12)
																			ELSE
																				NULL
																		END AS metadata_resource,
																		CASE x.lock_type
																			WHEN N''metadatalock'' THEN
																				SUBSTRING(wt.resource_description, NULLIF(CHARINDEX(N''classid='', wt.resource_description), 0) + 8, COALESCE(NULLIF(CHARINDEX(N'' dbid='', wt.resource_description) - CHARINDEX(N''classid='', wt.resource_description), 0), LEN(wt.resource_description) + 1) - 8)
																			ELSE
																				NULL
																		END AS metadata_class_id
																	FROM
																	(
																		SELECT TOP(1)
																			LEFT(wt.resource_description, CHARINDEX(N'' '', wt.resource_description) - 1) COLLATE Latin1_General_Bin2 AS lock_type
																	) AS x
																	FOR XML
																		PATH('''')
																)
															ELSE NULL
														END AS block_info,
														wt.wait_duration_ms,
														wt.waiting_task_address
													FROM
													(
														SELECT TOP(@i)
															wt0.wait_type COLLATE Latin1_General_Bin2 AS wait_type,
															wt0.resource_description COLLATE Latin1_General_Bin2 AS resource_description,
															wt0.wait_duration_ms,
															wt0.waiting_task_address,
															CASE
																WHEN wt0.blocking_session_id = p.blocked THEN
																	wt0.blocking_session_id
																ELSE
																	NULL
															END AS blocking_session_id
														FROM sys.dm_os_waiting_tasks AS wt0
														CROSS APPLY
														(
															SELECT TOP(1)
																s0.blocked
															FROM @sessions AS s0
															WHERE
																s0.session_id = wt0.session_id
																AND COALESCE(s0.wait_type, N'''') <> N''OLEDB''
																AND wt0.wait_type <> N''OLEDB''
														) AS p
													) AS wt
												) AS wt1
												GROUP BY
													wt1.wait_type,
													wt1.waiting_task_address
											) AS wt2 ON
												wt2.waiting_task_address = task_info.task_address
												AND wt2.wait_duration_ms > 0
												AND task_info.runnable_time IS NULL
											GROUP BY
												task_info.session_id,
												task_info.request_id,
												task_info.physical_io,
												task_info.context_switches,
												task_info.thread_CPU_snapshot,
												task_info.num_tasks,
												CASE
													WHEN task_info.runnable_time IS NOT NULL THEN
														''RUNNABLE''
													ELSE
														wt2.wait_type
												END
										) AS w1
									) AS waits
									ORDER BY
										waits.session_id,
										waits.request_id,
										waits.r
									FOR XML
										PATH(N''tasks''),
										TYPE
								) AS tasks_raw (task_xml_raw)
							) AS tasks_final
							CROSS APPLY tasks_final.task_xml.nodes(N''/tasks'') AS task_nodes (task_node)
							WHERE
								task_nodes.task_node.exist(N''session_id'') = 1
						) AS tasks ON
							tasks.session_id = y.session_id
							AND tasks.request_id = y.request_id 
						' else '' end+'LEFT OUTER HASH JOIN
				(
					SELECT TOP(@i)
						t_info.session_id,
						COALESCE(t_info.request_id, -1) AS request_id,
						SUM(t_info.tempdb_allocations) AS tempdb_allocations,
						SUM(t_info.tempdb_current) AS tempdb_current
					FROM
					(
						SELECT TOP(@i)
							tsu.session_id,
							tsu.request_id,
							tsu.user_objects_alloc_page_count +
								tsu.internal_objects_alloc_page_count AS tempdb_allocations,
							tsu.user_objects_alloc_page_count +
								tsu.internal_objects_alloc_page_count -
								tsu.user_objects_dealloc_page_count -
								tsu.internal_objects_dealloc_page_count AS tempdb_current
						FROM sys.dm_db_task_space_usage AS tsu
						CROSS APPLY
						(
							SELECT TOP(1)
								s0.session_id
							FROM @sessions AS s0
							WHERE
								s0.session_id = tsu.session_id
						) AS p

						UNION ALL

						SELECT TOP(@i)
							ssu.session_id,
							NULL AS request_id,
							ssu.user_objects_alloc_page_count +
								ssu.internal_objects_alloc_page_count AS tempdb_allocations,
							ssu.user_objects_alloc_page_count +
								ssu.internal_objects_alloc_page_count -
								ssu.user_objects_dealloc_page_count -
								ssu.internal_objects_dealloc_page_count AS tempdb_current
						FROM sys.dm_db_session_space_usage AS ssu
						CROSS APPLY
						(
							SELECT TOP(1)
								s0.session_id
							FROM @sessions AS s0
							WHERE
								s0.session_id = ssu.session_id
						) AS p
					) AS t_info
					GROUP BY
						t_info.session_id,
						COALESCE(t_info.request_id, -1)
				) AS tempdb_info ON
					tempdb_info.session_id = y.session_id
					AND tempdb_info.request_id =
						CASE
							WHEN y.status = N''sleeping'' THEN
								-1
							ELSE
								y.request_id
						END
				'+case when not(@get_avg_time=1 and @recursion=1) then '' else 'LEFT OUTER HASH JOIN
						(
							SELECT TOP(@i)
								*
							FROM sys.dm_exec_query_stats
						) AS qs ON
							qs.sql_handle = y.sql_handle
							AND qs.plan_handle = y.plan_handle
							AND qs.statement_start_offset = y.statement_start_offset
							AND qs.statement_end_offset = y.statement_end_offset
						' end+') AS x
			OPTION (KEEPFIXED PLAN, OPTIMIZE FOR (@i = 1)); ';

set @sql_n=CONVERT(NVARCHAR(MAX), @sql);

set @last_collection_start=GETDATE();

if @recursion=-1 and @sys_info=1
begin
select @first_collection_ms_ticks=ms_ticks from sys.dm_os_sys_info;
end;

insert into #sessions(recursion, session_id, request_id, session_number, elapsed_time, avg_elapsed_time, physical_io, reads, physical_reads, writes, tempdb_allocations, tempdb_current, CPU, thread_CPU_snapshot, context_switches, used_memory, tasks, status, wait_info, transaction_id, open_tran_count, sql_handle, statement_start_offset, statement_end_offset, sql_text, plan_handle, blocking_session_id, percent_complete, host_name, login_name, database_name, program_name, additional_info, start_time, login_time, last_request_start_time)
exec sp_executesql @sql_n, N'@recursion SMALLINT, @filter sysname, @not_filter sysname, @first_collection_ms_ticks BIGINT', @recursion, @filter, @not_filter, @first_collection_ms_ticks;

		--Collect transaction information?
if @recursion=1 and(@output_column_list like '%|[tran_start_time|]%' escape '|' or @output_column_list like '%|[tran_log_writes|]%' escape '|')
begin
declare @i INT;
set @i=2147483647;

update s set tran_start_time=CONVERT(DATETIME, LEFT(x.trans_info, NULLIF(CHARINDEX(NCHAR(254) collate Latin1_General_Bin2, x.trans_info)-1, -1)), 121), tran_log_writes=RIGHT(x.trans_info, LEN(x.trans_info)-CHARINDEX(NCHAR(254) collate Latin1_General_Bin2, x.trans_info)) from(select top (@i) trans_nodes.trans_node.value('(session_id/text())[1]', 'SMALLINT') as session_id, COALESCE(trans_nodes.trans_node.value('(request_id/text())[1]', 'INT'), 0) as request_id, trans_nodes.trans_node.value('(trans_info/text())[1]', 'NVARCHAR(4000)') as trans_info from(select top (@i) CONVERT(XML, REPLACE(CONVERT(NVARCHAR(MAX), trans_raw.trans_xml_raw) collate Latin1_General_Bin2, N'</trans_info></trans><trans><trans_info>', N'')) from(select top (@i) case u_trans.r when 1 then u_trans.session_id else null end as session_id,
case u_trans.r when 1 then u_trans.request_id else null end as request_id, CONVERT(NVARCHAR(MAX),
case when u_trans.database_id is not null then case u_trans.r when 1 then COALESCE(CONVERT(NVARCHAR, u_trans.transaction_start_time, 121)+NCHAR(254), N'') else N'' end+REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(128), COALESCE(DB_NAME(u_trans.database_id), N'(null)')), NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'?')+N': '+CONVERT(NVARCHAR, u_trans.log_record_count)+N' ('+CONVERT(NVARCHAR, u_trans.log_kb_used)+N' kB)'+N',' else N'N/A,' end collate Latin1_General_Bin2) as trans_info from(select top (@i) trans.*, ROW_NUMBER() over(partition by trans.session_id, trans.request_id order by trans.transaction_start_time desc) as r from(select top (@i) session_tran_map.session_id, session_tran_map.request_id, s_tran.database_id, COALESCE(SUM(s_tran.database_transaction_log_record_count), 0) as log_record_count, COALESCE(SUM(s_tran.database_transaction_log_bytes_used), 0)/1024 as log_kb_used, MIN(s_tran.database_transaction_begin_time) as transaction_start_time from(select top (@i) * from sys.dm_tran_active_transactions where transaction_begin_time<=@last_collection_start) as a_tran inner hash join(select top (@i) * from sys.dm_tran_database_transactions where database_id<32767) as s_tran on s_tran.transaction_id=a_tran.transaction_id left outer hash join(select top (@i) * from sys.dm_tran_session_transactions) as tst on s_tran.transaction_id=tst.transaction_id cross apply(select top (1) s3.session_id, s3.request_id from(select top (1) s1.session_id, s1.request_id from #sessions as s1 where s1.transaction_id=s_tran.transaction_id and s1.recursion=1
union all
select top (1) s2.session_id, s2.request_id from #sessions as s2 where s2.session_id=tst.session_id and s2.recursion=1) as s3 order by s3.request_id) as session_tran_map group by session_tran_map.session_id, session_tran_map.request_id, s_tran.database_id) as trans) as u_trans for xml path('trans'), type) as trans_raw(trans_xml_raw)) as trans_final(trans_xml) cross apply trans_final.trans_xml.nodes('/trans') as trans_nodes(trans_node)) as x inner hash join #sessions as s on s.session_id=x.session_id and s.request_id=x.request_id option(optimize for(@i=1));
end;

		--Variables for text and plan collection
declare @session_id SMALLINT, @request_id INT, @sql_handle VARBINARY(64), @plan_handle VARBINARY(64), @statement_start_offset INT, @statement_end_offset INT, @start_time DATETIME, @database_name sysname;

if @recursion=1 and @output_column_list like '%|[sql_text|]%' escape '|'
begin
declare sql_cursor cursor local fast_forward
for select session_id, request_id, sql_handle, statement_start_offset, statement_end_offset from #sessions where recursion=1 and sql_handle is not null option(keepfixed plan);

open sql_cursor;

fetch next from sql_cursor into @session_id, @request_id, @sql_handle, @statement_start_offset, @statement_end_offset;

			--Wait up to 5 ms for the SQL text, then give up
set lock_timeout 5;

while @@FETCH_STATUS=0
begin
begin try
update s set s.sql_text=(select REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(N'--'+NCHAR(13)+NCHAR(10)+case when @get_full_inner_text=1 then est.text when LEN(est.text)<@statement_end_offset/2+1 then est.text when SUBSTRING(est.text, @statement_start_offset/2, 2) like N'[a-zA-Z0-9][a-zA-Z0-9]' then est.text else case when @statement_start_offset>0 then SUBSTRING(est.text, @statement_start_offset/2+1,
case when @statement_end_offset=-1 then 2147483647 else(@statement_end_offset-@statement_start_offset)/2+1 end) else RTRIM(LTRIM(est.text)) end end+NCHAR(13)+NCHAR(10)+N'--' collate Latin1_General_Bin2, NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'') as [processing-instruction(query)] for xml path(''), type), s.statement_start_offset=case when LEN(est.text)<@statement_end_offset/2+1 then 0 when SUBSTRING(CONVERT(VARCHAR(MAX), est.text), @statement_start_offset/2, 2) like '[a-zA-Z0-9][a-zA-Z0-9]' then 0 else @statement_start_offset end, s.statement_end_offset=case when LEN(est.text)<@statement_end_offset/2+1 then -1 when SUBSTRING(CONVERT(VARCHAR(MAX), est.text), @statement_start_offset/2, 2) like '[a-zA-Z0-9][a-zA-Z0-9]' then -1 else @statement_end_offset end from #sessions as s, (select top (1) text from(select text, 0 as row_num from sys.dm_exec_sql_text(@sql_handle)
union all
select null, 1 as row_num) as est0 order by row_num) as est where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end try
begin catch
update s set s.sql_text=case ERROR_NUMBER() when 1222 then '<timeout_exceeded />' else '<error message="'+ERROR_MESSAGE()+'" />' end from #sessions as s where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end catch;

fetch next from sql_cursor into @session_id, @request_id, @sql_handle, @statement_start_offset, @statement_end_offset;
end;

			--Return this to the default
set lock_timeout-1;

close sql_cursor;
deallocate sql_cursor;
end;

if @get_outer_command=1 and @recursion=1 and @output_column_list like '%|[sql_command|]%' escape '|'
begin
declare @buffer_results table(EventType VARCHAR(30), Parameters INT, EventInfo NVARCHAR(4000), start_time DATETIME, session_number INT identity(1, 1) not null primary key);

declare buffer_cursor cursor local fast_forward
for select session_id, MAX(start_time) as start_time from #sessions where recursion=1 group by session_id order by session_id option(keepfixed plan);

open buffer_cursor;

fetch next from buffer_cursor into @session_id, @start_time;

while @@FETCH_STATUS=0
begin
begin try
					--In SQL Server 2008, DBCC INPUTBUFFER will throw 
					--an exception if the session no longer exists
insert into @buffer_results(EventType, Parameters, EventInfo)
exec sp_executesql N'DBCC INPUTBUFFER(@session_id) WITH NO_INFOMSGS;', N'@session_id SMALLINT', @session_id;

update br set br.start_time=@start_time from @buffer_results as br where br.session_number=(select MAX(br2.session_number) from @buffer_results as br2);
end try
begin catch
end catch;

fetch next from buffer_cursor into @session_id, @start_time;
end;

update s set sql_command=(select REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), N'--'+NCHAR(13)+NCHAR(10)+br.EventInfo+NCHAR(13)+NCHAR(10)+N'--' collate Latin1_General_Bin2), NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'') as [processing-instruction(query)] from @buffer_results as br where br.session_number=s.session_number and br.start_time=s.start_time and(s.start_time=s.last_request_start_time and exists(select * from sys.dm_exec_requests as r2 where r2.session_id=s.session_id and r2.request_id=s.request_id and r2.start_time=s.start_time) or s.request_id=0 and exists(select * from sys.dm_exec_sessions as s2 where s2.session_id=s.session_id and s2.last_request_start_time=s.last_request_start_time)) for xml path(''), type) from #sessions as s where recursion=1 option(keepfixed plan);

close buffer_cursor;
deallocate buffer_cursor;
end;

if @get_plans>=1 and @recursion=1 and @output_column_list like '%|[query_plan|]%' escape '|'
begin
declare @live_plan BIT;
set @live_plan=ISNULL(CONVERT(BIT, SIGN(OBJECT_ID('sys.dm_exec_query_statistics_xml'))), 0);

declare plan_cursor cursor local fast_forward
for select session_id, request_id, plan_handle, statement_start_offset, statement_end_offset from #sessions where recursion=1 and plan_handle is not null option(keepfixed plan);

open plan_cursor;

fetch next from plan_cursor into @session_id, @request_id, @plan_handle, @statement_start_offset, @statement_end_offset;

			--Wait up to 5 ms for a query plan, then give up
set lock_timeout 5;

while @@FETCH_STATUS=0
begin
declare @query_plan XML;
set @query_plan=null;

if @live_plan=1
begin
begin try
select @query_plan=x.query_plan from sys.dm_exec_query_statistics_xml(@session_id) as x;

if @query_plan is not null and exists(select * from sys.dm_exec_requests as r where r.session_id=@session_id and r.request_id=@request_id and r.plan_handle=@plan_handle and r.statement_start_offset=@statement_start_offset and r.statement_end_offset=@statement_end_offset)
begin
update s set s.query_plan=@query_plan from #sessions as s where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end;
end try
begin catch
set @query_plan=null;
end catch;
end;

if @query_plan is null
begin
begin try
update s set s.query_plan=(select CONVERT(xml, query_plan) from sys.dm_exec_text_query_plan(@plan_handle,
case @get_plans when 1 then @statement_start_offset else 0 end,
case @get_plans when 1 then @statement_end_offset else-1 end)) from #sessions as s where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end try
begin catch
if ERROR_NUMBER()=6335
begin
update s set s.query_plan=(select N'--'+NCHAR(13)+NCHAR(10)+N'-- Could not render showplan due to XML data type limitations. '+NCHAR(13)+NCHAR(10)+N'-- To see the graphical plan save the XML below as a .SQLPLAN file and re-open in SSMS.'+NCHAR(13)+NCHAR(10)+N'--'+NCHAR(13)+NCHAR(10)+REPLACE(qp.query_plan, N'<RelOp', NCHAR(13)+NCHAR(10)+N'<RelOp')+NCHAR(13)+NCHAR(10)+N'--' collate Latin1_General_Bin2 as [processing-instruction(query_plan)] from sys.dm_exec_text_query_plan(@plan_handle,
case @get_plans when 1 then @statement_start_offset else 0 end,
case @get_plans when 1 then @statement_end_offset else-1 end) as qp for xml path(''), type) from #sessions as s where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end;
else
begin
update s set s.query_plan=case ERROR_NUMBER() when 1222 then '<timeout_exceeded />' else '<error message="'+ERROR_MESSAGE()+'" />' end from #sessions as s where s.session_id=@session_id and s.request_id=@request_id and s.recursion=1 option(keepfixed plan);
end;
end catch;
end;

fetch next from plan_cursor into @session_id, @request_id, @plan_handle, @statement_start_offset, @statement_end_offset;
end;

			--Return this to the default
set lock_timeout-1;

close plan_cursor;
deallocate plan_cursor;
end;

if @get_locks=1 and @recursion=1 and @output_column_list like '%|[locks|]%' escape '|'
begin
declare locks_cursor cursor local fast_forward
for select distinct database_name from #locks where exists(select * from #sessions as s where s.session_id=#locks.session_id and recursion=1) and database_name<>'(null)' option(keepfixed plan);

open locks_cursor;

fetch next from locks_cursor into @database_name;

while @@FETCH_STATUS=0
begin
begin try
set @sql_n=CONVERT(NVARCHAR(MAX), '')+'UPDATE l '+'SET '+'object_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'o.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+'), '+'index_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'i.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+'), '+'schema_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'s.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+'), '+'principal_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'dp.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+') '+'FROM #locks AS l '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.allocation_units AS au ON '+'au.allocation_unit_id = l.allocation_unit_id '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.partitions AS p ON '+'p.hobt_id = '+'COALESCE '+'( '+'l.hobt_id, '+'CASE '+'WHEN au.type IN (1, 3) THEN au.container_id '+'ELSE NULL '+'END '+') '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.partitions AS p1 ON '+'l.hobt_id IS NULL '+'AND au.type = 2 '+'AND p1.partition_id = au.container_id '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.objects AS o ON '+'o.object_id = COALESCE(l.object_id, p.object_id, p1.object_id) '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.indexes AS i ON '+'i.object_id = COALESCE(l.object_id, p.object_id, p1.object_id) '+'AND i.index_id = COALESCE(l.index_id, p.index_id, p1.index_id) '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.schemas AS s ON '+'s.schema_id = COALESCE(l.schema_id, o.schema_id) '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.database_principals AS dp ON '+'dp.principal_id = l.principal_id '+'WHERE '+'l.database_name = @database_name '+'OPTION (KEEPFIXED PLAN); ';

exec sp_executesql @sql_n, N'@database_name sysname', @database_name;
end try
begin catch
update #locks set query_error=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), ERROR_MESSAGE() collate Latin1_General_Bin2), NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'') where database_name=@database_name option(keepfixed plan);
end catch;

fetch next from locks_cursor into @database_name;
end;

close locks_cursor;
deallocate locks_cursor;

create clustered index IX_SRD on #locks(session_id, request_id, database_name);

update s set s.locks=(select REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), l1.database_name collate Latin1_General_Bin2), NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'') as [Database/@name], MIN(l1.query_error) as [Database/@query_error], (select l2.request_mode as [Lock/@request_mode], l2.request_status as [Lock/@request_status], COUNT(*) as [Lock/@request_count] from #locks as l2 where l1.session_id=l2.session_id and l1.request_id=l2.request_id and l2.database_name=l1.database_name and l2.resource_type='DATABASE' group by l2.request_mode, l2.request_status for xml path(''), type) as [Database/Locks], (select COALESCE(l3.object_name, '(null)') as [Object/@name], l3.schema_name as [Object/@schema_name], (select l4.resource_type as [Lock/@resource_type], l4.page_type as [Lock/@page_type], l4.index_name as [Lock/@index_name],
case when l4.object_name is null then l4.schema_name else null end as [Lock/@schema_name], l4.principal_name as [Lock/@principal_name], l4.resource_description as [Lock/@resource_description], l4.request_mode as [Lock/@request_mode], l4.request_status as [Lock/@request_status], SUM(l4.request_count) as [Lock/@request_count] from #locks as l4 where l4.session_id=l3.session_id and l4.request_id=l3.request_id and l3.database_name=l4.database_name and COALESCE(l3.object_name, '(null)')=COALESCE(l4.object_name, '(null)') and COALESCE(l3.schema_name, '')=COALESCE(l4.schema_name, '') and l4.resource_type<>'DATABASE' group by l4.resource_type, l4.page_type, l4.index_name,
case when l4.object_name is null then l4.schema_name else null end, l4.principal_name, l4.resource_description, l4.request_mode, l4.request_status for xml path(''), type) as [Object/Locks] from #locks as l3 where l3.session_id=l1.session_id and l3.request_id=l1.request_id and l3.database_name=l1.database_name and l3.resource_type<>'DATABASE' group by l3.session_id, l3.request_id, l3.database_name, COALESCE(l3.object_name, '(null)'), l3.schema_name for xml path(''), type) as [Database/Objects] from #locks as l1 where l1.session_id=s.session_id and l1.request_id=s.request_id and l1.start_time in(s.start_time, s.last_request_start_time) and s.recursion=1 group by l1.session_id, l1.request_id, l1.database_name for xml path(''), type) from #sessions s option(keepfixed plan);
end;

if @find_block_leaders=1 and @recursion=1 and @output_column_list like '%|[blocked_session_count|]%' escape '|'
begin
with blockers
as (select session_id, session_id as top_level_session_id, CONVERT(VARCHAR(8000), '.'+CONVERT(VARCHAR(8000), session_id)+'.') as the_path from #sessions where recursion=1
union all
select s.session_id, b.top_level_session_id, CONVERT(VARCHAR(8000), b.the_path+CONVERT(VARCHAR(8000), s.session_id)+'.') as the_path from blockers as b join #sessions as s on s.blocking_session_id=b.session_id and s.recursion=1 and b.the_path not like '%.'+CONVERT(VARCHAR(8000), s.session_id)+'.%' collate Latin1_General_Bin2)
update s set s.blocked_session_count=x.blocked_session_count from #sessions as s join(select b.top_level_session_id as session_id, COUNT(*)-1 as blocked_session_count from blockers as b group by b.top_level_session_id) x on s.session_id=x.session_id where s.recursion=1;
end;

if @get_task_info=2 and @output_column_list like '%|[additional_info|]%' escape '|' and @recursion=1
begin
create table #blocked_requests(session_id SMALLINT not null, request_id INT not null, database_name sysname not null, object_id INT, hobt_id BIGINT, schema_id INT, schema_name sysname null, object_name sysname null, query_error NVARCHAR(2048), primary key(database_name, session_id, request_id));

create statistics s_database_name on #blocked_requests(database_name) with sample 0 rows, norecompute;
create statistics s_schema_name on #blocked_requests(schema_name) with sample 0 rows, norecompute;
create statistics s_object_name on #blocked_requests(object_name) with sample 0 rows, norecompute;
create statistics s_query_error on #blocked_requests(query_error) with sample 0 rows, norecompute;

insert into #blocked_requests(session_id, request_id, database_name, object_id, hobt_id, schema_id)
select session_id, request_id, database_name, object_id, hobt_id, CONVERT(INT, SUBSTRING(schema_node, CHARINDEX(' = ', schema_node)+3, LEN(schema_node))) as schema_id from(select session_id, request_id, agent_nodes.agent_node.value('(database_name/text())[1]', 'sysname') as database_name, agent_nodes.agent_node.value('(object_id/text())[1]', 'int') as object_id, agent_nodes.agent_node.value('(hobt_id/text())[1]', 'bigint') as hobt_id, agent_nodes.agent_node.value('(metadata_resource/text()[.="SCHEMA"]/../../metadata_class_id/text())[1]', 'varchar(100)') as schema_node from #sessions as s cross apply s.additional_info.nodes('//block_info') as agent_nodes(agent_node) where s.recursion=1) as t where t.database_name is not null and(t.object_id is not null or t.hobt_id is not null or t.schema_node is not null);

declare blocks_cursor cursor local fast_forward
for select distinct database_name from #blocked_requests;

open blocks_cursor;

fetch next from blocks_cursor into @database_name;

while @@FETCH_STATUS=0
begin
begin try
set @sql_n=CONVERT(NVARCHAR(MAX), '')+'UPDATE b '+'SET '+'b.schema_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'s.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+'), '+'b.object_name = '+'REPLACE '+'( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( '+'o.name COLLATE Latin1_General_Bin2, '+'NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''), '+'NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''), '+'NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''), '+'NCHAR(0), '+N''''' '+') '+'FROM #blocked_requests AS b '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.partitions AS p ON '+'p.hobt_id = b.hobt_id '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.objects AS o ON '+'o.object_id = COALESCE(p.object_id, b.object_id) '+'LEFT OUTER JOIN '+QUOTENAME(@database_name)+'.sys.schemas AS s ON '+'s.schema_id = COALESCE(o.schema_id, b.schema_id) '+'WHERE '+'b.database_name = @database_name; ';

exec sp_executesql @sql_n, N'@database_name sysname', @database_name;
end try
begin catch
update #blocked_requests set query_error=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), ERROR_MESSAGE() collate Latin1_General_Bin2), NCHAR(31), N'?'), NCHAR(30), N'?'), NCHAR(29), N'?'), NCHAR(28), N'?'), NCHAR(27), N'?'), NCHAR(26), N'?'), NCHAR(25), N'?'), NCHAR(24), N'?'), NCHAR(23), N'?'), NCHAR(22), N'?'), NCHAR(21), N'?'), NCHAR(20), N'?'), NCHAR(19), N'?'), NCHAR(18), N'?'), NCHAR(17), N'?'), NCHAR(16), N'?'), NCHAR(15), N'?'), NCHAR(14), N'?'), NCHAR(12), N'?'), NCHAR(11), N'?'), NCHAR(8), N'?'), NCHAR(7), N'?'), NCHAR(6), N'?'), NCHAR(5), N'?'), NCHAR(4), N'?'), NCHAR(3), N'?'), NCHAR(2), N'?'), NCHAR(1), N'?'), NCHAR(0), N'') where database_name=@database_name;
end catch;

fetch next from blocks_cursor into @database_name;
end;

close blocks_cursor;
deallocate blocks_cursor;

update s set additional_info.modify('
					insert <schema_name>{sql:column("b.schema_name")}</schema_name>
					as last
					into (/additional_info/block_info)[1]
				') from #sessions as s inner join #blocked_requests as b on b.session_id=s.session_id and b.request_id=s.request_id and s.recursion=1 where b.schema_name is not null;

update s set additional_info.modify('
					insert <object_name>{sql:column("b.object_name")}</object_name>
					as last
					into (/additional_info/block_info)[1]
				') from #sessions as s inner join #blocked_requests as b on b.session_id=s.session_id and b.request_id=s.request_id and s.recursion=1 where b.object_name is not null;

update s set additional_info.modify('
					insert <query_error>{sql:column("b.query_error")}</query_error>
					as last
					into (/additional_info/block_info)[1]
				') from #sessions as s inner join #blocked_requests as b on b.session_id=s.session_id and b.request_id=s.request_id and s.recursion=1 where b.query_error is not null;
end;

if @output_column_list like '%|[program_name|]%' escape '|' and @output_column_list like '%|[additional_info|]%' escape '|' and @recursion=1 and DB_ID('msdb') is not null
begin
set @sql_n=N'BEGIN TRY;
					DECLARE @job_name sysname;
					SET @job_name = NULL;
					DECLARE @step_name sysname;
					SET @step_name = NULL;

					SELECT
						@job_name = 
							REPLACE
							(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
									j.name,
									NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''),
									NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''),
									NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''),
								NCHAR(0),
								N''?''
							),
						@step_name = 
							REPLACE
							(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
									s.step_name,
									NCHAR(31),N''?''),NCHAR(30),N''?''),NCHAR(29),N''?''),NCHAR(28),N''?''),NCHAR(27),N''?''),NCHAR(26),N''?''),NCHAR(25),N''?''),NCHAR(24),N''?''),NCHAR(23),N''?''),NCHAR(22),N''?''),
									NCHAR(21),N''?''),NCHAR(20),N''?''),NCHAR(19),N''?''),NCHAR(18),N''?''),NCHAR(17),N''?''),NCHAR(16),N''?''),NCHAR(15),N''?''),NCHAR(14),N''?''),NCHAR(12),N''?''),
									NCHAR(11),N''?''),NCHAR(8),N''?''),NCHAR(7),N''?''),NCHAR(6),N''?''),NCHAR(5),N''?''),NCHAR(4),N''?''),NCHAR(3),N''?''),NCHAR(2),N''?''),NCHAR(1),N''?''),
								NCHAR(0),
								N''?''
							)
					FROM msdb.dbo.sysjobs AS j
					INNER JOIN msdb.dbo.sysjobsteps AS s ON
						j.job_id = s.job_id
					WHERE
						j.job_id = @job_id
						AND s.step_id = @step_id;

					IF @job_name IS NOT NULL
					BEGIN;
						UPDATE s
						SET
							additional_info.modify
							(''
								insert text{sql:variable("@job_name")}
								into (/additional_info/agent_job_info/job_name)[1]
							'')
						FROM #sessions AS s
						WHERE 
							s.session_id = @session_id
							AND s.recursion = 1
						OPTION (KEEPFIXED PLAN);
						
						UPDATE s
						SET
							additional_info.modify
							(''
								insert text{sql:variable("@step_name")}
								into (/additional_info/agent_job_info/step_name)[1]
							'')
						FROM #sessions AS s
						WHERE 
							s.session_id = @session_id
							AND s.recursion = 1
						OPTION (KEEPFIXED PLAN);
					END;
				END TRY
				BEGIN CATCH;
					DECLARE @msdb_error_message NVARCHAR(256);
					SET @msdb_error_message = ERROR_MESSAGE();
				
					UPDATE s
					SET
						additional_info.modify
						(''
							insert <msdb_query_error>{sql:variable("@msdb_error_message")}</msdb_query_error>
							as last
							into (/additional_info/agent_job_info)[1]
						'')
					FROM #sessions AS s
					WHERE 
						s.session_id = @session_id
						AND s.recursion = 1
					OPTION (KEEPFIXED PLAN);
				END CATCH;';

declare @job_id UNIQUEIDENTIFIER;
declare @step_id INT;

declare agent_cursor cursor local fast_forward
for select s.session_id, agent_nodes.agent_node.value('(job_id/text())[1]', 'uniqueidentifier') as job_id, agent_nodes.agent_node.value('(step_id/text())[1]', 'int') as step_id from #sessions as s cross apply s.additional_info.nodes('//agent_job_info') as agent_nodes(agent_node) where s.recursion=1 option(keepfixed plan);

open agent_cursor;

fetch next from agent_cursor into @session_id, @job_id, @step_id;

while @@FETCH_STATUS=0
begin
exec sp_executesql @sql_n, N'@job_id UNIQUEIDENTIFIER, @step_id INT, @session_id SMALLINT', @job_id, @step_id, @session_id;

fetch next from agent_cursor into @session_id, @job_id, @step_id;
end;

close agent_cursor;
deallocate agent_cursor;
end;

if @delta_interval>0 and @recursion<>1
begin
set @recursion=1;

declare @delay_time CHAR(12);
set @delay_time=CONVERT(VARCHAR, DATEADD(second, @delta_interval, 0), 114);
waitfor delay @delay_time;

goto REDO;
end;
end;

set @sql= 
		--Outer column list
		CONVERT(VARCHAR(MAX),
case when @destination_table<>'' and @return_schema=0 then 'INSERT '+@destination_table+' ' else '' end+'SELECT '+@output_column_list+' '+case @return_schema when 1 then 'INTO #session_schema ' else '' end
		--End outer column list
		)+ 
		--Inner column list
		CONVERT(VARCHAR(MAX), 'FROM '+'( '+'SELECT '+'session_id, '+
					--[dd hh:mm:ss.mss]
					case when @format_output in(1, 2) then 'CASE '+'WHEN elapsed_time < 0 THEN '+'RIGHT '+'( '+'REPLICATE(''0'', max_elapsed_length) + CONVERT(VARCHAR, (-1 * elapsed_time) / 86400), '+'max_elapsed_length '+') + '+'RIGHT '+'( '+'CONVERT(VARCHAR, DATEADD(second, (-1 * elapsed_time), 0), 120), '+'9 '+') + '+'''.000'' '+'ELSE '+'RIGHT '+'( '+'REPLICATE(''0'', max_elapsed_length) + CONVERT(VARCHAR, elapsed_time / 86400000), '+'max_elapsed_length '+') + '+'RIGHT '+'( '+'CONVERT(VARCHAR, DATEADD(second, elapsed_time / 1000, 0), 120), '+'9 '+') + '+'''.'' + '+'RIGHT(''000'' + CONVERT(VARCHAR, elapsed_time % 1000), 3) '+'END AS [dd hh:mm:ss.mss], ' else '' end+
					--[dd hh:mm:ss.mss (avg)] / avg_elapsed_time
					case when @format_output in(1, 2) then 'RIGHT '+'( '+'''00'' + CONVERT(VARCHAR, avg_elapsed_time / 86400000), '+'2 '+') + '+'RIGHT '+'( '+'CONVERT(VARCHAR, DATEADD(second, avg_elapsed_time / 1000, 0), 120), '+'9 '+') + '+'''.'' + '+'RIGHT(''000'' + CONVERT(VARCHAR, avg_elapsed_time % 1000), 3) AS [dd hh:mm:ss.mss (avg)], ' else 'avg_elapsed_time, ' end+
					--physical_io
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, physical_io))) OVER() - LEN(CONVERT(VARCHAR, physical_io))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_io), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_io), 1), 19)) AS ' else '' end+'physical_io, '+
					--reads
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, reads))) OVER() - LEN(CONVERT(VARCHAR, reads))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, reads), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, reads), 1), 19)) AS ' else '' end+'reads, '+
					--physical_reads
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, physical_reads))) OVER() - LEN(CONVERT(VARCHAR, physical_reads))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_reads), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_reads), 1), 19)) AS ' else '' end+'physical_reads, '+
					--writes
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, writes))) OVER() - LEN(CONVERT(VARCHAR, writes))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, writes), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, writes), 1), 19)) AS ' else '' end+'writes, '+
					--tempdb_allocations
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, tempdb_allocations))) OVER() - LEN(CONVERT(VARCHAR, tempdb_allocations))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_allocations), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_allocations), 1), 19)) AS ' else '' end+'tempdb_allocations, '+
					--tempdb_current
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, tempdb_current))) OVER() - LEN(CONVERT(VARCHAR, tempdb_current))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_current), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_current), 1), 19)) AS ' else '' end+'tempdb_current, '+
					--CPU
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, CPU))) OVER() - LEN(CONVERT(VARCHAR, CPU))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, CPU), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, CPU), 1), 19)) AS ' else '' end+'CPU, '+
					--context_switches
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, context_switches))) OVER() - LEN(CONVERT(VARCHAR, context_switches))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, context_switches), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, context_switches), 1), 19)) AS ' else '' end+'context_switches, '+
					--used_memory
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, used_memory))) OVER() - LEN(CONVERT(VARCHAR, used_memory))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, used_memory), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, used_memory), 1), 19)) AS ' else '' end+'used_memory, '+case when @output_column_list like '%|_delta|]%' escape '|' then
							--physical_io_delta			
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND physical_io_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, physical_io_delta))) OVER() - LEN(CONVERT(VARCHAR, physical_io_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_io_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_io_delta), 1), 19)) ' else 'physical_io_delta ' end+'ELSE NULL '+'END AS physical_io_delta, '+
							--reads_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND reads_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, reads_delta))) OVER() - LEN(CONVERT(VARCHAR, reads_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, reads_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, reads_delta), 1), 19)) ' else 'reads_delta ' end+'ELSE NULL '+'END AS reads_delta, '+
							--physical_reads_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND physical_reads_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, physical_reads_delta))) OVER() - LEN(CONVERT(VARCHAR, physical_reads_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_reads_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, physical_reads_delta), 1), 19)) ' else 'physical_reads_delta ' end+'ELSE NULL '+'END AS physical_reads_delta, '+
							--writes_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND writes_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, writes_delta))) OVER() - LEN(CONVERT(VARCHAR, writes_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, writes_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, writes_delta), 1), 19)) ' else 'writes_delta ' end+'ELSE NULL '+'END AS writes_delta, '+
							--tempdb_allocations_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND tempdb_allocations_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, tempdb_allocations_delta))) OVER() - LEN(CONVERT(VARCHAR, tempdb_allocations_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_allocations_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_allocations_delta), 1), 19)) ' else 'tempdb_allocations_delta ' end+'ELSE NULL '+'END AS tempdb_allocations_delta, '+
							--tempdb_current_delta
							--this is the only one that can (legitimately) go negative 
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, tempdb_current_delta))) OVER() - LEN(CONVERT(VARCHAR, tempdb_current_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_current_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tempdb_current_delta), 1), 19)) ' else 'tempdb_current_delta ' end+'ELSE NULL '+'END AS tempdb_current_delta, '+
							--CPU_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'THEN '+'CASE '+'WHEN '+'thread_CPU_delta > CPU_delta '+'AND thread_CPU_delta > 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, thread_CPU_delta + CPU_delta))) OVER() - LEN(CONVERT(VARCHAR, thread_CPU_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, thread_CPU_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, thread_CPU_delta), 1), 19)) ' else 'thread_CPU_delta ' end+'WHEN CPU_delta >= 0 THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, thread_CPU_delta + CPU_delta))) OVER() - LEN(CONVERT(VARCHAR, CPU_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, CPU_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, CPU_delta), 1), 19)) ' else 'CPU_delta ' end+'ELSE NULL '+'END '+'ELSE '+'NULL '+'END AS CPU_delta, '+
							--context_switches_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND context_switches_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, context_switches_delta))) OVER() - LEN(CONVERT(VARCHAR, context_switches_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, context_switches_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, context_switches_delta), 1), 19)) ' else 'context_switches_delta ' end+'ELSE NULL '+'END AS context_switches_delta, '+
							--used_memory_delta
							'CASE '+'WHEN '+'first_request_start_time = last_request_start_time '+'AND num_events = 2 '+'AND used_memory_delta >= 0 '+'THEN '+case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, used_memory_delta))) OVER() - LEN(CONVERT(VARCHAR, used_memory_delta))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, used_memory_delta), 1), 19)) ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, used_memory_delta), 1), 19)) ' else 'used_memory_delta ' end+'ELSE NULL '+'END AS used_memory_delta, ' else '' end+
					--tasks
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, tasks))) OVER() - LEN(CONVERT(VARCHAR, tasks))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tasks), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, tasks), 1), 19)) ' else '' end+'tasks, '+'status, '+'wait_info, '+'locks, '+'tran_start_time, '+'LEFT(tran_log_writes, LEN(tran_log_writes) - 1) AS tran_log_writes, '+
					--open_tran_count
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, open_tran_count))) OVER() - LEN(CONVERT(VARCHAR, open_tran_count))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, open_tran_count), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, open_tran_count), 1), 19)) AS ' else '' end+'open_tran_count, '+
					--sql_command
					case @format_output when 0 then 'REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), sql_command), ''<?query --''+CHAR(13)+CHAR(10), ''''), CHAR(13)+CHAR(10)+''--?>'', '''') AS ' else '' end+'sql_command, '+
					--sql_text
					case @format_output when 0 then 'REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), sql_text), ''<?query --''+CHAR(13)+CHAR(10), ''''), CHAR(13)+CHAR(10)+''--?>'', '''') AS ' else '' end+'sql_text, '+'query_plan, '+'blocking_session_id, '+
					--blocked_session_count
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, blocked_session_count))) OVER() - LEN(CONVERT(VARCHAR, blocked_session_count))) + LEFT(CONVERT(CHAR(22), CONVERT(MONEY, blocked_session_count), 1), 19)) AS ' when 2 then 'CONVERT(VARCHAR, LEFT(CONVERT(CHAR(22), CONVERT(MONEY, blocked_session_count), 1), 19)) AS ' else '' end+'blocked_session_count, '+
					--percent_complete
					case @format_output when 1 then 'CONVERT(VARCHAR, SPACE(MAX(LEN(CONVERT(VARCHAR, CONVERT(MONEY, percent_complete), 2))) OVER() - LEN(CONVERT(VARCHAR, CONVERT(MONEY, percent_complete), 2))) + CONVERT(CHAR(22), CONVERT(MONEY, percent_complete), 2)) AS ' when 2 then 'CONVERT(VARCHAR, CONVERT(CHAR(22), CONVERT(MONEY, blocked_session_count), 1)) AS ' else '' end+'percent_complete, '+'host_name, '+'login_name, '+'database_name, '+'program_name, '+'additional_info, '+'start_time, '+'login_time, '+'CASE '+'WHEN status = N''sleeping'' THEN NULL '+'ELSE request_id '+'END AS request_id, '+'GETDATE() AS collection_time '
		--End inner column list
		)+
		--Derived table and INSERT specification
		CONVERT(VARCHAR(MAX), 'FROM '+'( '+'SELECT TOP(2147483647) '+'*, '+'CASE '+'MAX '+'( '+'LEN '+'( '+'CONVERT '+'( '+'VARCHAR, '+'CASE '+'WHEN elapsed_time < 0 THEN '+'(-1 * elapsed_time) / 86400 '+'ELSE '+'elapsed_time / 86400000 '+'END '+') '+') '+') OVER () '+'WHEN 1 THEN 2 '+'ELSE '+'MAX '+'( '+'LEN '+'( '+'CONVERT '+'( '+'VARCHAR, '+'CASE '+'WHEN elapsed_time < 0 THEN '+'(-1 * elapsed_time) / 86400 '+'ELSE '+'elapsed_time / 86400000 '+'END '+') '+') '+') OVER () '+'END AS max_elapsed_length, '+case when @output_column_list like '%|_delta|]%' escape '|' then 'MAX(physical_io * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(physical_io * recursion) OVER (PARTITION BY session_id, request_id) AS physical_io_delta, '+'MAX(reads * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(reads * recursion) OVER (PARTITION BY session_id, request_id) AS reads_delta, '+'MAX(physical_reads * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(physical_reads * recursion) OVER (PARTITION BY session_id, request_id) AS physical_reads_delta, '+'MAX(writes * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(writes * recursion) OVER (PARTITION BY session_id, request_id) AS writes_delta, '+'MAX(tempdb_allocations * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(tempdb_allocations * recursion) OVER (PARTITION BY session_id, request_id) AS tempdb_allocations_delta, '+'MAX(tempdb_current * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(tempdb_current * recursion) OVER (PARTITION BY session_id, request_id) AS tempdb_current_delta, '+'MAX(CPU * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(CPU * recursion) OVER (PARTITION BY session_id, request_id) AS CPU_delta, '+'MAX(thread_CPU_snapshot * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(thread_CPU_snapshot * recursion) OVER (PARTITION BY session_id, request_id) AS thread_CPU_delta, '+'MAX(context_switches * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(context_switches * recursion) OVER (PARTITION BY session_id, request_id) AS context_switches_delta, '+'MAX(used_memory * recursion) OVER (PARTITION BY session_id, request_id) + '+'MIN(used_memory * recursion) OVER (PARTITION BY session_id, request_id) AS used_memory_delta, '+'MIN(last_request_start_time) OVER (PARTITION BY session_id, request_id) AS first_request_start_time, ' else '' end+'COUNT(*) OVER (PARTITION BY session_id, request_id) AS num_events '+'FROM #sessions AS s1 '+case when @sort_order='' then '' else 'ORDER BY '+@sort_order end+') AS s '+'WHERE '+'s.recursion = 1 '+') x '+'OPTION (KEEPFIXED PLAN); '+''+case @return_schema when 1 then 'SET @schema = '+'''CREATE TABLE <table_name> ( '' + '+'STUFF '+'( '+'( '+'SELECT '+''','' + '+'QUOTENAME(COLUMN_NAME) + '' '' + '+'DATA_TYPE + '+'CASE '+'WHEN DATA_TYPE LIKE ''%char'' THEN ''('' + COALESCE(NULLIF(CONVERT(VARCHAR, CHARACTER_MAXIMUM_LENGTH), ''-1''), ''max'') + '') '' '+'ELSE '' '' '+'END + '+'CASE IS_NULLABLE '+'WHEN ''NO'' THEN ''NOT '' '+'ELSE '''' '+'END + ''NULL'' AS [text()] '+'FROM tempdb.INFORMATION_SCHEMA.COLUMNS '+'WHERE '+'TABLE_NAME = (SELECT name FROM tempdb.sys.objects WHERE object_id = OBJECT_ID(''tempdb..#session_schema'')) '+'ORDER BY '+'ORDINAL_POSITION '+'FOR XML '+'PATH('''') '+'), + '+'1, '+'1, '+''''' '+') + '+''')''; ' else '' end
		--End derived table and INSERT specification
		);

set @sql_n=CONVERT(NVARCHAR(MAX), @sql);

exec sp_executesql @sql_n, N'@schema VARCHAR(MAX) OUTPUT', @schema output;
end;
go