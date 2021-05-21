
DECLARE @ThresholdValue INT,
		@HistRetDays INT,
		@DefaultSchema NVARCHAR(200),
		@ResultMode VARCHAR(50);

SET @ThresholdValue = 100;
SET @HistRetDays = 60;
SET @DefaultSchema = 'dbo';
SET @ResultMode = 'Full';

DECLARE @CheckDBSettingsAutoThresholdsCT INT;
SET @CheckDBSettingsAutoThresholdsCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsAutoThresholds)
IF @CheckDBSettingsAutoThresholdsCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSettingsAutoThresholds]
	(DBName, ThresholdMethod, ThresholdType, ThresholdMeasure, ThresholdValue, IsActive, Comment)
	VALUES
	('MinionDefault', 'Size', 'DataAndIndex', 'GB', @ThresholdValue, 1, 'MINION DEFAULT. DO NOT REMOVE.')
END

DECLARE @CheckDBSettingsDBCT INT;
SET @CheckDBSettingsDBCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsDB)
IF @CheckDBSettingsDBCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSettingsDB]
	(DBName, Port, OpLevel, OpName, Exclude, GroupOrder, GroupDBOrder, NoIndex, RepairOption, RepairOptionAgree, WithRollback, AllErrorMsgs, ExtendedLogicalChecks, NoInfoMsgs, IsTabLock, IntegrityCheckLevel, DisableDOP, IsRemote, IncludeRemoteInTimeLimit, PreferredServer, PreferredServerPort, PreferredDBName, RemoteJobName, RemoteCheckDBMode, RemoteRestoreMode, DropRemoteDB, DropRemoteJob, LockDBMode, ResultMode, HistRetDays, PushToMinion, MinionTriggerPath, AutoRepair, AutoRepairTime, DefaultSchema, DBPreCode, DBPostCode, TablePreCode, TablePostCode, DBInternalThreads, DefaultTimeEstimateMins, LogSkips, BeginTime, EndTime, DayOfWeek, IsActive, Comment)
	VALUES
	(N'MinionDefault', NULL, 'DB', 'CHECKDB', 0, 0, 0, 0, 'NONE', 0, NULL, 1, 0, 0, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @ResultMode, @HistRetDays, NULL, NULL, NULL, NULL, @DefaultSchema, NULL, NULL, NULL, NULL, 1, NULL, 1, '00:00:00', '23:59:00', 'Daily', 1, 'MinionDefault.  DO NOT REMOVE.' ), 
	(N'MinionDefault', NULL, 'DB', 'CHECKTABLE', 0, 0, 0, 0, 'NONE', 0, NULL, 1, 0, 0, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @ResultMode, @HistRetDays, NULL, NULL, NULL, NULL, @DefaultSchema, NULL, NULL, NULL, NULL, 1, NULL, 1, '00:00:00', '23:59:00', 'Daily', 1, 'MinionDefault.  DO NOT REMOVE.' )
END

DECLARE @CheckDBSettingsRotationCT INT;
SET @CheckDBSettingsRotationCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsRotation)
IF @CheckDBSettingsRotationCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSettingsRotation]
	(DBName, OpName, RotationLimiter, RotationLimiterMetric, RotationMetricValue, RotationPeriodInDays, IsActive, Comment)
	VALUES
	('MinionDefault', 'CHECKDB', 'DBCount', 'count', 10, NULL, 0, 'Default count limiter, 10 DBs every night.' ), 
	('MinionDefault', 'CHECKDB', 'Time', 'Mins', 60, NULL, 0, 'Default time limiter, 60 mins of CHECKDB every night.' ), 
	('MinionDefault', 'CHECKTABLE', 'TableCount', 'count', 100, NULL, 0, 'Default limiter, 100 tables every night.' ), 
	('MinionDefault', 'CHECKTABLE', 'Time', 'Mins', 60, NULL, 0, 'Default time limiter, 60 mins of CHECKTABLE every night.' )
END

DECLARE @CheckDBSettingsSnapshotCT INT;
SET @CheckDBSettingsSnapshotCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsSnapshot)
IF @CheckDBSettingsSnapshotCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSettingsSnapshot]
	(DBName, OpName, CustomSnapshot, SnapshotRetMins, SnapshotRetDeviation, DeleteFinalSnapshot, SnapshotFailAction, BeginTime, EndTime, DayOfWeek, IsActive, Comment)
	VALUES
	('MinionDefault', 'CHECKTABLE', 0, 0, NULL, 0, NULL, NULL, NULL, NULL, 1, 'MinionDefault custom snapshot settings for CHECKDB.' ), 
	('MinionDefault', 'CHECKDB', 0, 0, NULL, 0, NULL, NULL, NULL, NULL, 1, 'MinionDefault custom snapshot settings for CHECKTABLE.' )
END

DECLARE @CheckDBSettingsServerCT INT;
SET @CheckDBSettingsServerCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsServer)
IF @CheckDBSettingsServerCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSettingsServer]
	(DBType, OpName, Day, ReadOnly, BeginTime, EndTime, MaxForTimeframe, FrequencyMins, CurrentNumOps, NumConcurrentOps, DBInternalThreads, TimeLimitInMins, LastRunDateTime, Include, Exclude, Schemas, Tables, BatchPreCode, BatchPostCode, Debug, FailJobOnError, FailJobOnWarning, IsActive, Comment)
	VALUES
	('System', 'CHECKDB', 'Daily', 1, '22:00:00', '22:30:00', 1, NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 1, NULL ),
	('User', 'CHECKDB', 'Saturday', 1, '23:00:00', '23:30:00', 1, NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 1, NULL ), 
	('User', 'AUTO', 'Saturday', 1, '23:00:00', '23:30:00', 1, NULL, 0, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, NULL ) 
END

DECLARE @CheckDBSnapshotPathCT INT;
SET @CheckDBSnapshotPathCT = (SELECT COUNT(*) FROM Minion.CheckDBSnapshotPath)
IF @CheckDBSnapshotPathCT = 0
BEGIN
	INSERT INTO [Minion].[CheckDBSnapshotPath]
	([DBName], [OpName], [FileName], [SnapshotDrive], [SnapshotPath], [ServerLabel], [PathOrder], [IsActive], [Comment])
	VALUES
	(N'MinionDefault', 'CHECKTABLE', 'MinionDefault', 'C:\', 'SnapshotCheckTable\', NULL, 0, 1, 'MinionDefault' ), 
	(N'MinionDefault', 'CHECKDB', 'MinionDefault', 'C:\', 'SnapshotCheckDB\', NULL, 0, 1, 'MinionDefault' )
END


DECLARE @CheckDBSettingsRemoteThresholdsCT INT;
SET @CheckDBSettingsRemoteThresholdsCT = (SELECT COUNT(*) FROM Minion.CheckDBSettingsRemoteThresholds)
IF @CheckDBSettingsRemoteThresholdsCT = 0
BEGIN
INSERT INTO Minion.CheckDBSettingsRemoteThresholds (DBName, ThresholdType, ThresholdMeasure, ThresholdValue, IsActive, Comment)
VALUES
( N'MinionDefault', 'DataAndIndex', 'GB', 100, 0, 'MINION DEFAULT. DO NOT REMOVE.')
END



