/*========================================================================================================================

Description:	Display information about database files for all databases
Scope:			Instance
Author:			Guy Glantser
Created:		10/09/2020
Last Updated:	10/09/2020
Notes:			Use this information to plan a maintenance plan for managing the size of the databases in the instance

=========================================================================================================================*/

DROP TABLE IF EXISTS #DatabaseFiles;
GO


CREATE TABLE #DatabaseFiles (
    DatabaseId                        INT            NOT NULL,
    DatabaseName                      sysname        NOT NULL,
    FilegroupId                       INT            NULL,
    FilegroupName                     sysname        NULL,
    IsAutoGrowAllFiles                BIT            NULL, -- Applies to: SQL Server (SQL Server 2016 (13.x) through current version)
    FileId                            INT            NOT NULL,
    FileType                          NVARCHAR(60)   NOT NULL,
    FileLogicalName                   sysname        NOT NULL,
    FilePhysicalName                  NVARCHAR(260)  NOT NULL,
    FileState                         NVARCHAR(60)   NOT NULL,
    FileSize_MB                       DECIMAL(19, 2) NOT NULL,
    AllocatedSpace_MB                 DECIMAL(19, 2) NULL,
    UnallocatedSpace_MB               DECIMAL(19, 2) NULL,
    UnallocatedSpace_Percent          NVARCHAR(7)    NULL,
    AutoGrowthType                    NVARCHAR(9)    NULL,
    AutoGrowthValue                   DECIMAL(19, 2) NULL,
    FileMaxSize_MB                    INT            NULL,
    VolumeName                        NVARCHAR(512)  NULL,
    VolumeTotalSize_GB                DECIMAL(19, 2) NOT NULL,
    VolumeFreeSpace_GB                DECIMAL(19, 2) NOT NULL,
    VolumeFreeSpace_Percent           NVARCHAR(7)    NOT NULL,
    Warning                           NVARCHAR(37)   NOT NULL,
    IsReadOnly                        BIT            NOT NULL,
    NumberOfAutoGrowthEvents          INT            NULL,
    TimeSpan_Hours                    INT            NULL,
    AverageNumberOfHoursBetweenEvents DECIMAL(19, 2) NULL,
    AverageEventDuration_MS           DECIMAL(19, 2) NULL,
    AverageFileGrowthSize_MB          DECIMAL(19, 2) NULL
);
GO


DECLARE @DatabaseName AS sysname,
        @Command      AS NVARCHAR(MAX);

DECLARE Databases CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR
    SELECT name AS DatabaseName FROM sys.databases WHERE state = 0; -- Online

OPEN Databases;

