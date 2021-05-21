/*

 Datafile
 --------
 A physical file that contains the operating system blocks 
 that hold your actual data. At its core, a database is a collection of data files.
 
 Filegroup
 ---------
 Filegroups in SQL Server are used to group data files together for 
 administrative, data allocation and placement purposes. Filegroups provide an 
 abstraction layer between database objects such as tables and indexes and the 
 actual physical files sitting on the operating system.

*/


-- Check size of databases and tables in a SQL Server instance
USE tempdb;
GO

CREATE TABLE #DatabaseSize
(
    fileid INT,
    groupid INT,
    size INT,
    maxsize INT,
    growth INT,
    status INT,
    perf INT,
    name VARCHAR(50),
    filename VARCHAR(100)
);
GO

INSERT INTO #DatabaseSize
EXEC sp_MSforeachdb @command1 = 'select * from [?]..sysfiles;';
GO

SELECT name [DB File Name],
       filename [DB File Path],
       size * 8 / 1024 [DB Size (MB)]
FROM #DatabaseSize
ORDER BY [DB Size (MB)] DESC;
GO

DROP TABLE #DatabaseSize;
GO

-- Check the size of all Tables in the user Database
USE AdventureWorks;
GO

CREATE TABLE tablesize
(
    name VARCHAR(100),
    rows INT,
    reserved VARCHAR(100),
    data VARCHAR(100),
    index_size VARCHAR(100),
    unused VARCHAR(100)
);
GO

INSERT INTO tablesize
EXEC sp_MSforeachtable 'exec sp_spaceused ''?''';
GO

SELECT name [Table Name],
       CAST(REPLACE(data, 'KB', '') AS INT) [Data Size (KB)],
       CAST(REPLACE(index_size, 'KB', '') AS INT) [Index Size (KB)]
FROM tablesize
ORDER BY [Data Size (KB)] DESC;
GO

DROP TABLE tablesize;
GO


-------------------------------------------------------------------------------
-- In SQL Server, the simple way to move data to another filegroup is to 
-- rebuild the clustered index. Tables in SQL Server cannot have more than one 
-- clustered index.
-------------------------------------------------------------------------------

-- Check All Indexes on Posts
SELECT *
FROM sys.indexes
WHERE OBJECT_NAME(object_id) = 'SalesOrderDetailEnlarged';
GO

-- Listing 3: Create Filegroup FG
USE [master];
GO
ALTER DATABASE [AdventureWorks] ADD FILEGROUP [FG];
GO

USE [master];
GO
ALTER DATABASE AdventureWorks
ADD FILE
    (
        NAME = N'SalesOrderDetailEnlarged_01',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks_SalesOrderDetailEnlarged_01.ndf',
        SIZE = 524288KB,
        FILEGROWTH = 524288KB
    ),
    (
        NAME = N'SalesOrderDetailEnlarged_02',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks_SalesOrderDetailEnlarged_02.ndf',
        SIZE = 524288KB,
        FILEGROWTH = 524288KB
    ),
    (
        NAME = N'SalesOrderDetailEnlarged_03',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks_SalesOrderDetailEnlarged_03.ndf',
        SIZE = 524288KB,
        FILEGROWTH = 524288KB
    ),
    (
        NAME = N'SalesOrderDetailEnlarged_04',
        FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorks_SalesOrderDetailEnlarged_04.ndf',
        SIZE = 524288KB,
        FILEGROWTH = 524288KB
    )
TO FILEGROUP [FG];
GO

-- Create Filegroup FG
USE AdventureWorks;
GO
ALTER TABLE [Sales].[SalesOrderDetailEnlarged]
DROP CONSTRAINT PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID
--DROP INDEX [PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID] ON [Sales].[SalesOrderDetailEnlarged] WITH (ONLINE = OFF);
GO

CREATE CLUSTERED INDEX [PK_SalesOrderDetailEnlarged_SalesOrderID_SalesOrderDetailID]
ON [Sales].[SalesOrderDetailEnlarged] (
                                          SalesOrderID,
                                          SalesOrderDetailID
                                      )
WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [FG];
GO


/*

 Other Use Cases
 ---------------
 The technique we have discussed is useful for splitting the data in one large 
 data file to smaller data files but can also be used to achieve the following:
 
 - To organize a set of tables such that you can execute Partial Backup operations 
   for them in one step. This makes sense since they only way to ensure a table is 
   sitting on a particular physical file is to move that table to a filegroup which 
   contains those physical files.
 
 - In order to move specific data to volumes with faster disks. This means, you may 
   have identified tables which are hot tables and require more stringent response 
   times. You may like to dedicate Flash Storage for such tables for instance. 
   You simply create a filegroup with files sitting on this flash storage.
 
 - To simply reorganize tables for better performance. Rebuilding clustered indexes 
   is equivalent to reorganizing the table thus removing fragmentation assuming a 
   large number of DML operations such as deletes have fragmented a large table.

*/

-- Taking a Partial Backup of the FG Filegroup
BACKUP DATABASE AdventureWorks
FILEGROUP = 'FG'
TO  DISK = 'D:\SQLBackup\SalesOrderDetailEnlarged_Part_01',
    DISK = 'D:\SQLBackup\SalesOrderDetailEnlarged_Part_02',
    DISK = 'D:\SQLBackup\SalesOrderDetailEnlarged_Part_03',
    DISK = 'D:\SQLBackup\SalesOrderDetailEnlarged_Part_04'
WITH STATS = 10;