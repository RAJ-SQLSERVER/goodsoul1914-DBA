/*
 Horizontal Partitioning

 Horizontal partitioning divides a table into multiple tables that contain the same 
 number of columns, but fewer rows. For example, if a table contains a large number 
 of rows that represent monthly reports it could be partitioned horizontally into 
 tables by years, with each table representing all monthly reports for a specific year. 
 This way queries requiring data for a specific year will only reference the appropriate 
 table. Tables should be partitioned in a way that queries reference as few tables as possible.

 Tables are horizontally partitioned based on a column which will be used for partitioning 
 and the ranges associated to each partition. Partitioning column is usually a datetime 
 column but all data types that are valid for use as index columns can be used as a 
 partitioning column, except a timestamp column. The ntext, text, image, xml, varchar(max), 
 nvarchar(max), or varbinary(max), Microsoft .NET Framework common language runtime (CLR) 
 user-defined type, and alias data type columns cannot be specified.
*/
/*
 An example of horizontal partitioning with creating a new partitioned table
*/
ALTER DATABASE PartitioningDB ADD FILEGROUP January;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP February;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP March;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP April;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP May;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP June;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP July;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP August;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP September;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP October;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP November;
GO

ALTER DATABASE PartitioningDB ADD FILEGROUP December;
GO

-- To check created and available file groups in the current database run the following query:
SELECT name AS AvailableFilegroups
FROM sys.filegroups
WHERE type = 'FG';

-- When filegrups are created we will add .ndf file to every filegroup:
ALTER DATABASE [PartitioningDB] ADD FILE (
	NAME = [PartJan],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.LENOVO\MSSQL\DATA\PartitioningDB.ndf',
	SIZE = 3072 KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024 KB
	) TO FILEGROUP [January];

-- The same way files to all created filegroups with specifying the logical name of the file 
-- and the operating system (physical) file name for each filegroup e.g.:
ALTER DATABASE [PartitioningDB] ADD FILE (
	NAME = [PartFeb],
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.LENOVO\MSSQL\DATA\PartitioningDB2.ndf',
	SIZE = 3072 KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024 KB
	) TO FILEGROUP [February];

-- To check files created added to the filegroups run the following query:
SELECT name AS [FileName],
	physical_name AS [FilePath]
FROM sys.database_files
WHERE type_desc = 'ROWS';
GO

-- After creating additional filegroups for storing data we'll create a partition function. 
-- A partition function is a function that maps the rows of a partitioned table into partitions 
-- based on the values of a partitioning column. In this example we will create a partitioning 
-- function that partitions a table into 12 partitions, one for each month of a year's worth of 
-- values in a datetime column:
CREATE PARTITION FUNCTION [PartitioningByMonth] (DATETIME) AS RANGE RIGHT
FOR
VALUES (
	'20140201',
	'20140301',
	'20140401',
	'20140501',
	'20140601',
	'20140701',
	'20140801',
	'20140901',
	'20141001',
	'20141101',
	'20141201'
	);

-- To map the partitions of a partitioned table to filegroups and determine the number and 
-- domain of the partitions of a partitioned table we will create a partition scheme:
CREATE PARTITION SCHEME PartitionBymonth AS PARTITION PartitioningBymonth TO (
	January,
	February,
	March,
	April,
	May,
	June,
	July,
	Avgust,
	September,
	October,
	November,
	December
	);

-- Now we're going to create the table using the PartitionBymonth partition scheme, 
-- and fill it with the test data:
CREATE TABLE Reports (
	ReportDate DATETIME PRIMARY KEY,
	MonthlyReport VARCHAR(MAX)
	) ON PartitionBymonth (ReportDate);
GO

INSERT INTO Reports (
	ReportDate,
	MonthlyReport
	)
SELECT '20140105',
	'ReportJanuary'

UNION ALL

SELECT '20140205',
	'ReportFebryary'

UNION ALL

SELECT '20140308',
	'ReportMarch'

UNION ALL

SELECT '20140409',
	'ReportApril'

UNION ALL

SELECT '20140509',
	'ReportMay'

UNION ALL

SELECT '20140609',
	'ReportJune'

UNION ALL

SELECT '20140709',
	'ReportJuly'

UNION ALL

SELECT '20140809',
	'ReportAugust'

UNION ALL

SELECT '20140909',
	'ReportSeptember'

UNION ALL

SELECT '20141009',
	'ReportOctober'

UNION ALL

SELECT '20141109',
	'ReportNovember'

UNION ALL

SELECT '20141209',
	'ReportDecember';

-- We will now verify the rows in the different partitions:
SELECT p.partition_number AS PartitionNumber,
	f.name AS PartitionFilegroup,
	p.rows AS NumberOfRows
FROM sys.partitions p
JOIN sys.destination_data_spaces dds ON p.partition_number = dds.destination_id
JOIN sys.filegroups f ON dds.data_space_id = f.data_space_id
WHERE OBJECT_NAME(object_id) = 'Reports';
	-- Now just copy data from your table and rename a partitioned table.
