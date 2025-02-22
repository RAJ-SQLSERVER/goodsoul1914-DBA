use [master];
go

/************************************************************************************************
***** Object:  StoredProcedure [dbo].[sp_index_rebuild]    Script Date: 06/06/2007 12:00:07 *****
************************************************************************************************/

if exists (select *
           from sys.objects
           where object_id = OBJECT_ID(N'[dbo].[sp_index_rebuild]')
                 and type in (N'P', N'PC') ) 
    drop procedure 
        dbo.sp_index_rebuild;
go

/************************************************************************************************
***** Object:  StoredProcedure [dbo].[sp_index_rebuild]    Script Date: 06/06/2007 11:57:16 *****
************************************************************************************************/

set ansi_nulls on;
go
set quoted_identifier on;
go
-- =============================================
-- Author:		Bob Duffy, MCS
-- Create date: 30/05/2007
-- Description:	Rebuild Fragmented Indexes on entire database using fill factor and sort_in_tempdb
-- Example Usage:
--		
--rebuild current database with default values
--exec sp_index_rebuild 
--
--Force Rebuild of ALL Indexes with 80 Fill Factor in current db
--exec sp_index_rebuild 0,80
--
--rebuild all indexes in all databases that are fragmented
--exec sp_MSforeachdb 'print ''use [?]''; use ?;exec sp_index_rebuild'	
--		
-- References BOL: ms-help://MS.SQLCC.v9/MS.SQLSVR.v9.en/tsqlref9/html/d294dd8e-82d5-4628-aa2d-e57702230613.htm
-- =============================================
create procedure dbo.sp_index_rebuild 
    @target_frag_percent int = 10,	-- Target Fragmentation Percent 
    @fill_factor         int = -1,	-- Fill Factor. -1 means ignore fill factor 
    @report_only         bit = 0    -- if set to 1 will only generate SQL (not execute)
as
begin
    set nocount on;
    declare @partitioncount bigint;
    declare @schemaname sysname;
    declare @objectname sysname;
    declare @indexname sysname;
    declare @partitionnum bigint;
    declare @partitions bigint;
    declare @frag float;
    declare @command nvarchar(max);

    create table #work_to_do
    (
        schema_name    sysname, 
        table_name     sysname, 
        index_name     sysname, 
        partitionnum   int, 
        partitioncount int, 
        frag           float
    );

    -- conditionally select from the function, converting object and index IDs to names.
    -- We have to use Dynamic SQL as need USE statement
    -- In SP2, we can avoid doing these as object_name() has database qualifier in it
    --
    set @command = 'USE ' + DB_NAME() + '; SELECT
		s.name as schema_name
		,object_name(p.object_id) AS table_name
		,i.name as index_name
		,p.partition_number AS partitionnum
		,(select count (*) FROM sys.partitions
			WHERE object_id = p.object_id AND index_id = p.index_id) as partitioncount
		,p.avg_fragmentation_in_percent AS frag
	FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, ''LIMITED'') p
	inner join sys.indexes i 
	on i.object_id=p.object_id and i.index_id=p.index_id
	inner join sys.objects so 
	on so.object_id=p.object_id
	INNER JOIN sys.schemas as s
	on s.schema_id=so.schema_id
	WHERE avg_fragmentation_in_percent >= ' + CONVERT(varchar, @target_frag_percent) + ' and p.index_id > 0;';

    insert into #work_to_do
    exec sp_executesql @command;

    -- Declare the cursor for the list of partitions to be processed.
    declare partitions cursor
    for select *
        from #work_to_do;
    
    open partitions;
    
	-- Loop through the partitions.
    fetch next from partitions into @schemaname, 
                                    @objectname, 
                                    @indexname, 
                                    @partitionnum, 
                                    @partitioncount, 
                                    @frag;

    while @@FETCH_STATUS = 0
    begin
        select 
            @command = 'ALTER INDEX ' + @indexname + ' ON ' + @schemaname + '.' + @objectname + ' REBUILD';
        select 
            @command = @command + ' WITH (';
        if @fill_factor >= 0
            select 
                @command = @command + 'FILLFACTOR = ' + CONVERT(varchar(3), @fill_factor) + ' ,';
        select 
            @command = @command + ' SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = ON)';
        if @partitioncount > 1
            select 
                @command = @command + ' PARTITION=' + CONVERT(char, @partitionnum);

        print @command;

        if @report_only = 0
            exec sp_executesql @command;

        fetch next from partitions into @schemaname, 
                                        @objectname, 
                                        @indexname, 
                                        @partitionnum, 
                                        @partitioncount, 
                                        @frag;

    end;

    close partitions;
    deallocate partitions;

    drop table #work_to_do;
end;