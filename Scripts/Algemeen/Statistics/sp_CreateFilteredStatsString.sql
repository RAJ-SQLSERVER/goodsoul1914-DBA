use [master];
go

if OBJECT_ID(N'sp_CreateFilteredStatsString') is not null
	drop procedure sp_CreateFilteredStatsString;
go

set ansi_nulls on;

set quoted_identifier on;
go

create procedure dbo.sp_CreateFilteredStatsString
(
	@schemaname             sysname, 
	@objectname             sysname, 
	@columnname             sysname, 
	@twopartname            nvarchar(520), 
	@MinValue               sql_variant, 
	@MaxValue               sql_variant   = null, 
	@coldef                 nvarchar(100), 
	@coldefcollationforcast nvarchar(100), 
	@usecollation           bit, 
	@fullscan               varchar(8)    = null, 
	@samplepercent          tinyint       = null) 
as
begin
	set nocount on;

	declare @execstring nvarchar(max);

	select @execstring = N'CREATE STATISTICS ' + QUOTENAME(N'SQLskills_FS_' + SUBSTRING(@schemaname, 1, 10) + N'_' + SUBSTRING(@objectname, 1, 32) + N'_' + SUBSTRING(@columnname, 1, 32) + N'_' + case
																																																	   when SUBSTRING(@coldef, 1, 4) in(N'date', N'time') then CONVERT(varchar, @MinValue, 126)
																																																	   else CONVERT(varchar, @MinValue)
																																																   end + case
																																																			 when @MaxValue is not null then N'_' + case
																																																														when SUBSTRING(@coldef, 1, 4) in(N'date', N'time') then CONVERT(varchar, @MaxValue, 126)
																																																														else CONVERT(varchar, @MaxValue)
																																																													end
																																																			 else+N'_unbounded'
																																																		 end, ']') + N' ON ' + @twopartname + N' (' + QUOTENAME(@columnname, N']') + N') ' + N' WHERE ' + QUOTENAME(@columnname, N']') + N' >= CAST(''' + REPLACE(CONVERT(varchar, @MinValue), '''', '''''') + N''' AS ' + @coldef + N') ' + case
																																																																																																												 when @MaxValue is not null then N' AND ' + QUOTENAME(@columnname, N']') + N' < CAST(''' + REPLACE(CONVERT(varchar, @MaxValue), '''', '''''') + N''' AS ' + @coldef + N') '
																																																																																																												 else N''
																																																																																																											 end + case
																																																																																																													   when UPPER(@fullscan) = N'FULLSCAN' then N' WITH FULLSCAN'
																																																																																																													   when UPPER(@fullscan) = N'SAMPLE'
																																																																																																															and @samplepercent is not null then N' WITH SAMPLE ' + CONVERT(varchar, @samplepercent)
																																																																																																													   else N''
																																																																																																												   end;

	--SELECT @execstring
	exec (@execstring);
end;
go

exec sys.sp_MS_marksystemobject 'sp_CreateFilteredStatsString';
go