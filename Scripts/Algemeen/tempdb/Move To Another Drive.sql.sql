
DECLARE @TempData varchar(2000) = 'T:\TempDB\', 
	    @TempLog varchar(2000) = 'L:\SQLLogs\'

SELECT [name] AS [Logical Name],
	physical_name AS [Current Location],
	state_desc AS [Status],
	size * 8 / 1024 AS [Size(MB)],
	'ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],' 
	+ CASE 
		WHEN right(f.physical_name, 3) = 'ldf' THEN ' FILENAME = ''' + @TempLog + f.name 
		ELSE ' FILENAME = ''' + @TempData + f.name 
	END + CASE 
		WHEN right(f.physical_name, 3) = 'ldf' THEN '.ldf' 
		WHEN right(f.physical_name, 3) = 'ndf' THEN '.ndf' 
		WHEN right(f.physical_name, 3) = 'mdf' THEN '.mdf' 
	END + ''');' AS [Create New TempDB Files]
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb');



-- Move TempDB to another drive (and add new files)
---------------------------------------------------------------------------------------------------
DBCC DROPCLEANBUFFERS;
GO
DBCC FREEPROCCACHE;
GO
DBCC FREESESSIONCACHE;
GO
DBCC FREESYSTEMCACHE('ALL');
GO

USE master;
GO

SELECT name,
       physical_name AS CurrentLocation
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = 'tempdev',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb.mdf',
    SIZE = 500MB,
    FILEGROWTH = 100MB
);
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = templog,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\templog.ldf',
    SIZE = 100MB,
    FILEGROWTH = 10MB
);
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = N'tempdev2',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev2.ndf',
    SIZE = 500MB,
    FILEGROWTH = 100
);
ALTER DATABASE tempdb
MODIFY FILE (
    NAME = N'tempdev3',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev3.ndf',
    SIZE = 500MB,
    FILEGROWTH = 100
);
ALTER DATABASE tempdb
MODIFY FILE (
    NAME = N'tempdev4',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdev4.ndf',
    SIZE = 500MB,
    FILEGROWTH = 100
);
GO

SELECT name,
       physical_name AS CurrentLocation,
       state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');

-- Delete the tempdb.mdf and templog.ldf files from the original location