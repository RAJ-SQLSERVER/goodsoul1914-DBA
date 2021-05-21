-- Separate the READING and UPDATING phase by using a SPOOL.
-- This way multiple updates to the same record are prevented.

create database HalloweenProtection;
go

use HalloweenProtection;
go

-- Create a new table

create table Foo
(
	Col1 int
	primary key, 
	Col2 int, 
	Col3 int);
go

-- Create a nonclustered index

create nonclustered index idx_Col3 on Foo
(Col3);
go

-- Insert a few records

insert into Foo (Col1, 
				 Col2, 
				 Col3) 
values (1, 1, 1), (2, 2, 2), (3, 3, 3);
go

-- Run a UPDATE statement where the Query Optimizer will introduce a Spool
-- for Halloween Protection

update Foo
set Col3 = Col3 * 2
from Foo with (index(idx_Col3))
where Col3 < 3;
go