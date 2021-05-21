
/*
While you're free to change this script all you like, we recommend that you leave it as-is.
If you want to change the default data and it's not one of the parameters, we recommend you
create a data update script and add it to the end of InstallOrder.txt.
This way you can prevent any upgrade issues with the data.  See the install guide for more details.
*/

DECLARE
@BackupLocType VARCHAR(20),
@BackupDrive VARCHAR(100),
@BackupPath VARCHAR(100),
@PathFileName VARCHAR(500),
@PathFileExtension VARCHAR(50),
@PathServerLabel varchar(150),
@RetHrs INT,
@HistRetDays INT;

SET @BackupLocType = 'MinionBackupLocType';
SET @BackupDrive = 'MinionBackupDrive';
SET @BackupPath = 'MinionBackupPath';
SET @PathFileName = 'MinionPathFileName';
SET @PathFileExtension = 'MinionPathFileExtension';
SET @PathServerLabel = 'MinionPathServerLabel';
SET @RetHrs = 168;
SET @HistRetDays = 60;

DECLARE @BackupSettingsInstallerCT INT;
SET @BackupSettingsInstallerCT = (SELECT COUNT(*) FROM Minion.BackupSettings)
IF @BackupSettingsInstallerCT = 0
BEGIN
		DECLARE @ListeningPortInstaller INT;
		SET @ListeningPortInstaller = (SELECT local_tcp_port
									   FROM   sys.dm_exec_connections
									   WHERE  session_id = @@SPID)
