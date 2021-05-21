drop table if exists dbo.PostsStaging;
create table dbo.PostsStaging
(
	Id int
	primary key clustered );
go

insert into dbo.PostsStaging (Id) 
select Id
from dbo.Posts;
go

-- Update statistics
update statistics dbo.PostsStaging with fullscan;
update statistics dbo.Posts with fullscan;
go

-- All rows should match 
delete dbo.Posts
where Id in
(
	select Id
	from dbo.PostsStaging
);

-- No rows should match 
delete dbo.Posts
where Id not in
(
	select Id
	from dbo.PostsStaging
);

-- Update stats again, this time with the default sampling: 
update statistics dbo.PostsStaging;
update statistics dbo.Posts;
go

dbcc show_statistics('dbo.PostsStaging', 'PK__PostsSta__3214EC078E600FBE');

-- Delete odd-numbered rows from Posts and even-numbered rows from PostsStaging
delete dbo.Posts
where Id % 2 = 1;
go

delete dbo.PostsStaging
where Id % 2 = 0;
go

-- And give SQL Server its best chance: 
update statistics dbo.PostsStaging with fullscan;
update statistics dbo.Posts with fullscan;
go

select top 10 *
from dbo.Posts;

select top 10 *
from dbo.PostsStaging;

select COUNT(*)
from dbo.Posts as p
	 inner join dbo.PostsStaging as ps on p.Id = ps.Id; -- 0 rows

-- Estimates will be horrible now!
delete dbo.Posts
where Id in
(
	select Id
	from dbo.PostsStaging
); -- SQL Server thinks that 50% of the Posts rows will be deleted

delete dbo.Posts
where Id not in
(
	select Id
	from dbo.PostsStaging
); -- SQL Server thinks that 121 records will be deleted, when in fact ALL rows will

/*******************************************************************************
 We get better estimates by doing as much of the work ahead of time as possible 
*******************************************************************************/

-- Get a list of the Ids that need to be deleted: 
create table #PostsToDelete
(
	Id int
	primary key clustered );
insert into #PostsToDelete (Id) 
select p.Id
from dbo.Posts as p
	 inner join dbo.PostsStaging as ps on p.Id = ps.Id; -- No Exclusive locks against Posts table are needed now!

-- Only run the delete if rows were found 
if exists
(
	select *
	from #PostsToDelete
) 
begin
	begin tran;
	delete dbo.Posts
	where Id in
	(
		select ptd.Id
		from #PostsToDelete as ptd
	);
	commit;
end;