/*
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


/*
 A nonclustered index is an index structure that is separate from the 
 data in the table. In this way, data can be found faster than with a 
 search of the underlying table. In general, nonclustered indexes are 
 created to improve the performance of frequently used queries that are 
 not covered by the clustered index or heap.

 Since a heap does not sort data according to a key attribute, a 
 nonclustered index can only form a reference by using the position of 
 the data record in the heap. The position of a data record in a heap is
 determined by three pieces of information:

 - File number
 - Data page
 - Slot
 
 These three pieces of information are stored as a reference in each 
 Nonclustered index for the actual key of the index.
*/

SELECT *
FROM dbo.CustomerOrderList
WHERE OrderDate = '20081220'
OPTION (QUERYTRACEON 9130);
GO


/*
 Unfortunately, the following things are often disregarded, which are 
 relevant regardless of the time:

 - The query parallelizes and consumes the CPUs configured for MAXDOP!
 - A [SCH-S] lock is kept on the table during the runtime!
 - What happens if not only one user runs the query, but there is also 
   a web client running thousands of queries in parallel?
*/

CREATE NONCLUSTERED INDEX nix_CustomerOrderList_OrderDate
ON dbo.CustomerOrderList (OrderDate);
GO

/* Rerun the same query */
SELECT *
FROM dbo.CustomerOrderList
WHERE OrderDate = '20081220'
OPTION (QUERYTRACEON 9130);
GO


/*
 Some of the disadvantages of a table scan have been eliminated by
 using an index:

 - The query no longer parallelizes because the costs have dropped 
   below the threshold for parallelization
 - The CPU resources can no longer be measured
 - Only the [SCH-S] lock is still used; however, concerning the 
   runtime – maybe – it can be ignored.

 One can say that nonclustered indexes for heaps can be of great 
 advantage!

 Internal structures
 -------------------
 A Nonclustered Index (NCI) must ALWAYS store a reference to the record 
 in the table. Since an NCI generally only contains a few attributes of 
 the table, it must be ensured that attributes that are not used in the 
 NCI can be determined from the table at any time. This reference is 
 stored in a heap as RID (RowLocatorID) and has a size of 8 bytes!

 Based on the demonstration above, the query took a total of 211 I/O’s 
 to retrieve the data. If you look at the execution plan, you can see the 
 use of the previously created index. Each index uses a tree structure 
 with a reference to the next level. This means that data in an index can 
 be searched quickly and efficiently.
*/

-------------------------------------------------------------------------------
-- Get the information about the root node of the index
-------------------------------------------------------------------------------
SELECT P.index_id,
       SIAU.total_pages,
       SIAU.used_pages,
       SIAU.data_pages,
       SIAU.root_page,
       sys.fn_PhysLocFormatter(SIAU.root_page) AS root_page
FROM sys.system_internals_allocation_units AS SIAU
    INNER JOIN sys.partitions AS P
        ON (SIAU.container_id = P.partition_id)
WHERE P.object_id = OBJECT_ID(N'dbo.CustomerOrderList', N'U');
GO


/*
 The root node of the index [nix_CustomerOrderList_OrderDate] is in file #1 on 
 data page 327922. The content of the data page can be examined with the 
 undocumented command DBCC PAGE.
*/
DBCC TRACEON (3604);
DBCC PAGE (0, 1, 327922, 3);
GO


/*
 Since the index only stores the [OrderDate] attribute, the information of 
 the other attributes for the data record is missing. To get this information, 
 Microsoft SQL Server has to decode the RID to get to the data page where the 
 record is located.

 The RID is stored in the index for EVERY record and has a fixed length of 
 8 bytes. These 8 bytes contain all the relevant information to get to the 
 data record.
 

 For example:
 ------------
 FileId	PageId	Row	Level	ChildFileId	ChildPageId	OrderDate (key)	HEAP RID (key)	   	 Row Size
 1	    327922	1	2	    1	        327921	    2002-05-12	    0xEE5C030001000B00	 18

 Position           Hex-Value       shifted         Decimal-Value
 -----------------------------------------------------------------
 Byte 1-4: Page     0xEE5C0300      0x00 03 5C EE   220398
 Byte 5-6: File     0x0100          0x00 01         1
 Byte 7-8: Slot     0x0B00          0x00 0B         11
*/

DBCC PAGE(0, 1, 220398, 3) WITH TABLERESULTS;
GO


/*
 RID lookup vs. Key lookup
 -------------------------
 Contrary to a heap, Microsoft SQL Server cannot refer directly to the data 
 page in which the record is located in the table with a clustered index. 
 With a Clustered Index Microsoft SQL Server does not save the position of the 
 data record in an NCI for a table with a grouped index, but the value of the 
 key attribute of the clustered index.

 The advantage of using a clustered index is the maintenance of indexes 
 rather than the performance of queries!

 With a RID lookup, the RowLocatorID must be converted, which leads to a – 
 supposedly – higher CPU load. One of the biggest problems in Microsoft SQL 
 Server execution plans is estimating the cost of a SCALAR operation. 
 By default, they are calculated at 0%; however, it will forget that the 
 operator for EVERY record must be run from the previous operator.
*/

