/*
 Filegroup Summary
*/
WITH fg_sizes
AS (SELECT fg.data_space_id AS FGID,
           COUNT(f.file_id) AS FileCount,
           ROUND(CAST(SUM(f.size) AS FLOAT) / 128, 2) AS Reserved_MB,
           ROUND(CAST(SUM(FILEPROPERTY(f.name, 'SpaceUsed')) AS FLOAT) / 128, 2) AS Used_MB,
           ROUND((CAST(SUM(f.size) AS FLOAT) / 128) - (CAST(SUM(FILEPROPERTY(f.name, 'SpaceUsed')) AS FLOAT) / 128), 2) AS Free_MB
    FROM sys.filegroups fg
        LEFT JOIN sys.database_files f
            ON f.data_space_id = fg.data_space_id
    GROUP BY fg.data_space_id),
     fg_objs
AS (SELECT ID AS FGID,
           SUM(n) AS TotalObjects
    FROM
    (
        SELECT au.data_space_id AS ID,
               COUNT(*) AS n
        FROM sys.allocation_units au
        WHERE au.[type] = 1
        GROUP BY au.data_space_id
        UNION ALL
        SELECT t.lob_data_space_id AS ID,
               COUNT(*) AS n
        FROM sys.allocation_units au
            JOIN sys.partitions p
                ON au.container_id = p.partition_id
            JOIN sys.objects o
                ON p.object_id = o.object_id
            LEFT JOIN sys.tables t
                ON o.object_id = t.object_id
        WHERE au.[type] = 1
              AND au.data_space_id <> t.lob_data_space_id
        GROUP BY t.lob_data_space_id
    ) q
    GROUP BY ID)
SELECT fg.[data_space_id] AS FilegroupID,
       fg.[name] AS FilegroupName,
       fgs.FileCount,
       ISNULL(fgo.TotalObjects, 0) AS ObjectCount,
       CONVERT(VARCHAR, CONVERT(MONEY, MAX(fgs.Reserved_MB)), 1) AS Reserved_MB,
       CONVERT(VARCHAR, CONVERT(MONEY, MAX(fgs.Used_MB)), 1) AS Used_MB,
       CONVERT(VARCHAR, CONVERT(MONEY, MAX(fgs.Free_MB)), 1) AS Free_MB,
       ROUND(MAX(fgs.Free_MB) / MAX(fgs.Reserved_MB) * 100, 2) AS Percent_Free
FROM sys.filegroups fg
    INNER JOIN fg_sizes fgs
        ON fg.data_space_id = fgs.FGID
    LEFT JOIN fg_objs fgo
        ON fg.data_space_id = fgo.FGID
GROUP BY fg.data_space_id,
         fg.name,
         fgs.FileCount,
         fgo.TotalObjects
ORDER BY Percent_Free DESC;


/*
 What’s In That Filegroup?
*/
DECLARE @FGID INT;
SET @FGID = 1; -- Filegroup ID

SELECT QUOTENAME(s.name) AS SchemaName,
       QUOTENAME(o.name) AS ObjName,
       o.object_id AS ObjID,
       p.index_id AS IndexID,
       QUOTENAME(i.name) AS IndexName,
       ROUND(CAST(au.data_pages AS FLOAT) / 128, 2) AS MB_Used,
       p.data_compression_desc,
       QUOTENAME(f.name) AS DataFilegroup,
       QUOTENAME(f2.name) AS LOBFilegroup
FROM sys.allocation_units au
    INNER JOIN sys.partitions p
        ON au.container_id = p.partition_id
    INNER JOIN sys.objects o
        ON p.object_id = o.object_id
    INNER JOIN sys.indexes i
        ON p.index_id = i.index_id
           AND i.object_id = p.object_id
    INNER JOIN sys.schemas s
        ON o.schema_id = s.schema_id
    LEFT JOIN sys.tables t
        ON o.object_id = t.object_id
    LEFT JOIN sys.filegroups f
        ON au.data_space_id = f.data_space_id
    LEFT JOIN sys.filegroups f2
        ON t.lob_data_space_id = f2.data_space_id
WHERE au.[type] = 1
      AND
      (
          au.data_space_id = @FGID
          OR t.lob_data_space_id = @FGID
      )
ORDER BY SchemaName,
         ObjName,
         p.index_id;

/*
 What Files Make Up That Filegroup?
*/
SELECT a.fileid AS FileID,
       a.groupid AS FileGroupID,
       a.[name] AS LogicalName,
       a.[filename] AS FilePath,
       ROUND(CAST(a.size AS FLOAT) / 128, 2) AS Reserved_MB,
       ROUND(CAST(FILEPROPERTY(a.name, 'SpaceUsed') AS FLOAT) / 128, 2) AS Used_MB,
       ROUND(CAST(a.size AS FLOAT) / 128 - CAST(FILEPROPERTY(a.name, 'SpaceUsed') AS FLOAT) / 128, 2) AS Free_MB
FROM dbo.sysfiles a
WHERE a.groupid = 1
ORDER BY Reserved_MB DESC;