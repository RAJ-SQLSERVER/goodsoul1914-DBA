/*************************************************************
 Stairway to Transaction Log Management in SQL Server, Level 1
*************************************************************/

use master;
go

-- Drop database if it exists
if exists (select name
		   from sys.databases
		   where name = 'TestDB') 
	drop database TestDB;

create database TestDB on (name = TestDB_dat, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDB.mdf') LOG on (name = TestDB_log, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDB.ldf');

-- Show transaction log info
dbcc sqlperf(LOGSPACE);

-- full backup of the database
backup database TestDB to disk = 'D:\SQLBackup\TestDB.bak' with init;
go

-- Create a table with a million records
use TestDB;
go

if OBJECT_ID('dbo.LogTest', 'U') is not null
	drop table dbo.LogTest;
--===== AUTHOR: Jeff Moden
--===== Create and populate 1,000,000 row test table.
-- "SomeID" has range of 1 to 1000000 unique numbers
-- "SomeInt" has range of 1 to 50000 non-unique numbers
-- "SomeLetters2";"AA"-"ZZ" non-unique 2-char strings
-- "SomeMoney"; 0.0000 to 99.9999 non-unique numbers
-- "SomeDate" ; >=01/01/2000 and <01/01/2010 non-unique
-- "SomeHex12"; 12 random hex characters (ie, 0-9,A-F) 
select top 1000000 SomeID = IDENTITY( int, 1, 1), 
				   SomeInt = ABS(CHECKSUM(NEWID())) % 50000 + 1, 
				   SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65), 
				   SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 / 100.0 as money), 
				   SomeDate = CAST(RAND(CHECKSUM(NEWID())) * 3653.0 + 36524.0 as datetime), 
				   SomeHex12 = RIGHT(NEWID(), 12)
into dbo.LogTest
from sys.all_columns as ac1
cross join sys.all_columns as ac2;

-- Show transaction log info
dbcc sqlperf(LOGSPACE);

-- now backup the transaction log
backup Log TestDB to disk = 'D:\SQLBackup\TestDB_log.bak' with init;
go

-- Show transaction log info
dbcc sqlperf(LOGSPACE);

/*************************************************************
 Stairway to Transaction Log Management in SQL Server, Level 2
*************************************************************/

use master;
go

-- Drop database if it exists
if exists (select name
		   from sys.databases
		   where name = 'TestDB') 
	drop database TestDB;

-- Create it 
create database TestDB on (name = TestDB_dat, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDB.mdf') LOG on (name = TestDB_log, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDB.ldf');

-- Switch database context
use TestDB;
go

-- How many VLFs?
DBCC Loginfo
GO

-- Create another table with a million records
if OBJECT_ID('dbo.LogTest', 'U') is not null
	drop table dbo.LogTest;

--===== AUTHOR: Jeff Moden
--===== Create and populate 1,000,000 row test table.
-- "SomeID" has range of 1 to 1000000 unique numbers
-- "SomeInt" has range of 1 to 50000 non-unique numbers
-- "SomeLetters2";"AA"-"ZZ" non-unique 2-char strings
-- "SomeMoney"; 0.0000 to 99.9999 non-unique numbers
-- "SomeDate" ; >=01/01/2000 and <01/01/2010 non-unique
-- "SomeHex12"; 12 random hex characters (ie, 0-9,A-F) 
select top 1000000 SomeID = IDENTITY( int, 1, 1), 
				   SomeInt = ABS(CHECKSUM(NEWID())) % 50000 + 1, 
				   SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65), 
				   SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 / 100.0 as money), 
				   SomeDate = CAST(RAND(CHECKSUM(NEWID())) * 3653.0 + 36524.0 as datetime), 
				   SomeHex12 = RIGHT(NEWID(), 12)
into dbo.LogTest
from sys.all_columns as ac1
cross join sys.all_columns as ac2;

-- How many VLFs?
DBCC Loginfo
GO

/*************************************************************
 Stairway to Transaction Log Management in SQL Server, Level 3
*************************************************************/

use master;

-- set recovery model to FULL
alter database TestDB set recovery full;

-- set recovery model to SIMPLE
alter database TestDB set recovery simple;

-- set recovery model to BULK_LOGGED
alter database TestDB set recovery bulk_logged;

-- Querying `sys.databases` for the recovery model*
select name, 
	   recovery_model_desc
from sys.databases
where name = 'TestDB';
go

use master;
if exists (select name
		   from sys.databases
		   where name = 'TestDB') 
	drop database TestDB;

create database TestDB on (name = TestDB_dat, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Data\TestDB.mdf') LOG on (name = TestDB_log, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\Data\TestDB.ldf');

-- STEP 2: INSERT A MILLION ROWS INTO A TABLE
use TestDB;
go

if OBJECT_ID('dbo.LogTest', 'U') is not null
	drop table dbo.LogTest;

select top 1000000 SomeID = IDENTITY( int, 1, 1), 
				   SomeInt = ABS(CHECKSUM(NEWID())) % 50000 + 1, 
				   SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65), 
				   SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 / 100.0 as money), 
				   SomeDate = CAST(RAND(CHECKSUM(NEWID())) * 3653.0 + 36524.0 as datetime), 
				   SomeHex12 = RIGHT(NEWID(), 12)
into dbo.LogTest
from sys.all_columns as ac1
cross join sys.all_columns as ac2;
select name, 
	   recovery_model_desc
from sys.databases
where name = 'TestDB';
GO


