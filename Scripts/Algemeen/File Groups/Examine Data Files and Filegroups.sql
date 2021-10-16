SELECT A.name AS "FILE_Name",
       fg.name AS "FILEGROUP_NAME",
       CONVERT (DECIMAL(10, 2), A.size / 128.0) AS "FILESIZE_MB",
       CONVERT (
           DECIMAL(10, 2), A.size / 128.0 - ((size / 128.0) - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0)
       ) AS "USEDSPACE_MB",
       CONVERT (DECIMAL(10, 2), A.size / 128.0 - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0) AS "FREESPACE_MB",
       CONVERT (
           DECIMAL(10, 2),
           ((A.size / 128.0 - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0) / (A.size / 128.0)) * 100
       ) AS "FREESPACE_%"
FROM sys.database_files AS A
LEFT JOIN sys.filegroups AS fg
    ON A.data_space_id = fg.data_space_id
WHERE A.type_desc <> 'LOG'
ORDER BY A.type DESC,
         A.name;
