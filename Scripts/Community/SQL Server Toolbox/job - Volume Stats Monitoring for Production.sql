--CHECK TODO's
--This version is for production systems. See other script aptly named for non-production systems.

-- Create Table
USE DBA; --TODO
GO

IF NOT EXISTS (
    SELECT *
    FROM sys.objects
    WHERE name = 'VolumeStats'
          AND type_desc = 'USER_TABLE'
)
    CREATE TABLE dbo.VolumeStats (
        ID                INT               IDENTITY(1, 1) NOT NULL,
        DiskDrive         NVARCHAR(512)     NULL,
        FileSystemType    NVARCHAR(512)     NULL,
        LogicalVolumeName NVARCHAR(512)     NULL,
        DriveSize         DECIMAL(19, 2)    NULL,
        DriveFreeSpace    DECIMAL(19, 2)    NULL,
        DrivePercentFree  DECIMAL(19, 2)    NULL,
        DateTimePerformed DATETIMEOFFSET(2) NULL,
        CONSTRAINT PK_VolumeStats
            PRIMARY KEY CLUSTERED (ID ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON
            ) ON [PRIMARY]
    ) ON [PRIMARY];

GO

--Create Sproc
CREATE PROCEDURE dbo.Get_VolumeStats @Threshold DECIMAL(19, 2)
AS
BEGIN
    -- Version# May 2020 Rev01
    DECLARE @VolumeStats TABLE (
        ID                  INT NOT NULL IDENTITY(1, 1),
        volume_mount_point  NVARCHAR(512),
        file_system_type    NVARCHAR(512),
        logical_volume_name NVARCHAR(512),
        Total_Size          DECIMAL(19, 2),
        Available_Size      DECIMAL(19, 2),
        Space_Free          DECIMAL(19, 2),
        DateTimePerformed   DATETIMEOFFSET(2)
    );


    DECLARE @TimeStamp DATETIMEOFFSET(2) = SYSDATETIMEOFFSET ();
    DECLARE VolumeInfo CURSOR FOR
    SELECT MAX (vs.volume_mount_point),
           MAX (vs.file_system_type),
           MAX (vs.logical_volume_name),
           CONVERT (DECIMAL(19, 2), MIN (vs.total_bytes / 1073741824.0)) AS "Total Size (GB)",
           CONVERT (DECIMAL(19, 2), MIN (vs.available_bytes / 1073741824.0)) AS "Available Size (GB)",
           CONVERT (DECIMAL(19, 2), MIN (vs.available_bytes * 1. / vs.total_bytes * 100.)) AS "Space Free %",
           @TimeStamp
    FROM sys.master_files AS f WITH (NOLOCK)
    CROSS APPLY sys.dm_os_volume_stats (f.database_id, f.file_id) AS vs
    GROUP BY vs.volume_mount_point; --group by was added 20171107 CLL

    DECLARE @volume           NVARCHAR(512),
            @file_system_type NVARCHAR(512),
            @logical_name     NVARCHAR(512);
    DECLARE @TotalSize     DECIMAL(19, 2),
            @AvailableSize DECIMAL(19, 2),
            @percent       DECIMAL(19, 2);
    DECLARE @MyTime DATETIMEOFFSET(2);

    OPEN VolumeInfo;

    FETCH NEXT FROM VolumeInfo
    INTO @volume,
         @file_system_type,
         @logical_name,
         @TotalSize,
         @AvailableSize,
         @percent,
         @MyTime;
    WHILE (@@FETCH_STATUS <> -1)
    BEGIN

        IF @percent <= @Threshold
        BEGIN
            INSERT INTO dbo.VolumeStats (DiskDrive,
                                         FileSystemType,
                                         LogicalVolumeName,
                                         DriveSize,
                                         DriveFreeSpace,
                                         DrivePercentFree,
                                         DateTimePerformed)
            VALUES (@volume, @file_system_type, @logical_name, @TotalSize, @AvailableSize, @percent, @TimeStamp);
            INSERT INTO @VolumeStats (volume_mount_point,
                                      file_system_type,
                                      logical_volume_name,
                                      Total_Size,
                                      Available_Size,
                                      Space_Free,
                                      DateTimePerformed)
            VALUES (@volume, @file_system_type, @logical_name, @TotalSize, @AvailableSize, @percent, @TimeStamp);
        END;
        ELSE
        BEGIN
            INSERT INTO dbo.VolumeStats (DiskDrive,
                                         FileSystemType,
                                         LogicalVolumeName,
                                         DriveSize,
                                         DriveFreeSpace,
                                         DrivePercentFree,
                                         DateTimePerformed)
            VALUES (@volume, @file_system_type, @logical_name, @TotalSize, @AvailableSize, @percent, @TimeStamp);

        END;

        FETCH NEXT FROM VolumeInfo
        INTO @volume,
             @file_system_type,
             @logical_name,
             @TotalSize,
             @AvailableSize,
             @percent,
             @MyTime;
    END;
    CLOSE VolumeInfo;
    DEALLOCATE VolumeInfo;

    IF (
        SELECT COUNT (*)
        FROM @VolumeStats
        WHERE logical_volume_name <> 'TempDBdata'
    ) > 0
    BEGIN
        DECLARE @tableHTML NVARCHAR(MAX);

        SET @tableHTML = N'<h2>Server: ' + @@SERVERNAME + N'</h2>' + N'<H3>Drive Space Alert</H3>'
                         + N'<table border="1">' + N'<tr><th>Volume</th><th>File Sytem Type</th>'
                         + N'<th>Logical Name</th><th>Total Size</th><th>Available Size</th>'
                         + N'<th>Percent Free</th></tr>' + CAST((
                                                               SELECT v.volume_mount_point AS "td",
                                                                      '',
                                                                      v.file_system_type AS "td",
                                                                      '',
                                                                      v.logical_volume_name AS "td",
                                                                      '',
                                                                      CONVERT (VARCHAR(8), v.Total_Size) AS "td",
                                                                      '',
                                                                      CONVERT (VARCHAR(8), v.Available_Size) AS "td",
                                                                      '',
                                                                      CONVERT (VARCHAR(8), v.Space_Free) AS "td",
                                                                      ''
                                                               FROM @VolumeStats AS v
                                                               ORDER BY v.volume_mount_point
                                                               FOR XML PATH ('tr'), TYPE
                                                           ) AS NVARCHAR(MAX)) + N'</table>';

        BEGIN
            IF @percent > 1
               AND @percent < @Threshold
            BEGIN
                EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPN', --TODO
                                             @recipients = 'mboomaars@gmail.com',
                                             @body = @tableHTML,
                                             @importance = 'HIGH',
                                             @body_format = 'HTML',
                                             @subject = 'Volume Size Report';
            END;
        END;
        BEGIN
            IF @percent < 1
            BEGIN
                EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPN', --TODO
                                             @recipients = 'mboomaars@gmail.com',
                                             @body = @tableHTML,
                                             @importance = 'HIGH',
                                             @body_format = 'HTML',
                                             @subject = 'Emergency: Volume Size Report';
            END;
        END;
    END;
