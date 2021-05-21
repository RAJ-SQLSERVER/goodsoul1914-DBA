use master;
go

-- Create a new database

create database XEventsDemo;
go

use XEventsDemo;
go

-- Create a table and track the wait statistics for it

create table DummyTable
(
	Col1 int identity(1, 1) not null primary key, 
	Col2 int, 
	Col3 char(8000));
go

-- Open a new session and use that session id
-- ...
-- Create a new event session that collects wait statistics for the
-- current session

create event session CollectWaitStatistics on server add event sqlos.wait_info(where sqlserver.session_id = 55) add target package0.event_file(set FILENAME = 'c:\temp\CollectWaitStatistics.xel');
go

-- Start the Event Session

alter event session CollectWaitStatistics on server state = start;
go

-- Execute the code from the other session
-- ...
-- Drop the previously created Event Session

drop event session CollectWaitStatistics on server;
go