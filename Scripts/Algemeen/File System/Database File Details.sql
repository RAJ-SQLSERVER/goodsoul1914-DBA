/************************************************************************************************************************
 Author: S.L.S.N. Sandeep Kumar 
 Purpose: Analyze individual database size details
 Compatible & Tested SQL Versions: 2005, 2008, 2008 R2, 2012, 2014, 2016 & 2017
 v
 Usage: 
 1. Open SQL Server Management Studio (SSMS) and connect to SQL Server.
 2. Select the specified database and create a New Query, copy the complete code and, paste it and run (Complete code).
 
 Description: This script performs a detailed analysis of All DB individual files size and filegroups.
************************************************************************************************************************/
SELECT [Database Name] = DB_NAME(),
	[Logical Filename] = name,
	[Physical File Location] = SUBSTRING(filename, 1, LEN(filename) - CHARINDEX('\', REVERSE(filename), 1)),
	[Physical File Name] = SUBSTRING(filename, LEN(filename) - (CHARINDEX(' \ ', REVERSE(filename), 1) - 2), LEN(filename)),
	[Total Size] = CASE 
		WHEN size * 8 < 1024
			THEN CAST(size * 8 AS VARCHAR(10)) + ' KB '
		WHEN size * 8 < 1048576
			THEN CAST(CAST((size * 8) / 1024.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' MB '
		WHEN size * 8 < 1073741824
			THEN CAST(CAST((size * 8) / 1048576.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' GB '
		ELSE CAST(CAST((size * 8) / 1073741824.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' TB '
		END,
	[Used Space] = CASE 
		WHEN FILEPROPERTY(name, ' spaceused ') * 8 < 1024
			THEN CAST(FILEPROPERTY(name, ' spaceused ') * 8 AS VARCHAR(10)) + ' KB '
		WHEN FILEPROPERTY(name, ' spaceused ') * 8 < 1048576
			THEN CAST(CAST((FILEPROPERTY(name, ' spaceused ') * 8) / 1024.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' MB '
		WHEN FILEPROPERTY(name, ' spaceused ') * 8 < 1073741824
			THEN CAST(CAST((FILEPROPERTY(name, ' spaceused ') * 8) / 1048576.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' GB '
		ELSE CAST(CAST((FILEPROPERTY(name, ' spaceused ') * 8) / 1073741824 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' TB '
		END,
	[Free Space] = CASE 
		WHEN (size - FILEPROPERTY(name, ' spaceused ')) * 8 < 1024
			THEN CAST((size - FILEPROPERTY(name, ' spaceused ')) * 8 AS VARCHAR(10)) + ' KB '
		WHEN (size - FILEPROPERTY(name, ' spaceused ')) * 8 < 1048576
			THEN CAST(CAST(((size - FILEPROPERTY(name, ' spaceused ')) * 8) / 1024.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' MB '
		WHEN (size - FILEPROPERTY(name, ' spaceused ')) * 8 < 1073741824
			THEN CAST(CAST(((size - FILEPROPERTY(name, ' spaceused ')) * 8) / 1048576.0 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' GB '
		ELSE CAST(CAST(((size - FILEPROPERTY(name, ' spaceused ')) * 8) / 1073741824 AS NUMERIC(10, 3)) AS VARCHAR(20)) + ' TB '
		END,
	[Free_Space(%)] = CAST(CAST(((size - FILEPROPERTY(name, ' spaceused ')) * 1.00 / size) * 100 AS NUMERIC(30, 3)) AS VARCHAR(50)) + ' % ',
	File_Growth = CASE 
		WHEN growth LIKE ' __ '
			THEN CAST(growth AS VARCHAR(100)) + ' % '
		WHEN growth = 0
			THEN ' * * * Disabled * * * '
		ELSE CAST(growth * 8 / 1024 AS VARCHAR(200)) + ' MB '
		END,
	[File Type] = CASE 
		WHEN STATUS & 0x40 <> 0
			THEN ' Log FILE '
		WHEN STATUS & 0x2 <> 0
			THEN ' Data FILE '
		ELSE CAST(STATUS AS VARCHAR(2000))
		END,
	[File Group]
FROM sysfiles
LEFT JOIN (
	SELECT data_space_id,
		[File Group] = CASE 
			WHEN is_default = 1
				THEN name + ' (DEFAULT) '
			ELSE name
			END
	FROM sys.filegroups
	) AS FileGroup ON sysfiles.groupid = FileGroup.data_space_id;
