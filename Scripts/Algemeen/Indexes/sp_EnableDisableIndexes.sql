use master;
go

if not exists
(
	select 1
	from INFORMATION_SCHEMA.ROUTINES
	where ROUTINE_NAME = 'sp_EnableDisableIndexes'
		  and ROUTINE_SCHEMA = 'dbo'
) 
begin
	exec ('CREATE PROCEDURE dbo.sp_EnableDisableIndexes AS BEGIN PRINT ''STUB FOR PROCEDURE'' END');
end;
go

/********************************************************************************************************
================================================================================
Name        : sp_EnableDisableIndexes
Author      : Joshua Feierman
Description : A stored procedure for enabling / disabling all indices on a 
              particular table. Since it is installed in the 'master' database
			  and marked as a system object it can be run in the context of any user
			  database.

License:
  sp_EnableDisableIndexes is free to download and use for personal, educational, and internal
  purposes, provided this license and all original attributions are included.
  Redistribution or sale in whole or in part is prohibited without the author's 
  express written consent.

  By using this stored procedure, you accept any and all responsibility for any loss
  or damages resulting from its use. Always test in a non production environment
  and evaluate function carefully!

This code and all contents are copyright 2015 Joshua Feierman, all rights reserved.

For more information, visit http://www.sqljosh.com/sp_EnableDisableIndexes/.

===============================================================================
Parameters   : 

Name                  | I/O   | Description
--------------------------------------------------------------------------------
@i_EnableDisable_Fl     I       A flag to designate whether we want to enable all disabled indices ('E')
                                or disable all enabled indices ('D').
@i_Schema_Name          I       The schema name of the object to target.
@i_Table_Name           I       The name of the object to target.
@i_Exclude_Unique_Fl    I       If set to 1, will not disable unique indices. Useful when loading data to
                                ensure constraints are not violated.
@i_ForReal_Fl           I       If set to 1, will actually perform the desired action. If set to 0,
                                the generated SQL is printed out and nothing is done. Defaults to 0.
@i_Column_To_Exclude_Nm I       When a value is provided, any index with the provided column name
                                as a leading column is not disabled. Useful for purging data so that
                                a full table scan may not occur.
@i_MaxDOP               I       Indicates the maximum parallel threads used when enabling indices.
                                When not specified option MAXDOP=1 will be used.
@i_Online               I       When set to 1 and the edition of SQL is Enterprise or Developer,
                                indices will be enabled in online mode.
Revisions    :
--------------------------------------------------------------------------------
Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
********************************************************************************************************/

alter procedure dbo.sp_EnableDisableIndexes 
	@i_EnableDisable_Fl     char(1), 
	@i_Schema_Name          sysname, 
	@i_Table_Name           sysname, 
	@i_Exclude_Unique_Fl    bit     = 1, 
	@i_ForReal_Fl           bit     = 0, 
	@i_Column_To_Exclude_Nm sysname = null, 
	@i_MaxDOP               tinyint = null, 
	@i_Online               bit     = 1
as
begin
	declare @SQL nvarchar(max);

	set @SQL =
	(
		select 'RAISERROR(' + QUOTENAME(case @i_EnableDisable_Fl
											when 'E' then 'Enabling '
										else 'Disabling '
										end + ' index ' + sidx.name + ' on table ' + ssch.name + '.' + sobj.name, '''') + ',10,1) with nowait;' + 'ALTER INDEX ' + QUOTENAME(sidx.name) + ' ON ' + QUOTENAME(ssch.name) + '.' + QUOTENAME(sobj.name) + ' ' + case @i_EnableDisable_Fl
																																																																 when 'E' then 'REBUILD' + ' WITH (MAXDOP=' + case
																																																																												  when @i_MaxDOP is null then CONVERT(varchar, 1)
																																																																											  else CONVERT(varchar, @i_MaxDOP)
																																																																											  end + ',ONLINE=' + case
																																																																																	 when @i_Online = 1
																																																																																		  and SERVERPROPERTY('EngineEdition') = 3 then 'ON'
																																																																																 else 'OFF'
																																																																																 end + ')'
																																																																 when 'D' then 'DISABLE'
																																																															 end + ';'
		from sys.schemas as ssch
			 join sys.objects as sobj on ssch.schema_id = sobj.schema_id
										 and ssch.name = @i_Schema_Name
										 and ( sobj.name = @i_Table_Name
											   or @i_Table_Name = ''
											 )
			 join sys.indexes as sidx on sobj.object_id = sidx.object_id
										 and sidx.is_primary_key = 0 -- exclude primary keys
										 and sidx.is_unique = case
																  when @i_Exclude_Unique_Fl = 1 then 0
															  else sidx.is_unique
															  end -- exclude unique indexes
										 and sidx.index_id > 1 -- exclude clustered index and heap
										 and sidx.is_disabled = case @i_EnableDisable_Fl
																	when 'E' then 1 -- only include disabled indexes when the "Enable" option is set
																	when 'D' then 0 -- only include enabled indexes when the "Disable" option is set
																end
		where not exists
		(
			select 1
			from sys.index_columns as ic
				 join sys.columns as c on c.column_id = ic.column_id
										  and c.object_id = ic.object_id
			where ic.index_id = sidx.index_id
				  and ic.object_id = sidx.object_id
				  and c.name = @i_Column_To_Exclude_Nm
				  and ic.key_ordinal = 1
				  and ic.is_included_column = 0
		) for xml path('')
	);

	if @i_ForReal_Fl = 1
		exec sp_executesql @SQL;
	else
		if @SQL is not null
			print @SQL;
end;
go

-- We mark this as a system object so that it can be used in the context of any database.

exec sys.sp_MS_marksystemobject @objname = N'dbo.sp_EnableDisableIndexes';