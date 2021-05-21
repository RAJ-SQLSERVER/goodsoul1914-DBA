/*****************************************************************************
============================================================================
  File:     sp_finddupes.sql

  Summary:  Run against a single database this procedure will list ALL
            duplicate indexes and the needed TSQL to drop them!
					
  Date:     July 2011

  SQL Server 2008 Version
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills instructors.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================
*****************************************************************************/

use master;
go

if OBJECTPROPERTY(OBJECT_ID('sp_finddupes'), 'IsProcedure') = 1
	drop procedure sp_finddupes;
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_finddupes
(
	@ObjName nvarchar(776) = null		-- the table to check for duplicates
-- when NULL it will check ALL tables
)
as
begin

	--  Jul 2011: V1 to find duplicate indexes.
	-- See my blog for updates and/or additional information
	-- http://www.SQLskills.com/blogs/Kimberly (Kimberly L. Tripp)

	set nocount on;

	declare @ObjID      int, -- the object id of the table
			@DBName     sysname, 
			@SchemaName sysname, 
			@TableName  sysname, 
			@ExecStr    nvarchar(4000);

	-- Check to see that the object names are local to the current database.
	select @DBName = PARSENAME(@ObjName, 3);

	if @DBName is null
		select @DBName = DB_NAME();
	else
		if @DBName <> DB_NAME()
		begin
			raiserror(15250, -1, -1);
			-- select * from sys.messages where message_id = 15250
			return 1;
		end;

	if @DBName = N'tempdb'
	begin
		raiserror('WARNING: This procedure cannot be run against tempdb. Skipping tempdb.', 10, 0);
		return 1;
	end;

	-- Check to see the the table exists and initialize @ObjID.
	select @SchemaName = PARSENAME(@ObjName, 2);

	if @SchemaName is null
		select @SchemaName = SCHEMA_NAME();

	-- Check to see the the table exists and initialize @ObjID.
	if @ObjName is not null
	begin
		select @ObjID = OBJECT_ID(@ObjName);

		if @ObjID is null
		begin
			raiserror(15009, -1, -1, @ObjName, @DBName);
			-- select * from sys.messages where message_id = 15009
			return 1;
		end;
	end;

	create table #DropIndexes
	(
		DatabaseName  sysname, 
		SchemaName    sysname, 
		TableName     sysname, 
		IndexName     sysname, 
		DropStatement nvarchar(2000));

	create table #FindDupes
	(
		index_id          int, 
		is_disabled       bit, 
		index_name        sysname, 
		index_description varchar(210), 
		index_keys        nvarchar(2126), 
		included_columns  nvarchar(max), 
		filter_definition nvarchar(max), 
		columns_in_tree   nvarchar(2126), 
		columns_in_leaf   nvarchar(max));

	-- OPEN CURSOR OVER TABLE(S)
	if @ObjName is not null
		declare TableCursor cursor local static
		for select @SchemaName, 
				   PARSENAME(@ObjName, 1);
	else
		declare TableCursor cursor local static
		for select SCHEMA_NAME(uid), 
				   name
			from sysobjects
			where type = 'U' --AND name
			order by SCHEMA_NAME(uid), 
					 name;

	open TableCursor;

	fetch TableCursor into @SchemaName, 
						   @TableName;

	-- For each table, list the add the duplicate indexes and save 
	-- the info in a temporary table that we'll print out at the end.

	while @@fetch_status >= 0
	begin
		truncate table #FindDupes;

		select @ExecStr = 'EXEC sp_finddupes_helpindex ''' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'''';

		--SELECT @ExecStr

		insert into #FindDupes
		exec (@ExecStr);

		--SELECT * FROM #FindDupes

		insert into #DropIndexes
		select distinct 
			   @DBName, 
			   @SchemaName, 
			   @TableName, 
			   t1.index_name, 
			   N'DROP INDEX ' + QUOTENAME(@SchemaName, N']') + N'.' + QUOTENAME(@TableName, N']') + N'.' + t1.index_name
		from #FindDupes as t1
			 join #FindDupes as t2 on t1.columns_in_tree = t2.columns_in_tree
									  and t1.columns_in_leaf = t2.columns_in_leaf
									  and ISNULL(t1.filter_definition, 1) = ISNULL(t2.filter_definition, 1)
									  and PATINDEX('%unique%', t1.index_description) = PATINDEX('%unique%', t2.index_description)
									  and t1.index_id > t2.index_id;

		fetch TableCursor into @SchemaName, 
							   @TableName;
	end;

	deallocate TableCursor;

	-- DISPLAY THE RESULTS

	if
	(
		select COUNT(*)
		from #DropIndexes
	) = 0
		raiserror('Database: %s has NO duplicate indexes.', 10, 0, @DBName);
	else
		select *
		from #DropIndexes
		order by SchemaName, 
				 TableName;

	return 0;
end; -- sp_finddupes
go

exec sys.sp_MS_marksystemobject 'sp_finddupes';
go