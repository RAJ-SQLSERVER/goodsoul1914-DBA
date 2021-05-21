/********************************************
 Tracking tempdb growth using Extended Events
********************************************/

-- Create an Extended Event session

create event session [PublicToilet] on server add event sqlserver.database_file_size_change(action(sqlserver.session_id, sqlserver.database_id, sqlserver.client_hostname, sqlserver.sql_text) where database_id = 2
																																																	 and session_id > 50), add event sqlserver.databases_log_file_used_size_changed(action(sqlserver.session_id, sqlserver.database_id, sqlserver.client_hostname, sqlserver.sql_text) where database_id = 2
																																																																																															 and session_id > 50) add target package0.asynchronous_file_target(set filename = N'c:\temp\publictoilet.xel', metadatafile = N'c:\temp\publictoilet.xem', max_file_size = (10), max_rollover_files = 10) with
(max_memory = 4096 kb, event_retention_mode = allow_single_event_loss, max_dispatch_latency = 1 seconds, max_event_size = 0 kb, memory_partition_mode = none, track_causality = on, startup_state = on);
go

alter event session [PublicToilet] on server state = start;

-- Abuse tempdb

use [tempdb];
set nocount on;

if OBJECT_ID('tempdb..#Users') is not null
	drop table dbo.#Users;

dbcc shrinkfile('tempdev', 1);
dbcc shrinkfile('temp2', 1);
dbcc shrinkfile('temp3', 1);
dbcc shrinkfile('temp4', 1);
dbcc shrinkfile('temp5', 1);
dbcc shrinkfile('temp6', 1);
dbcc shrinkfile('temp7', 1);
dbcc shrinkfile('temp8', 1);

dbcc shrinkfile('templog', 1);

create table #Users
(
	Id          int null, 
	Age         int null, 
	DisplayName nvarchar(40) null, 
	AboutMe     nvarchar(max) null);

declare @i int = 0;
declare @rc varchar(20) = 0;

while @i < 3
begin
	insert into #Users (Id, 
						Age, 
						DisplayName, 
						AboutMe) 
	select top (75000) Id, 
					   Age, 
					   DisplayName, 
					   AboutMe
	from StackOverflow2010.dbo.Users;

	update u1
	set u1.DisplayName = SUBSTRING(CAST(NEWID() as nvarchar(max)), 0, 40), u1.Age = u2.Age * 2, u1.AboutMe = REPLACE(u2.AboutMe, 'a', CAST(NEWID() as nvarchar(max)))
	from #Users u1
	cross join #Users u2;

	set @rc = @@ROWCOUNT;
	raiserror('Current # rows %s', 0, 1, @rc) with nowait;

	set @i+=1;
	raiserror('Current # runs %i', 0, 1, @i) with nowait;
end;

-- Look at the result

select evts.event_data.[value]('(event/action[@name="session_id"]/value)[1]', 'INT') as SessionID, 
	   evts.event_data.[value]('(event/action[@name="client_hostname"]/value)[1]', 'VARCHAR(MAX)') as ClientHostName, 
	   COALESCE(DB_NAME(evts.event_data.[value]('(event/action[@name="database_id"]/value)[1]', 'BIGINT')), ';(._.); I AM KING KRAB') as OriginatingDB, 
	   DB_NAME(evts.event_data.[value]('(event/data[@name="database_id"]/value)[1]', 'BIGINT')) as GrowthDB, 
	   evts.event_data.[value]('(event/data[@name="file_name"]/value)[1]', 'VARCHAR(MAX)') as GrowthFile, 
	   evts.event_data.[value]('(event/data[@name="file_type"]/text)[1]', 'VARCHAR(MAX)') as DBFileType, 
	   evts.event_data.[value]('(event/@name)[1]', 'VARCHAR(MAX)') as EventName, 
	   evts.event_data.[value]('(event/data[@name="size_change_kb"]/value)[1]', 'BIGINT') as SizeChangeInKb, 
	   evts.event_data.[value]('(event/data[@name="total_size_kb"]/value)[1]', 'BIGINT') as TotalFileSizeInKb, 
	   evts.event_data.[value]('(event/data[@name="duration"]/value)[1]', 'BIGINT') as DurationInMS, 
	   evts.event_data.[value]('(event/@timestamp)[1]', 'VARCHAR(MAX)') as GrowthTime, 
	   evts.event_data.[value]('(event/action[@name="sql_text"]/value)[1]', 'VARCHAR(MAX)') as QueryText
from (select CAST(event_data as xml) as TargetData
	  from sys.fn_xe_file_target_read_file('c:\temp\publictoilet*.xel', null, null, null)) as evts(event_data)
where evts.event_data.[value]('(event/@name)[1]', 'VARCHAR(MAX)') = 'database_file_size_change'
	  or evts.event_data.[value]('(event/@name)[1]', 'VARCHAR(MAX)') = 'databases_log_file_used_size_changed'
order by GrowthTime asc;