/*

 Since a Heap has no index structures, Microsoft SQL Server must always read 
 the entire table. Microsoft SQL Server solves the problem with predicates 
 with a FILTER operator (Predicate Pushdown)

   
 If necessary restore the sample database:

 USE master
 GO 
 RESTORE DATABASE CustomerOrders
 FROM DISK = N'D:\Dropbox\SQL Server\Sample Data\CustomerOrders.bak'
 WITH MOVE 'CustomerOrders_Data'
      TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\CustomerOrders.mdf',
      MOVE 'CustomerOrders_Log'
      TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\CustomerOrders.ldf',
      REPLACE,
      STATS = 10;
 GO
*/


USE Playground;
GO

-------------------------------------------------------------------------------
-- Create a BIG table with ~4.000.000 rows
------------------------------------------------------------------------------- 
SELECT C.ID AS Customer_Id,
       C.Name,
       A.CCode,
       A.ZIP,
       A.City,
       A.Street,
       A.[State],
       CO.OrderNumber,
       CO.InvoiceNumber,
       CO.OrderDate,
       CO.OrderStatus_Id,
       CO.Employee_Id,
       CO.InsertUser,
       CO.InsertDate
INTO dbo.CustomerOrderList
FROM CustomerOrders.dbo.Customers AS C
    INNER JOIN CustomerOrders.dbo.CustomerAddresses AS CA
        ON (C.Id = CA.Customer_Id)
    INNER JOIN CustomerOrders.dbo.Addresses AS A
        ON (CA.Address_Id = A.Id)
    INNER JOIN CustomerOrders.dbo.CustomerOrders AS CO
        ON (C.Id = CO.Customer_Id)
ORDER BY C.Id,
         CO.OrderDate
OPTION (MAXDOP 1);
GO

-------------------------------------------------------------------------------
-- When data is read from a Heap, a TABLE SCAN operator is used in the 
-- execution plan – regardless of the number of data records that have to be 
-- delivered to the client.
-------------------------------------------------------------------------------
SELECT * 
FROM dbo.CustomerOrderList
GO

/*
 When Microsoft SQL Server reads data from a table or an index, this can be 
 done in two ways:

 - The data selection follows the B-tree structure of an index
 - The data is selected in accordance with the logical arrangement of data 
   pages

 In a Heap, the reading process takes place in the order in which data was 
 saved on the data pages. Microsoft SQL Server reads information about the 
 data pages of the Heap from the IAM page of a table.

 After the “route” for reading the data has been read from the IAM, the SCAN 
 process begins to send the data to the client. This technique is called 
 “Allocation Order Scan” and can be observed above all at Heaps.

 If the data is limited by a predicate, the way of working does not change. 
 Since the data is unsorted in a Heap, Microsoft SQL Server must always search 
 the complete table (all data pages).
*/

SELECT * 
FROM dbo.CustomerOrderList
WHERE Customer_Id = 10;
GO


/*
 The filtering is called “predicate pushdown”. Before further processes are 
 processed, the number of data records is reduced as much as possible! 
 A predicate pushdown can be made visible in the execution plan using 
 trace flag 9130!
*/

SELECT *
FROM dbo.CustomerOrderList
WHERE Customer_Id = 10
OPTION (QUERYTRACEON 9130);
GO


/*
 Heaps appear to be inferior to an index when reading data. 
 However, this statement only applies if the data is to be limited by a 
 predicate. In fact, when reading the complete table, the Heap has two
 significant advantages:

 - No B-tree structure has to be read; only the data pages are read.
 - If the Heap is not fragmented and has no forwarded records, Heaps can be 
   read sequentially. Data is read from the storage in the order in which 
   they were entered.
 - An index always follows the pointers to the next data page. 
   If the index is fragmented, random reads occur that are not as powerful as 
   sequential read operations.

 One of the biggest drawbacks when reading data from a Heap is the IAM scan 
 while reading the data. Microsoft SQL Server must hold a lock to ensure that 
 the metadata of the table structure is not changed during the read process.

 In a highly competitive system, such locks are not desirable because they 
 serialize operations. The larger the Heap, the longer the locks will prevent 
 further metadata operations:

 - Create indexes
 - Rebuild indexes
 - Add or delete columns
 - TRUNCATE operations
 - ...
*/

