/*
 *	Create and alter statements
 */
/* find out all the types of modules defined in the database */

select distinct 
	   type_desc
from sys.sql_modules as m
inner join sys.objects as o on m.object_ID = o.object_ID;

--

if OBJECT_ID('dbo.DeleteMePlease') is not null
begin
	drop function dbo.DeleteMePlease;
end;
go

create function dbo.DeleteMePlease
( 
	@MyParameter INT
)
returns INT
with execute as caller
as
begin
	return @MyParameter * 1.6180339887;
end;
go

select dbo.DeleteMePlease (2);

-- Better way
--
-- CREATE statements must be at the start of a batch 
-- and SQL Server local variables have a scope of only a single batch
--
-- check whether dbo.DeleteMePlease exists as an object in the dbo schema

if OBJECT_ID('dbo.DeleteMePlease') is not null
begin -- check whether dbo.DeleteMePlease exists as a scalar function
	if OBJECTPROPERTYEX(OBJECT_ID('dbo.DeleteMePlease'), 'IsScalarFunction') = 0
	begin --do whatever is necessary. You have to find out why
		raiserror('dbo.DeleteMePlease already exists and it isn''t a scalar function', 16, 1);
		set noexec on; -- prevent futher execution on this connection 
	end;
	else
	begin
		drop function dbo.DeleteMePlease;
	end; -- safe to drop it because it exists as a function
end;
go -- so now we can create our new better version of the function

create function dbo.DeleteMePlease
( 
	@MyParameter INT
)
returns INT
with execute as caller
as
begin
	return @MyParameter * 1.6180339887;
end;
go

set noexec off; -- always remember to do this. It can be perplexing otherwise

/*
 *	Duplicate names for objects
 */

-- SQL Server allows duplicate names for objects, 
-- which means that you either have to reference object names with their schema, 
-- or use the object_ID of the object

/* this simply demonstrates that you can have duplicate names for
the same object type in SQL Server */

create table dbo.DeleteMePlease
( 
	MyKey INT identity
); --create a dummy table in DBO
go

create schema silly;

create table silly.DeleteMePlease
( 
	MyKey INT identity
);--create another dummy table in silly
go

create schema sillier;

create table sillier.DeleteMePlease
( 
	MyKey INT identity
);--create another dummy table in sillier
go
--now demonstrate the fact that using a name alone is bad news

select OBJECT_SCHEMA_NAME(object_ID) + '.' + name + ' (' + type_desc collate database_default + ')'
from sys.objects
where name like 'deleteMePlease';

/* --------- which gives...
dbo.DeleteMePlease (USER_TABLE)
silly.DeleteMePlease (USER_TABLE)
sillier.DeleteMePlease (USER_TABLE)
------*/

--now we clean up

drop table dbo.DeleteMePlease;

drop table silly.DeleteMePlease;

drop table sillier.DeleteMePlease;

drop schema silly;

drop schema sillier;

--

declare @MyObject INT;

select @MyObject = OBJECT_ID('dbo.DeleteMePlease');

select OBJECT_SCHEMA_NAME(@MyObject) + '.' + OBJECT_NAME(@MyObject);

/*
 *	A few guard clauses
 */

-- Adding a table column

if not exists
(
	select *
	from sys.columns
	where object_ID = OBJECT_ID('HumanResources.Employee') and 
		  COL_NAME(object_ID, column_Id) = 'BusinessEntityID'
)
begin
	print 'Does not exist';
end;

-- Altering the datatype of a table column

if not exists
(
	select name, TYPE_NAME(user_type_id)
	from sys.columns
	where object_ID = OBJECT_ID('HumanResources.Employee') and 
		  name = 'Jobtitle' and 
		  TYPE_NAME(user_type_id) = 'nvarchar'
)
begin
	print 'it isn''t an NVARCHAR so do something';
end;

-- Creating an index only if it doesn’t exist

if not exists
(
	select *
	from sys.indexes as i
	where i.object_ID = OBJECT_ID('HumanResources.Employee') and 
		  name = 'AK_Employee_LoginID'
)
begin
	print 'index doesn’t exist';
end;

-- ALTERing an index if it does exist and creating it first if it doesn’t
--ALTERing an index if it does exist but creating it first if it doesn’t

if exists
(
	select *
	from sys.indexes as i
	where i.object_ID = OBJECT_ID('HumanResources.Employee') and 
		  name = 'AK_Employee_LoginID'
)
begin
	set noexec on;