FETCH NEXT FROM Databases
INTO @DatabaseName;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @Command
        = N'
			USE
				' + QUOTENAME (@DatabaseName)
          + N';

			INSERT INTO
				#DatabaseFiles
			(
				DatabaseId ,
				DatabaseName ,
				FilegroupId ,
				FilegroupName ,
				IsAutoGrowAllFiles ,	-- Applies to: SQL Server (SQL Server 2016 (13.x) through current version)
				FileId ,
				FileType ,
				FileLogicalName ,
				FilePhysicalName ,
				FileState ,
				FileSize_MB ,
				AllocatedSpace_MB ,
				UnallocatedSpace_MB ,
				UnallocatedSpace_Percent ,
				AutoGrowthType ,
				AutoGrowthValue ,
				FileMaxSize_MB ,
				VolumeName ,
				VolumeTotalSize_GB ,
				VolumeFreeSpace_GB ,
				VolumeFreeSpace_Percent ,
				Warning ,
				IsReadOnly ,
				NumberOfAutoGrowthEvents ,
				TimeSpan_Hours ,
				AverageNumberOfHoursBetweenEvents ,
				AverageEventDuration_MS ,
				AverageFileGrowthSize_MB
			)
			SELECT
				DatabaseId							= DB_ID () ,
				DatabaseName						= DB_NAME () ,
				FilegroupId							= Filegroups.data_space_id ,
				FilegroupName						= Filegroups.[name] ,
				IsAutoGrowAllFiles					= Filegroups.is_autogrow_all_files ,	-- Applies to: SQL Server (SQL Server 2016 (13.x) through current version)
				FileId								= DatabaseFiles.file_id ,
				FileType							= DatabaseFiles.[type_desc] ,
				FileLogicalName						= DatabaseFiles.[name] ,
				FilePhysicalName					= DatabaseFiles.physical_name ,
				FileState							= DatabaseFiles.state_desc ,
				FileSize_MB							= CAST ((CAST (DatabaseFiles.size AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2)) ,
				AllocatedSpace_MB					= CAST ((CAST (FILEPROPERTY (DatabaseFiles.[name] , ''SpaceUsed'') AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2)) ,
				UnallocatedSpace_MB					= CAST ((CAST ((DatabaseFiles.size - FILEPROPERTY (DatabaseFiles.[name] , ''SpaceUsed'')) AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2)) ,
				UnallocatedSpace_Percent			= FORMAT (CAST ((DatabaseFiles.size - FILEPROPERTY (DatabaseFiles.[name] , ''SpaceUsed'')) AS DECIMAL(19,2)) / CAST (DatabaseFiles.size AS DECIMAL(19,2)) , ''P'') ,
				AutoGrowthType						=
					CASE DatabaseFiles.growth
						WHEN 0
							THEN NULL
						ELSE
							CASE DatabaseFiles.is_percent_growth
								WHEN 0
									THEN N''Megabytes''
								WHEN 1
									THEN N''Percent''
							END
					END ,
				AutoGrowthValue						=
					CASE DatabaseFiles.growth
						WHEN 0
							THEN NULL
						ELSE
							CASE DatabaseFiles.is_percent_growth
								WHEN 0
									THEN CAST ((CAST (DatabaseFiles.growth AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2))
								WHEN 1
									THEN CAST (DatabaseFiles.growth AS DECIMAL(19,2))
							END
					END ,
				FileMaxSize_MB						=
					CASE DatabaseFiles.max_size
						WHEN 0
							THEN NULL
						WHEN -1
							THEN -1
						WHEN 268435456
							THEN -1
						ELSE
							CAST (ROUND ((CAST (DatabaseFiles.max_size AS DECIMAL(19,2)) * 8.0 / 1024.0) , 0) AS INT)
					END ,
				VolumeName							= Volumes.volume_mount_point ,
				VolumeTotalSize_GB					= CAST ((CAST (Volumes.total_bytes AS DECIMAL(19,2)) / 1024.0 / 1024.0 / 1024.0) AS DECIMAL(19,2)) ,
				VolumeFreeSpace_GB					= CAST ((CAST (Volumes.available_bytes AS DECIMAL(19,2)) / 1024.0 / 1024.0 / 1024.0) AS DECIMAL(19,2)) ,
				VolumeFreeSpace_Percent				= FORMAT (CAST (Volumes.available_bytes AS DECIMAL(19,2)) / CAST (Volumes.total_bytes AS DECIMAL(19,2)) , ''P'') ,
				Warning								=
					CASE
						WHEN
							DatabaseFiles.growth != 0
						AND
						(
							DatabaseFiles.is_percent_growth = 0
						AND
							CAST ((CAST (DatabaseFiles.growth AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2)) > CAST ((CAST (Volumes.available_bytes AS DECIMAL(19,2)) / 1024.0 / 1024.0) AS DECIMAL(19,2))
						OR
							DatabaseFiles.is_percent_growth = 1
						AND
							CAST ((CAST (DatabaseFiles.size AS DECIMAL(19,2)) * 8.0 / 1024.0) AS DECIMAL(19,2)) * CAST (DatabaseFiles.growth AS DECIMAL(19,2)) > CAST ((CAST (Volumes.available_bytes AS DECIMAL(19,2)) / 1024.0 / 1024.0) AS DECIMAL(19,2))
						)
						THEN
							N''Not Enough Space for Next Auto Growth''
						ELSE
							N''''
					END ,
				IsReadOnly					= DatabaseFiles.is_read_only ,
				NumberOfAutoGrowthEvents			= NULL ,
				TimeSpan_Hours						= NULL ,
				AverageNumberOfHoursBetweenEvents	= NULL ,
				AverageEventDuration_MS				= NULL ,
				AverageFileGrowthSize_MB			= NULL
			FROM
				sys.database_files AS DatabaseFiles
			LEFT OUTER JOIN
				sys.filegroups AS Filegroups
			ON
				DatabaseFiles.data_space_id = Filegroups.data_space_id
			CROSS APPLY
				sys.dm_os_volume_stats (DB_ID () , DatabaseFiles.file_id) AS Volumes;
		';

    EXECUTE sys.sp_executesql @stmt = @Command;

    FETCH NEXT FROM Databases
    INTO @DatabaseName;

END;

CLOSE Databases;

DEALLOCATE Databases;
GO


DECLARE @CurrentTraceFilePath NVARCHAR(260),
        @FirstTraceFilePath   NVARCHAR(260);

SELECT @CurrentTraceFilePath = path FROM sys.traces WHERE is_default = 1;

SET @FirstTraceFilePath
    = LEFT(@CurrentTraceFilePath, LEN (@CurrentTraceFilePath) - PATINDEX (N'%\%', REVERSE (@CurrentTraceFilePath)))
      + N'\log.trc';

WITH DatabaseFileAutoGrowthStats (DatabaseName, FileLogicalName, NumberOfAutoGrowthEvents, TimeSpan_Hours,
                                  AverageNumberOfHoursBetweenEvents, AverageEventDuration_MS, AverageFileGrowthSize_MB
)
AS (
    SELECT DatabaseName AS DatabaseName,
           FileName AS FileLogicalName,
           COUNT (*) AS NumberOfAutoGrowthEvents,
           DATEDIFF (HOUR, MIN (StartTime), SYSDATETIME ()) AS TimeSpan_Hours,
           CAST(CAST(DATEDIFF (HOUR, MIN (StartTime), SYSDATETIME ()) AS DECIMAL(19, 2)) / COUNT (*) AS DECIMAL(19, 2)) AS AverageNumberOfHoursBetweenEvents,
           CAST(AVG (CAST(Duration / 1000.0 AS DECIMAL(19, 2))) AS DECIMAL(19, 2)) AS AverageEventDuration_MS,
           CAST(AVG (CAST(IntegerData * 8.0 / 1024.0 AS DECIMAL(19, 2))) AS DECIMAL(19, 2)) AS AverageFileGrowthSize_MB
    FROM sys.fn_trace_gettable (@FirstTraceFilePath, DEFAULT)
    WHERE EventClass IN ( 92, 93 )
    GROUP BY DatabaseName,
             FileName
)
UPDATE DatabaseFiles
SET NumberOfAutoGrowthEvents = DatabaseFileAutoGrowthStats.NumberOfAutoGrowthEvents,
    TimeSpan_Hours = DatabaseFileAutoGrowthStats.TimeSpan_Hours,
    AverageNumberOfHoursBetweenEvents = DatabaseFileAutoGrowthStats.AverageNumberOfHoursBetweenEvents,
    AverageEventDuration_MS = DatabaseFileAutoGrowthStats.AverageEventDuration_MS,
    AverageFileGrowthSize_MB = DatabaseFileAutoGrowthStats.AverageFileGrowthSize_MB
FROM #DatabaseFiles AS DatabaseFiles
LEFT OUTER JOIN DatabaseFileAutoGrowthStats
    ON DatabaseFiles.DatabaseName = DatabaseFileAutoGrowthStats.DatabaseName
       AND DatabaseFiles.FileLogicalName = DatabaseFileAutoGrowthStats.FileLogicalName;
GO


SELECT DatabaseId,
       DatabaseName,
       FilegroupId,
       FilegroupName,
       IsAutoGrowAllFiles, -- Applies to: SQL Server (SQL Server 2016 (13.x) through current version)
       FileId,
       FileType,
       FileLogicalName,
       FilePhysicalName,
       FileState,
       FileSize_MB,
       AllocatedSpace_MB,
       UnallocatedSpace_MB,
       UnallocatedSpace_Percent,
       AutoGrowthType,
       AutoGrowthValue,
       FileMaxSize_MB,
       VolumeName,
       VolumeTotalSize_GB,
       VolumeFreeSpace_GB,
       VolumeFreeSpace_Percent,
       Warning,
       IsReadOnly,
       NumberOfAutoGrowthEvents,
       TimeSpan_Hours,
       AverageNumberOfHoursBetweenEvents,
       AverageEventDuration_MS,
       AverageFileGrowthSize_MB
FROM #DatabaseFiles
ORDER BY DatabaseId ASC,
         FilegroupId ASC,
         FileId ASC;
GO


DROP TABLE #DatabaseFiles;
GO
