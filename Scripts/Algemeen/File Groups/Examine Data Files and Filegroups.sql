SELECT FILE_Name = A.name,
	FILEGROUP_NAME = fg.name,
	FILESIZE_MB = CONVERT(DECIMAL(10, 2), A.size / 128.0),
	USEDSPACE_MB = CONVERT(DECIMAL(10, 2), A.size / 128.0 - ((size / 128.0) - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT) / 128.0)),
	FREESPACE_MB = CONVERT(DECIMAL(10, 2), A.size / 128.0 - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT) / 128.0),
	[FREESPACE_%] = CONVERT(DECIMAL(10, 2), ((A.size / 128.0 - CAST(FILEPROPERTY(A.name, 'SPACEUSED') AS INT) / 128.0) / (A.size / 128.0)) * 100)
FROM sys.database_files AS A
LEFT JOIN sys.filegroups AS fg ON A.data_space_id = fg.data_space_id
WHERE A.type_desc <> 'LOG'
ORDER BY A.type DESC,
	A.name;
