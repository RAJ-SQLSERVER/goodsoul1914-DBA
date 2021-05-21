/*****************************************************************************
  File:     sp_AnalyzeTransactionLog.sql
 
  Summary:  This script cracks the transaction log and prints a hierarchy of
            transactions
 
  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
 
  (c) 2016, SQLskills.com. All rights reserved.
 
  For more scripts and sample code, check out 
    http://www.SQLskills.com
 
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
*****************************************************************************/

use [master];
go

if OBJECT_ID(N'sp_AnalyzeTransactionLog') is not null
	drop procedure sp_AnalyzeTransactionLog;
go

if OBJECT_ID(N'sp_AnalyzeTransactionLogInner') is not null
	drop procedure sp_AnalyzeTransactionLogInner;
go

create procedure sp_AnalyzeTransactionLogInner
(
	@XactID as char(13), 
	@Depth as  int) 
as
begin
	declare @String varchar(8000);
	declare @InsertString varchar(8000);
	declare @Name varchar(256);
	declare @ID int;

	declare @SubXactID char(13);
	declare @SubDepth int = @Depth + 3;

	declare [LogAnalysisX] cursor fast_forward local
	for select [Transaction ID], 
			   [Transaction Name]
		from   ##SQLskills_Log_Analysis
		where  [Parent Transaction ID] = @XactID;

	open [LogAnalysisX];

	fetch next from [LogAnalysisX] into @SubXactID, 
										@Name;

	while @@FETCH_STATUS = 0
	begin
		select @InsertString = REPLICATE('.', @Depth) + @Name;

		-- Select the last transaction name inserted into the table
		select top 1 @ID = ID, 
					 @String = XactName
		from         ##SQLskills_Log_Analysis2
		order by ID desc;

		if @String = @InsertString
			update ##SQLskills_Log_Analysis2
			set    Times = Times + 1
			where  ID = @ID;
		else
			insert into ##SQLskills_Log_Analysis2
			values      (
				@InsertString, 1);

		-- Recurse...
		exec sp_AnalyzeTransactionLogInner @SubXactID, @SubDepth;

		fetch next from [LogAnalysisX] into @SubXactID, 
											@Name;
	end;

	close [LogAnalysisX];
	deallocate [LogAnalysisX];
end;
go

create procedure sp_AnalyzeTransactionLog
(
	-- The name of a database, default of master
	@DBName      sysname     = N'master',

	-- Detailed = 0 means just the transaction name
	-- Detailed = 1 means time and user
	@Detailed    int         = 0,

	-- Deep = 0 means only the top-level transactions
	-- Deep = 1 means sub-transaction hierarchy (slow!)
	@Deep        int         = 0,

	-- PrintOption = 0 means SELECT as a resultset
	-- PrintOption = 1 means PRINT as text
	@PrintOption varchar(25) = 0) 
as
begin
	set nocount on;

	if exists (select *
			   from   tempdb.sys.objects
			   where  name = N'##SQLskills_Log_Analysis') 
		drop table ##SQLskills_Log_Analysis;

	if exists (select *
			   from   tempdb.sys.objects
			   where  name = N'##SQLskills_Log_Analysis2') 
		drop table ##SQLskills_Log_Analysis2;

	-- Only get the detailed info if we need it
	if @Detailed = 1
		exec ('USE '+@DBName+';'+'SELECT [Transaction ID], [Transaction Name], [Parent Transaction ID],'+'[Begin Time], SUSER_SNAME ([Transaction SID]) AS [Who] '+'INTO ##SQLskills_Log_Analysis FROM fn_dblog (null,null) '+'WHERE [Operation] = ''LOP_BEGIN_XACT'';');
	else
		exec ('USE '+@DBName+';'+'SELECT [Transaction ID], [Transaction Name], [Parent Transaction ID],'+'NULL AS [Begin Time], NULL AS [Who]'+'INTO ##SQLskills_Log_Analysis FROM fn_dblog (null,null) '+'WHERE [Operation] = ''LOP_BEGIN_XACT'';');

	create table ##SQLskills_Log_Analysis2
	(
		ID       int identity, 
		XactName varchar(8000), 
		Times    int);

	create clustered index ID_CL on ##SQLskills_Log_Analysis2 (ID);

	-- Insert a dummy row to make the loop logic simpler
	insert into ##SQLskills_Log_Analysis2
	values      (
		'PSRDummy', 1);

	-- Calculate the transaction hierarchy
	declare @XactID char(13);
	declare @Name varchar(256);
	declare @Begin varchar(100);
	declare @Who varchar(100);
	declare @String varchar(8000);
	declare @ID int;
	declare @Counter int;

	declare [LogAnalysis] cursor fast_forward
	for select [Transaction ID], 
			   [Transaction Name], 
			   [Begin Time], 
			   Who
		from   ##SQLskills_Log_Analysis
		where  [Parent Transaction ID] is null;

	open [LogAnalysis];

	fetch next from [LogAnalysis] into @XactID, 
									   @Name, 
									   @Begin, 
									   @Who;

	while @@FETCH_STATUS = 0
	begin
		-- Select the last transaction name inserted into the table
		select top 1 @ID = ID, 
					 @String = XactName
		from         ##SQLskills_Log_Analysis2
		order by ID desc;

		-- If it's the same as we're about to insert, update the counter,
		-- otherwise insert the new transaction name
		if @String = @Name
			update ##SQLskills_Log_Analysis2
			set    Times = Times + 1
			where  ID = @ID;
		else
		begin
			select @String = @Name;

			-- Add detail if necessary
			if @Detailed = 1
			begin
				-- Do this separately in case CONCAT_NULL_YIELDS_NULL is set
				if @WHO is not null
					select @String = @String + ' by ' + @Who;

				select @String = @String + ' @ ' + @Begin;
			end;

			insert into ##SQLskills_Log_Analysis2
			values      (
				@String, 1);
		end;

		-- Look for subtransactions of this one
		if @Deep = 1
			exec sp_AnalyzeTransactionLogInner @XactID, 3;

		fetch next from [LogAnalysis] into @XactID, 
										   @Name, 
										   @Begin, 
										   @Who;
	end;

	close [LogAnalysis];
	deallocate [LogAnalysis];

	-- Discard the dummy row
	delete from ##SQLskills_Log_Analysis2
	where       ID = 1;

	-- Print the hierachy
	declare [LogAnalysis2] cursor
	for select ID, 
			   XactName, 
			   Times
		from   ##SQLskills_Log_Analysis2;

	open [LogAnalysis2];

	-- Fetch the first transaction name, if any
	fetch next from [LogAnalysis2] into @ID, 
										@String, 
										@Counter;

	while @@FETCH_STATUS = 0
	begin
		if @Counter > 1
		begin
			select @String = @String + ' ' + CONVERT(varchar, @Counter) + ' times';
		end;

		-- If we're going to SELECT the output, update the row
		if @PrintOption = 0
			update ##SQLskills_Log_Analysis2
			set    XactName = @String
			where  ID = @ID;
		else
			print @String;

		fetch next from [LogAnalysis2] into @ID, 
											@String, 
											@Counter;
	end;

	close [LogAnalysis2];
	deallocate [LogAnalysis2];

	if @PrintOption = 0
	begin
		select XactName
		from   ##SQLskills_Log_Analysis2;
	end;

	drop table ##SQLskills_Log_Analysis;
	drop table ##SQLskills_Log_Analysis2;
end;
go

exec sys.sp_MS_marksystemobject sp_AnalyzeTransactionLog;

exec sys.sp_MS_marksystemobject sp_AnalyzeTransactionLogInner;
go