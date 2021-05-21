-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------
CREATE Table dbo.Cars (Id INT, BrandName VARCHAR(100))
GO
INSERT INTO dbo.Cars VALUES(1,'Ford')
INSERT INTO dbo.Cars VALUES(2,'Fiat')
INSERT INTO dbo.Cars VALUES(3,'Mini')
INSERT INTO dbo.Cars VALUES(4,'Jaguar')
INSERT INTO dbo.Cars VALUES(5,'Kia')
INSERT INTO dbo.Cars VALUES(6,'Nissan')
INSERT INTO dbo.Cars VALUES(7,'BMW')
INSERT INTO dbo.Cars VALUES(8,'Mercedes')
INSERT INTO dbo.Cars VALUES(9,'Mazda')
INSERT INTO dbo.Cars VALUES(10,'Volvo')
INSERT INTO dbo.Cars VALUES(11,'Lexus')
INSERT INTO dbo.Cars VALUES(12,'Buick')
INSERT INTO dbo.Cars VALUES(13,'GMC')
INSERT INTO dbo.Cars VALUES(14,'Honda')
INSERT INTO dbo.Cars VALUES(15,'Lotus')
INSERT INTO dbo.Cars VALUES(16,'Opel')
INSERT INTO dbo.Cars VALUES(17,'Bentley')
INSERT INTO dbo.Cars VALUES(18,'Dodge')
INSERT INTO dbo.Cars VALUES(19,'Tesla')
INSERT INTO dbo.Cars VALUES(20,'Porche')
INSERT INTO dbo.Cars VALUES(21,'Ferrari')
INSERT INTO dbo.Cars VALUES(22,'Audi')
GO

CREATE UNIQUE CLUSTERED INDEX IX_001
ON dbo.Cars (Id);
GO


-------------------------------------------------------------------------------
-- SQL Server Clustered Index and Singleton Seek
-------------------------------------------------------------------------------

/*
 SQL Server performs a clustered index seek process when it accesses data to 
 using the B-tree structure. 
*/

/*
 When we execute the following query, it will perform a clustered index seek 
 operation. The clustered index seek operation uses the structure of the B-tree 
 structure very efficiently and easily finds the qualified row(s).
*/

SELECT *
FROM   dbo.Cars
WHERE  Id = 12;

/*
 In this execution plan, the seek predicates indicate that the storage engine 
 uses the B-tree structure and finds the leaf level that stores the data rows. 
 For this query, the uniqueness of the clustered index is very important 
 because this constraint guarantees that only one row will return from the 
 query. This data searching concept is called singleton seek.

 Secret:
 Defining a clustered index as unique can gain performance improvements when 
 the indexed column(s) is used after the WHERE clause
*/


-------------------------------------------------------------------------------
-- SQL Server Clustered Index and Range Scan
-------------------------------------------------------------------------------

/*
 When we explain the structure of the clustered index, we mentioned an 
 interconnection between the index pages and its backward and forward pages. 
 This connection is very useful for queries that have upper or lower boundaries 
 or have both of them. For example, the following query will perform singleton 
 seek firstly and reaches the leaf level that contains the data row (Id=12). 
 According to retrieve the index keys, the range scans operation has been 
 performed either in forward or backward directions.
*/

SELECT *
FROM   dbo.Cars
WHERE  Id > 12;

/*
 Most of the time, we can hear that the SQL Server clustered index seek 
 operator is super faster than the other data searching operations. However, 
 this myth may not be exactly true for some queries that perform a range scan. 
 For example, we create a table and insert some synthetic data.
*/

DROP TABLE IF EXISTS dbo.TestPerformance
CREATE TABLE dbo.TestPerformance
(
    ID INT IDENTITY(1, 1),
    TextList VARCHAR(100)
);
GO

INSERT INTO dbo.TestPerformance
VALUES
('Any Text');
GO 15000

SELECT *
FROM   dbo.TestPerformance
WHERE  ID > 2;

/*
 It has read 49 pages and has performed a table scan.
*/

CREATE UNIQUE CLUSTERED INDEX IX_001
ON dbo.TestPerformance (Id);

SELECT *
FROM   dbo.TestPerformance
WHERE  ID > 2;

/*
 For this query, the clustered index seek operator does not change the 
 performance of the query and both of them have read the same amount of the 
 data. The problem of this query is it reads whole leaf pages of the index so 
 it doesn’t make any difference in performance between the table scan and index
 seek search. On the other hand, if we repeat the same test for the following 
 query, we will not obtain the same result.
*/

