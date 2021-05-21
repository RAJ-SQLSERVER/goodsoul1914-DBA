/*****************************************************************************
   File: SQLskillsSPConfigureChanged.sql

   Summary: This script reports the time that sp_configure options were
			last changed

   SQL Server Versions:
         2005 RTM onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
	
  (c) 2011, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
*****************************************************************************/

set nocount on;

-- Create the temp table
--
if exists
(
	select *
	from msdb.sys.objects
	where NAME = 'SQLskillsDBCCPage'
) 
	drop table msdb.dbo.SQLskillsDBCCPage;

create table msdb.dbo.SQLskillsDBCCPage
(
	ParentObject varchar(100), 
	Object       varchar(100), 
	Field        varchar(100), 
	[VALUE]      varchar(100));

declare @hours int;
declare @minutes int;
declare @seconds int;
declare @milliseconds bigint;
declare @LastUpdateTime datetime;
declare @upddate int;
declare @updtime bigint;
declare @dbccPageString varchar(200);

-- Build the dynamic SQL
--
select @dbccPageString = 'DBCC PAGE (master, 1, 10, 3) WITH TABLERESULTS, NO_INFOMSGS';

-- Empty out the temp table and insert into it again
--
insert into msdb.dbo.SQLskillsDBCCPage
exec (@dbccPageString);

select @updtime = [VALUE]
from msdb.dbo.SQLskillsDBCCPage
where Field = 'cfgupdtime';

select @upddate = [VALUE]
from msdb.dbo.SQLskillsDBCCPage
where Field = 'cfgupddate';

-- Convert updtime to seconds
select @milliseconds = CONVERT(int, CONVERT(float, @updtime) * ( 3 + 1.0 / 3 ));
select @updtime = @milliseconds / 1000;

-- Pull out hours, minutes, seconds, milliseconds
select @hours = @updtime / 3600;
select @minutes = ( @updtime % 3600 ) / 60;
select @seconds = @updtime - @hours * 3600 - @minutes * 60;

-- Calculate number of milliseconds
select @milliseconds = @milliseconds - @seconds * 1000 - @minutes * 60 * 1000 - @hours * 3600 * 1000;

-- No messy conversion code required for the date as SQL Server can do it for us
select @LastUpdateTime = DATEADD(DAY, @upddate, '1900-01-01');

-- And add in the hours, minutes, seconds, and milliseconds
-- There are nicer functions to do this but they don't work in 2005/2008
select @LastUpdateTime = DATEADD(HOUR, @hours, @LastUpdateTime);
select @LastUpdateTime = DATEADD(MINUTE, @minutes, @LastUpdateTime);
select @LastUpdateTime = DATEADD(SECOND, @seconds, @LastUpdateTime);
select @LastUpdateTime = DATEADD(MILLISECOND, @milliseconds, @LastUpdateTime);
select @LastUpdateTime as 'sp_configure options last updated';

-- Clean up
--
drop table msdb.dbo.SQLskillsDBCCPage;
go