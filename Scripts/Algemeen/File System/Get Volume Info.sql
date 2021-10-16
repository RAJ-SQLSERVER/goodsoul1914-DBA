--EXEC tempdb..[usp_AnalyzeSpaceCapacity] @getLogInfo = 1 ,@verbose = 1

/********************************************************************************
	Created By:		Ajay Dwivedi
	Purpose:		Get Space Utilization of All DB Files along with Free space on Drives.
					This considers even non-accessible DBs
********************************************************************************/

DECLARE @output TABLE (line VARCHAR(2000));
DECLARE @_powershellCMD VARCHAR(400);
DECLARE @mountPointVolumes TABLE (
    Volume          VARCHAR(200),
    Label           VARCHAR(100)  NULL,
    [capacity(MB)]  DECIMAL(20, 2),
    [freespace(MB)] DECIMAL(20, 2),
    VolumeName      VARCHAR(50),
    [capacity(GB)]  DECIMAL(20, 2),
    [freespace(GB)] DECIMAL(20, 2),
    [freespace(%)]  DECIMAL(20, 2)
);

--	Begin: Get Data & Log Mount Point Volumes
SET @_powershellCMD = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME (@@servername, '''')
                      + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,Label,capacity,freespace | foreach{$_.name+''|''+$_.Label+''|''+$_.capacity/1048576+''|''+$_.freespace/1048576}"';

--inserting disk name, Label, total space and free space value in to temporary table
INSERT INTO @output
EXEC xp_cmdshell @_powershellCMD;

WITH t_RawData AS
(
    SELECT 1 AS "ID",
           line,
           LEFT(line, CHARINDEX ('|', line) - 1) AS "expression",
           SUBSTRING (line, CHARINDEX ('|', line) + 1, LEN (line) + 1) AS "searchExpression",
           CHARINDEX ('|', SUBSTRING (line, CHARINDEX ('|', line) + 1, LEN (line) + 1)) AS "delimitorPosition"
    FROM @output
    WHERE line LIKE '[A-Z][:]%'
    --line like 'C:\%'
    -- 
    UNION ALL
    --
    SELECT ID + 1 AS "ID",
           line,
           CASE
               WHEN delimitorPosition = 0 THEN searchExpression
               ELSE LEFT(searchExpression, delimitorPosition - 1)
           END AS "expression",
           CASE
               WHEN delimitorPosition = 0 THEN NULL
               ELSE SUBSTRING (searchExpression, delimitorPosition + 1, LEN (searchExpression) + 1)
           END AS "searchExpression",
           CASE
               WHEN delimitorPosition = 0 THEN -1
               ELSE CHARINDEX ('|', SUBSTRING (searchExpression, delimitorPosition + 1, LEN (searchExpression) + 1))
           END AS "delimitorPosition"
    FROM t_RawData
    WHERE delimitorPosition >= 0
),
     T_Volumes AS
(
    SELECT line,
           Volume,
           Label,
           [capacity(MB)],
           [freespace(MB)]
    FROM (
        SELECT line,
               CASE ID
                   WHEN 1 THEN 'Volume'
                   WHEN 2 THEN 'Label'
                   WHEN 3 THEN 'capacity(MB)'
                   WHEN 4 THEN 'freespace(MB)'
                   ELSE NULL
               END AS "Column",
               expression AS "Value"
        FROM t_RawData
    ) AS up
    PIVOT (
        MAX(Value)
        FOR [Column] IN (Volume, Label, [capacity(MB)], [freespace(MB)])
    ) AS pvt
--ORDER BY LINE
)
INSERT INTO @mountPointVolumes (Volume,
                                Label,
                                [capacity(MB)],
                                [freespace(MB)],
                                VolumeName,
                                [capacity(GB)],
                                [freespace(GB)],
                                [freespace(%)])
SELECT Volume,
       Label,
       CAST([capacity(MB)] AS NUMERIC(20, 2)) AS "capacity(MB)",
       CAST([freespace(MB)] AS NUMERIC(20, 2)) AS "freespace(MB)",
       Label AS "VolumeName",
       CAST(CAST([capacity(MB)] AS NUMERIC(20, 2)) / 1024.0 AS DECIMAL(20, 2)) AS "capacity(GB)",
       CAST(CAST([freespace(MB)] AS NUMERIC(20, 2)) / 1024.0 AS DECIMAL(20, 2)) AS "freespace(GB)",
       CAST((CAST([freespace(MB)] AS NUMERIC(20, 2)) * 100.0) / [capacity(MB)] AS DECIMAL(20, 2)) AS "freespace(%)"
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

SELECT *
FROM @mountPointVolumes;