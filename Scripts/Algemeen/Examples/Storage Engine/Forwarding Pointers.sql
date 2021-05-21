-- 1 page
-- Scan count 1, logical reads 1

create table dbo.ForwardingPointers (
	ID INT not null, Val VARCHAR(8000) null);

insert into dbo.ForwardingPointers (ID, Val) 
values (1, null), (2, REPLICATE('2', 7800)), (3, null);

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'dbo.ForwardingPointers'), 0, null, 'DETAILED');

set statistics io on;

select COUNT(*) as [RowCnt]
from dbo.ForwardingPointers;

set statistics io off;

-- Increase size
-- 3 pages
-- Scan count 1, logical reads 5

update dbo.ForwardingPointers
  set Val = REPLICATE('1', 5000)
where ID = 1;

update dbo.ForwardingPointers
  set Val = REPLICATE('3', 5000)
where ID = 3;

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'dbo.ForwardingPointers'), 0, null, 'DETAILED');

set statistics io on;

select COUNT(*) as [RowCnt]
from dbo.ForwardingPointers;

set statistics io off;

-- Now with more rows
-- 220 pages
-- Scan count 1, logical reads 220

truncate table dbo.ForwardingPointers;
go

with N1(C)
	 as (select 0
		 union all
		 select 0) -- 2 rows
,
	 N2(C)
	 as (select 0
		 from N1 as T1
		 cross join N1 as T2) -- 4 rows
	 ,
	 N3(C)
	 as (select 0
		 from N2 as T1
		 cross join N2 as T2) -- 16 rows
	 ,
	 N4(C)
	 as (select 0
		 from N3 as T1
		 cross join N3 as T2) -- 256 rows
	 ,
	 N5(C)
	 as (select 0
		 from N4 as T1
		 cross join N4 as T2) -- 65,536 rows
	 ,
	 IDs(ID)
	 as (select ROW_NUMBER() over(
		 order by(select null))
		 from N5)
	 insert into dbo.ForwardingPointers (ID) 
	 select ID
	 from IDs;

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'dbo.ForwardingPointers'), 0, null, 'DETAILED');

set statistics io on;

select COUNT(*) as [RowCnt]
from dbo.ForwardingPointers;

set statistics io off;

-- Set a Val
-- 4760 pages
-- Scan count 1, logical reads 68324

update dbo.ForwardingPointers
  set Val = REPLICATE('a', 500);

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'dbo.ForwardingPointers'), 0, null, 'DETAILED');

set statistics io on;

select COUNT(*) as [RowCnt]
from dbo.ForwardingPointers;

set statistics io off;

-- Rebuild heap
-- 4375 pages
-- Scan count 1, logical reads 4375

alter table dbo.ForwardingPointers rebuild;

select page_count, avg_record_size_in_bytes, avg_page_space_used_in_percent, forwarded_record_count
from sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(N'dbo.ForwardingPointers'), 0, null, 'DETAILED');

select COUNT(*) as [RowCnt]
from dbo.ForwardingPointers;

set statistics io on;