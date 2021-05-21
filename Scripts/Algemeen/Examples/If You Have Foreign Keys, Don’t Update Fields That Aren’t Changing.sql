-- Every Post’s OwnerUserId column must map up to a valid Users.Id
alter table dbo.Posts
with nocheck
add constraint FK_Posts_OwnerUserId_Users_Id foreign key(OwnerUserId) references dbo.Users(Id);

-- Let’s grab a Posts row and see who the current OwnerUserId is:
select OwnerUserId
from dbo.Posts
where Id = 215808; -- 26837

-- Set the Posts.OwnerUserId to the same value
update dbo.Posts
set OwnerUserId = 26837
where Id = 215808;

-- Even if we specify this, it also seeks the Users table
update dbo.Posts
set OwnerUserId = OwnerUserId
where Id = 215808;

-- But if I update an unrelated column, like Score, 
-- then SQL Server doesn’t have to check the Users foreign key
update dbo.Posts
set Score = Score + 1
where Id = 215808;