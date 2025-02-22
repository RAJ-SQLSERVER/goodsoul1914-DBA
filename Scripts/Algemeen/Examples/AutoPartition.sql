CREATE DATABASE AutoPartition;
GO

/*
 Adding File Groups to the database:
*/
ALTER DATABASE AutoPartition ADD FILEGROUP FG_01_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_02_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_03_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_04_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_05_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_06_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_07_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_08_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_09_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_10_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_11_2020;
GO

ALTER DATABASE AutoPartition ADD FILEGROUP FG_12_2020;
GO

/*
 Adding Files to each File Group
*/
ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_012020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_012020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_01_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_022020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_022020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_02_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_032020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_032020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_03_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_042020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_042020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_04_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_052020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_052020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_05_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_062020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_062020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_06_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_072020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_072020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_07_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_082020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_082020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_08_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_092020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_092020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_09_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_102020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_102020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_10_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_112020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_112020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_11_2020;
GO

ALTER DATABASE AutoPartition ADD FILE (
	NAME = [File_122020],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\File_122020.ndf',
	SIZE = 5 MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10 MB
	) TO FILEGROUP FG_12_2020;
GO

USE AutoPartition
GO

/*
 Adding a Partition Function with Month wise range
*/
CREATE PARTITION FUNCTION [PF_MonthlyPartition] (DATETIME) AS RANGE RIGHT
FOR
VALUES (
	'2020-01-31 23:59:59.997',
	'2020-02-29 23:59:59.997',
	'2020-03-31 23:59:59.997',
	'2020-04-30 23:59:59.997',
	'2020-05-31 23:59:59.997',
	'2020-06-30 23:59:59.997',
	'2020-07-31 23:59:59.997',
	'2020-08-31 23:59:59.997',
	'2020-09-30 23:59:59.997',
	'2020-10-31 23:59:59.997',
	'2020-11-30 23:59:59.997',
	'2020-12-31 23:59:59.997'
	);
GO

/*
 Adding a Partition Scheme with File Groups to the Partition Function
*/
CREATE PARTITION SCHEME PS_MonthWise AS PARTITION PF_MonthlyPartition TO (
	'FG_01_2020',
	'FG_02_2020',
	'FG_03_2020',
	'FG_04_2020',
	'FG_05_2020',
	'FG_06_2020',
	'FG_07_2020',
	'FG_08_2020',
	'FG_09_2020',
	'FG_10_2020',
	'FG_11_2020',
	'FG_12_2020',
	'Primary'
	);
GO

/*
 Creating a Table with the Partition Scheme
*/
CREATE TABLE orders (
	[order_id] BIGINT IDENTITY(1, 1) NOT NULL,
	[user_id] BIGINT,
	[order_amt] DECIMAL(10, 2),
	[address_id] BIGINT,
	[status_id] TINYINT,
	[is_active] BIT,
	[order_date] [DATETIME]
	) ON PS_MonthWise ([order_date]);
GO

CREATE CLUSTERED INDEX CI_orders_order_id ON orders (order_id);
GO

CREATE NONCLUSTERED INDEX IX_user_id ON orders (user_id);
GO

/*
 Inserting data into Table [orders]
*/
INSERT INTO orders (
	user_id,
	order_amt,
	address_id,
	status_id,
	is_active,
	order_date
	)
VALUES (
	43,
	1623.78,
	51,
	1,
	1,
	'2020-01-14 13:21:51.869'
	),
	(
	51,
	8963.17,
	43,
	1,
	1,
	'2020-02-17 05:07:43.193'
	),
	(
	27,
	7416.93,
	66,
	1,
	1,
	'2020-03-21 07:53:07.743'
	),
	(
	58,
	9371.54,
	45,
	1,
	1,
	'2020-04-26 16:19:27.852'
	),
	(
	53,
	8541.56,
	65,
	1,
	1,
	'2020-05-08 19:21:58.654'
	),
	(
	98,
	6971.85,
	54,
	1,
	1,
	'2020-06-17 21:34:52.426'
	),
	(
	69,
	5217.74,
	78,
	1,
	1,
	'2020-07-03 07:37:51.391'
	),
	(
	21,
	9674.14,
	98,
	1,
	1,
	'2020-08-27 23:49:53.813'
	),
	(
	52,
	1539.96,
	32,
	1,
	1,
	'2020-09-01 17:17:07.317'
	),
	(
	17,
	7193.63,
	21,
	1,
	1,
	'2020-10-23 10:23:37.307'
	),
	(
	68,
	3971.25,
	19,
	1,
	1,
	'2020-11-30 09:01:27.079'
	),
	(
	97,
	5973.58,
	97,
	1,
	1,
	'2020-12-06 13:43:21.190'
	),
	(
	76,
	4163.95,
	76,
	1,
	1,
	'2021-01-03 18:51:17.764'
	);
