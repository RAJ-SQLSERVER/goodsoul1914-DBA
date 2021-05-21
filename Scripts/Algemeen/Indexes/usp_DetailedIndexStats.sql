CREATE PROCEDURE [dbo].[usp_DetailedIndexStats] @table_name sysname
AS

---------------------------------------------------------------------------------- 
-- ******VARIABLE DECLARATIONS****** 
---------------------------------------------------------------------------------- 
DECLARE @IndexTable TABLE
(
    [Database] sysname,
    [Table] sysname,
    [Index Name] sysname NULL,
    index_id SMALLINT,
    [object_id] INT,
    [Index Type] VARCHAR(20),
    [Alloc Unit Type] VARCHAR(20),
    [Avg Frag %] DECIMAL(5, 2),
    [Row Ct] BIGINT,
    [Stats Update Dt] DATETIME
);

DECLARE @dbid SMALLINT; --Database id for current database 
DECLARE @objectid INT; --Object id for table being analyzed 
DECLARE @indexid INT; --Index id for the target index for the STATS_DATE() function 

---------------------------------------------------------------------------------- 
-- ******VARIABLE ASSIGNMENTS****** 
---------------------------------------------------------------------------------- 
SELECT @dbid = DB_ID(DB_NAME());
SELECT @objectid = OBJECT_ID(@table_name);

IF @objectid IS NULL
BEGIN
    PRINT 'Table not found';
    RETURN;
END;

---------------------------------------------------------------------------------- 
-- ******Load @IndexTable with Index Metadata****** 
---------------------------------------------------------------------------------- 
INSERT INTO @IndexTable
(
    [Database],
    [Table],
    [Index Name],
    index_id,
    [object_id],
    [Index Type],
    [Alloc Unit Type],
    [Avg Frag %],
    [Row Ct]
)
SELECT DB_NAME() AS "Database",
       @table_name AS "Table",
       SI.name AS "Index Name",
       IPS.index_id,
       IPS.object_id,            --These fields included for joins only 
       IPS.index_type_desc,      --Heap, Non-clustered, or Clustered 
       IPS.alloc_unit_type_desc, --In-row data or BLOB data 
       CAST(IPS.avg_fragmentation_in_percent AS DECIMAL(5, 2)),
       IPS.record_count
FROM sys.dm_db_index_physical_stats(@dbid, @objectid, NULL, NULL, 'sampled') IPS
    LEFT JOIN sys.sysindexes SI
        ON IPS.object_id = SI.id
           AND IPS.index_id = SI.indid
WHERE IPS.index_id <> 0;

---------------------------------------------------------------------------------- 
-- ******ADD STATISTICS INFORMATION****** 
---------------------------------------------------------------------------------- 
DECLARE curIndex_ID CURSOR FOR
SELECT I.index_id
FROM @IndexTable I
ORDER BY I.index_id;

OPEN curIndex_ID;
FETCH NEXT FROM curIndex_ID
INTO @indexid;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE @IndexTable
    SET [Stats Update Dt] = STATS_DATE(@objectid, @indexid)
    WHERE [object_id] = @objectid
          AND [index_id] = @indexid;

    FETCH NEXT FROM curIndex_ID
    INTO @indexid;
END;

CLOSE curIndex_ID;
DEALLOCATE curIndex_ID;

---------------------------------------------------------------------------------- 
-- ******RETURN RESULTS****** 
---------------------------------------------------------------------------------- 
SELECT I.[Database],
       I.[Table],
       I.[Index Name],
       I.[Index Type],
       I.[Avg Frag %],
       I.[Row Ct],
       CONVERT(VARCHAR, I.[Stats Update Dt], 110) AS "Stats Dt"
FROM @IndexTable I
ORDER BY I.[Index Type],
         I.[index_id];


----------------------------------------------------------------------------------
-- ******EXAMPLE******
--
-- EXEC dbo.usp_DetailedIndexStats @table_name = 'Orders'
----------------------------------------------------------------------------------
