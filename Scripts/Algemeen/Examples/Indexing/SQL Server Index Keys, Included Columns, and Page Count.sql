use Playground
go



create table dbo.pagetest (
    FirstName varchar(255),
    FirstNameByBirthDateId int,
    Gender char(1)
);
go



insert into dbo.pagetest
values ('Kala', 121, 'M'), ('Kris', 13, 'M'), ('Kris', 138981, 'F'), ('Leaf', 1001, 'M');
go



create index nc_pagetest on dbo.pagetest (FirstName, FirstNameByBirthDateId) 
include (Gender);
go



select 
    allocated_page_page_id, -- 198744
    page_level              -- 0 (leaf-level)
from sys.dm_db_database_page_allocations (DB_ID(), OBJECT_ID('pagetest'), null, null, 'detailed')
where is_allocated = 1
      and index_id = 2 -- first nc index
      and page_type_desc <> 'IAM_PAGE';



set nocount on
go
insert into dbo.pagetest values 
('Kala', 121, 'M'), 
('Kris', 13, 'M'), 
('Kris', 138981, 'F'), 
('Leaf', 1001, 'M');
go 100



select 
    allocated_page_page_id, 
    page_level
from sys.dm_db_database_page_allocations (DB_ID(), OBJECT_ID('pagetest'), null, null, 'detailed')
where is_allocated = 1
      and index_id = 2
      and page_type_desc <> 'IAM_PAGE';
--allocated_page_page_id	page_level
--198744	                0
--198745	                1
--198746	                0