-------------------------------------------------------------------------------
-- Create an XEvent for analysis of the locking
-------------------------------------------------------------------------------
CREATE EVENT SESSION [Track Lockings]
ON SERVER
    ADD EVENT sqlserver.lock_acquired
    (ACTION
     (
         package0.event_sequence
     )
     WHERE (
               sqlserver.session_id = 57
               AND mode = 1
           )
    ),
    ADD EVENT sqlserver.lock_released
    (ACTION
     (
         package0.event_sequence
     )
     WHERE (
               sqlserver.session_id = 57
               AND mode = 1
           )
    ),
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         package0.event_sequence
     )
     WHERE (sqlserver.session_id = 57)
    ),
    ADD EVENT sqlserver.sql_statement_starting
    (ACTION
     (
         package0.event_sequence
     )
     WHERE (sqlserver.session_id = 57)
    )
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = ON,
    STARTUP_STATE = OFF
);
GO
ALTER EVENT SESSION [Track Lockings] ON SERVER STATE = START;
GO


SELECT * 
FROM dbo.CustomerOrderList
GO


-------------------------------------------------------------------------------
-- Optimize SELECT operations
-------------------------------------------------------------------------------

-- Select the very first record
-- NOTE: Although only one data record is to be determined, 
--       a SCH-S lock is set on the table!
SELECT TOP (1) *
FROM dbo.CustomerOrderList
OPTION (QUERYTRACEON 9130);
GO

-- Select the very first record with a predicate
-- which determines a record at the beginning of
-- the Heap
SELECT TOP (1) *
FROM dbo.CustomerOrderList
WHERE Customer_Id = 1
OPTION (QUERYTRACEON 9130, MAXDOP 1);
GO

-- Select the very first record with a predicate
-- which determines a record at any position in
-- the Heap
SELECT TOP (1) *
FROM dbo.CustomerOrderList
WHERE Customer_Id = 22844
OPTION (QUERYTRACEON 9130);
GO


/*
 The bottom line is that a TOP operator can be helpful; in practice, this is 
 rather not the case, since the number of data pages to be read always depends 
 on the logical position of the data record.
*/


/*
 For Heaps and partitioned Heaps, data compression can be a distinct advantage 
 in terms of I/O. However, there are a few special features that need to be 
 considered when compressing data in a Heap. When a Heap is configured to 
 compress at the page level, the compression is done in the following ways:

 - The mapping of new data pages in a Heap as part of DML operations only uses 
   page compression after the Heap has been re-created.
 - Changing the compression setting for a Heap forces all nonclustered indexes 
   to be rebuilt because the position mappings must be rewritten.
 - ROW or PAGE compression can be activated and deactivated online or offline.
 - Enabling compression for a Heap online is done with a single thread.
*/

-------------------------------------------------------------------------------
-- Evaluate the savings by compression of data
-------------------------------------------------------------------------------
DECLARE @Result TABLE
(
    Data_Compression CHAR(4) NOT NULL
        DEFAULT '---',
    object_name sysname NOT NULL,
    schema_name sysname NOT NULL,
    index_id INT NOT NULL,
    partition_number INT NOT NULL,
    current_size_KB BIGINT NOT NULL,
    request_size_KB BIGINT NOT NULL,
    sample_size_KB BIGINT NOT NULL,
    sample_request_KB BIGINT NOT NULL
);

INSERT INTO @Result
(
    object_name,
    schema_name,
    index_id,
    partition_number,
    current_size_KB,
    request_size_KB,
    sample_size_KB,
    sample_request_KB
)
EXEC sp_estimate_data_compression_savings @schema_name = 'dbo',
                                          @object_name = 'CustomerOrderList',
                                          @index_id = 0,
                                          @partition_number = NULL,
                                          @data_compression = 'PAGE';

UPDATE @Result
SET Data_Compression = 'PAGE'
WHERE Data_Compression = '---';

-- Evaluate the savings by compression of data
INSERT INTO @Result
(
    object_name,
    schema_name,
    index_id,
    partition_number,
    current_size_KB,
    request_size_KB,
    sample_size_KB,
    sample_request_KB
)
EXEC sp_estimate_data_compression_savings @schema_name = 'dbo',
                                          @object_name = 'CustomerOrderList',
                                          @index_id = 0,
                                          @partition_number = NULL,
                                          @data_compression = 'ROW';

