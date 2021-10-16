SELECT smf.name AS "LogicalName",
       smf.file_id AS "FileID",
       smf.physical_name AS "FileName",
       CAST(CAST(sf.name AS VARBINARY(256)) AS sysname) AS "FileGroupName",
       CONVERT (VARCHAR(10), smf.size * 8) + ' KB' AS "Size",
       CASE
           WHEN smf.max_size = -1 THEN 'Unlimited'
           ELSE CONVERT (VARCHAR(10), CONVERT (BIGINT, smf.max_size) * 8) + ' KB'
       END AS "MaxSize",
       CASE smf.is_percent_growth
           WHEN 1 THEN CONVERT (VARCHAR(10), smf.growth) + '%'
           ELSE CONVERT (VARCHAR(10), smf.growth * 8) + ' KB'
       END AS "Growth",
       CASE
           WHEN smf.type = 0 THEN 'Data Only'
           WHEN smf.type = 1 THEN 'Log Only'
           WHEN smf.type = 2 THEN 'FILESTREAM Only'
           WHEN smf.type = 3 THEN 'Informational purposes Only'
           WHEN smf.type = 4 THEN 'Full-text '
       END AS "USAGE",
       DB_NAME (smf.database_id) AS "DatabaseName"
FROM sys.master_files AS smf
LEFT JOIN sys.filegroups AS sf
    ON (smf.type = 2 OR smf.type = 0)
       AND smf.drop_lsn IS NULL
       AND smf.data_space_id = sf.data_space_id;