END;

GO


DECLARE @startup_job_id UNIQUEIDENTIFIER;
SELECT @startup_job_id = job_id
FROM msdb.dbo.sysjobs
WHERE name = 'Volume Stats Monitoring';

IF @startup_job_id IS NOT NULL
    EXEC msdb.dbo.sp_delete_job @job_id = @startup_job_id,
                                @delete_unused_schedule = 1;
GO



--Create SQL Agent Job
USE msdb;
GO
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'Volume Stats Monitoring',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 2,
                         @notify_level_page = 2,
                         @delete_level = 0,
                         @category_name = N'[Uncategorized (Local)]',
                         @owner_login_name = N'sa',
                         @job_id = @jobId OUTPUT;
SELECT @jobId;
GO
EXEC msdb.dbo.sp_add_jobserver @job_name = N'Volume Stats Monitoring',
                               @server_name = N'(LOCAL)';
GO
USE msdb;
GO
EXEC msdb.dbo.sp_add_jobstep @job_name = N'Volume Stats Monitoring',
                             @step_name = N'Exec Get Volume Stats',
                             @step_id = 1,
                             @cmdexec_success_code = 0,
                             @on_success_action = 1,
                             @on_fail_action = 2,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'exec dbo.Get_VolumeStats @Threshold = 14;', --Default threshold of 14, change if desired in the job step
                             @database_name = N'DBA',                          --TODO: make sure db name matches
                             @flags = 0;
GO
USE msdb;
GO
EXEC msdb.dbo.sp_update_job @job_name = N'Volume Stats Monitoring',
                            @enabled = 1,
                            @start_step_id = 1,
                            @notify_level_eventlog = 0,
                            @notify_level_email = 2,
                            @notify_level_netsend = 2,
                            @notify_level_page = 2,
                            @delete_level = 0,
                            @description = N'',
                            @category_name = N'[Uncategorized (Local)]',
                            @owner_login_name = N'sa',
                            @notify_email_operator_name = N'', --TODO: enter operator name
                            @notify_netsend_operator_name = N'',
                            @notify_page_operator_name = N'';
GO
USE msdb;
GO
DECLARE @schedule_id INT;
EXEC msdb.dbo.sp_add_jobschedule @job_name = N'Volume Stats Monitoring',
                                 @name = N'Every 4 Hours',
                                 @enabled = 1,
                                 @freq_type = 4,
                                 @freq_interval = 1,
                                 @freq_subday_type = 8,
                                 @freq_subday_interval = 4,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 1,
                                 @active_start_date = 20171204,
                                 @active_end_date = 99991231,
                                 @active_start_time = 0,
                                 @active_end_time = 235959,
                                 @schedule_id = @schedule_id OUTPUT;
SELECT @schedule_id;
GO
