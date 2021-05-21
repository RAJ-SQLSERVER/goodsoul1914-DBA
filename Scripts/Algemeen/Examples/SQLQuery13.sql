USE Playground;
GO

-- A simple table with 1 index
CREATE TABLE dbo.FragTest (PKCol INT NOT NULL,
                           InfoCol NCHAR(64) NOT NULL,
                           CONSTRAINT PK_FragTest_PKCol
                               PRIMARY KEY NONCLUSTERED (PKCol));
GO

-- Check the fragmentation
SELECT IX.name AS "Name",
       PS.index_level AS "Level",
       PS.page_count AS "Pages",
       PS.avg_page_space_used_in_percent AS "Page Fullness (%)",
       PS.avg_fragmentation_in_percent AS "External Fragmentation (%)",
       PS.fragment_count AS "Fragments",
       PS.avg_fragment_size_in_pages AS "Avg Fragment Size"
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), DEFAULT, DEFAULT, 'DETAILED') AS PS
  JOIN sys.indexes AS IX
    ON IX.object_id = PS.object_id
   AND IX.index_id  = PS.index_id
 WHERE IX.name = 'PK_FragTest_PKCol';
GO

-- Randomly inserting rows
TRUNCATE TABLE dbo.FragTest;
GO

DECLARE @limit INT;
SET @limit = 50000;
DECLARE @counter INT;
SET @counter = 1;
DECLARE @key INT;
SET NOCOUNT ON;
WHILE @counter <= @limit
BEGIN
    SET @key = CONVERT(INT, RAND() * 1000000);
    BEGIN TRY
        INSERT INTO dbo.FragTest (PKCol, InfoCol)
        VALUES (@key, 'AAAA');
        SET @counter = @counter + 1;
    END TRY
    BEGIN CATCH
    END CATCH;
END;
GO

SELECT IX.name AS "Name",
       PS.index_level AS "Level",
       PS.page_count AS "Pages",
       PS.avg_page_space_used_in_percent AS "Page Fullness (%)",
       PS.avg_fragmentation_in_percent AS "External Fragmentation (%)",
       PS.fragment_count AS "Fragments",
       PS.avg_fragment_size_in_pages AS "Avg Fragment Size"
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), DEFAULT, DEFAULT, 'DETAILED') AS PS
  JOIN sys.indexes AS IX
    ON IX.object_id = PS.object_id
   AND IX.index_id  = PS.index_id
 WHERE IX.name = 'PK_FragTest_PKCol';
GO

/*
 The output tells us that the average leaf level page is slightly less than 75% full. 
 It also tells us that the index is completely fragmented; that is, every page is its own 
 fragment, meaning that no next-page pointer points to the physically following page.
*/

-- Inserting Rows in Ascending Sequence
TRUNCATE TABLE dbo.FragTest;
GO

DECLARE @limit INT;
SET @limit = 50000;
DECLARE @counter INT;
SET @counter = 1;
SET NOCOUNT ON;
WHILE @counter <= @limit
BEGIN
    BEGIN TRY
        INSERT INTO dbo.FragTest (PKCol, InfoCol)
        VALUES (@counter, 'AAAA');
        SET @counter = @counter + 1;
    END TRY
    BEGIN CATCH
    END CATCH;
END;
GO

SELECT IX.name AS "Name",
       PS.index_level AS "Level",
       PS.page_count AS "Pages",
       PS.avg_page_space_used_in_percent AS "Page Fullness (%)",
       PS.avg_fragmentation_in_percent AS "External Fragmentation (%)",
       PS.fragment_count AS "Fragments",
       PS.avg_fragment_size_in_pages AS "Avg Fragment Size"
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), DEFAULT, DEFAULT, 'DETAILED') AS PS
  JOIN sys.indexes AS IX
    ON IX.object_id = PS.object_id
   AND IX.index_id  = PS.index_id
 WHERE IX.name = 'PK_FragTest_PKCol';
GO

/*
 This time results are indicating that the pages are densely packed, and that external 
 fragmentation is near zero.  Because external fragmentation is near zero, SQL Server can 
 scan the index by reading one extent, or more, per IO; IO that can be done as read-ahead 
 reads.
*/

-- Inserting Rows in Descending Sequence
TRUNCATE TABLE dbo.FragTest;
GO

DECLARE @limit INT;
SET @limit = 50000;
DECLARE @counter INT;
SET @counter = 1;
SET NOCOUNT ON;
WHILE @counter <= @limit
BEGIN
    BEGIN TRY
        INSERT INTO dbo.FragTest (PKCol, InfoCol)
        VALUES (@limit - @counter, 'AAAA');
        SET @counter = @counter + 1;
    END TRY
    BEGIN CATCH
    END CATCH;
END;
GO

SELECT IX.name AS "Name",
       PS.index_level AS "Level",
       PS.page_count AS "Pages",
       PS.avg_page_space_used_in_percent AS "Page Fullness (%)",
       PS.avg_fragmentation_in_percent AS "External Fragmentation (%)",
       PS.fragment_count AS "Fragments",
       PS.avg_fragment_size_in_pages AS "Avg Fragment Size"
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.FragTest'), DEFAULT, DEFAULT, 'DETAILED') AS PS
  JOIN sys.indexes AS IX
    ON IX.object_id = PS.object_id
   AND IX.index_id  = PS.index_id
 WHERE IX.name = 'PK_FragTest_PKCol';
GO

/*
 Pages are full, but the file is totally fragmented. This latter fact is slightly 
 misleading, for the pages of the index are contiguous; but the first page in index key 
 sequence is the physically last page in the file.  Each next-page pointer points to the 
 physically previous page, thus giving the file its high external fragmentation rating.
*/
