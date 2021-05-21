-- DetachDB.sql

-------------------------------------------------------------------------------
-- 1. List all attached databases with file paths
-------------------------------------------------------------------------------
SELECT DB_NAME(database_id) [Database],
       physical_name
FROM sys.master_files
ORDER BY [Database];


-------------------------------------------------------------------------------
-- 2. Create Attach Script for chosen databases (accumulate history here)
-------------------------------------------------------------------------------
USE [master];
CREATE DATABASE AdventureWorksDW
ON
    (
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW.mdf'
    ),
    (
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\AdventureWorksDW_log.ldf'
    )
FOR ATTACH;

USE [master];
CREATE DATABASE StackOverflow2013
ON
    (
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\StackOverflow2013_1.mdf'
    ),
    (
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\StackOverflow2013_log.ldf'
    ),
	(
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\StackOverflow2013_2.ndf'
	),
	(
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\StackOverflow2013_3.ndf'
	),
	(
		FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\StackOverflow2013_4.ndf'
	)
FOR ATTACH;


-------------------------------------------------------------------------------
-- 3. Detach Database
-------------------------------------------------------------------------------
USE [master];
EXEC master.dbo.sp_detach_db @dbname = N'AdventureWorksDW';


-------------------------------------------------------------------------------
-- 4. To rollback, re-attach database (scripted in step-2)
-------------------------------------------------------------------------------
