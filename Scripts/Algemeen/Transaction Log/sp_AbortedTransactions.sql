/*****************************************************************************
============================================================================
  File:     sp_AbortedTransactions.sql
  
  Summary:  This script cracks the transaction log and shows which
            transactions were rolled back after a crash
  
  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
  
  (c) 2017, SQLskills.com. All rights reserved.
  
  For more scripts and sample code, check out 
    http://www.SQLskills.com
  
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
    
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================
*****************************************************************************/

use [master];
go

if OBJECT_ID(N'sp_AbortedTransactions') is not null
	drop procedure sp_AbortedTransactions;
go

create procedure sp_AbortedTransactions
as
begin
	set nocount on;

	dbcc traceon(2537);

	declare @BootTime datetime;
	declare @XactID char(13);

	select @BootTime = sqlserver_start_time
	from sys.dm_os_sys_info;

	if exists (select *
			   from tempdb.sys.objects
			   where name = N'##SQLskills_Log_Analysis') 
		drop table ##SQLskills_Log_Analysis;

	-- Get the list of started and rolled back transactions from the log
	select [Begin Time], 
		   [Transaction Name], 
		   SUSER_SNAME([Transaction SID]) as [Started By], 
		   [Transaction ID], 
		   [End Time], 
		   0 as RolledBackAfterCrash, 
		   Operation
	into ##SQLskills_Log_Analysis
	from fn_dblog(null, null)
	where Operation = 'LOP_BEGIN_XACT'
		  and [Begin Time] < @BootTime
		  or Operation = 'LOP_ABORT_XACT'
		  and [End Time] > @BootTime;

	declare [LogAnalysis] cursor fast_forward
	for select [Transaction ID]
		from ##SQLskills_Log_Analysis;

	open [LogAnalysis];

	fetch next from [LogAnalysis] into @XactID;

	while @@FETCH_STATUS = 0
	begin
		if exists (select [End Time]
				   from ##SQLskills_Log_Analysis
				   where Operation = 'LOP_ABORT_XACT'
						 and [Transaction ID] = @XactID) 
			update ##SQLskills_Log_Analysis
			set RolledBackAfterCrash = 1
			where [Transaction ID] = @XactID
				  and Operation = 'LOP_BEGIN_XACT';

		fetch next from [LogAnalysis] into @XactID;
	end;

	close [LogAnalysis];
	deallocate [LogAnalysis];

	select [Begin Time], 
		   [Transaction Name], 
		   [Started By], 
		   [Transaction ID]
	from ##SQLskills_Log_Analysis
	where RolledBackAfterCrash = 1;

	dbcc traceoff(2537);

	drop table ##SQLskills_Log_Analysis;
end;
go

exec sys.sp_MS_marksystemobject sp_AbortedTransactions;
go

-- USE [Company]; EXEC sp_AbortedTransactions;