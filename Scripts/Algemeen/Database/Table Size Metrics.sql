set nocount on;

declare @_dbName varchar(2000);
set @_dbName = null;

declare @_sqlString nvarchar(max);
if OBJECT_ID('tempdb..#TableSizeMetrics') is not null
	drop table #TableSizeMetrics;
create table #TableSizeMetrics
(
	DbName           nvarchar(128) null, 
	object_id        int not null, 
	table_name       nvarchar(257) not null, 
	type_desc        nvarchar(120) null, 
	modify_date      datetime not null, 
	IndexName        sysname null, 
	index_type_desc  nvarchar(60) null, 
	fill_factor      tinyint not null, 
	total_Table_rows bigint null, 
	total_pages      bigint null, 
	[size(MB)]       decimal(36, 2) null);

declare dbCursor cursor local static forward_only
for select d.name
	from sys.databases as d
	where d.is_read_only = 0
		  and d.is_in_standby = 0
		  and d.database_id > 4
		  and d.state_desc = 'ONLINE'
		  and ( @_dbName is null
				or d.name = @_dbName
			  );

open dbCursor;
fetch next from dbCursor into @_dbName;

while @@FETCH_STATUS = 0
begin
	set @_sqlString = '
USE [' + @_dbName + '];
SELECT	[DbName] = DB_NAME()
		,t.[object_id]
		,[table_name] = s.[Name] + ''.'' + t.[name]
		,t.[type_desc], t.modify_date
		,[IndexName] = i.[name]
		,[index_type_desc] = i.[type_desc]
		,i.fill_factor 
		,p.[total_Table_rows]
		,[total_pages] = a.total_Index_pages
		,[size(MB)] = convert(decimal(36,2),(a.total_Index_pages * 8.0)/1024)
    FROM 
        sys.tables t
    INNER JOIN 
        sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN      
        sys.indexes i ON t.OBJECT_ID = i.object_id
    OUTER APPLY (
			SELECT SUM(P.rows) AS [total_Table_rows] 
			FROM sys.partitions p
			WHERE i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
		) p
	OUTER APPLY (
			SELECT [total_Index_pages] = SUM(a.total_pages)
			FROM sys.partitions p INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
			WHERE i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
		) a
    WHERE 
        t.is_ms_shipped = 0 AND i.OBJECT_ID > 255
	ORDER BY DB_NAME(), s.Name, t.name, i.name;
';
	
	--PRINT @_sqlString;
	insert into #TableSizeMetrics
	exec (@_sqlString);

	fetch next from dbCursor into @_dbName;
end;

close dbCursor;
deallocate dbCursor;

select *
from #TableSizeMetrics;