SELECT *
FROM   dbo.TestPerformance
WHERE  ID > 3000;

/*
 Besides that, the singleton seeks principle can also work multiple times for 
 some queries as we can see in the below query.
*/

SELECT *
FROM   dbo.Cars
WHERE  Id = 6
       OR Id = 20;

/*
 The following query is another example of the multiple singleton seeks:
*/

SELECT *
FROM   Cars
WHERE  Id IN ( 1, 4, 8, 12, 22 );


-------------------------------------------------------------------------------
-- SQL Server Clustered Index and Primary Key
-------------------------------------------------------------------------------

/*
 The primary key ensures that the values of a column in the table are unique so 
 that all rows are identified with a unique key. By default when we create a 
 primary key SQL Server creates a unique clustered index. However, we can 
 create a primary key without a clustered index because the only mandatory 
 requirement is uniqueness for the primary key. So the main differences between 
 the primary key and clustered index are:

 A primary key is a logical structure and it provides the uniqueness for a table
 A clustered index is a physical structure and it provides the physical order of 
 the records on the storage
 Perhaps, this question is the right one to ask:

 “Why we use the primary key and clustered indexes on the same key column?”

 SQL Server adds a 4-byte uniquefier value for every duplicate index key on the 
 non-unique clustered indexes.
*/

/*
 At first, we will create a very basic table, it will include only two-column 
 and then we create a non-unique clustered index for this table.
*/

CREATE TABLE dbo.TestDublicate
(
    IdNumber INT,
    Col1 VARCHAR(100)
);
GO

CREATE CLUSTERED INDEX IX_001 ON dbo.TestDublicate (IdNumber);

/*
 Now, we will insert a row to this table and querying the size of max and minimum 
 record size of the index pages with help of the sys.dm_db_index_physical_stats 
 view.
*/

INSERT INTO dbo.TestDublicate
(
    IdNumber,
    Col1
)
VALUES
(1, 'Text-1');

SELECT min_record_size_in_bytes,
       max_record_size_in_bytes
FROM   sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('TestDublicate'), NULL, NULL, N'SAMPLED');

/*
	min_record_size_in_bytes	max_record_size_in_bytes
	23							23
*/

/*
 We will add a duplicate row and re-examine the max record size column.
*/

INSERT INTO dbo.TestDublicate
(
    IdNumber,
    Col1
)
VALUES
(1, 'Text-2');

SELECT min_record_size_in_bytes,
       max_record_size_in_bytes
FROM   sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('TestDublicate'), NULL, NULL, N'SAMPLED');

/*
	min_record_size_in_bytes	max_record_size_in_bytes
	23							27
*/

/*
 Now let’s look at the metadata of the index page. At first, we will determine 
 the page id of the clustered index page.
*/

SELECT          DB_NAME(PageDetail.database_id) AS DatabaseName,
                OBJECT_NAME(PageDetail.object_id) AS TableName,
                ind.name AS IndexName,
                PageDetail.allocated_page_page_id
FROM            sys.dm_db_database_page_allocations(DB_ID('Playground'), OBJECT_ID('TestDublicate'), 1, NULL, 'DETAILED') AS PageDetail
LEFT OUTER JOIN sys.indexes AS ind ON ind.object_id = PageDetail.object_id
                                      AND ind.index_id = PageDetail.index_id
WHERE           PageDetail.is_allocated = 1
                AND PageDetail.page_type IN ( 1, 2 )
ORDER BY        PageDetail.page_level DESC,
                PageDetail.is_allocated DESC,
                PageDetail.previous_page_page_id;

/*
	DatabaseName	TableName		IndexName	allocated_page_page_id
	---------------|---------------|-----------|-----------------------
	Playground		TestDublicate	IX_001		190864
*/


/*
 DBCC PAGE command shows the contents of the data and index page. 
 We will use this command to find out detailed information about the index page.
*/

DBCC TRACEON(3604);
DBCC PAGE('Playground', 1, 190864, 3) WITH TABLERESULTS;

/*
 As we can see the first index page uniquifier field value is 0 which means 
 there isn’t a uniquifier defined for this index page. However, the second index 
 page includes an uniquifier field value is 1 which means SQL Server adds an 
 additional KeyHashValue.
*/
