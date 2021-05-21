-- ========================
-- Round Robin Allocation
-- ========================

create database MultipleFileGroups on primary
(
-- Primary File Group
name = 'MultiplFileGroups', filename = 'D:\Documents\MSSQL\DATA\MultiplFileGroups.mdf', size = 5 mb, maxsize = unlimited, filegrowth = 1024 kb),
-- Secondary File Group
filegroup FileGroup1
(
-- 1st file in the secondary File Group
name = 'MultiplFileGroups1', filename = 'D:\Documents\MSSQL\DATA\MultiplFileGroups1.ndf', size = 1 mb, maxsize = unlimited, filegrowth = 1024 kb),
(
-- 2nd file in the secondary File Group
name = 'MultiplFileGroups2', filename = 'D:\Documents\MSSQL\DATA\MultiplFileGroups2.ndf', size = 1 mb, maxsize = unlimited, filegrowth = 1024 kb) LOG on
(
-- Log file
name = 'MultiplFileGroups_Log', filename = 'D:\Documents\MSSQL\LOG\MultiplFileGroups_Log.ldf', size = 5 mb, maxsize = unlimited, filegrowth = 1024 kb);

-- FileGroup1 gets the default filegroup, where new database objects
-- will be created

alter database MultipleFileGroups modify filegroup FileGroup1 default;
go

use MultipleFileGroups;
go

-- Create a table with 393 length + 7 bytes overhead = 400 bytes
-- One record is stored on one data page
-- The table will be created in the file group "FileGroup1"

create table Test
(
	Filler char(8000));
go

-- Insert 40000 records, results in about 312 MB data (40000 x 8KB / 1024 = 312MB)
-- They are distributed in a round-robin fashion between the files in the file group.
-- Each file in FileGroup1 will get about 160 MB

declare @i int = 1;

while @i <= 40000
begin
	insert into Test
	values (REPLICATE('x', 8000));

	set @i+=1;
end;
go

-- Retrieve file statistics information about the created database files

declare @dbId int;

select @dbId = database_id
from sys.databases
where name = 'MultipleFileGroups';

select sys.database_files.type_desc, 
	   sys.database_files.physical_name, 
	   sys.dm_io_virtual_file_stats.*
from sys.dm_io_virtual_file_stats (@dbId, null) 
	 inner join sys.database_files on sys.database_files.file_id = sys.dm_io_virtual_file_stats.file_id;
go