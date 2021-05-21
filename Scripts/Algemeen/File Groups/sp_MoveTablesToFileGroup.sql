use master;
go
------------------------------------------------------------------------------------------
--  sp_MoveTablesToFileGroup
--
--  Moves tables, heaps and indexes and LOBS to a filegroup.
--  Author:   Mark White   (maranite@gmail.com)

-- Move all tables, indexes and heaps, from all schemas into the filegroup named SECONDARY
--EXEC dbo.sp_MoveTablesToFileGroup
--	@SchemaFilter = '%',   -- chooses schemas using the LIKE operator
--	@TableFilter  = '%',   -- chooses tables using the LIKE operator
--	@DataFileGroup = 'SECONDARY', -- The name of the filegroup to move index and in-row data to.
--	@ClusteredIndexes = 1,   -- 1 means "Move all clustered indexes" - i.e. table data where a primary key / clustered index exists
--	@SecondaryIndexes = 1,   -- 1 means "Move all secondary indexes"
--	@Heaps = 1,      -- 1 means "Move all heaps" - i.e. tables with no clustered index.
--	@ProduceScript = 1    -- Don't move anything, just produce a T-SQL script

---- Produce a script to move LOBS to the LOB_DATA filegroup, and move table data to the SECONDARY filegroup, for tables in the TEST schema only
--EXEC dbo.sp_MoveTablesToFileGroup
--	@SchemaFilter = 'TEST',   -- Only tables in the TEST schema
--	@TableFilter  = '%',   -- All tables
--	@DataFileGroup = 'SECONDARY', -- Move in-row data to SECONDARY
--	@LobFileGroup =  'LOB_DATA', -- Move LOB data to LOB_DATA fg.
--	@ClusteredIndexes = 1,   -- Move all clustered indexes
--	@SecondaryIndexes = 0,   -- Don't move all secondary indexes
--	@Heaps = 0,      -- Don't move tables with no PK
--	@ProduceScript = 1    -- Don't move anything, just produce a T-SQL script

-----------------------------------------------------------------------------------------
create proc dbo.sp_MoveTablesToFileGroup 
    @SchemaFilter     varchar(255) = '%', -- Filter which table schemas to work on
    @TableFilter      varchar(255) = '%', -- Filter which tables to work on
    @DataFileGroup    varchar(255) = 'PRIMARY', -- Name of filegroup that data must be moved to
    @LobFileGroup     varchar(255) = null, -- Name of filegroup that LOBs (if any) must be moved to
    @FromFileGroup    varchar(255) = '%', -- Only move objects that currenly occupy this filegroup
    @ClusteredIndexes bit          = 1, -- 1 = move clustered indexes (table data), else 0
    @SecondaryIndexes bit          = 1, -- 1 = move secondary indexes, else 0
    @Heaps            bit          = 1, -- 1 = move heaps (lazy-assed, unindexed crap), else 0
    @Online           bit          = 0, -- 1 = keep indexes online (required Enterprise edition)
    @ProduceScript    bit          = 0             -- 1 = emit a T-SQL script instead of performing the moves
as
begin
    set nocount on;
    set concat_null_yields_null on;

    if FILEGROUP_ID(@DataFileGroup) is null
        raiserror('Invalid Data FileGroup specified.', 10, 1);

    if @Online = 1
       and SERVERPROPERTY('EngineEdition') <> 3
        raiserror('SQL Server Enterprise edition is required for online index operations.', 10, 1);

    if @LobFileGroup is not null
       and @@MICROSOFTVERSION / 0x01000000 < 11
        raiserror('LOB data can only be moved in SQL 2012 or newer. Consider re-creating your table/s.', 10, 1);

    declare @SQL varchar(max) = '';
    declare @Script varchar(max) = '';
    declare @RANDOM_NAME varchar(100) = REPLACE(NEWID(), '-', '');

    declare C cursor
    for
        with TYPED_COLUMNS
             as(select 
                    name = '[' + col.name + '] ', 
                    col.is_nullable, 
                    col.user_type_id, 
                    col.max_length, 
                    col.object_id, 
                    col.column_id, 
                    type_name = '[' + typ.name + '] '
                from sys.columns as col
                join sys.types as typ on typ.user_type_id = col.user_type_id),
             INDEX_COLUMNS
             as(select 
                    col.*, 
                    k.index_id, 
                    k.is_included_column, 
                    k.key_ordinal, 
                    k.is_descending_key
                from TYPED_COLUMNS as col
                join sys.index_columns as k on k.object_id = col.object_id
                                               and k.column_id = col.column_id)
             select distinct
        
