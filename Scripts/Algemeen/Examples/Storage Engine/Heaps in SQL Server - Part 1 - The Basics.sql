USE Playground;
GO

-------------------------------------------------------------------------------
-- Create heap and insert some rows
-------------------------------------------------------------------------------
CREATE TABLE dbo.Customers
(
    Id INT NOT NULL,
    Name VARCHAR(200) NOT NULL,
    Street VARCHAR(200) NOT NULL,
    Code CHAR(3) NOT NULL,
    ZIP VARCHAR(5) NOT NULL,
    City VARCHAR(200) NOT NULL,
    State VARCHAR(200) NOT NULL
);
GO
INSERT INTO dbo.Customers
(
    Id,
    Name,
    Street,
    Code,
    ZIP,
    City,
    State
)
VALUES
(1, 'John Smith', 'Times Square', '123', '10001', 'New York', 'New York');
GO


-------------------------------------------------------------------------------
-- A Heap has always the index_id = 0
-------------------------------------------------------------------------------
SELECT object_id,
       name,
       index_id,
       type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.Customers', N'U');
GO

-------------------------------------------------------------------------------
-- Index Allocation Map
-------------------------------------------------------------------------------
SELECT SIAU.type_desc,
       SIAU.total_pages,
       SIAU.used_pages,
       SIAU.data_pages,
       SIAU.first_iam_page,
       sys.fn_PhysLocFormatter(SIAU.first_iam_page) AS iam_page
FROM sys.system_internals_allocation_units AS SIAU
    INNER JOIN sys.partitions AS P
        ON SIAU.container_id = CASE
                                   WHEN SIAU.type IN ( 1, 3 ) THEN
                                       P.hobt_id
                                   ELSE
                                       P.partition_id
                               END
WHERE P.object_id = OBJECT_ID(N'dbo.Customers', N'U');
GO


-------------------------------------------------------------------------------
-- Show the content of the IAM page
-------------------------------------------------------------------------------
DBCC TRACEON(3604); -- Route the output of DBCC PAGE to the client
DBCC PAGE(0, 1, 70531, 3); -- Show the contents of a data page (IAM)
DBCC PAGE(0, 1, 198760, 3) -- Show the contents of the data page with our row
GO


-------------------------------------------------------------------------------
-- The next example shows how the fill level changes when the state (bytes) is 
-- exceeded. To do this, a Heap is created that stores 2,004 bytes per data 
-- record.
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.demo_table;
GO
CREATE TABLE dbo.demo_table
(
    C1 INT NOT NULL IDENTITY(1, 1),
    C2 CHAR(2000) NOT NULL
        DEFAULT ('Test')
);
GO
INSERT INTO dbo.demo_table
DEFAULT VALUES;
GO


-------------------------------------------------------------------------------
-- What pages have been allocated? (current fill level of data pages of a heap)
-------------------------------------------------------------------------------
SELECT allocated_page_page_id,
       previous_page_page_id,
       next_page_page_id,
       page_type_desc,
       page_free_space_percent
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID(N'dbo.demo_table', N'U'), 0, NULL, N'DETAILED');
GO


-------------------------------------------------------------------------------
-- Insert 2 more rows into the demo table
-------------------------------------------------------------------------------
INSERT INTO dbo.demo_table
DEFAULT VALUES;
GO 2

/* Check fill level */

/*
 Advantages of Heaps:
 
 Using a heap can be more efficient than a table with a clustered index. 
 In general, there are some use cases for Heaps like loading staging tables 
 or storing protocol data into a Heap, since there is no need to pay attention 
 to sorting when saving data. Data records are saved on the next possible data 
 page on which there is sufficient space. Furthermore, the INSERT process does 
 not require moving down the B-Tree of an index structure to the data page to 
 save the record!
 
 Disadvantages of Heaps:
 
 - A Heap cannot scale if the database design is unsuitable because of 
 PFS contention (will be handled in the next articles in detail!)
 
 - You cannot efficiently search for data in a Heap.
 
 - The time to search for data in a Heap increases linearly with the volume of 
 data.
 
 - A Heap is unsuitable for frequent data updates because of the risk of 
 forwarded records (will be handled in the next articles in detail)
 
 - A Heap is horrible for every database administrator when it comes to 
 maintenance because a Heap requires an update of nonclustered indexes when 
 the Heap is rebuilt.
 
 Some of the “disadvantages” mentioned above can be eliminated or bypassed 
 if you know how a heap “ticks” internally. I hope I can convince one or the 
 other that a clustered index is not always the better choice.
*/