If @ListeningPortInstaller = 1433
	BEGIN
		SET @ListeningPortInstaller = NULL;
	END

		INSERT [Minion].[BackupSettings] ([DBName], [Port], [BackupType], [Exclude], [GroupOrder], [GroupDBOrder], [Mirror], [DelFileBefore], [DelFileBeforeAgree], [LogLoc], [HistRetDays], [MinionTriggerPath], [DBPreCode], [DBPostCode], [PushToMinion], [DynamicTuning], [Verify], [PreferredServer], [ShrinkLogOnLogBackup], [ShrinkLogThresholdInMB], [ShrinkLogSizeInMB], [MinSizeForDiffInGB], [DiffReplaceAction], [LogProgress], [FileAction], [FileActionTime], [Encrypt], [Name], [ExpireDateInHrs], [RetainDays], [Descr], [Checksum], [Init], [Format], [CopyOnly], [Skip], [BackupErrorMgmt], [MediaName], [MediaDescription], [IsActive], [Comment]) 
		VALUES (N'MinionDefault', @ListeningPortInstaller, N'All', 0, 0, 0, 0, 0, 0, N'Local', @HistRetDays, NULL, NULL, NULL, NULL, 1, N'0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, 1, 'MinionDefault. DO NOT DELETE.')
	END


DECLARE @BackupTuningThresholdsInstallerCT INT;
SET @BackupTuningThresholdsInstallerCT = (SELECT COUNT(*) FROM Minion.BackupTuningThresholds)
IF @BackupTuningThresholdsInstallerCT = 0
BEGIN
	INSERT Minion.BackupTuningThresholds
	(DBName, BackupType, SpaceType, ThresholdMeasure, ThresholdValue, NumberOfFiles, Buffercount, MaxTransferSize, Compression, BlockSize, BeginTime, EndTime, DayOfWeek, IsActive, Comment)
	SELECT
	'MinionDefault' AS DBName, --Default row. DO NOT CHANGE!
	'All' AS BackupType, --Default row. DO NOT CHANGE!
	'DataAndIndex' AS SpaceType, --Valid values: Data|DataAndIndex|File
	'GB' AS ThresholdMeasure, --Valid values: GB
	0 AS ThresholdValue,  --Default row. DO NOT CHANGE!
	1 AS NumberOfFiles, --Number of files you want to use by default for backups.  This is best left at 1.  You'll have a chance to use more files once the product is installed.
	0 AS Buffercount, --Number of buffers you want to use by default for backups.  This is best left at 0.  You'll have a chance to use more files once the product is installed.
	0 AS MaxTransferSize, --Transfer size you want to use by default for backups.  This is best left at 0.  You'll have a chance to use more files once the product is installed.
	NULL AS Compression, -- Default compression for all backups.  We left this at NULL which will allow your server-level settings to kick in.  Change it if you're on a version of SQL Server that allows compression.
	0 AS BlockSize, --Block size you want to use by default for backups.  This is best left at 0.  You'll have a chance to use more files once the product is installed.
	NULL AS BeginTime,
	NULL AS EndTime,
	NULL AS DayOfWeek,
	1 AS IsActive, --Default row. DO NOT CHANGE!
	'Minion default. DO NOT REMOVE.' AS Comment --Default row. DO NOT CHANGE!
END


DECLARE @BackupSettingsPathInstallerCT INT;
SET @BackupSettingsPathInstallerCT = (SELECT COUNT(*) FROM Minion.BackupSettingsPath)
IF @BackupSettingsPathInstallerCT = 0
BEGIN
	INSERT Minion.BackupSettingsPath
	(DBName, IsMirror, BackupType, BackupLocType, BackupDrive, BackupPath,
	FileName, FileExtension, ServerLabel, RetHrs, FileActionMethod,
	FileActionMethodFlags, PathOrder, IsActive, AzureCredential, Comment)
	SELECT
	'MinionDefault' AS DBName,  --Default row. DO NOT CHANGE!
	0 AS IsMirror,  --Default row. DO NOT CHANGE!
	'All' AS BackupType,  --Default row. DO NOT CHANGE!
	@BackupLocType AS BackupLocType, --BackupLocType. This is the location type.  Local, NAS, Remote, URL.  This setting is used for your benefit, so put whatever will remind you what type it is.  It only matters if it's 'URL', but that feature isn't live yet so you shouldn't worry about this.
	@BackupDrive AS BackupDrive, --BackupDrive. Drive letter or base UNC path like '\\MyNAS\'.
	@BackupPath AS BackupPath, --BackupPath. The folder structure you want under the base path. So in this case the backups will go to C:\SQLBackups.
	@PathFileName AS FileName,
	@PathFileExtension AS FileExtension,
	@PathServerLabel AS ServerLabel, --ServerLabel. Unless you have a reason to change this, you can leave it NULL.  The vid discusses this setting.
	@RetHrs AS RetHrs, -- How long do you want to keep the backup files on disk?
	NULL AS FileActionMethod,
	NULL AS FileActionMethodFlags,
	0 AS PathOrder, --PathOrder. Unless you want to specify which drive in a multi drive scenario gets written to first, just leave this as is.
	1 AS IsActive,  --Default row. DO NOT CHANGE!
	NULL AS AzureCredential, --AzureCredential. This feature isn't currently active.
	'Minion default. DO NOT REMOVE.' AS Comment --Default row. DO NOT CHANGE!

END

DECLARE @BackupSettingsServerInstallerCT INT;
SET @BackupSettingsServerInstallerCT = (SELECT COUNT(*) FROM Minion.BackupSettingsServer)
IF @BackupSettingsServerInstallerCT = 0
BEGIN
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'System', N'Full', N'Daily', 1, N'22:00:00', N'22:30:00', 1, 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, N'Daily System Backups')
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'User', N'Full', N'Saturday', 1, N'23:00:00', N'23:30:00', 1, 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, N'Weekly Full Backups')
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'User', N'Diff', N'Weekday', 1, N'23:00:00', N'23:30:00', 1, 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, N'Daily Diff Backups')
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'User', N'Diff', N'Sunday', 1, N'23:00:00', N'23:30:00', 1, 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, N'Sunday Diff Backups')
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'User', N'Log', N'Daily', 1, N'00:00:00', N'23:59:00', 300, 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, N'Log Backups Multi-day')
	INSERT [Minion].[BackupSettingsServer] ([DBType], [BackupType], [Day], [ReadOnly], [BeginTime], [EndTime], [MaxForTimeframe], [CurrentNumBackups], [NumConcurrentBackups], [LastRunDateTime], [Include], [Exclude], [SyncSettings], [SyncLogs], [BatchPreCode], [BatchPostCode], [IsActive], [Comment]) 
	VALUES (N'User', N'Diff', N'Daily', 1, N'05:00:00', N'05:30:00', 1, 0, NULL, NULL, 'Missing', NULL, 0, 0, NULL, NULL, 0, N'Missing Backups')
END




DECLARE @BackupRestoreSettingsPathCT INT;
SET @BackupRestoreSettingsPathCT = (SELECT COUNT(*) FROM Minion.BackupRestoreSettingsPath)
IF @BackupRestoreSettingsPathCT = 0
BEGIN
INSERT INTO [Minion].[BackupRestoreSettingsPath]
(DBName, ServerName, RestoreType, FileType, TypeName, RestoreDrive, RestorePath, RestoreFileName, RestoreFileExtension, BackupLocation, RestoreDBName, ServerLabel, PathOrder, IsActive, Comment)
VALUES
('MinionDefault', 'localhost', 'Full', 'FileType', 'All', 'C:\', 'MyDBs\CheckDBRestores\', 'MinionDefault', 'MinionDefault', 'Backup', '%DBName%', NULL, 0, 1, NULL )
END