/********************************************************************************************************************************************
  If the table contains LOB data which does not reside where the caller would like it to reside, then use the Brad Hoff's neat 
            partition scheme trick to move LOB data. Effectively, we simply create a partition function & scheme, rebuild the index on that
			scheme, and then allow the normal rebuild (without partitioning) to be done afterwards.
            For details, see Kimberly Tripp's site: http://www.sqlskills.com/blogs/kimberly/understanding-lob-data-20082008r2-2012/)         
********************************************************************************************************************************************/

                 case
                     when COALESCE(lob_fg, @LobFileGroup, 'PRIMARY') <> COALESCE(@LobFileGroup, lob_fg, 'PRIMARY')
                          and first_ix_col_type is not null
                          and type_desc <> 'NONCLUSTERED' then 'CREATE PARTITION FUNCTION PF_' + random_name + ' (' + first_ix_col_type + ') AS RANGE RIGHT FOR VALUES (0);' + CHAR(13) + 'CREATE PARTITION SCHEME PS_' + random_name + ' AS PARTITION PF_' + random_name + ' TO ([' + @LobFileGroup + '],[' + @LobFileGroup + ']);' + CHAR(13) + CHAR(13) + case type_desc
                                                                                                                                                                                                                                                                                                                                                                 when 'HEAP' then 'CREATE CLUSTERED ' + index_on_table + ' (' + index_columns + ') ' + options + ' ON PS_' + random_name + '(' + first_ix_col_name + ');' + CHAR(13) + 'DROP ' + index_on_table + ';' + CHAR(13)
                                                                                                                                                                                                                                                                                                                                                             else 'CREATE ' + is_unique + type_desc + ' ' + index_on_table + ' (' + index_columns + ')' + CHAR(13) + [includes / filters] + options + 'ON PS_' + random_name + '(' + first_ix_col_name + ');' + CHAR(13)
                                                                                                                                                                                                                                                                                                                                                             end + CHAR(13)
                 else ''
                 end + case type_desc
                           when 'HEAP' then 'CREATE CLUSTERED ' + index_on_table + ' (' + index_columns + ') ' + options + ' ON [' + @DataFileGroup + '];' + CHAR(13) + 'DROP ' + index_on_table + ';' + CHAR(13)
                       else 'CREATE ' + is_unique + type_desc + ' ' + index_on_table + ' (' + index_columns + ')' + CHAR(13) + [includes / filters] + options + 'ON [' + @DataFileGroup + '];'
                       end + case
                                 when COALESCE(lob_fg, @LobFileGroup, 'PRIMARY') <> COALESCE(@LobFileGroup, lob_fg, 'PRIMARY')
                                      and first_ix_col_type is not null then CHAR(13) + CHAR(13) + 'DROP PARTITION SCHEME PS_' + random_name + ';' + CHAR(13) + 'DROP PARTITION FUNCTION PF_' + random_name + ';' + CHAR(13) + CHAR(13)
                             else ''
                             end
             from (select distinct 
                       index_on_table = 'INDEX [' + ISNULL(i.name, 'PK_' + sch.name + '_' + obj.name) collate DATABASE_DEFAULT + ']' + CHAR(13) + 'ON [' + sch.name + '].[' + obj.name + ']', 
                       type_desc = i.type_desc, 
                       is_unique = case
                                       when i.is_unique = 1 then 'UNIQUE '
                                   else ''
                                   end, 
                       lob_fg = case
                                    when i.type in(0, 1)
                                         and exists (select 
                                                         *
                                                     from TYPED_COLUMNS as col
                                                     where col.object_id = obj.object_id
                                                           and col.max_length = -1)
                                         or i.type = 2
                                            and exists (select 
                                                            *
                                                        from INDEX_COLUMNS as col
                                                        where col.object_id = i.object_id
                                                              and col.index_id = i.index_id
                                                              and col.max_length = -1) then FILEGROUP_NAME(obj.lob_data_space_id)
                                end, 
                       index_columns = REPLACE(ISNULL( (select 
                                                            col.name + case
                                                                           when is_descending_key = 1 then 'DESC'
                                                                       else 'ASC'
                                                                       end as [data()]
                                                        from INDEX_COLUMNS as col
                                                        where col.object_id = i.object_id
                                                              and col.index_id = i.index_id
                                                              and col.is_included_column <> 1
                                                              and i.type in (1, 2)
                                                        order by 
                                                            key_ordinal for
                                                        xml path('')), (select top 1 
                                                                            '[' + col.name + '] ' as [data()]
                                                                        from sys.columns as col
                                                                        where col.object_id = i.object_id
                                                                              and i.type = 0
                                                                              and ( col.user_type_id in (48, 52, 56, 58, 59, 62, 104, 127, 106, 108)
                                                                                    or col.max_length between 1 and 800 )
                                                                        order by 
                                                                            col.is_nullable desc for
                                                                        xml path('')) ), ' [', ', ['), 
                       first_ix_col_name = ISNULL( (select top 1 
                                                        col.name
                                                    from INDEX_COLUMNS as col
                                                    where col.object_id = i.object_id
                                                          and col.index_id = i.index_id
                                                          and col.is_included_column <> 1
                                                          and i.type in (1, 2)
                                                    order by 
                                                        key_ordinal), (select top 1 
                                                                           name --type_name 
                                                                       from TYPED_COLUMNS as col
                                                                       where col.object_id = i.object_id
                                                                             and i.type = 0
                                                                             and ( col.user_type_id in (48, 52, 56, 58, 59, 62, 104, 127, 106, 108)
                                                                                   or col.max_length between 1 and 800 )
                                                                       order by 
                                                                           col.is_nullable desc) ), 
                       first_ix_col_type = ISNULL( (select top 1 
                                                        type_name
                                                    from INDEX_COLUMNS as col
                                                    join sys.types as typ on typ.user_type_id = col.user_type_id
                                                    where col.object_id = i.object_id
                                                          and col.index_id = i.index_id
                                                          and col.is_included_column <> 1
                                                          and i.type in (1, 2)
                                                    order by 
                                                        key_ordinal), (select top 1 
                                                                           type_name + case
                                                                                           when col.user_type_id not in(48, 52, 56, 58, 59, 62, 104, 127, 106, 108) then '(' + CONVERT(varchar(10), col.max_length) + ')'
                                                                                       else ''
                                                                                       end
                                                                       from TYPED_COLUMNS as col
                                                                       where col.object_id = i.object_id
                                                                             and i.type = 0
                                                                             and ( col.user_type_id in (48, 52, 56, 58, 59, 62, 104, 127, 106, 108)
                                                                                   or col.max_length between 1 and 800 )
                                                                       order by 
                                                                           col.is_nullable desc) ), 
                       [includes / filters] = ISNULL(REPLACE('INCLUDE (*)', '*', REPLACE( (select 
                                                                                               col.name as [data()]
                                                                                           from INDEX_COLUMNS as col
                                                                                           where col.object_id = i.object_id
                                                                                                 and col.index_id = i.index_id
                                                                                                 and col.is_included_column <> 0
                                                                                           order by 
                                                                                               key_ordinal, 
                                                                                               col.column_id for
                                                                                           xml path('')), ']  [', '], [')) + CHAR(13), '') + ISNULL('WHERE ' + i.filter_definition + CHAR(13), ''), 
                       options = ' WITH (' + ISNULL(case
                                                        when i.type in(1, 2) then 'DROP_EXISTING = ON '
                                                    end, 'DROP_EXISTING = OFF') + ISNULL(', FILLFACTOR = ' + NULLIF(CAST(fill_factor as varchar(10)), '0'), '') + ISNULL(', PAD_INDEX = ' + case is_padded
                                                                                                                                                                                                when 1 then 'ON'
                                                                                                                                                                                            else 'OFF'
                                                                                                                                                                                            end, '') + ISNULL(', ALLOW_ROW_LOCKS = ' + case allow_row_locks
                                                                                                                                                                                                                                           when 1 then 'ON'
                                                                                                                                                                                                                                       else 'OFF'
                                                                                                                                                                                                                                       end, '') + ISNULL(', ALLOW_PAGE_LOCKS = ' + case allow_page_locks
                                                                                                                                                                                                                                                                                       when 1 then 'ON'
                                                                                                                                                                                                                                                                                   else 'OFF'
                                                                                                                                                                                                                                                                                   end, '') + ISNULL(', IGNORE_DUP_KEY = ' + case ignore_dup_key
                                                                                                                                                                                                                                                                                                                                 when 1 then 'ON'
                                                                                                                                                                                                                                                                                                                                 when 0 then 'OFF'
                                                                                                                                                                                                                                                                                                                             end, '') + ISNULL(', DATA_COMPRESSION = ' + data_compression_desc, '') + ISNULL(', STATISTICS_NORECOMPUTE = ' + case no_recompute
                                                                                                                                                                                                                                                                                                                                                                                                                                                 when 1 then 'ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                 when 0 then 'OFF'
                                                                                                                                                                                                                                                                                                                                                                                                                                             end, '') + case
                                                                                                                                                                                                                                                                                                                                                                                                                                                            when @Online = 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                 and SERVERPROPERTY('EngineEdition') = 3 then ', ONLINE = ON'
                                                                                                                                                                                                                                                                                                                                                                                                                                                        else ''
                                                                                                                                                                                                                                                                                                                                                                                                                                                        end + ') ' + CHAR(13), 
                       random_name = 'MOVE_HELPER_' + @RANDOM_NAME
                   from sys.indexes as i(readpast)
                   join sys.filegroups as f(readpast) on i.data_space_id = f.data_space_id
                   join sys.tables as obj(readpast) on i.object_id = obj.object_id
                   join sys.schemas as sch on obj.schema_id = sch.schema_id
                   left join sys.partitions as part on i.object_id = part.object_id
                                                       and i.index_id = part.index_id
                   left join sys.stats as stats on i.object_id = stats.object_id
                                                   and i.index_id = stats.stats_id
                   where sch.name <> 'sys'
                         and sch.name like ISNULL(@SchemaFilter, '%')
                         and obj.name like ISNULL(@TableFilter, '%')
                         and f.name like ISNULL(@FromFileGroup, '%')
                         and ( f.name <> @DataFileGroup
                               or COALESCE(FILEGROUP_NAME(obj.lob_data_space_id), @LobFileGroup, 'PRIMARY') <> COALESCE(@LobFileGroup, FILEGROUP_NAME(obj.lob_data_space_id), 'PRIMARY') )
                         and ( i.type = 1
                               and @ClusteredIndexes = 1
                               or i.type = 2
                                  and @SecondaryIndexes = 1
                               or i.type = 0
                                  and @Heaps = 1 )) as Script_Builder;


    open C;
    fetch next from C into @SQL;

    while @@FETCH_STATUS = 0
    begin
        if @ProduceScript = 1
            select 
                @SQL;
        else
            exec (@SQL);

        fetch next from C into @SQL;
    end;

    close C;
    deallocate C;
end;
go

exec sp_ms_marksystemobject 'sp_MoveTablesToFileGroup';