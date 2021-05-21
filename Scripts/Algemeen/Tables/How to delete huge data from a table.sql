-------------------------------------------------------------------------------
-- How to Delete huge data from a SQL Server Table
-------------------------------------------------------------------------------

-- Get data file and log file for a database in MB
SELECT file_id,
       name,
       type_desc,
       physical_name,
       (size * 8) / 1024 AS SizeinMB,
       max_size
FROM   sys.database_files;

-- Delete records in small chunks from a table
DECLARE @DeleteRowCnt INT = 1;
DECLARE @DeleteBatchSize INT = 100000;

WHILE (@DeleteRowCnt > 0)
BEGIN
    DELETE TOP (@DeleteBatchSize) 
	FROM dbo.Customer
    WHERE RegionCD = 'NA';

    SET @DeleteRowCnt = @@ROWCOUNT;
END;
