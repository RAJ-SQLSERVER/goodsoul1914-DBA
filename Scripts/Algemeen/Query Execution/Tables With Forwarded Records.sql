/******************************************************
 Find tables with forwarded records on Single Database 
******************************************************/

select OBJECT_NAME(ps.object_id) as TableName, 
	   i.name as IndexName, 
	   ps.index_type_desc, 
	   ps.page_count, 
	   ps.avg_fragmentation_in_percent, 
	   ps.forwarded_record_count
from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, 'DETAILED') as ps
	 inner join sys.indexes as i on ps.OBJECT_ID = i.OBJECT_ID
									and ps.index_id = i.index_id
where forwarded_record_count > 0;
go


/*****************************************************
	Find Forwarded Records using Cursor Method for VLDBs	
*****************************************************/

set nocount on;
if OBJECT_ID('tempdb..#objects') is not null
	drop table #objects;
create table #objects
(
	dbID     int, 
	objectID int);
exec sp_msforeachdb '
	use [?];
	SET NOCOUNT ON;
	insert #objects
	(dbID, objectID)
	select db_id() as dbID, o.object_id
	from sys.objects as o inner join sys.schemas as s on s.schema_id = o.schema_id
	inner join sys.indexes as i on i.object_id = o.object_id
	where o.type_desc = ''USER_TABLE''
	and i.type_desc = ''HEAP''
';
--select * from #objects;

if OBJECT_ID('tempdb..#HeapFragTable') is not null
	drop table #HeapFragTable;
create table #HeapFragTable
(
	dbName                       varchar(100), 
	table_name                   varchar(100), 
	forwarded_record_count       int, 
	avg_fragmentation_in_percent decimal(20, 2), 
	page_count                   bigint);
declare @c_ObjectID int;
declare @c_dbID int;

declare curObjects cursor local forward_only
for select dbID, 
		   objectID
	from #objects;
		
open curObjects;  

fetch next from curObjects into @c_dbID, 
								@c_ObjectID;

while @@FETCH_STATUS = 0
begin  
	--PRINT	@c_ObjectID;
	insert into #HeapFragTable
	select DB_NAME(@c_dbID) as dbName, 
		   OBJECT_NAME(object_id) as table_name, 
		   forwarded_record_count, 
		   avg_fragmentation_in_percent, 
		   page_count
	from sys.dm_db_index_physical_stats(@c_dbID, @c_ObjectID, default, default, 'DETAILED');

	fetch next from curObjects into @c_dbID, 
									@c_ObjectID;
end;

close curObjects;  
deallocate curObjects; 

select *
from #HeapFragTable
where forwarded_record_count > 0
	  and table_name is not null;
go