UPDATE @Result
SET Data_Compression = 'ROW'
WHERE Data_Compression = '---';

SELECT Data_Compression,
       current_size_KB,
       request_size_KB,
       (1.0 - (request_size_KB * 1.0 / current_size_KB * 1.0)) * 100.0 AS percentage_savings
FROM @Result;
GO


-------------------------------------------------------------------------------
-- The next script inserts all records from the [dbo].[CustomerOrderList] table 
-- into a temporary table. Both I/O and CPU times are measured. The test is 
-- performed with uncompressed data, page compression and row compression
-------------------------------------------------------------------------------
ALTER TABLE dbo.CustomerOrderList REBUILD WITH (DATA_COMPRESSION = NONE);
GO

-- IO and CPU without compression
SELECT *
INTO #Dummy
FROM dbo.CustomerOrderList;
GO

DROP TABLE #Dummy;
GO

ALTER TABLE dbo.CustomerOrderList REBUILD WITH (DATA_COMPRESSION = PAGE);
GO

-- IO and CPU without compression
SELECT *
INTO #Dummy
FROM dbo.CustomerOrderList;
GO

DROP TABLE #Dummy;
GO

ALTER TABLE dbo.CustomerOrderList REBUILD WITH (DATA_COMPRESSION = ROW);
GO

-- IO and CPU without compression
SELECT *
INTO #Dummy
FROM dbo.CustomerOrderList;
GO

DROP TABLE #Dummy;
GO


/*
 With the help of partitioning, tables are divided horizontally. 
 Several groups are created that lie within the boundaries of partitions.

 The advantage of partitioning Heaps can only take effect if the Heap is 
 used to search for predicate patterns that match the partition key. 
 Unless you’re looking for the partition key, partitioning can’t really 
 help you find data.
*/

-- Find all orders from 2016
SELECT *
FROM dbo.CustomerOrderList
WHERE OrderDate >= '20160101'
      AND OrderDate <= '20161231'
ORDER BY Customer_Id,
         OrderDate DESC
OPTION (QUERYTRACEON 9130);
GO


/*
 Without an index, there is no way to reduce I/O or CPU load. 
 A reduction can only be achieved by reducing the amount of data to be 
 read. For this reason, the table gets partitioned so that a separate 
 partition is used for each year.
*/

-------------------------------------------------------------------------------
-- We create one filegroup for each year up to 2019 and add one file 
-- for every filegroup!
-------------------------------------------------------------------------------
DECLARE @DataPath NVARCHAR(256) = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(256));
DECLARE @stmt NVARCHAR(1024);
DECLARE @Year INT = 2000;

WHILE @Year <= 2019
BEGIN
    SET @stmt = N'ALTER DATABASE Playground 
                 ADD FileGroup ' + QUOTENAME(N'P_' + CAST(@Year AS NCHAR(4))) + N';';

    RAISERROR('Statement: %s', 0, 1, @stmt);

    EXEC sys.sp_executesql @stmt;

    SET @stmt
        = N'ALTER DATABASE Playground
            ADD FILE
            (
	            NAME = ' + QUOTENAME(N'Playground_Orders_' + CAST(@Year AS NCHAR(4)), '''') + N',
	            FILENAME = ''' + @DataPath + N'Playground_ORDERS_' + CAST(@Year AS NCHAR(4))
                      + N'.ndf'',
	            SIZE = 128MB,
	            FILEGROWTH = 128MB
            )
            TO FILEGROUP ' + QUOTENAME(N'P_' + CAST(@Year AS NCHAR(4))) + N';';
    
    RAISERROR('Statement: %s', 0, 1, @stmt);
    
    EXEC sys.sp_executesql @stmt;
    
    SET @Year += 1;
END;
GO

-------------------------------------------------------------------------------
-- Create a partition function that ensures that the order year is correctly 
-- assigned and saved
-------------------------------------------------------------------------------
CREATE PARTITION FUNCTION pf_OrderDate (DATE)
AS RANGE LEFT FOR VALUES
(   '20001231',
    '20011231',
    '20021231',
    '20031231',
    '20041231',
    '20051231',
    '20061231',
    '20071231',
    '20081231',
    '20091231',
    '20101231',
    '20111231',
    '20121231',
    '20131231',
    '20141231',
    '20151231',
    '20161231',
    '20171231',
    '20181231',
    '20191231'
);
GO

