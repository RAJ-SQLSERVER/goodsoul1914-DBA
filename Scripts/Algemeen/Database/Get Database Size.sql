/********************************************************************************
	Created By:		Ajay Dwivedi
	Purpose:		Get Space Utilization of All DB Files along with Free space on Drives.
					This considers even non-accessible DBs
********************************************************************************/
DECLARE @output TABLE (line VARCHAR(2000));
DECLARE @_powershellCMD VARCHAR(400);
DECLARE @mountPointVolumes TABLE (
	Volume VARCHAR(200),
	Label VARCHAR(100) NULL,
	[capacity(MB)] DECIMAL(20, 2),
	[freespace(MB)] DECIMAL(20, 2),
	VolumeName VARCHAR(50),
	[capacity(GB)] DECIMAL(20, 2),
	[freespace(GB)] DECIMAL(20, 2),
	[freespace(%)] DECIMAL(20, 2)
	);

--	Begin: Get Data & Log Mount Point Volumes
SET @_powershellCMD = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@@servername, '''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,Label,capacity,freespace | foreach{$_.name+''|''+$_.Label+''|''+$_.capacity/1048576+''|''+$_.freespace/1048576}"';

--inserting disk name, Label, total space and free space value in to temporary table
INSERT INTO @output
EXEC xp_cmdshell @_powershellCMD;

WITH t_RawData
AS (
	SELECT ID = 1,
		line,
		expression = LEFT(line, CHARINDEX('|', line) - 1),
		searchExpression = SUBSTRING(line, CHARINDEX('|', line) + 1, LEN(line) + 1),
		delimitorPosition = CHARINDEX('|', SUBSTRING(line, CHARINDEX('|', line) + 1, LEN(line) + 1))
	FROM @output
	WHERE line LIKE '[A-Z][:]%'
	--line like 'C:\%'
	-- 
	
	UNION ALL
	
	--
	SELECT ID = ID + 1,
		line,
		expression = CASE 
			WHEN delimitorPosition = 0
				THEN searchExpression
			ELSE LEFT(searchExpression, delimitorPosition - 1)
			END,
		searchExpression = CASE 
			WHEN delimitorPosition = 0
				THEN NULL
			ELSE SUBSTRING(searchExpression, delimitorPosition + 1, LEN(searchExpression) + 1)
			END,
		delimitorPosition = CASE 
			WHEN delimitorPosition = 0
				THEN - 1
			ELSE CHARINDEX('|', SUBSTRING(searchExpression, delimitorPosition + 1, LEN(searchExpression) + 1))
			END
	FROM t_RawData
	WHERE delimitorPosition >= 0
	),
T_Volumes
AS (
	SELECT line,
		Volume,
		Label,
		[capacity(MB)],
		[freespace(MB)]
	FROM (
		SELECT line,
			[Column] = CASE ID
				WHEN 1
					THEN 'Volume'
				WHEN 2
					THEN 'Label'
				WHEN 3
					THEN 'capacity(MB)'
				WHEN 4
					THEN 'freespace(MB)'
				ELSE NULL
				END,
			[Value] = expression
		FROM t_RawData
		) AS up
	pivot(MAX([Value]) FOR [Column] IN (Volume, Label, [capacity(MB)], [freespace(MB)])) AS pvt
		--ORDER BY LINE
	)
INSERT INTO @mountPointVolumes (
	Volume,
	Label,
	[capacity(MB)],
	[freespace(MB)],
	VolumeName,
	[capacity(GB)],
	[freespace(GB)],
	[freespace(%)]
	)
SELECT Volume,
	Label,
	[capacity(MB)] = CAST([capacity(MB)] AS NUMERIC(20, 2)),
	[freespace(MB)] = CAST([freespace(MB)] AS NUMERIC(20, 2)),
	Label AS VolumeName,
	CAST(CAST([capacity(MB)] AS NUMERIC(20, 2)) / 1024.0 AS DECIMAL(20, 2)) AS [capacity(GB)],
	CAST(CAST([freespace(MB)] AS NUMERIC(20, 2)) / 1024.0 AS DECIMAL(20, 2)) AS [freespace(GB)],
	CAST((CAST([freespace(MB)] AS NUMERIC(20, 2)) * 100.0) / [capacity(MB)] AS DECIMAL(20, 2)) AS [freespace(%)]
FROM T_Volumes AS v
WHERE v.Volume LIKE '[A-Z]:\Data\'
	OR v.Volume LIKE '[A-Z]:\Data[0-9]\'
	OR v.Volume LIKE '[A-Z]:\Data[0-9][0-9]\'
	OR v.Volume LIKE '[A-Z]:\Logs\'
	OR v.Volume LIKE '[A-Z]:\Logs[0-9]\'
	OR v.Volume LIKE '[A-Z]:\Logs[0-9][0-9]\'
	OR v.Volume LIKE '[A-Z]:\tempdb\'
	OR v.Volume LIKE '[A-Z]:\tempdb[0-9]\'
	OR v.Volume LIKE '[A-Z]:\tempdb[0-9][0-9]\'
	OR EXISTS (
		SELECT *
		FROM sys.master_files AS mf
		WHERE mf.physical_name LIKE Volume + '%'
		);

SELECT DB_NAME(mf.database_id) AS DbName,
	Volume = '(' + Label + ')' + Volume,
	[VolumeSize(GB)] = [capacity(GB)],
	[VolumeFreeSpace(GB)] = [freespace(GB)],
	type_desc,
	name AS FileName,
	CurrentSize = CASE 
		WHEN size = 0
			THEN '0'
		WHEN size * 8 / 1024 / 1024 >= 1
			THEN CAST(size * 8 / 1024 / 1024 AS VARCHAR(20)) + ' gb'
		WHEN size * 8 / 1024 >= 1
			THEN CAST(size * 8 / 1024 AS VARCHAR(20)) + ' mb'
		ELSE CAST(size * 8 AS VARCHAR(20)) + ' kb'
		END,
	max_size = CASE 
		WHEN max_size = - 1
			THEN '-1'
		WHEN (max_size * 8.0) / 1024 / 1024 >= 1
			THEN CAST(CAST((max_size * 8.0) / 1024 / 1024 AS NUMERIC(20, 2)) AS VARCHAR(40)) + ' gb'
		WHEN (max_size * 8.0) / 1024 >= 1
			THEN CAST((max_size * 8.0) / 1024 AS VARCHAR(40)) + ' mb'
		ELSE CAST(max_size * 8.0 AS VARCHAR(40)) + ' kb'
		END,
	growth AS growth_Pages,
	is_percent_growth,
	physical_name
FROM sys.master_files AS mf
LEFT JOIN @mountPointVolumes AS v ON mf.physical_name LIKE v.Volume + '%'
ORDER BY DbName;
