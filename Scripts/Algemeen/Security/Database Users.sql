-- DATABASE-LEVEL SECURITY
-- create new login

create login mylogin with password = N'1234' must_change, default_database = master, check_expiration = on -- checked against AD
, check_policy = on; -- checked against AD
go

use Food;
go

-- create new stored procedure

create procedure sp1
as
begin
	select @@servername;
end;
go

-- create user and map it to a login

create user mylogin for login mylogin with default_schema = [dbo];
go

-- create a new role

create role [ROweb];

-- add user to the new role

alter role [ROweb] add member [mylogin];

-- grant exec permission on sp1 to user

grant execute on sp1 to [mylogin];
go

-- execute sp under context of new user

execute as user = 'mylogin';
go

sp1;

-- revert execute

revert;