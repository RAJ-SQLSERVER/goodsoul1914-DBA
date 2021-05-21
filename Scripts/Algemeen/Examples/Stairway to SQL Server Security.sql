create login Topaz
with password = 'yBqyZIPT8}b]b[{5al0v'


use AdventureWorks
go

create user Topaz for login Topaz
with default_schema = HumanResources
go

drop user Topaz
go


create user TopazD for login Topaz
with default_schema = HumanResources
go


alter login Topaz 
with password = 'yBqyZIPT8}b]b[{5al0v', check_expiration = off, check_policy = off;

alter login Topaz 
with password = 'yBqyZIPT8}b]b[{5al0v' 
unlock;


alter server role [dbcreator] add member [Topaz];
go
alter server role [diskadmin] add member [Topaz];
go


EXEC sp_addsrvrolemember 'Topaz', 'dbcreator';
EXEC sp_addsrvrolemember 'Topaz', 'diskadmin';

exec sp_helpsrvrole
exec sp_helpsrvrolemember


create server role LimitedDBA;
USE master;
GO
-- Grant the role virtual sysadmin permissions
grant control server to LimitedDBA;
-- And take some permissions away
deny alter any login to LimitedDBA;
DENY ALTER ANY SERVER AUDIT TO LimitedDBA;
deny alter any server role to LimitedDBA;
deny create server role to LimitedDBA; 
deny unsafe assembly to LimitedDBA;
alter server role LimitedDBA add member [LT-RSD-01\SQLTest];


-- Create carol login
create login carol with password = 'crolPWD123%%%';
execute as login = 'carol';
-- Verify user context
print SUSER_SNAME();
-- Can Carol alter logins?
create login donkiely with password = 'G@Sm3aIKU3HA#fW^MNyA'; -- No
-- Other server-level permissions?
select *
from sys.dm_exec_cached_plans; -- No, requires VIEW USER STATE
create server role CarolRole; -- No
revert;


alter server role LimitedDBA add member carol;
-- Now does Carol have permissions?
execute as login = 'carol';
create login donkiely with password = 'G@Sm3aIKU3HA#fW^MNyA'; -- Still not possible
select *
from sys.dm_exec_cached_plans; -- Yes, CONTROL SERVER covers VIEW USER STATE
create server role CarolRole; -- Not possible
revert;


SELECT * 
FROM sys.fn_builtin_permissions('SERVER') 
ORDER BY permission_name;


use AdventureWorks;
go
revoke connect from guest;
go


-- Create the DataEntry role and assign Topaz to it
create role [DataEntry] authorization [dbo];
alter role [DataEntry] add member [Topaz];

-- Assign permissions to the DataEntry role
grant insert on HumanResources.Employee to [DataEntry];
grant update on HumanResources.Employee to [DataEntry];
grant insert on HumanResources.JobCandidate to [DataEntry];
grant update on HumanResources.JobCandidate to [DataEntry];
grant insert on Person.Address to [DataEntry];
grant update on Person.Address to [DataEntry];
grant execute on HumanResources.uspUpdateEmployeeHireInfo to [DataEntry];
deny view definition on HumanResources.uspUpdateEmployeeHireInfo to [DataEntry];
grant execute on HumanResources.uspUpdateEmployeePersonalInfo to [DataEntry];
deny view definition on HumanResources.uspUpdateEmployeePersonalInfo to [DataEntry];
go


select 
    DB_NAME() as 'Database', 
    p.name, 
    p.type_desc, 
    dbp.state_desc, 
    dbp.permission_name, 
    so.name, 
    so.type_desc
from sys.database_permissions as dbp
left join sys.objects as so on dbp.major_id = so.object_id
left join sys.database_principals as p on dbp.grantee_principal_id = p.principal_id
where p.name = 'DataEntry'
order by 
    so.name, 
    dbp.permission_name;


execute as USER = 'TopazD';
-- Succeeds
insert into Person.Address
(
    AddressLine1, 
    City, 
    StateProvinceID, 
    PostalCode
) 
values ('8 Hazelnut', 'Irvine', 9, '92602');
go
-- Fails
insert into HumanResources.Department
(
    Name, 
    GroupName
) 
values ('Advertising', 'Sales and Marketing');
go
-- Succeeds (doesn't actually change any data)
declare @RC int;
execute @RC = HumanResources.uspUpdateEmployeePersonalInfo 1, '295847284', '1963-03-02', 'S', 'M';
go
-- Fails
execute dbo.uspGetManagerEmployees 1;
go
revert;


create role DataEntry authorization dbo;
grant delete on schema ::Purchasing to DataEntry;
grant insert on schema ::Purchasing to DataEntry;
grant select on schema ::Purchasing to DataEntry;
grant update on schema ::Purchasing to DataEntry;
go


if SUSER_SID('carol') is not null
    drop login carol;
go
create database DefaultSchema;
go
use DefaultSchema;
go
create login carol with password = 'crolPWD123%%%';
create USER carol for login carol;
grant create table to carol;
execute as login = 'carol';
go
create table table1 (tID int);
go
revert;
go
create schema DogSchema authorization carol;
go
create table DogSchema.table1(tID int);
go
create USER carol for login carol with default_schema = DogSchema;
-- or
alter USER carol with default_schema = DogSchema;
go
execute as login = 'carol';
go
create table table2 (tID int);
go
select *
from table2;
go
revert;
go
select *
from DogSchema.table2;
go


create login [Marathon\DBAs] from windows;
create USER DataAdmins from login [Marathon\DBAs];
create role DBAs;
alter role DBAs add member DataAdmins;
grant create table to DBAs;
grant control on schema::DogSchema to DBAs;
create table table1 (tID int);


