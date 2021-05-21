---------------------------------------------------
-- How to Defragment All The Indexes In a Database
---------------------------------------------------
DECLARE @NoOfPartitions BIGINT;
DECLARE @objectid INT;
DECLARE @indexid INT;
DECLARE @idxname NVARCHAR(255);
DECLARE @objname NVARCHAR(255);
DECLARE @partitionnum BIGINT;
DECLARE @schemaname NVARCHAR(255);
DECLARE @partitions BIGINT;
DECLARE @frag FLOAT;
DECLARE @statement VARCHAR(8000);
-- checking existance of the table that we create for temporary purpose

IF OBJECT_ID('defrag_work', 'U') IS NOT NULL
    DROP TABLE defrag_work;


-- Copy the fragmented indexes data into defrag_work table
-- All the indexes that has fragmentation < 5 are getting stored into our work table
SELECT [object_id] AS objectid,
       index_id AS indexid,
       partition_number AS partition_no,
       avg_fragmentation_in_percent AS frag
INTO defrag_work
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 5.0
      AND index_id > 0;


-- cursor to process the list of partitions
DECLARE partitions CURSOR FOR SELECT * FROM defrag_work;

-- Open the cursor.
OPEN partitions;

-- Looping through the partitions
FETCH NEXT FROM partitions
INTO @objectid,
     @indexid,
     @partitionnum,
     @frag;

WHILE @@FETCH_STATUS = 0
BEGIN;
    SELECT @objname = QUOTENAME(so.name),
           @schemaname = QUOTENAME(ss.name)
    FROM sys.objects AS so
        JOIN sys.schemas AS ss
            ON ss.schema_id = so.schema_id
    WHERE so.object_id = @objectid;


    SELECT @idxname = QUOTENAME(name)
    FROM sys.indexes
    WHERE object_id = @objectid
          AND index_id = @indexid;


    SELECT @NoOfPartitions = COUNT(*)
    FROM sys.partitions
    WHERE object_id = @objectid
          AND index_id = @indexid;

    /* 
		Let’s say N = fragmentation percentage

		N <= 5 = IGNORE
		5 < N < 30 = REORGANIZE
		N > 30 = REBUILD
	*/

    IF (@frag < 30.0) -- @frag > 5 is already filtered in our first query, so we need that condition here
    BEGIN;
        SELECT @statement = 'ALTER INDEX ' + @idxname + ' ON ' + @schemaname + '.' + @objname + ' REORGANIZE';
        IF @NoOfPartitions > 1
            SELECT @statement = @statement + ' PARTITION=' + CONVERT(CHAR, @partitionnum);
        EXEC (@statement);
    END;

    IF @frag >= 30.0
    BEGIN;
        SELECT @statement = 'ALTER INDEX ' + @idxname + ' ON ' + @schemaname + '.' + @objname + ' REBUILD';
        IF @NoOfPartitions > 1
            SELECT @statement = @statement + ' PARTITION=' + CONVERT(CHAR, @partitionnum);
        EXEC (@statement);
    END;
    PRINT 'Executed ' + @statement;

    FETCH NEXT FROM partitions
    INTO @objectid,
         @indexid,
         @partitionnum,
         @frag;
END;
-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- drop the table
IF OBJECT_ID('defrag_work', 'U') IS NOT NULL
    DROP TABLE defrag_work;