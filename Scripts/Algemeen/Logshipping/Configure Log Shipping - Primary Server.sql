-- Execute on the Primary to configure Log Shipping 
DECLARE @LS_BackupJobId AS UNIQUEIDENTIFIER;
DECLARE @LS_PrimaryId AS UNIQUEIDENTIFIER;
DECLARE @SP_Add_RetCode AS INT;

-- Configure the Primary database for log shipping, create backup job and add Monitor server link
EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database @database = N'AdventureWorks', -- name of the log shipping primary database
	@backup_directory = N'M:\SQLBackups\LSBackups', -- path to the backup folder on the primary server 
	@backup_share = N'\\zkh.local\zkh\LSBackups', -- network path to the backup directory on the primary server
	@backup_job_name = N'LSBackup_AdventureWorks', -- name of the SQL Server Agent job on the primary server that copies the backup into the backup folder
	@backup_retention_period = 4320, -- length of time, in minutes, to retain the log backup file in the backup directory on the primary server
	@backup_compression = 1, -- specifies whether a log shipping configuration uses backup compression
	--@monitor_server = N'LABDB01',					-- name of the monitor server
	--@monitor_server_security_mode = 0,				-- security mode used to connect to the monitor server
	--@monitor_server_login = N'sa',					-- username of the account used to access the monitor server
	--@monitor_server_password = N'1994Acura#',		-- password of the account used to access the monitor server
	@backup_threshold = 60, -- length of time, in minutes, after the last backup before a threshold_alert error is raised
	@threshold_alert_enabled = 1, -- specifies whether an alert will be raised when backup_threshold is exceeded
	@history_retention_period = 5760, -- length of time in minutes in which the history will be retained
	@backup_job_id = @LS_BackupJobId OUTPUT, -- SQL Server Agent job ID associated with the backup job on the primary server
	@primary_id = @LS_PrimaryId OUTPUT, -- ID of the primary database for the log shipping configuration
	@overwrite = 1;-- 

IF @@ERROR = 0
	AND @SP_Add_RetCode = 0
BEGIN
	DECLARE @LS_BackUpScheduleUID AS UNIQUEIDENTIFIER;
	DECLARE @LS_BackUpScheduleID AS INT;

	-- Add a schedule for the backup job
	EXEC msdb.dbo.sp_add_schedule @schedule_name = N'LSBackupSchedule_LABDB031', -- name of the schedule
		@enabled = 1, -- the current status of the schedule
		@freq_type = 4, -- value indicating when a job is to be executed
		@freq_interval = 1, -- days that a job is executed
		@freq_subday_type = 4, -- units for freq_subday_interval
		@freq_subday_interval = 15, -- number of freq_subday_type periods to occur between each execution of a job
		@freq_recurrence_factor = 0, -- number of weeks or months between the scheduled execution of a job
		@active_start_date = 20170928, -- date on which execution of a job can begin
		@active_end_date = 99991231, -- date on which execution of a job can stop
		@active_start_time = 0, -- time on any day between active_start_date and active_end_date to begin execution of a job
		@active_end_time = 235900, -- time on any day between active_start_date and active_end_date to end execution of a job
		@schedule_uid = @LS_BackUpScheduleUID OUTPUT, -- unique identifier for the schedule
		@schedule_id = @LS_BackUpScheduleID OUTPUT;-- identifier for the schedule

	-- Link the schedule to the job
	EXEC msdb.dbo.sp_attach_schedule @job_id = @LS_BackupJobId,
		@schedule_id = @LS_BackUpScheduleID;

	-- Enable the backup job
	EXEC msdb.dbo.sp_update_job @job_id = @LS_BackupJobId,
		@enabled = 1;
END;

-- Add information about secondary server and database
EXEC master.dbo.sp_add_log_shipping_primary_secondary @primary_database = N'AdventureWorks',
	@secondary_server = N'LABDB04',
	@secondary_database = N'AdventureWorks',
	@overwrite = 1;