end;
go

create unique nonclustered index AK_Employee_LoginID on HumanResources.Employee
( LoginID asc
) 
	with( pad_index = off, statistics_norecompute = off, sort_in_tempdb = off, ignore_dup_key = off, drop_existing = off, online = off, allow_row_locks = on, allow_page_locks = on ) on [PRIMARY];
go

exec sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Unique nonclustered index.', @level0type = N'SCHEMA', @level0name = N'HumanResources', @level1type = N'TABLE', @level1name = N'Employee', @level2type = N'INDEX', @level2name = N'AK_Employee_LoginID';
go

set noexec off;

alter index AK_Employee_LoginID on HumanResources.Employee rebuild;

-- Creating an index only if nothing similar exists

/* See if a similar index already exists and only create it if no similar
one exists (be careful with the comma delimiter, it must have a space after it!)
Note that one can have different ideas of what constitutes a similar index.
You can have a stricter or morelax definition.
*/

if not exists
(
	select *
	from
	(
		select COALESCE(STUFF(
		(
			select ', ' + COL_NAME(Ic.Object_Id, Ic.Column_Id) + case
																	 when Is_Descending_key <> 0 then ' DESC' else ''
																 end
			from Sys.Index_Columns as Ic
			where Ic.Index_Id = indexes.Index_Id and 
				  Ic.Object_Id = indexes.Object_Id and 
				  is_included_column = 0
			order by key_Ordinal for xml path(''), type
		).value ('.', 'varchar(max)'), 1, 2, ''), '?') as columnList
		from sys.indexes as indexes
		where type_desc not in ('heap', 'xml') and 
			  indexes.object_ID = OBJECT_ID('HumanResources.Employee')
	) as f
	where columnList like 'OrganizationLevel, OrganizationNode'
)
begin
	create unique index AK_NewIndex on HumanResources.Employee( OrganizationLevel, OrganizationNode );
end;

-- Checking whether a column has any sort of constraint

if exists
(
	select *
	from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	where CONSTRAINT_COLUMN_USAGE.TABLE_SCHEMA = 'HumanResources' and 
		  CONSTRAINT_COLUMN_USAGE.TABLE_NAME = 'Employee' and 
		  CONSTRAINT_COLUMN_USAGE.COLUMN_NAME = 'BusinessEntityID'
)
begin
	print 'Do something';
end;

if exists
(
	select ConstraintType
	from --check, default, unique, primary key, foreign key, Not NULL
	(
		select object_ID, parent_column_ID, 'default'
		from sys.default_constraints
		union all
		select parent_object_ID, parent_column_ID, 'foreign'
		from sys.foreign_key_columns
		union all
		select object_ID, column_ID, 'NOT NULL'
		from sys.columns
		where is_nullable = 0
		union all
		select i.object_ID, ic.column_ID,
							   case
								   when is_primary_key = 1 then 'Primary Key' else 'Unique'
							   end
		from sys.indexes as i
		inner join sys.index_columns as ic on i.object_ID = ic.object_ID and 
											  i.index_id = ic.index_ID
		where is_primary_key = 1 or 
			  is_unique_constraint = 1
		union all
		select object_ID, parent_column_ID, 'Check'
		from sys.check_constraints
	) as allConstraints(object_ID, Column_ID, ConstraintType)
	where object_ID = OBJECT_ID('HumanResources.Employee') and 
		  COL_NAME(object_ID, column_ID) = 'BusinessEntityID'
)
begin
	print 'Do something';
end;

if exists
(
	select *
	from sys.columns as ic
	where ic.is_nullable = 0 and 
		  ic.object_id = OBJECT_ID('HumanResources.Employee') and 
		  COL_NAME(ic.object_id, ic.column_id) = 'BusinessEntityID'
)
begin
	print 'Do something';
	select 1;
end;

-- Checking whether a column participates in a primary key etc

if exists
(
	select 1
	from sys.indexes as i
	inner join sys.index_columns as ic on i.object_ID = ic.object_ID and 
										  i.index_id = ic.index_ID
	where is_primary_key = 1 and 
		  i.object_ID = OBJECT_ID('HumanResources.Employee') and 
		  COL_NAME(ic.object_ID, ic.column_Id) = 'BusinessEntityID'
)
begin
	print 'Do something';
end;