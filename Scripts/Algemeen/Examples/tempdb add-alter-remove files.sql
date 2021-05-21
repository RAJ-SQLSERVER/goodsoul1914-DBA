--
USE tempdb;
GO
DBCC SHRINKFILE('tempdev2', EMPTYFILE)
GO
USE master;
GO
ALTER DATABASE tempdb REMOVE FILE tempdev2;

--
EXEC sp_helpdb @dbname = 'tempdb';

--
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, SIZE = 512MB);
--
ALTER DATABASE tempdb ADD FILE ( NAME = N'temp2',
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\temp2.ndf', SIZE = 512MB , FILEGROWTH = 256MB)
GO
--
ALTER DATABASE tempdb ADD FILE ( NAME = N'tempventvalve',
FILENAME = N'D:\temp\tempventvalve.ndf' , SIZE = 1MB , FILEGROWTH = 1MB)
GO