GO

/*
 Partition details with Row count
*/
SELECT DISTINCT o.name AS table_name,
	rv.value AS partition_range,
	fg.name AS file_groupName,
	p.partition_number,
	p.rows AS number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id
	AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id
	AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id
	AND p.partition_number = rv.boundary_id
WHERE o.object_id = OBJECT_ID('orders');
GO

/*
 Table Rows with Partition Number
*/
SELECT $PARTITION.PF_MonthlyPartition(order_date) AS PartitionNumber,
	*
FROM orders;
GO

/*
 Automate the Partition flow
*/
SELECT o.name AS table_name,
	pf.name AS PartitionFunction,
	ps.name AS PartitionScheme,
	MAX(rv.value) AS LastPartitionRange,
	CASE 
		WHEN MAX(rv.value) <= DATEADD(MONTH, 2, GETDATE())
			THEN 1
		ELSE 0
		END AS isRequiredMaintenance
--INTO #temp
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id
	AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
INNER JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id
	AND p.partition_number = rv.boundary_id
GROUP BY o.name,
	pf.name,
	ps.name;
GO

/*
 
*/
SELECT table_name,
	PartitionFunction,
	PartitionScheme,
	LastPartitionRange,
	CONVERT(VARCHAR, DATEADD(MONTH, 1, LastPartitionRange), 25) AS NewRange,
	'FG_' + CAST(FORMAT(DATEADD(MONTH, 1, LastPartitionRange), 'MM') AS VARCHAR(2)) + '_' + CAST(YEAR(DATEADD(MONTH, 1, LastPartitionRange)) AS VARCHAR(4)) AS NewFileGroup,
	'File_' + CAST(FORMAT(DATEADD(MONTH, 1, LastPartitionRange), 'MM') AS VARCHAR(2)) + CAST(YEAR(DATEADD(MONTH, 1, LastPartitionRange)) AS VARCHAR(4)) AS FileName,
	'C:\Program Files\Microsoft SQL Server\MSSQL13.JRAIYANI\MSSQL\DATA\' AS file_path
INTO #generateScript
FROM #temp
WHERE isRequiredMaintenance = 1;
GO

/*
 
*/
DECLARE @filegroup NVARCHAR(MAX) = N'';
DECLARE @file NVARCHAR(MAX) = N'';
DECLARE @PScheme NVARCHAR(MAX) = N'';
DECLARE @PFunction NVARCHAR(MAX) = N'';

SELECT @filegroup = @filegroup + CONCAT (
		'IF NOT EXISTS(SELECT 1 FROM AutoPartition.sys.filegroups WHERE name = ''',
		NewFileGroup,
		''')
    BEGIN
      ALTER DATABASE AutoPartition ADD FileGroup ',
		NewFileGroup,
		' 
    END;'
		),
	@file = @file + CONCAT (
		'IF NOT EXISTS(SELECT 1 FROM AutoPartition.sys.database_files WHERE name = ''',
		FileName,
		''')
    BEGIN
    ALTER DATABASE AutoPartition ADD FILE 
    (NAME = ''',
		FileName,
		''', 
    FILENAME = ''',
		file_path,
		FileName,
		'.ndf'', 
    SIZE = 5MB, MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10MB )
    TO FILEGROUP ',
		NewFileGroup,
		'
    END;'
		),
	@PScheme = @PScheme + CONCAT (
		'ALTER PARTITION SCHEME ',
		PartitionScheme,
		' NEXT USED ',
		NewFileGroup,
		';'
		),
	@PFunction = @PFunction + CONCAT (
		'ALTER PARTITION FUNCTION ',
		PartitionFunction,
		'() SPLIT RANGE (''',
		NewRange,
		''');'
		)
FROM #generateScript;

EXEC (@filegroup);

EXEC (@file);

EXEC (@PScheme);

EXEC (@PFunction);
GO


