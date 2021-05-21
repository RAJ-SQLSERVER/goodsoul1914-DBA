use master;
go

create database TestDatabase;
go

-- Change Recovery Model from FULL to SIMPLE

alter database TestDatabase set recovery simple with no_wait;
go

use TestDatabase;
go

-- Create a new table

create table Foo
(
	Bar int);
go

-- We cannot perform a Transaction Log Backup

backup LOG TestDatabase to disk = N'D:\Documents\MSSQL\BACKUP\TestDatabase.trn';
go

-- But we can perform a Full Database Backup

backup database TestDatabase to disk = N'D:\Documents\MSSQL\BACKUP\TestDatabase.bak';
go

-- This transaction will be lost when you do not perform any additional backups
-- since the last Full Backup.

insert into Foo
values (1);
go