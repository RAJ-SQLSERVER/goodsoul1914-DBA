/*

 Every SQL Server database has at least two operating system files: 
 a data file and a log file. Data files can be of two types: Primary or Secondary.  
 The Primary data file contains startup information for the database and points to 
 other files in the database. User data and objects can be stored in this file and 
 every database has one primary data file. Secondary data files are optional and 
 can be used to spread data across multiple files/disks by putting each file on a 
 different disk drive. SQL Server databases can have multiple data and log files, 
 but only one primary data file. Above these operating system files, there are 
 Filegroups. Filegroups work as a logical container for the data files and a 
 filegroup can have multiple data files.
 
 The disk space allocated to a data file is logically divided into pages which is 
 the fundamental unit of data storage in SQL Server. A database page is an 8 KB 
 chunk of data. When you insert any data into a SQL Server database, it saves the 
 data to a series of 8 KB pages inside the data file. If multiple data files exist 
 within a filegroup, SQL Server allocates pages to all data files based on a 
 round-robin mechanism. So if we insert data into a table, SQL Server allocates 
 pages first to data file 1, then allocates to data file 2, and so on, then back 
 to data file 1 again. SQL Server achieves this by an algorithm known as 
 Proportional Fill.
 
 The proportional fill algorithm is used when allocating pages, so all data files 
 allocate space around the same time. This algorithm determines the amount of 
 information that should be written to each of the data files in a multi-file 
 filegroup based on the proportion of free space within each file, which allows 
 the files to become full at approximately the same time. Proportional fill works 
 based on the free space within a file.

*/

-------------------------------------------------------------------------------
-- Analyzing How SQL Server Data is Stored
-------------------------------------------------------------------------------
CREATE DATABASE [Manvendra] CONTAINMENT = NONE
ON PRIMARY
       (
           NAME = N'Manvendra',
           FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Manvendra.mdf',
           SIZE = 5MB,
           MAXSIZE = UNLIMITED,
           FILEGROWTH = 10MB
       ),
       (
           NAME = N'Manvendra_1',
           FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Manvendra_1.ndf',
           SIZE = 5MB,
           MAXSIZE = UNLIMITED,
           FILEGROWTH = 10MB
       ),
       (
           NAME = N'Manvendra_2',
           FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Manvendra_2.ndf',
           SIZE = 5MB,
           MAXSIZE = UNLIMITED,
           FILEGROWTH = 10MB
       )
LOG ON
    (
        NAME = N'Manvendra_log',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Manvendra_log.ldf',
        SIZE = 10MB,
        MAXSIZE = 1GB,
        FILEGROWTH = 10%
    );
GO

USE Manvendra;
GO


-- Check available free space in each data file of this database to track the 
-- sequence of page allocations to the data files
SELECT DB_NAME() AS [DatabaseName],
       name,
       file_id,
       physical_name,
       (size * 8.0 / 1024) AS Size,
       ((size * 8.0 / 1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024)) AS FreeSpace
FROM sys.database_files;
GO


-- Check how many Extents are allocated for this database
DBCC showfilestats
GO

/*
 With this command we can see the number of Extents for each data file. 
 As you may know, the size of each data page is 8KB and eight continuous 
 pages equals one extent, so the size of an extent would be approximately 64KB. 
 We created each data file with a size of 5 MB, so the total number of 
 available extents would be 80 which is shown in column TotalExtents, 
 we can get this by (5*1024)/64.

 UsedExtents is the number of extents allocated with data. As I mentioned above, 
 the primary data file includes system information about the database, 
 so this is why this file has a higher number of UsedExtents.
*/


-- Create a table
CREATE TABLE [Test_Data]
(
    [Sr.No] INT IDENTITY,
    [Date] DATETIME
        DEFAULT GETDATE(),
    [City] CHAR(25)
        DEFAULT 'Bangalore',
    [Name] CHAR(25)
        DEFAULT 'Manvendra Deo Singh'
);
GO


-- Check the allocated pages and free space available in each data file
SELECT DB_NAME() AS [DatabaseName],
       name,
       file_id,
       physical_name,
       (size * 8.0 / 1024) AS Size,
       ((size * 8.0 / 1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024)) AS FreeSpace
FROM sys.database_files;
GO


-- 
DBCC showfilestats
GO


-- Insert some data
INSERT INTO Test_Data
DEFAULT VALUES;
GO 10000


-- Check the available free space in each data file and the total 
-- allocated pages of each data file.
SELECT DB_NAME() AS [DatabaseName],
       name,
       file_id,
       physical_name,
       (size * 8.0 / 1024) AS Size,
       ((size * 8.0 / 1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024)) AS FreeSpace
FROM sys.database_files;
GO


-- 
DBCC showfilestats
GO



USE master
GO
DROP DATABASE Manvendra
GO
