USE DBA;
GO

CREATE OR ALTER PROCEDURE dbo.usp_DatabaseSizing
(
    @granularity VARCHAR(1) = NULL,
    @database_name sysname = NULL
)
AS
/*-------------------------------------------------------------
dbo.usp_DatabaseSizing Stored Procedure 
Created by Tim Ford, www.sqlcruise.com, www.thesqlagentman.com
Use freely but review code before executing.
Code downloaded from internet so execute at your own risk.
-------------------------------------------------------------*/

DECLARE @sql_command VARCHAR(5000);

CREATE TABLE #Results
(
    Server NVARCHAR(128),
    DatabaseName NVARCHAR(128),
    FileName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    FileType VARCHAR(4),
    TotalSizeMB INT,
    AvailableSpaceMB INT,
    GrowthUnits VARCHAR(15),
    MaxFileSizeMB INT
);

SELECT @sql_command
    = 'USE [?] 
		INSERT INTO #Results([Server], [DatabaseName], [FileName], [PhysicalName],  
		[FileType], [TotalSizeMB], [AvailableSpaceMB],  
		[GrowthUnits], [MaxFileSizeMB])  
		SELECT 
			CONVERT(nvarchar(128), SERVERPROPERTY(''Servername'')), 
			DB_NAME(), 
			[name] AS [FileName],  
			physical_name AS [PhysicalName],  
			[FileType] =  
				CASE type 
				WHEN 0 THEN ''Data''' + 'WHEN 1 THEN ''Log'''
					  + 'END, 
			[TotalSizeMB] = 
				CASE ceiling([size]/128)  
				WHEN 0 THEN 1 
				ELSE ceiling([size]/128) 
				END, 
			[AvailableSpaceMB] =  
				CASE ceiling([size]/128) 
				WHEN 0 THEN (1 - CAST(FILEPROPERTY([name], ''SpaceUsed'''
					  + ') as int) /128) 
				ELSE (([size]/128) - CAST(FILEPROPERTY([name], ''SpaceUsed'''
					  + ') as int) /128) 
				END, 
			[GrowthUnits]  =  
				CASE [is_percent_growth]  
				WHEN 1 THEN CAST([growth] AS varchar(20)) + ''%''' + 'ELSE CAST([growth]/1024*8 AS varchar(20)) + ''Mb'''
					  + 'END, 
			[MaxFileSizeMB] =  
				CASE [max_size] 
				WHEN -1 THEN NULL 
				WHEN 268435456 THEN NULL 
				ELSE [max_size]/1024*8 
				END 
		FROM sys.database_files WITH (NOLOCK)
		ORDER BY [FileType], [file_id]';

--Print the command to be issued against all databases 
--PRINT @sql_command 

EXEC sys.sp_MSforeachdb @command1 = @sql_command;

IF @database_name IS NULL
BEGIN
    IF @granularity = 'd' /* Database Scope */
    BEGIN
        SELECT T.Server,
               T.DatabaseName,
               T.total_size_mb AS DatabaseSizeMB,
               T.available_space_mb AS DatabaseFreeMB,
               T.used_space_mb AS DatabaseUsedMB,
               D.total_size_mb AS DataFileSizeMB,
               D.available_space_mb AS DataFileFreeMB,
               D.used_space_mb AS DataFileUsedMB,
               CEILING(CAST(D.available_space_mb AS DECIMAL(10, 1)) / D.total_size_mb * 100) AS DateFileFreePercentage,
               L.total_size_mb AS LogFileSizeMB,
               L.available_space_mb AS LogFileFreeMB,
               L.used_space_mb AS LogFileUsedMB,
               CEILING(CAST(L.available_space_mb AS DECIMAL(10, 1)) / L.total_size_mb * 100) AS LogFileFreePercentage
        FROM
        (
            SELECT server,
                   DatabaseName,
                   SUM(TotalSizeMB) AS total_size_mb,
                   SUM(AvailableSpaceMB) AS available_space_mb,
                   SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
            FROM #Results
            GROUP BY server,
                     DatabaseName
        ) AS T
            INNER JOIN
            (
                SELECT server,
                       DatabaseName,
                       SUM(TotalSizeMB) AS total_size_mb,
                       SUM(AvailableSpaceMB) AS available_space_mb,
                       SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
                FROM #Results
                WHERE FileType = 'Data'
                GROUP BY server,
                         DatabaseName
            ) AS D
                ON T.DatabaseName = D.DatabaseName
            INNER JOIN
            (
                SELECT server,
                       DatabaseName,
                       SUM(TotalSizeMB) AS total_size_mb,
                       SUM(AvailableSpaceMB) AS available_space_mb,
                       SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
                FROM #Results
                WHERE FileType = 'Log'
                GROUP BY server,
                         DatabaseName
            ) AS L
                ON T.DatabaseName = L.DatabaseName
        ORDER BY D.DatabaseName;
    END;
    ELSE /* File Scope */
    BEGIN
        SELECT server,
               DatabaseName,
               FileName,
               PhysicalName,
               FileType,
               TotalSizeMB AS DataFileSizeMB,
               AvailableSpaceMB AS DataFileFreeMB,
               CEILING(CAST(AvailableSpaceMB AS DECIMAL(10, 1)) / TotalSizeMB * 100) AS DataFileFreePercentage,
               GrowthUnits,
               MaxFileSizeMB
        FROM #Results
        ORDER BY DatabaseName,
                 FileType,
                 FileName;
    END;
END;
ELSE
BEGIN
    IF @granularity = 'd' /* Database Scope */
    BEGIN
        SELECT T.server,
               T.DatabaseName,
               T.total_size_mb AS DatabaseSizeMB,
               T.available_space_mb AS DatabaseFreeMB,
               T.used_space_mb AS DatabaseUsedMB,
               D.total_size_mb AS DataFileSizeMB,
               D.available_space_mb AS DataFileFreeMB,
               D.used_space_mb AS DataFileUsedMB,
               CEILING(CAST(D.available_space_mb AS DECIMAL(10, 1)) / D.total_size_mb * 100) AS DateFileFreePercentage,
               L.total_size_mb AS LogFileSizeMB,
               L.available_space_mb AS LogFileFreeMB,
               L.used_space_mb AS LogFileUsedMB,
               CEILING(CAST(L.available_space_mb AS DECIMAL(10, 1)) / L.total_size_mb * 100) AS LogFileFreePercentage
        FROM
        (
            SELECT server,
                   DatabaseName,
                   SUM(TotalSizeMB) AS total_size_mb,
                   SUM(AvailableSpaceMB) AS available_space_mb,
                   SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
            FROM #Results
            WHERE DatabaseName = @database_name
            GROUP BY server,
                     DatabaseName
        ) AS T
            INNER JOIN
            (
                SELECT server,
                       DatabaseName,
                       SUM(TotalSizeMB) AS total_size_mb,
                       SUM(AvailableSpaceMB) AS available_space_mb,
                       SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
                FROM #Results
                WHERE FileType = 'Data'
                      AND DatabaseName = @database_name
                GROUP BY server,
                         DatabaseName
            ) AS D
                ON T.DatabaseName = D.DatabaseName
            INNER JOIN
            (
                SELECT server,
                       DatabaseName,
                       SUM(TotalSizeMB) AS total_size_mb,
                       SUM(AvailableSpaceMB) AS available_space_mb,
                       SUM(TotalSizeMB - AvailableSpaceMB) AS used_space_mb
                FROM #Results
                WHERE FileType = 'Log'
                      AND DatabaseName = @database_name
                GROUP BY server,
                         DatabaseName
            ) AS L
                ON T.DatabaseName = L.DatabaseName
        ORDER BY D.DatabaseName;
    END;
    ELSE /* File Scope */
    BEGIN
        SELECT server,
               DatabaseName,
               FileName,
               PhysicalName,
               FileType,
               TotalSizeMB AS DataFileSizeMB,
               AvailableSpaceMB AS DataFileFreeMB,
               CEILING(CAST(AvailableSpaceMB AS DECIMAL(10, 1)) / TotalSizeMB * 100) AS DataFileFreePercentage,
               GrowthUnits,
               MaxFileSizeMB
        FROM #Results
        WHERE DatabaseName = @database_name
        ORDER BY FileType,
                 FileName;
    END;
END;