-------------------------------------------------------------------------------
-- Finally, in order to connect the partition function with the filegroups, 
-- you need the partition scheme, which gets generated with the next script.
-------------------------------------------------------------------------------
CREATE PARTITION SCHEME [OrderDates]
AS PARTITION pf_OrderDate
TO
(
    [P_2000],
    [P_2001],
    [P_2002],
    [P_2003],
    [P_2004],
    [P_2005],
    [P_2006],
    [P_2007],
    [P_2008],
    [P_2009],
    [P_2010],
    [P_2011],
    [P_2012],
    [P_2013],
    [P_2014],
    [P_2015],
    [P_2016],
    [P_2017],
    [P_2018],
    [P_2019],
    [PRIMARY]
);
GO

-------------------------------------------------------------------------------
-- When the Partition schema exists, you can now distribute the data from the 
-- table over all the partitions based on the year of the order. 
-- To move a non-partitioned Heap into a partition schema, you need to build a 
-- Clustered Index based on the partition schema and drop it afterwards.
-------------------------------------------------------------------------------
CREATE CLUSTERED INDEX cix_CustomerOrderList_OrderDate
ON dbo.CustomerOrderList (OrderDate)
ON OrderDates(OrderDate);
GO

DROP INDEX cix_CustomerOrderList_OrderDate ON dbo.CustomerOrderList;
GO


-------------------------------------------------------------------------------
-- Let's combine all information to an overview
-------------------------------------------------------------------------------
SELECT p.partition_number AS [Partition #],
       CASE pf.boundary_value_on_right
           WHEN 1 THEN
               'Right / Lower'
           ELSE
               'Left / Upper'
       END AS [Boundary Type],
       prv.value AS [Boundary Point],
       stat.row_count AS [Rows],
       fg.name AS [Filegroup]
FROM sys.partition_functions AS pf
    INNER JOIN sys.partition_schemes AS ps
        ON ps.function_id = pf.function_id
    INNER JOIN sys.indexes AS si
        ON si.data_space_id = ps.data_space_id
    INNER JOIN sys.partitions AS p
        ON (
               si.object_id = p.object_id
               AND si.index_id = p.index_id
           )
    LEFT JOIN sys.partition_range_values AS prv
        ON (
               prv.function_id = pf.function_id
               AND p.partition_number = CASE pf.boundary_value_on_right
                                            WHEN 1 THEN
                                                prv.boundary_id + 1
                                            ELSE
                                                prv.boundary_id
                                        END
           )
    INNER JOIN sys.dm_db_partition_stats AS stat
        ON (
               stat.object_id = p.object_id
               AND stat.index_id = p.index_id
               AND stat.index_id = p.index_id
               AND stat.partition_id = p.partition_id
               AND stat.partition_number = p.partition_number
           )
    INNER JOIN sys.allocation_units AS au
        ON (
               au.container_id = p.hobt_id
               AND au.type_desc = 'IN_ROW_DATA'
           )
    INNER JOIN sys.filegroups AS fg
        ON fg.data_space_id = au.data_space_id
ORDER BY [Partition #];
GO


-------------------------------------------------------------------------------
-- Find all orders from 2016
-------------------------------------------------------------------------------
SELECT *
FROM dbo.CustomerOrderList
WHERE OrderDate >= '20160101'
      AND OrderDate <= '20161231'
ORDER BY Customer_Id,
         OrderDate DESC
OPTION (QUERYTRACEON 9130);
GO

/*
 Microsoft SQL Server uses the boundaries for the partitions to identify the 
 partition in which the values to be found can appear. Other partitions are no 
 longer considered and are, therefore, “excluded” from the table scan.

 The runtime has not changed significantly (the number of data records sent to 
 the client has not changed!), but you can see very well that the CPU load has
 been reduced by approximately 25%.
*/


-------------------------------------------------------------------------------
-- If the whole workload is focused on I/O and not on the CPU load, the last 
-- possibility for reduction is to compress the data at the partition level!
-------------------------------------------------------------------------------
ALTER TABLE dbo.CustomerOrderList
REBUILD PARTITION = 17
WITH
(
    DATA_COMPRESSION = ROW
);
GO

