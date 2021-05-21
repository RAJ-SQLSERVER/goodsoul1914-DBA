-- String split function
---------------------------------------------------------------------------------------------------

select *
from STRING_SPLIT('It''s.about.time', '.');
go

-- not really full-featured yet

select *
from STRING_SPLIT('I...test.    test 2  .  .        test3.   .', '.');
go

-- but workable

select RTRIM(LTRIM(value))
from STRING_SPLIT('I...test.    test 2  .  .        test3.   .', '.')
where RTRIM(LTRIM(value)) <> '';
go

-- output row number

select RTRIM(LTRIM(value)), 
	   ROW_NUMBER() over(
	   order by
(
	select null
) )
from STRING_SPLIT('I...test.    test 2  .  .        test3.   .', '.')
where RTRIM(LTRIM(value)) <> '';
go

-- Session context
---------------------------------------------------------------------------------------------------

declare @info varbinary(128)= CONVERT(varbinary, 'hello');

set CONTEXT_INFO @info;
go

select CONTEXT_INFO();
go

-- SQL 2016: 
-- Set a named slot

exec sys.sp_set_session_context @key = N'My favorite password', @value = 'P@$$w0rd';
go

-- Retrieve a named slot (returns sqlvariant = 128KB of data)

select SESSION_CONTEXT(N'My favorite password');
go

-- Readonly values

exec sys.sp_set_session_context @key = N'access_control_key', @value = 0x00, @readonly = 1;
go

select SESSION_CONTEXT(N'access_control_key');
go

exec sys.sp_set_session_context @key = N'access_control_key', @value = 0x01;
go

-- Temporal tables
---------------------------------------------------------------------------------------------------

create table temporal_test
(
	i              int not null primary key, 
	j              int, 
	start_datetime datetime2 generated always as row start, 
	end_datetime   datetime2 generated always as row end, 
	period for system_time(start_datetime, end_datetime)) with(system_versioning = on);
go

insert into temporal_test (i, 
						   j) 
select 1, 
	   2
union all
select 2, 
	   3;
go

-- update the temporal table

update temporal_test
set j = 123
where i = 1;
go

delete temporal_test
where i = 2;
go

-- query the temporal table

select *
from temporal_test for system_time between '2020-01-01' and '9999-12-31'
order by i, 
		 start_datetime;
go

-- just dropping it will not work

drop table temporal_test;
go

-- first turn of versioning

alter table temporal_test set(system_versioning = off);
go

drop table temporal_test;
go

-- Real timezone support
---------------------------------------------------------------------------------------------------

select SYSDATETIMEOFFSET();
go

select *
from sys.time_zone_info;
go

-- What time is it in London?

select SYSDATETIMEOFFSET() at time zone 'GMT Standard Time';
go

-- DST awareness
-- On march 26 at 05:00 EST, what time was it in London?

select CONVERT(datetime, '2019-03-26 05:00:00') at time zone 'Eastern Standard Time' at time zone 'GMT Standard Time'; 
go

-- best practice, use UTC for everything, always, and convert...

declare @desired_time_zone varchar(50) = 'W. Europe Standard Time';

SELECT  SYSDATETIMEOFFSET() AT TIME ZONE 'UTC' AT TIME ZONE @desired_time_zone;
go

-- Security 
---------------------------------------------------------------------------------------------------

declare @data nvarchar(max) = 'This is some data to hash';

select HASHBYTES('SHA2_512', @data);
go

declare @data nvarchar(max)= REPLICATE(CONVERT(nvarchar(max), N'data to hash'), 10000);

select HASHBYTES('SHA2_512', @data);
go

-- the bad news

declare @data nvarchar(max)= REPLICATE(CONVERT(nvarchar(max), N'data to hash'), 10000);

select ENCRYPTBYPASSPHRASE('p@$$w0rd', @data, 0, null);
go

-- Query processor insight
---------------------------------------------------------------------------------------------------

use tempdb;
go

select *
from sys.dm_os_wait_stats;
go

/*********************************************
-- new tab...make some I/O waits
USE tempdb
GO

CREATE TABLE iowaits
(
    i INT IDENTITY(1, 1) NOT NULL,
    j VARCHAR(100) NOT NULL,
    PRIMARY KEY (i)
)
GO

INSERT iowaits(j) VALUES (REPLICATE('a', 200))
GO

INSERT iowaits(j)
SELECT TOP 20000 j
FROM iowaits
ORDER BY NEWID()
OPTION (MAXDOP 1)
GO 500
*********************************************/

-- check out our I/O waits

select *
from sys.dm_os_wait_stats
where wait_type = 'IO_COMPLETION';
go

-- what is happening now?

select *
from sys.dm_os_waiting_tasks
where wait_type = 'IO_COMPLETION';
go

-- what happened HISTORICALLY?

select *
from sys.dm_exec_session_wait_stats
where wait_type = 'IO_COMPLETION';
go

-- Getting the input buffer
---------------------------------------------------------------------------------------------------
-- the old way

dbcc inputbuffer(54);
go

-- the new way

select t.*, 
	   b.*
from sys.dm_exec_requests as r
	 cross apply sys.dm_exec_sql_text (r.plan_handle) as t
	 cross apply sys.dm_exec_input_buffer (r.session_id, r.request_id) as b
where r.session_id = 54;
go

-- Manageability
---------------------------------------------------------------------------------------------------

use tempdb;
go

select configuration_id, 
	   name, 
	   value, 
	   value_for_secondary
from sys.database_scoped_configurations;
go

alter database scoped configuration

/************
FOR SECONDARY
************/
set maxdop = 4;
go

-- Data Storage
---------------------------------------------------------------------------------------------------

use StackOverflow2010;
go

exec sp_spaceused 'dbo.Posts';