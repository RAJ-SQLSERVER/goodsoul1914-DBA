-----------------------------------------------
--  SQL Server Index Internals: A Deep Dive  --
-----------------------------------------------

-- investigate Index/Data Pages

use Playground
go

set statistics io, xml off
set nocount on
go

if DB_ID('HeapsDB') is not null
begin
	alter database HeapsDB
	set single_user with rollback immediate

	drop database HeapsDB
end
go

create database HeapsDB
go

alter database HeapsDB
set recovery simple
go

use HeapsDB
go

create table NumbersTable
(
	NumberValue bigint not null,
	BiggerNumber bigint not null,
	CharacterColumn char(50)
)
go

insert into NumbersTable
(
	NumberValue, BiggerNumber, CharacterColumn
)
select	NumberValue, 
		NumberValue + 5000000,
		LEFT(replicate((cast(NumberValue as varchar(50))), 50), 50)
from
(
	select	NumberValue = ROW_NUMBER() over(order by newid() asc)
	from	master..spt_values a
	cross apply 
			master..spt_values b
	where	a.type = 'P' 
			and a.number <= 200 
			and a.number > 0 
			and b.type = 'P' 
			and b.number <= 200 
			and b.number > 0
) a


-- look at the depth of the trees on the heap
select	page_count, 
		index_depth, 
		page_level = index_level, 
		record_count, 
		*
from	sys.dm_db_index_physical_stats(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED');
go


-- look at the linkages for the heap
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id
from	sys.dm_db_database_page_allocations(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc = 'DATA_PAGE';
go


-- cluster the table
set statistics xml on

create clustered index cix_NumbersTable on NumbersTable(NumberValue)
with (maxdop = 1)

set statistics xml off


-- look at the depth of the trees for the clustered table
select	page_count, 
		index_depth, 
		page_level = index_level, 
		record_count, 
		*
from	sys.dm_db_index_physical_stats(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED');
go


-- look at the linkages for the heap
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id
from	sys.dm_db_database_page_allocations(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc in ('DATA_PAGE', 'INDEX_PAGE')
order by
		case when page_type_desc = 'INDEX_PAGE' then 0
		else allocated_page_page_id
		end
go


dbcc traceon(3604, -1)
go


-- look at the root page. Notice the UNIQUIFIER (key) column
dbcc page(HeapsDB, 1, 744, 3) 
with tableresults


-- look at the data page. Notice the values it contains. Notice the UNIQUIFIER
dbcc page(HeapsDB, 1, 712, 3) 
with tableresults
 

-- what happens if we make the clustered key unique?
create unique clustered index cix_NumbersTable on NumbersTable(NumberValue)
with (drop_existing = on, maxdop = 1)


-- look at the page structure and the linked list
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id
from	sys.dm_db_database_page_allocations(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc in ('DATA_PAGE', 'INDEX_PAGE')
order by
		case when page_type_desc = 'INDEX_PAGE' then 0
		else allocated_page_page_id
		end
go


-- look at the root index page. Notice the UNIQUIFIER is gone
dbcc page(HeapsDB, 1, 352, 3) 
with tableresults


-- look at a leaf page. Notice the UNIQUIFIER is gone
dbcc page(HeapsDB, 1, 321, 3) 
with tableresults


-- truncate NumbersTable
truncate table NumbersTable
go

insert into NumbersTable
(
	NumberValue, BiggerNumber, CharacterColumn
)
select	NumberValue, 
		NumberValue + 5000000,
		LEFT(replicate((cast(NumberValue as varchar(50))), 50), 50)
from
(
	select	NumberValue = ROW_NUMBER() over(order by newid() asc)
	from	master..spt_values a
	cross apply 
			master..spt_values b
	where	a.type = 'P' 
			and a.number <= 700 
			and a.number > 0 
			and b.type = 'P' 
			and b.number <= 700 
			and b.number > 0
) a


-- create a unique clustered index
create unique clustered index cix_NumbersTable 
on NumbersTable(NumberValue)
with (drop_existing = on, maxdop = 1);
go


-- create a non-unique nonclustered index
create nonclustered index idx_NumbersTable 
on NumbersTable(BiggerNumber);
go


-- look at the depth of the trees on the NC index
select	page_count, 
		index_depth, 
		page_level = index_level, 
		record_count, 
		*
from	sys.dm_db_index_physical_stats(db_id(), object_id('NumbersTable'), NULL, NULL, 'DETAILED');
go


-- look at the linkages for the NC index
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id,
		page_level,
		page_type_desc
from	sys.dm_db_database_page_allocations(db_id(), object_id('NumbersTable'), object_id('idx_NumbersTable'), NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc in ('DATA_PAGE', 'INDEX_PAGE')
order by
		page_level desc, allocated_page_page_id asc;
go


/* dump an intermediate level page. Notice the columns stored on the page */
dbcc page(HeapsDB, 1, 10512, 3) 
with tableresults


/* first, look at the first leaf page to show row-->page pointers */
dbcc page(HeapsDB, 1, 4216, 3) 
with tableresults


-- look at values in the leaf level for a page.
-- use fn_PhysLocFormatter to find page location.
select	BiggerNumber,
		'Location(File:Page:Slot)' = sys.fn_PhysLocFormatter(%%physloc%%),
		KeyHashValue = %%lockres%%
from NumbersTable 
with (index = idx_NumbersTable);


-- change table to a heap, this will rebuild the NC index
-- so that the pointer to the heap is now a RID
drop index cix_NumbersTable on NumbersTable


-- find a page in the NC index and verify the RID association
select	BiggerNumber,
		'Location(File:Page:Slot)' = sys.fn_PhysLocFormatter(%%physloc%%),
		KeyHashValue = %%lockres%%
from NumbersTable 
with (index = idx_NumbersTable);


dbcc page(HeapsDB, 1, 10000, 3) 
with tableresults


-- recreate the clustered index
create unique clustered index cix_NumbersTable 
on NumbersTable(NumberValue)
with (maxdop = 1);


-- recreate the non-clustered index as unique
create unique nonclustered index idx_NumbersTable 
on NumbersTable(BiggerNumber)
with (drop_existing = on);


-- find an intermediate level page in the index
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id,
		page_level,
		page_type_desc
from	sys.dm_db_database_page_allocations(
			db_id(), object_id('NumbersTable'), object_id('idx_NumbersTable'), NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc in ('DATA_PAGE', 'INDEX_PAGE')
order by
		page_level desc, allocated_page_page_id asc;


-- dump the intermediate level of the unique NC index
-- notice what's stored in the intermediate page now since it's unique.
dbcc page(HeapsDB, 1, 4970, 3) 
with tableresults


-- recreate the NC index and include an extra column
create unique nonclustered index idx_NumbersTable 
on NumbersTable(BiggerNumber)
include (CharacterColumn)
with (drop_existing = on);


-- look at the pages in our new index with an included column
select	allocated_page_page_id,
		next_page_page_id,
		previous_page_page_id,
		page_level,
		page_type_desc
from	sys.dm_db_database_page_allocations(
			db_id(), object_id('NumbersTable'), object_id('idx_NumbersTable'), NULL, 'DETAILED')
where	page_type_desc is not null 
		and page_type_desc in ('DATA_PAGE', 'INDEX_PAGE')
order by
		page_level desc, allocated_page_page_id asc;


-- intermediate level page
dbcc page(HeapsDB, 1, 14664, 3) 
with tableresults		


-- leaf level page
dbcc page(HeapsDB, 1, 323, 3) 
with tableresults		


