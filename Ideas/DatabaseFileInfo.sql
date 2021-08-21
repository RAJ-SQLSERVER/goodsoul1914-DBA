
SELECT A.type_desc AS "Type",
       A.name AS "FileName",
       fg.name AS "FileGroupName",
       A.physical_name AS "FileLocation",
       CONVERT (DECIMAL(10, 2), A.size / 128.0) AS "FileSizeMB",
       CONVERT (
           DECIMAL(10, 2), A.size / 128.0 - ((size / 128.0) - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0)
       ) AS "UsedSpaceMB",
       CONVERT (DECIMAL(10, 2), A.size / 128.0 - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0) AS "FreeSpaceMB",
       CONVERT (
           DECIMAL(10, 2),
           ((A.size / 128.0 - CAST(FILEPROPERTY (A.name, 'SPACEUSED') AS INT) / 128.0) / (A.size / 128.0)) * 100
       ) AS "FreeSpacePct",
       'By ' + CASE is_percent_growth
                   WHEN 0 THEN CAST(growth / 128 AS VARCHAR(10)) + ' MB -'
                   WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -'
                   ELSE ''
               END + CASE max_size
                         WHEN 0 THEN 'DISABLED'
                         WHEN -1 THEN ' Unrestricted'
                         ELSE ' Restricted to ' + CAST(max_size / (128 * 1024) AS VARCHAR(10)) + ' GB'
                     END + CASE is_percent_growth
                               WHEN 1 THEN ' [autogrowth by percent, BAD setting!]'
                               ELSE ''
                           END AS "Autogrow"
FROM sys.database_files AS A
LEFT JOIN sys.filegroups AS fg
    ON A.data_space_id = fg.data_space_id
ORDER BY A.type DESC,
         A.name;

