/*****************************************************************************
  File:     sp_FindDuplicateIndexes2.sql

  Summary:  This is similar to the rewrite of sp_helpindex but it requires
            that the included columns be unordered.
					
  Date:     July 2011

  SQL Server 2008 Version
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SYSolutions, Inc.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills instructors.  
*****************************************************************************/

use master;
go

if OBJECTPROPERTY(OBJECT_ID('sp_FindDuplicateIndexes2'), 'IsProcedure') = 1
	drop procedure sp_FindDuplicateIndexes2;
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_FindDuplicateIndexes2 
	@objname nvarchar(776)		-- the table to check for indexes
as
begin

	--November 2010: Added a column to show if an index is disabled.
	--     May 2010: Added tree/leaf columns to the output - this requires the 
	--               stored procedure: sp_ExposeColumnsInIndexLevels
	--               (Better known as sp_helpindex8)
	--   March 2010: Added index_id to the output (ordered by index_id as well)
	--  August 2008: Fixed a bug (missing begin/end block) AND I found
	--               a few other issues that people hadn't noticed (yikes!)!
	--   April 2008: Updated to add included columns to the output. 
	-- See my blog for updates and/or additional information
	-- http://www.SQLskills.com/blogs/Kimberly (Kimberly L. Tripp)

	set nocount on;

	declare @objid             int, -- the object id of the table
			@indid             smallint, -- the index id of an index
			@groupid           int, -- the filegroup id of an index
			@indname           sysname, 
			@groupname         sysname, 
			@status            int, 
			@keys              nvarchar(2126), --Length (16*max_identifierLength)+(15*2)+(16*3)
			@inc_columns       nvarchar(max), 
			@inc_Count         smallint, 
			@loop_inc_Count    smallint, 
			@dbname            sysname, 
			@ignore_dup_key    bit, 
			@is_unique         bit, 
			@is_hypothetical   bit, 
			@is_primary_key    bit, 
			@is_unique_key     bit, 
			@is_disabled       bit, 
			@auto_created      bit, 
			@no_recompute      bit, 
			@filter_definition nvarchar(max), 
			@ColsInTree        nvarchar(2126), 
			@ColsInLeaf        nvarchar(max);

	-- Check to see that the object names are local to the current database.
	select @dbname = PARSENAME(@objname, 3);
	if @dbname is null
		select @dbname = DB_NAME();
		else
		if @dbname <> DB_NAME()
		begin
			raiserror(15250, -1, -1);
			return 1;
		end;

	-- Check to see the the table exists and initialize @objid.
	select @objid = OBJECT_ID(@objname);
	if @objid is null
	begin
		raiserror(15009, -1, -1, @objname, @dbname);
		return 1;
	end;

	-- OPEN CURSOR OVER INDEXES (skip stats: bug shiloh_51196)
	declare ms_crs_ind cursor local static
	for select i.index_id, 
			   i.data_space_id, 
			   QUOTENAME(i.name, N']') as name, 
			   i.ignore_dup_key, 
			   i.is_unique, 
			   i.is_hypothetical, 
			   i.is_primary_key, 
			   i.is_unique_constraint, 
			   s.auto_created, 
			   s.no_recompute, 
			   i.filter_definition, 
			   i.is_disabled
		from sys.indexes as i
			 join sys.stats as s on i.object_id = s.object_id
									and i.index_id = s.stats_id
		where i.object_id = @objid;
	open ms_crs_ind;
	fetch ms_crs_ind into @indid, 
						  @groupid, 
						  @indname, 
						  @ignore_dup_key, 
						  @is_unique, 
						  @is_hypothetical, 
						  @is_primary_key, 
						  @is_unique_key, 
						  @auto_created, 
						  @no_recompute, 
						  @filter_definition, 
						  @is_disabled;

	-- IF NO INDEX, QUIT
	if @@fetch_status < 0
	begin
		deallocate ms_crs_ind;
		--raiserror(15472,-1,-1,@objname) -- Object does not have any indexes.
		return 0;
	end;

	-- create temp tables
	create table #spindtab
	(
		index_name        sysname collate database_default not null, 
		index_id          int, 
		ignore_dup_key    bit, 
		is_unique         bit, 
		is_hypothetical   bit, 
		is_primary_key    bit, 
		is_unique_key     bit, 
		is_disabled       bit, 
		auto_created      bit, 
		no_recompute      bit, 
		groupname         sysname collate database_default null, 
		index_keys        nvarchar(2126) collate database_default not null, -- see @keys above for length descr
		filter_definition nvarchar(max), 
		inc_Count         smallint, 
		inc_columns       nvarchar(max), 
		cols_in_tree      nvarchar(2126), 
		cols_in_leaf      nvarchar(max));

	create table #IncludedColumns
	(
		RowNumber smallint, 
		Name      nvarchar(128));

	-- Now check out each index, figure out its type and keys and
	--	save the info in a temporary table that we'll print out at the end.
	while @@fetch_status >= 0
	begin
		-- First we'll figure out what the keys are.
		declare @i       int, 
				@thiskey nvarchar(131); -- 128+3

		select @keys = QUOTENAME(INDEX_COL(@objname, @indid, 1), N']'), 
			   @i = 2;
		if INDEXKEY_PROPERTY(@objid, @indid, 1, 'isdescending') = 1
			select @keys = @keys + '(-)';

		select @thiskey = QUOTENAME(INDEX_COL(@objname, @indid, @i), N']');
		if @thiskey is not null
		   and INDEXKEY_PROPERTY(@objid, @indid, @i, 'isdescending') = 1
			select @thiskey = @thiskey + '(-)';

		while @thiskey is not null
		begin
			select @keys = @keys + ', ' + @thiskey, 
				   @i = @i + 1;
			select @thiskey = QUOTENAME(INDEX_COL(@objname, @indid, @i), N']');
			if @thiskey is not null
			   and INDEXKEY_PROPERTY(@objid, @indid, @i, 'isdescending') = 1
				select @thiskey = @thiskey + '(-)';
		end;

		-- Second, we'll figure out what the included columns are.
		select @inc_columns = null;

		select @inc_Count = COUNT(*)
		from sys.tables as tbl
			 inner join sys.indexes as si on si.index_id > 0
											 and si.is_hypothetical = 0
											 and si.object_id = tbl.object_id
			 inner join sys.index_columns as ic on ic.column_id > 0
												   and ( ic.key_ordinal > 0
														 or ic.partition_ordinal = 0
														 or ic.is_included_column != 0
													   )
												   and ic.index_id = CAST(si.index_id as int)
													   and ic.object_id = si.object_id
			 inner join sys.columns as clmns on clmns.object_id = ic.object_id
												and clmns.column_id = ic.column_id
		where ic.is_included_column = 1
			  and si.index_id = @indid
			  and tbl.object_id = @objid;

		if @inc_Count > 0
		begin
			delete from #IncludedColumns;
			insert into #IncludedColumns
			select ROW_NUMBER() over(
				   order by clmns.column_id), 
				   clmns.name
			from sys.tables as tbl
				 inner join sys.indexes as si on si.index_id > 0
												 and si.is_hypothetical = 0
												 and si.object_id = tbl.object_id
				 inner join sys.index_columns as ic on ic.column_id > 0
													   and ( ic.key_ordinal > 0
															 or ic.partition_ordinal = 0
															 or ic.is_included_column != 0
														   )
													   and ic.index_id = CAST(si.index_id as int)
														   and ic.object_id = si.object_id
				 inner join sys.columns as clmns on clmns.object_id = ic.object_id
													and clmns.column_id = ic.column_id
			where ic.is_included_column = 1
				  and si.index_id = @indid
				  and tbl.object_id = @objid;

			select @inc_columns = QUOTENAME(Name, N']')
			from #IncludedColumns
			where RowNumber = 1;

			set @loop_inc_Count = 1;

			while @loop_inc_Count < @inc_Count
			begin
				select @inc_columns = @inc_columns + ', ' + QUOTENAME(Name, N']')
				from #IncludedColumns
				where RowNumber = @loop_inc_Count + 1;
				set @loop_inc_Count = @loop_inc_Count + 1;
			end;
		end;

		select @groupname = null;
		select @groupname = name
		from sys.data_spaces
		where data_space_id = @groupid;

		-- Get the column list for the tree and leaf level, for all nonclustered indexes IF the table has a clustered index
		if @indid = 1
		   and
		(
			select is_unique
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 0
			select @ColsInTree = @keys + N', UNIQUIFIER', 
				   @ColsInLeaf = N'All columns "included" - the leaf level IS the data row, plus the UNIQUIFIER';

		if @indid = 1
		   and
		(
			select is_unique
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 1
			select @ColsInTree = @keys, 
				   @ColsInLeaf = N'All columns "included" - the leaf level IS the data row.';

		if @indid > 1
		   and
		(
			select COUNT(*)
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 1
			exec sp_ExposeColumnsInIndexLevelsWithUnordered @objid, @indid, @ColsInTree output, @ColsInLeaf output;

		if @indid > 1
		   and @is_unique = 0
		   and
		(
			select is_unique
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 0
			select @ColsInTree = @ColsInTree + N', UNIQUIFIER', 
				   @ColsInLeaf = @ColsInLeaf + N', UNIQUIFIER';

		if @indid > 1
		   and @is_unique = 1
		   and
		(
			select is_unique
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 0
			select @ColsInLeaf = @ColsInLeaf + N', UNIQUIFIER';

		if @indid > 1
		   and
		(
			select COUNT(*)
			from sys.indexes
			where index_id = 1
				  and object_id = @objid
		) = 0 -- table is a HEAP
		begin
			if @is_unique_key = 0
				select @ColsInTree = @keys + N', RID', 
					   @ColsInLeaf = @keys + N', RID' + case
															when @inc_columns is not null then N', ' + @inc_columns
															else N''
														end;

			if @is_unique_key = 1
				select @ColsInTree = @keys, 
					   @ColsInLeaf = @keys + N', RID' + case
															when @inc_columns is not null then N', ' + @inc_columns
															else N''
														end;
		end;

		-- INSERT ROW FOR INDEX

		insert into #spindtab
		values (@indname, @indid, @ignore_dup_key, @is_unique, @is_hypothetical, @is_primary_key, @is_unique_key, @is_disabled, @auto_created, @no_recompute, @groupname, @keys, @filter_definition, @inc_Count, @inc_columns, @ColsInTree, @ColsInLeaf);

		-- Next index
		fetch ms_crs_ind into @indid, 
							  @groupid, 
							  @indname, 
							  @ignore_dup_key, 
							  @is_unique, 
							  @is_hypothetical, 
							  @is_primary_key, 
							  @is_unique_key, 
							  @auto_created, 
							  @no_recompute, 
							  @filter_definition, 
							  @is_disabled;
	end;
	deallocate ms_crs_ind;

	-- DISPLAY THE RESULTS

	select 'index_id' = index_id, 
		   'is_disabled' = is_disabled, 
		   'index_name' = index_name, 
		   'index_description' = CONVERT(varchar(210), --bits 16 off, 1, 2, 16777216 on, located on group
													case
														when index_id = 1 then 'clustered'
														else 'nonclustered'
													end + case
															  when ignore_dup_key <> 0 then ', ignore duplicate keys'
															  else ''
														  end + case
																	when is_unique = 1 then ', unique'
																	else ''
																end + case
																		  when is_hypothetical <> 0 then ', hypothetical'
																		  else ''
																	  end + case
																				when is_primary_key <> 0 then ', primary key'
																				else ''
																			end + case
																					  when is_unique_key <> 0 then ', unique key'
																					  else ''
																				  end + case
																							when auto_created <> 0 then ', auto create'
																							else ''
																						end + case
																								  when no_recompute <> 0 then ', stats no recompute'
																								  else ''
																							  end + ' located on ' + groupname), 
		   'index_keys' = index_keys, 
		   'included_columns' = inc_columns, 
		   'filter_definition' = filter_definition, 
		   'columns_in_tree' = cols_in_tree, 
		   'columns_in_leaf' = cols_in_leaf
	from #spindtab
	order by index_id;

	return 0;
end; -- sp_FindDuplicateIndexes2
go

exec sys.sp_MS_marksystemobject 'sp_FindDuplicateIndexes2';
go