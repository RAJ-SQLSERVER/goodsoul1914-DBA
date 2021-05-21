set nocount on;
go

DECLARE @Module varchar(100) = 'Backup';
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- HELP Tables and Data --------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

/*

This is the process, including data, for the intaller script:
	Process of loading HELP to a new Minion Reinstall installation:
	
	1. Delete any old module rows from Minion.HelpObjectDetail 
	2. Delete any old module rows from Minion.HelpObjects 
	3. Load all HELP data to temp tables (#HelpObjects and #HelpObjectDetails)
	4. Insert all HelpObjects
	5. Update #HelpObjects and #HelpObjectDetails with the new object IDs from Minion.HelpObjects
	6. Insert all HelpObjectDetail rows
	7. Cleanup

*/

--&--------------------------------------------
-- 1. delete any old module rows from Minion.HelpObjectDetail 
DELETE  FROM Minion.HELPObjectDetail
FROM    Minion.HELPObjects AS O
WHERE   ObjectID = O.ID
        AND O.Module = @Module;


--&--------------------------------------------
-- 2. delete any old module rows from Minion.HelpObjects 
DELETE  Minion.HELPObjects
WHERE   Module = @Module;



--&--------------------------------------------
-- 3. Load all HELP data to temp tables (#HelpObjects and #HelpObjectDetails)
IF OBJECT_ID('tempdb..#HelpObjects') IS NOT NULL
BEGIN
	DROP TABLE #HelpObjects;
END

IF OBJECT_ID('tempdb..#HelpObjectDetail') IS NOT NULL
BEGIN
	DROP TABLE #HelpObjectDetail;
END

CREATE TABLE #HelpObjects
    (
      [ID] [INT] NOT NULL ,
      [Module] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL ,
      [ObjectName] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [ObjectType] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [MinionVersion] [FLOAT] NULL ,
      [GlobalPosition] [INT] NULL ,
      NewObjectID INT NULL
    );

CREATE TABLE #HelpObjectDetail
    (
      [ObjectID] [INT] NULL ,
      [DetailName] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [Position] [SMALLINT] NULL ,
      [DetailType] [sysname] COLLATE DATABASE_DEFAULT NULL ,
      [DetailHeader] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [DetailText] [VARCHAR](MAX) COLLATE DATABASE_DEFAULT NULL ,
      [Datatype] [VARCHAR](20) COLLATE DATABASE_DEFAULT NULL ,
      updated BIT NULL
    );

--------------------------------
---- BEGIN: INSERTS GO HERE ----
 --------------------------------

--1.4--
--INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
--SELECT 159 AS [ID], 'Backup' AS [Module], 'What’s new in MB 1.3' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 5 AS [GlobalPosition];

INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 159 AS [ID], 'Backup' AS [Module], 'What’s new in MB 1.4' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 5 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 1 AS [ID], 'Backup' AS [Module], 'Quick Start' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 10 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 2 AS [ID], 'Backup' AS [Module], 'Top 20 Features' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 20 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 3 AS [ID], 'Backup' AS [Module], 'Architecture Overview' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 30 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 4 AS [ID], 'Backup' AS [Module], 'How To: Configure settings for a single database' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 40 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 5 AS [ID], 'Backup' AS [Module], 'How To: Configure settings for all databases' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 50 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 6 AS [ID], 'Backup' AS [Module], 'How To: Back up databases in a specific order' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 60 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 7 AS [ID], 'Backup' AS [Module], 'How To: Change backup schedules' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 70 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 8 AS [ID], 'Backup' AS [Module], 'How To: Generate back up statements only' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 80 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 9 AS [ID], 'Backup' AS [Module], 'How To: Back up only databases that are not marked READ_ONLY' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 90 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 10 AS [ID], 'Backup' AS [Module], 'How To: Include databases in backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 100 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 11 AS [ID], 'Backup' AS [Module], 'How To: Exclude databases from backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 110 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 12 AS [ID], 'Backup' AS [Module], 'How To: Run code before or after backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 120 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 13 AS [ID], 'Backup' AS [Module], 'How To: Configure backup file retention' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 130 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 14 AS [ID], 'Backup' AS [Module], 'How to: Set up mirror backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 140 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 15 AS [ID], 'Backup' AS [Module], 'How to: Copy files after backup (single and multiple locations)' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 150 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 16 AS [ID], 'Backup' AS [Module], 'How to: Move files to a location after backup' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 160 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 17 AS [ID], 'Backup' AS [Module], 'How to: Copy and move backup files' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 170 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 18 AS [ID], 'Backup' AS [Module], 'How to: Back up to multiple files in a single location' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 180 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 19 AS [ID], 'Backup' AS [Module], 'How to: Back up to multiple locations' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 190 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 20 AS [ID], 'Backup' AS [Module], 'How to: Install Minion Backup across multiple instances' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 200 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 21 AS [ID], 'Backup' AS [Module], 'How to: Shrink log files after log backup' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 210 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 22 AS [ID], 'Backup' AS [Module], 'How to: Configure certificate backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 220 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 23 AS [ID], 'Backup' AS [Module], 'How to: Encrypt backups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 230 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 24 AS [ID], 'Backup' AS [Module], 'How to: Synchronize backup settings and logs among instances' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 240 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 25 AS [ID], 'Backup' AS [Module], 'How to: Set up backups on Availability Groups' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 250 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 26 AS [ID], 'Backup' AS [Module], 'How to: Set up dynamic backup tuning thresholds' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 270 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 300 AS [ID], 'Backup' AS [Module], 'How To: Restore to Another Server' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 272 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 27 AS [ID], 'Backup' AS [Module], 'Overview of Tables' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 280 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 28 AS [ID], 'Backup' AS [Module], 'Minion.BackupCert' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 290 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 29 AS [ID], 'Backup' AS [Module], 'Minion.BackupEncryption' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 300 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 251 AS [ID], 'Backup' AS [Module], 'Minion.BackupRestoreSettingsPath' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 303 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 252 AS [ID], 'Backup' AS [Module], 'Minion.BackupRestoreTuningThresholds' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 307 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 30 AS [ID], 'Backup' AS [Module], 'Minion.BackupSettings' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 310 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 31 AS [ID], 'Backup' AS [Module], 'Minion.BackupSettingsPath' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 320 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 32 AS [ID], 'Backup' AS [Module], 'Minion.BackupSettingsServer' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 330 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 33 AS [ID], 'Backup' AS [Module], 'Minion.BackupTuningThresholds' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 340 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 255 AS [ID], 'Backup' AS [Module], 'Minion.DBMaintDBGroups' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 342 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 253 AS [ID], 'Backup' AS [Module], 'Minion.DBMaintInlineTokens' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 343 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 34 AS [ID], 'Backup' AS [Module], 'Minion.DBMaintRegexLookup' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 345 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 35 AS [ID], 'Backup' AS [Module], 'Minion.SyncServer' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 350 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 36 AS [ID], 'Backup' AS [Module], 'Minion.BackupDebug' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 360 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 37 AS [ID], 'Backup' AS [Module], 'Minion.BackupDebugLogDetails' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 370 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 256 AS [ID], 'Backup' AS [Module], 'Minion.BackupRestoreFileListOnlyTemp' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 375 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 257 AS [ID], 'Backup' AS [Module], 'Minion.DBMaintDBSizeTemp' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 376 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 38 AS [ID], 'Backup' AS [Module], 'Minion.BackupFileListOnly' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 380 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 39 AS [ID], 'Backup' AS [Module], 'Minion.BackupFiles' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 390 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 40 AS [ID], 'Backup' AS [Module], 'Minion.BackupHeaderOnlyWork' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 395 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 41 AS [ID], 'Backup' AS [Module], 'Minion.BackupLog' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 400 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 42 AS [ID], 'Backup' AS [Module], 'Minion.BackupLogDetails' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 410 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 43 AS [ID], 'Backup' AS [Module], 'Minion.SyncCmds' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 420 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 44 AS [ID], 'Backup' AS [Module], 'Minion.SyncErrorCmds' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 430 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 45 AS [ID], 'Backup' AS [Module], 'Minion.Work' AS [ObjectName], 'Table' AS [ObjectType], 1.4 AS [MinionVersion], 440 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 258 AS [ID], 'Backup' AS [Module], 'Overview of Views' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 444 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 46 AS [ID], 'Backup' AS [Module], 'Overview of Procedures' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 450 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 47 AS [ID], 'Backup' AS [Module], 'Minion.BackupDB' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 460 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 48 AS [ID], 'Backup' AS [Module], 'Minion.BackupFileAction' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 470 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 49 AS [ID], 'Backup' AS [Module], 'Minion.BackupFilesDelete' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 480 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 50 AS [ID], 'Backup' AS [Module], 'Minion.BackupMaster' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 490 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 51 AS [ID], 'Backup' AS [Module], 'Minion.BackupRestoreDB' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 495 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 52 AS [ID], 'Backup' AS [Module], 'Minion.BackupSyncLogs' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 500 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 53 AS [ID], 'Backup' AS [Module], 'Minion.BackupSyncSettings' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 510 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 54 AS [ID], 'Backup' AS [Module], 'Minion.BackupStatusMonitor' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 530 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 55 AS [ID], 'Backup' AS [Module], 'Minion.BackupStmtGet' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 540 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 56 AS [ID], 'Backup' AS [Module], 'Minion.CloneSettings' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 550 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 57 AS [ID], 'Backup' AS [Module], 'Minion.HELP' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 560 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 58 AS [ID], 'Backup' AS [Module], 'Minion.SyncPush' AS [ObjectName], 'Procedure' AS [ObjectType], 1.4 AS [MinionVersion], 565 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 59 AS [ID], 'Backup' AS [Module], 'Overview of Jobs' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 570 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 60 AS [ID], 'Backup' AS [Module], 'About: Backup Schedules' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 580 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 61 AS [ID], 'Backup' AS [Module], 'About: Backup file retention' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 590 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 62 AS [ID], 'Backup' AS [Module], 'About: Synchronizing settings and log data with the Data Waiter' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 600 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 63 AS [ID], 'Backup' AS [Module], 'About: Dynamic Backup Tuning Thresholds' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 605 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 64 AS [ID], 'Backup' AS [Module], 'About: Backing up to NUL' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 606 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 65 AS [ID], 'Backup' AS [Module], 'Revisions' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 608 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 66 AS [ID], 'Backup' AS [Module], 'FAQ' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 610 AS [GlobalPosition];

GO
INSERT INTO #HelpObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
SELECT 67 AS [ID], 'Backup' AS [Module], 'About Us' AS [ObjectName], 'Information' AS [ObjectType], 1.4 AS [MinionVersion], 620 AS [GlobalPosition];

GO
--1.4--
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 159 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, '     * Added delete for SyncCmds
     * Fixed: Creating "Christmas tree folders" when using robocopy with multiple files.
     * Fixed: Missing a couple entries in the InlineTokens table.
     * Fixed: Some sync commands being written to SyncCmds table even though SyncLogs is 0.
     * Fixed: Wasn’t logging properly when a DB is in an AG.
     * Fixed: Formatting issues in Minion.HELP.
	 * Fixed: Wrong restore location when restoring to a named instance and the path is being converted from a local drive.  The instance name was being included in the UNC path.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 256 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table is for internal use only. Do not modify in any way.
Note that this table is shared between Minion modules.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 257 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table is for internal use only. Do not modify in any way.
Note that this table is shared between Minion modules.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 258 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Minion Backup comes with three views:
  * Minion.BackupFilesCurrent – Provides the most recent batch of backup file information.
  * Minion.BackupLogCurrent – Provides the most recent batch of backup operations.
  * Minion.BackupLogDetailsCurrent –  Provides the most recent batch of backup operations (at the detail level).' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table stores the path settings for restore scenarios. In other words, here is where you define the paths and file names the system will restore to. 

This table comes with a default row, with DBName = ‘MinionDefault’ and Servername = ‘localhost’. This enables you to generate restore statements without any additional configuration, and gives an exmple of restore path configuration.

Note: The only valid restore type in Minion.BackupRestoreSettingsPath is ‘Full’, because only a restore of a full backup requires path information.

For more information, see “How to: Set up Restore Profiles”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table holds the thresholds used to determine the tuning of a restore. 

The principles for tuning restores are exactly the same as those for tuning backups. We have chosen, therefore, not to duplicate tuning documentation for both backup and restore. Refer to the sections “About: Dynamic Backup Tuning Thresholds” and “How to: Set up dynamic backup tuning thresholds”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
--1.4--
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 5 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Minion CheckDB 1.0 and MinionBackup 1.3 introduced a new feature to the Minion suite – Inline Tokens.  Inline Tokens allow you use defined patterns to create dynamic names and paths. For example, MB comes with the predefined Inline Token “Server” and “DBName”. To create a dynamic backup path for all backups, we update the path table: 
 UPDATE Minion.BackupSettingsPath
 SET    BackupPath = ''SQLBackups\%Server%\%DBName%\'';

MB recognizes %Server% and %DBName% as Inline Tokens, and refers to the Minion.DBMaintInlineTokens table for the definition. Note that custom tokens must be used with pipe delimiters, instead of percent signs: ‘|MyCustomToken|’.

For more information, see “About: Inline Tokens”.

Note that this table is shared between Minion modules.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 10 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 12 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Run code before or after backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 14 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Set up mirror backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 15 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Copy files after backup (single and multiple locations)' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 16 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Move files to a location after backup' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 17 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Copy and move backup files' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 18 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Back up to multiple files in a single location' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 19 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Back up to multiple locations' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 20 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Install Minion Backup across multiple instances' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 21 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Shrink log files after log backup' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 22 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Configure certificate backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 13 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Configure backup file retention' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 24 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Synchronize backup settings and logs among instances' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 25 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Set up backups on Availability Groups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 26 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Set up dynamic backup tuning thresholds' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 300 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Restore to Another Server' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 10 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 10 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'Quick Start' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 2 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'Top 20 Features' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'Architecture Overview' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 4 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Configure settings for a single database' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 5 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Configure settings for all databases' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 6 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Back up databases in a specific order' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 7 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Change backup schedules' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 8 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Generate back up statements only' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 9 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Back up only databases that are not marked READ_ONLY' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 10 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Include databases in backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 11 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How To: Exclude databases from backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 23 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'How to: Encrypt backups' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 27 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 10 AS [Position]
	, 'ObjectName' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'Overview of Tables' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 40 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 10 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Minion.BackupHeaderOnlyWork' AS [DetailHeader]
	, 'This table is for internal use only. Do not modify in any way.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 10 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, '	Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'Action' AS [DetailName]
	, 15 AS [Position]
	, 'Column' AS [DetailType]
	, 'Action' AS [DetailHeader]
	, 'The action that this group applies to. Databases can be a part of a named “Include” group, or a named “Exclude” group. 

For more information, see the example below. 

Valid values:
Include
Exclude' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Contains records of backup operations.  It contains one time-stamped row for each run of Minion.BackupMaster, which may encompass several database backup operations. This table stores status information for the overall backup operation.  This information can help with troubleshooting, or just information gathering when you want to see what has happened between one backup run to the next.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 18 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup allows you to back up to multiple files.  You can configure multi-file backups in just two steps: 
  1. Configure the number of backup files in the Minion.BackupTuningThresholds table.
  2. Configure the backup location in the Minion.BackupSettingsPath table.

When this is configured, backups will proceed as defined: a database will back up to multiple files.

Let us take the example of backing up the DB1 database to four files, for full backups and differential backups.

First, configure the number of backup files in Minion.BackupTuningThresholds. Log backups in this example will be backed up to one file, while full and differential backups will be backed up to four. We can configure this with two rows – one for BackupType=Log and NumberOfFiles=1, and one for BackupType=All and NumberOfFiles=4: 
INSERT  INTO Minion.BackupTuningThresholds
        ( [DBName] ,
          [BackupType] ,
          [SpaceType] ,
          [ThresholdMeasure] ,
          [ThresholdValue] ,
          [NumberOfFiles] ,
          [Buffercount] ,
          [MaxTransferSize] ,
          [Compression] ,
          [BlockSize] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        ''DataAndIndex'' AS [SpaceType] ,
        ''GB'' AS [ThresholdMeasure] ,
        0 AS [ThresholdValue] ,
        4 AS [NumberOfFiles] ,
        0 AS [Buffercount] ,
        0 AS [MaxTransferSize] ,
        NULL AS [Compression] ,
        0 AS [BlockSize] ,
        1 AS [IsActive] ,
        ''DB1 full and differential.'' AS [Comment];

INSERT  INTO Minion.BackupTuningThresholds
        ( [DBName] ,
          [BackupType] ,
          [SpaceType] ,
          [ThresholdMeasure] ,
          [ThresholdValue] ,
          [NumberOfFiles] ,
          [Buffercount] ,
          [MaxTransferSize] ,
          [Compression] ,
          [BlockSize] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        ''Log'' AS [BackupType] ,
        ''DataAndIndex'' AS [SpaceType] ,
        ''GB'' AS [ThresholdMeasure] ,
        0 AS [ThresholdValue] ,
        1 AS [NumberOfFiles] ,
        0 AS [Buffercount] ,
        0 AS [MaxTransferSize] ,
        NULL AS [Compression] ,
        0 AS [BlockSize] ,
        1 AS [IsActive] ,
        ''DB1 log.'' AS [Comment];

Note that the code above omits BeginTime, EndTime, and DayOfWeek. These fields are optional; they may be used to limit the days and times at which the threshold in question applies. As we want these new threshold settings to apply at all time, we can comfortably leave these three fields NULL.

Next, configure the backup location. Determine whether the default location in Minion.BackupSettingsPath (as configured in the row where DBName=’MinionDefault’ and BackupType=’All’) is correct for your backups. For this example, we will say that the default location is not correct. So, we will insert a new row to configure the new path: 
INSERT  INTO Minion.BackupSettingsPath
        ( [DBName] ,
          [IsMirror] ,
          [BackupType] ,
          [BackupLocType] ,
          [BackupDrive] ,
          [BackupPath] ,
          [ServerLabel] ,
          [RetHrs] ,
          [FileActionMethod] ,
          [FileActionMethodFlags] ,
          [PathOrder] ,
          [IsActive] ,
          [AzureCredential] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        0 AS [IsMirror] ,
        ''All'' AS [BackupType] ,
        ''Local'' AS [BackupLocType] ,
        ''E:\'' AS [BackupDrive] ,
        ''SQLBackups\'' AS [BackupPath] ,
        NULL AS [ServerLabel] ,
        24 AS [RetHrs] ,
        NULL AS [FileActionMethod] ,
        NULL AS [FileActionMethodFlags] ,
        0 AS [PathOrder] ,
        1 AS [IsActive] ,
        NULL AS [AzureCredential] ,
        ''DB1 location.'' AS [Comment];

Once the files and paths are configured, the DB1 backups will be placed as follows: 
  * DB1 full (or differential) backups will stripe to four files on the DB1 location. 
  * DB1 log backups have only one file defined, so Minion Backup backs up the DB1 log to one file on the DB1 location. 

The use of the Minion.BackupTuningThresholds table is detailed much more thoroughly in the “How to: Set up dynamic backup tuning thresholds” section, and in the “Minion.BackupTuningThresholds” section.

And for more information on backup paths, see “Minion.BackupSettingsPath”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table allows you to configure which types of certificates to back up, and the password to use when backing them up.  As far as Minion Backup is concerned, there are only two types of certificates: ServerCert, and DatabaseCert. So, this table will only ever have two rows: one for server certificates, and one for database certificates.

Certificates that are enabled and configured for backups, are automatically backed up with every full backup.  For more information on enabling and configuring certificate backups, see the “How to: Configure certificate backups” section.

Note: The certificate backup password is stored encrypted. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Contains records of individual backup operations.  It contains one time-stamped row for each individual database backup operation.  This table stores the parameters and settings that were used during the operation, as well as status information.  This information can help with troubleshooting, or just information gathering when you want to see what has happened between one backup run to the next.  

Note: Several of the columns in this table are from the output of Trace Flag 3213; you can read more about this trace flag at http://blogs.msdn.com/b/psssql/archive/2008/01/28/how-it-works-sql-server-backup-buffer-exchange-a-vdi-focus.aspx' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 14 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'SQL Server Enterprise edition allows you to back up to two locations simultaneously: the primary location and the mirror location. This is not the same as striping a backup (where a single backup media set is placed across several locations); a mirrored backup creates two independent backup media sets.

To configure mirrored backups: 
  * Enable mirrored backups in Minion.BackupSettings, using the Mirror field. 
  * Configure a backup mirror path in Minion.BackupSettingsPath, being sure to set isMirror = 1.

For example, to mirror full backups for database DB8, first enable mirrored backups for that database and backup type. We will insert one row for DB8, BackupType=Full; and one row for DB8, BackupType=All, to provide settings for DB8 diff and log backups (as explained in “The Configuration Settings Hierarchy Rule”.) 

-- DB8 BackupType=''All'', to cover log and differential settings.
INSERT	INTO Minion.BackupSettings
		( [DBName] ,
		  [Port] ,
		  [BackupType] ,
		  [Exclude] ,
		  [GroupOrder] ,
		  [GroupDBOrder] ,
		  [Mirror] ,
		  [DelFileBefore] ,
		  [DelFileBeforeAgree] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [DynamicTuning] ,
		  [Verify] ,
		  [ShrinkLogOnLogBackup] ,
		  [MinSizeForDiffInGB] ,
		  [DiffReplaceAction] ,
		  [Encrypt] ,
		  [Checksum] ,
		  [Init] ,
		  [Format] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB8'' AS [DBName] ,
	NULL AS [Port] ,
	''All'' AS [BackupType] ,
	0 AS [Exclude] ,
	50 AS [GroupOrder] ,
	0 AS [GroupDBOrder] ,
	0 AS [Mirror] , 	-- Disable mirrored log/diff backups for DB8
	0 AS [DelFileBefore] ,
	0 AS [DelFileBeforeAgree] ,
	''Local'' AS [LogLoc] ,
	90 AS [HistRetDays] ,
	1 AS [DynamicTuning] ,
	''0'' AS [Verify] ,
	1 AS [ShrinkLogOnLogBackup] ,
	20 AS [MinSizeForDiffInGB] ,
	''Log'' AS [DiffReplaceAction] ,
	0 AS [Encrypt] ,
	1 AS [Checksum] ,
	1 AS [Init] ,
	1 AS [Format] ,
	1 AS [IsActive] ,
	NULL AS [Comment];

-- DB8 BackupType=''Full''; enable full mirrored backups.
INSERT	INTO Minion.BackupSettings
		( [DBName] ,
		  [Port] ,
		  [BackupType] ,
		  [Exclude] ,
		  [GroupOrder] ,
		  [GroupDBOrder] ,
		  [Mirror] ,
		  [DelFileBefore] ,
		  [DelFileBeforeAgree] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [DynamicTuning] ,
		  [Verify] ,
		  [ShrinkLogOnLogBackup] ,
		  [MinSizeForDiffInGB] ,
		  [DiffReplaceAction] ,
		  [Encrypt] ,
		  [Checksum] ,
		  [Init] ,
		  [Format] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB8'' AS [DBName] ,
	NULL AS [Port] ,
	''Full'' AS [BackupType] ,
	0 AS [Exclude] ,
	50 AS [GroupOrder] ,
	0 AS [GroupDBOrder] ,
	1 AS [Mirror] ,	-- Enable mirrored full backups for DB8 
	0 AS [DelFileBefore] ,
	0 AS [DelFileBeforeAgree] ,
	''Local'' AS [LogLoc] ,
	90 AS [HistRetDays] ,
	1 AS [DynamicTuning] ,
	''0'' AS [Verify] ,
	1 AS [ShrinkLogOnLogBackup] ,
	20 AS [MinSizeForDiffInGB] ,
	''Log'' AS [DiffReplaceAction] ,
	0 AS [Encrypt] ,
	1 AS [Checksum] ,
	1 AS [Init] ,
	1 AS [Format] ,
	1 AS [IsActive] ,
	NULL AS [Comment];

Next, we configure a primary backup path in Minion.BackupSettingsPath for DB8. For this particular server, we would like all mirrored backups to go to “M:\SQLMirrorBackups\”. So, we can simply implement a new MinionDefault row where isMirror=1:
INSERT  INTO Minion.BackupSettingsPath
                ( [DBName] ,
                  [IsMirror] ,
                  [BackupType] ,
                  [BackupLocType] ,
                  [BackupDrive] ,
                  [BackupPath] ,
                  [ServerLabel] ,
                  [RetHrs] ,
                  [PathOrder] ,
                  [IsActive] ,
                  [AzureCredential] ,
                  [Comment]
                )
        SELECT  ''MinionDefault'' AS [DBName] ,
                1 AS [IsMirror] ,
                ''All'' AS [BackupType] ,
                ''Local'' AS [BackupLocType] ,
                ''M:\'' AS [BackupDrive] ,
                ''SQLMirrorBackups\'' AS [BackupPath] ,
                NULL AS [ServerLabel] ,
                24 AS [RetHrs] ,
                0 AS [PathOrder] ,
                1 AS [IsActive] ,
                NULL AS [AzureCredential] ,
                ''MinionDefault mirror row.'' AS [Comment]; 

Note: If we did not want all mirrored backups going to the same location, we could just as easily have defined the Minion.BackupSettingsPath with DBName=’DB1’.

Once these two steps are done, all full backups for DB8 will be mirrored backups, with the mirror backup files going to M:\SQLMirrorBackups\. Minion Backup will manage these mirrored backup files just like the primary files, deleting them once they have exceeded the retention period.

IMPORTANT: Mirrored backups are only supported in SQL Server Enterprise edition.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 15 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'As part of your backup routine, you can choose to copy your backup files to multiple locations, move your backup files to a location, or both.  This section will walk you through the steps of setting up file copy operations. For more information, see the section “About: Copy and move backup files”.

Note: Currently, Minion Backup can''t copy or move files to or from Microsoft Azure Blobs.  However, you can do a primary backup to an Azure Blob.

The basic steps to configure copy operations for backup files are: 
  1. Set the FileAction and FileActionTime fields in Minion.BackupSettings, for the appropriate database(s) and backup type(s). 
  
  2. Insert one row per operation into the Minion.BackupSettingsPath table. 

Note: If you specify one database-specific setting in the Minion.BackupSettings table, you must be sure that all backup types are covered for that database. For example: one row for Full backups, and one row with BackupType=’All’ to cover differential and log backups. The same rule exists for Minion.BackupSettingsPath. For more information, see the FAQ section “Why must I supply values for all backup types for a database in the settings tables?”

So for example, we can configure Minion Backup to copy the YourDatabase full backup file to two secondary locations. First, set the FileAction and FileActionTime fields in Minion.BackupSettings, for the appropriate database(s) and backup type(s):
  1. Insert a row for YourDatabase into Minion.BackupSettings, in order to enable the file action (“COPY”) and file action time (in this example, “AfterBatch”). Settings for the “YourDatabase” full backup row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Full’
     c. FileAction = ‘Copy’
     d. FileActionTime = ‘AfterBatch’

  2. Insert a BackupType=’All’ row into the Minion.BackupSettings table, to cover differential and log backup operations. As we don’t wish to copy log or differential backups in this example, the settings for this row (DBName= “YourDatabase”, BackupType=”All”) should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘All’
     c. FileAction = NULL
     d. FileActionTime = NULL

Note: The simplest way to insert a row to a table is to use the Minion.CloneSettings  procedure to generate an insert statement for that table, modify the statement to reflect the proper database and specifications, and run it.

So, the contents of the Minion.BackupSettings table would look like this (some columns omitted for brevity):
DBName        BackupType FileAction FileActionTime Comment
MinionDefault All        NULL       NULL           Minion default. DO NOT REMOVE.
YourDatabase  Full       Copy       AfterBatch     YourDatabase database full backup.
YourDatabase  All        NULL       NULL           YourDatabase database - all backups.

Second, insert one row per operation into the Minion.BackupSettingsPath table:
  1. Insert a BackupType=’Full’ row into the Minion.BackupSettingsPath table, for the full backup operation. Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Full’
     c. BackupDrive = the name of your backup drive (e.g., ‘C:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘SQLBackups\’)
     e. FileActionMethod=NULL

  2. Insert a BackupType=’All’ row into the Minion.BackupSettingsPath table, to cover differential and log backup operations. (The reason for this is, whenever you specify a database-specific setting in Minion.BackupSettingsPath, all three basic backup types must be represented, one way or another.)  Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘All’
     c. BackupDrive = the name of your backup drive (e.g., ‘C:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘SQLBackups\’)
     e. FileActionMethod=NULL

  3. Insert a BackupType=’Copy’ row into the Minion.BackupSettingsPath table, for the first copy operation. Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Copy’
     c. BackupDrive = the name of your first copy drive (e.g., ‘F:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘BackupCopies\’)
     e. FileActionMethod=’XCOPY’ (Optional: see the note below for information about this field).

  4. Insert a BackupType=’Copy’ row into the Minion.BackupSettingsPath table, for the second copy operation. Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Copy’
     c. BackupDrive = the name of your first copy drive (e.g., ‘Y:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘MoreBackupCopies\’)
     e. FileActionMethod=’XCOPY’ (Optional: see the note below for information about this field).

Note: Minion Backup lets you choose what program you use to do your file copy and move operations. So, the FileActionMethod field in Minion.BackupSettings has several valid inputs: NULL (same as COPY), COPY, MOVE,  XCOPY, ROBOCOPY, ESEUTIL.  Note that “COPY” and “MOVE” use PowerShell COPY or MOVE commands as needed.  

So the contents of the Minion.BackupSettingsPath table would look like this (some columns omitted for brevity):

DBName        BackupType BackupDrive BackupPath        FileActionMethod Comment
MinionDefault All        C:\         SQLBackups\       NULL             Minion default. DO NOT REMOVE.
YourDatabase  Full       C:\         SQLBackups\       NULL             YourDatabase database full backup.
YourDatabase  All        C:\         SQLBackups\       NULL             YourDatabase database - all backups.
YourDatabase  Copy       F:\         BackupCopies\     XCOPY            YourDatabase database full backup copy #1.
YourDatabase  Copy       Y:\         MoreBackupCopies\ XCOPY            YourDatabase database full backup copy #2.

Note: You can view a log of copy and move operations in the Minion.BackupFiles table.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 16 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'As part of your backup routine, you can choose to copy your backup files to multiple locations, move your backup files to a location, or both.  This section will walk you through the steps of setting up a file move operation. For more information, see the section “About: Copy and move backup files”.

Note: Currently, Minion Backup can''t copy or move files to or from Microsoft Azure Blobs.  However, you can do a primary backup to an Azure Blob.

The basic steps to configure move operations for backup files are: 
1.	Set the FileAction and FileActionTime fields in Minion.BackupSettings, for the appropriate database(s) and backup type(s). 
2.	Insert one row per operation into the Minion.BackupSettingsPath table. 

Note: If you specify one database-specific setting in the Minion.BackupSettings table, you must be sure that all backup types are covered for that database. For example: one row for Full backups, and one row with BackupType=’All’ to cover differential and log backups.  The same rule exists for Minion.BackupSettingsPath. For more information, see the FAQ section “Why must I supply values for all backup types for a database in the settings tables?”

So for example, we can configure Minion Backup to move the YourDatabase full backup file to one secondary location. (You cannot move the backup file to more than one location; after the first move, the file will no longer be in the original location!) First, set the FileAction and FileActionTime fields in Minion.BackupSettings, for the appropriate database(s) and backup type(s):
  1. Insert a row for YourDatabase into Minion.BackupSettings, in order to enable the file action (“MOVE”) and file action time (in this example, “AfterBackup”). Settings for the “YourDatabase” full backup row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Full’
     c. FileAction = ‘Move’
     d. FileActionTime = ‘AfterBackup’
  
  2. Insert a BackupType=’All’ row into the Minion.BackupSettings table, to cover differential and log backup operations. As we don’t wish to move log or differential backups in this example, the settings for this row (DBName= “YourDatabase”, BackupType=”All”) should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘All’
     c. FileAction = NULL
     d. FileActionTime = NULL

Note: The simplest way to insert a row to a table is to use the Minion.CloneSettings  procedure to generate an insert statement for that table, modify the statement to reflect the proper database and specifications, and run it.

So the contents of the Minion.BackupSettings table would look like this (some columns omitted for brevity):

DBName        BackupType FileAction FileActionTime Comment
MinionDefault All        NULL       NULL           Minion default. DO NOT REMOVE.
YourDatabase  Full       Move       AfterBackup    YourDatabase database full backup.
YourDatabase  All        NULL       NULL           YourDatabase database - all backups.

Second, insert one row per operation into the Minion.BackupSettingsPath table:
  1. Insert a BackupType=’Full’ row into the Minion.BackupSettingsPath table, for the full backup operation. Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Full’
     c. BackupDrive = the name of your backup drive (e.g., ‘C:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘SQLBackups\’)
     e. FileActionMethod=NULL
  
  2. Insert a BackupType=’All’ row into the Minion.BackupSettingsPath table, to cover differential and log backup operations. (The reason for this is, whenever you specify a database-specific setting in Minion.BackupSettingsPath, all three basic backup types must be represented, one way or another.)  Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘All’
     c. BackupDrive = the name of your backup drive (e.g., ‘C:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘SQLBackups\’)
     e. FileActionMethod=NULL
  
  3. Insert a BackupType=’Move’ row into the Minion.BackupSettingsPath table, for the move operation. Settings for the “YourDatabase” row should include, in part:
     a. DBName = ‘YourDatabase’
     b. BackupType = ‘Move’
     c. BackupDrive = the name of your first copy drive (e.g., ‘X:\’)
     d. BackupPath = the full backup path, without the drive letter (e.g., ‘MovedBackups\’)
     e. FileActionMethod=’ROBOCOPY’ (Optional: see the note below for information about this field).

Note: Minion Backup lets you choose what program you use to do your file copy and move operations. So, the FileActionMethod field in Minion.BackupSettings has several valid inputs: NULL (same as COPY), COPY, MOVE,  XCOPY, ROBOCOPY, ESEUTIL.  Note that “COPY” and “MOVE” use PowerShell COPY or MOVE commands as needed.  

So, the contents of the Minion.BackupSettingsPath table would look like this (some columns omitted for brevity):

DBName        BackupType BackupDrive BackupPath    FileActionMethod Comment
MinionDefault All        C:\         SQLBackups\   NULL             Minion default. DO NOT REMOVE.
YourDatabase  Full       C:\         SQLBackups\   NULL             YourDatabase database full backup.
YourDatabase  All        C:\         SQLBackups\   NULL             YourDatabase database - all backups.
YourDatabase  Move       X:\         MovedBackups\ ROBOCOPY         YourDatabase database full backup move.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 2 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup by MidnightDBA is a stand-alone database backup module.  Once installed, Minion Backup automatically backs up all online databases on the SQL Server instance, and will incorporate databases as they are added or removed.
Twenty of the very best features of Minion Backup are, in a nutshell:
  1. Live Insight – See what Minion Backup is doing every step of the way.  You can even see the percent complete for each backup as it runs.

  2. Dynamic Backup Tuning – Configure thresholds and backup tuning settings. Minion Backup will adjust the tuning settings based on your thresholds!  Tuning settings can be configured even down to the time of day for maximum control of your resources.

  3. Stripe, mirror, copy, and/or move backup files – Minion Backup provides extensive file action functionality, all without additional jobs.  You even get to choose which utility performs the operations.

  4. Flexible backup file delete and archive – Each database and backup type can have an individual backup file retention setting. And, you can mark certain backup files as “Archived”, thus preventing Minion Backup from deleting them.

  5. Shrink log file on backup – Specify the size threshold for shrinking your log file. Minion Backup logs the before and after log sizes.

  6. Backup certificates – Back up your server and database certificates with secure, encrypted passwords.

  7. Backup ordering – Back up databases in exactly the order you need.

  8. Extensive, useful logging – Use the Minion Backup log for estimating the end of the current backup run, troubleshooting, planning, and reporting.  And errors get reported in the log table instead of in text files.  There’s almost nothing MB doesn’t log.

  9. Run “missing” backups only – Did some of your database backups fail last night?  The “missing” keyword allows you to rerun a backup operation, catching those backups that failed in the last run (for that database type and backup type).  You can even tell MB to check for missing backup automatically.

  10. HA/DR Aware – Our new Data Waiter feature synchronizes backup settings, backup logs, or both among Availability Group nodes; mirroring partners; log ship targets; or any other SQL Server instance.  There are other features that enhance your HA/DR scenarios as well.

  11. Flexible include and exclude – Backup only the databases you want, using specific database names, LIKE expressions, and even regular expressions.

  12. Run code before or after backups – This is an extraordinarily flexible feature that allows for nearly infinite configurability.

  13. Integrated help – Get help on any Minion Backup object without leaving Management Studio. And, use the new CloneSettings procedure to generate template insert statements for any table, based on an example row in the table.

  14. Built-in Verify – If you choose to verify your backups, set the verify command to run after each backup, or after the entire set of backups.

  15. Single-job operation – You no longer need multiple jobs to run your backups.  MB allows you to configure fairly complex scenarios and manage only a single job.

  16. Encrypt backups – In SQL Server 2014 and beyond, you can choose to encrypt your backups.

  17. Compatible with Availability Groups – Minion Backup takes full backup of Availability Group scenarios. You can not only use the preferred AG replica for your backups, but you can also specify specific replicas for each backup type.

  18. Scenario testing— Dynamic tuning, file delete, and file paths all have facilities for testing your configuration before you rely on it.

  19. Automated operation – Run the Minion Backup installation scripts, and it just goes.  You can even rollout to hundreds of servers almost as easily as you can to a single server.

  20. Granular configuration without extra jobs – Configure extensive settings at the default, and/or database levels with ease.  Say good-bye to managing multiple jobs for specialized scenarios.  Most of the time you’ll run MB with a single job.
For links to downloads, tutorials and articles, see MidnightSQL.com/Minion.

__Minion Enterprise Hint__ Minion Enterprise (ME) is our enterprise management solution for centralized SQL Server management and alerting. This solution allows your database administrator to manage an enterprise of one, hundreds, or even thousands of SQL Servers from one central location. ME provides not just alerting and reporting, but backups, maintenance, configuration, and enforcement. ME integrates with Minion Backup.
See http://www.MidnightSQL.com/Minion  for more information, or  email us today at Support@MidnightDBA.com for a demo! ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 8 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Sometimes it is useful to generate backup statements and run them by hand, either individually or in small groups.  To generate backup statements without running the statements, run the procedure Minion.BackupMaster with the parameter @StmtOnly set to 1.  

Example code - The following code will generate full backup statements for all system databases.  
EXEC [Minion].[BackupMaster]
		@DBType = ''System'' ,
		@BackupType = ''Full'', 
		@Include = ''All'',
		@StmtOnly = 1;

Running Minion.BackupMaster with @StmtOnly=1 will generate a list of Minion.BackupDB execution statements, all set to @StmtOnly=1.  Running these Minion.BackupDB statements will generate the “BACKUP DATABASE” or “BACKUP LOG” statements. 

This is an excellent way to discover what settings Minion Backup will use for a particular database (or set of databases). For more information – and another method – for determining the settings Minion Backup will use, see the “Discussion” portion of the “Minion.BackupStmtGet” section below. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup is made up of SQL Server stored procedures, functions, tables, and jobs.  There is also an optional PowerShell script for mass installation (MinionMassInstall.ps1) included in the download.  The tables store configuration and log data; functions encrypt and decrypt sensitive data; stored procedures perform backup operations; and the jobs execute and monitor those backup operations on a schedule.

This section provides a brief overview of Minion Backup elements at a high level: configuration hierarchy, include/exclude precedence, run time configuration, logging and alerting.

Note: Minion Backup is installed in the master database by default.  You certainly can install Minion in another database (like a DBAdmin database), but when you do, you must also verify that the job points to the appropriate database. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup by MidnightDBA is a stand-alone backup solution that can be deployed on any number of servers, for free.  Minion Backup is comprised of SQL Server tables, stored procedures, and SQL Agent jobs.  For links to downloads, tutorials, and articles, see MidnightSQL.com/Minion.
This document explains Minion Backup by MidnightDBA (“Minion Backup”), its uses, features, moving parts, and examples.
NOTE: Minion Backup is one module of the Minion suite of products.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'ServerName' AS [DetailName]
	, 15 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerName' AS [DetailHeader]
	, 'Name of the remote server.

Valid inputs: 
<specific server name>
MinionDefault' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'DynamicName' AS [DetailName]
	, 15 AS [Position]
	, 'Column' AS [DetailType]
	, 'DynamicName' AS [DetailHeader]
	, 'The name of the dynamic part, e.g., “Date”. 

We recommend you do not include any special symbols – only alphanumeric characters.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 24 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup provides a “Data Waiter” feature, which syncs backup settings and backup logs between instances of SQL Server. This is especially useful in failover situations – for example, Availability Groups, replication scenarios, or mirrored partners – so that all the latest backup settings and logs are available, regardless of which node is the primary at any given time.

Note: This feature is informally known as the Data Waiter, because it goes around and gives data to all of your destination tables. (Get it?)

The basic steps to configure the Data Waiter are: 
  1. Install Minion Backup on each destination instance.
  2. Configure the synchronization partners in the Minion.SyncServer table.
  3. Enable the Data Waiter for settings and/or logs, in the Minion.BackupSettingsServer table.
  4. Run the Minion.BackupSyncSettings procedure, to prepare a snapshot of settings data.
  5. Run Minion.SyncPush to initialize the servers.

Note: The Minion.SyncServer table itself is not synchronized across nodes; this table identifies synchronization partners – targets – and therefore the data would not be valid once moved off of the primary instance. The debug tables are also not synchronized.

IMPORTANT: There are particular considerations to keep in mind when synchronizing settings. Be sure to see the section “About: Synchronizing settings and log data with the Data Waiter”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 13 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup deletes old backup files based on configured settings. Set the backup retention in hours in the Minion.BackupSettingsPath table, using the RetHrs (“retention in hours”) field.  You can either modify the default “MinionDefault” row, or insert your own database-specific entry:
INSERT	INTO Minion.BackupSettingsPath
		( [DBName] ,
		  [isMirror] ,
		  [BackupType] ,
		  [BackupLocType] ,
		  [BackupDrive] ,
		  [BackupPath] ,
		  [ServerLabel] ,
		  [RetHrs] ,
		  [PathOrder] ,
		  [IsActive] 
		)
SELECT	''DB1'' AS [DBName] ,
		0 AS [isMirror] ,
		''All'' AS [BackupType] ,
		''Local'' AS [BackupLocType] ,
		''C:\'' AS [BackupDrive] ,
		''SQLBackups\'' AS [BackupPath] ,
			NULL AS [ServerLabel] ,
		48 AS [RetHrs] ,
		0 AS [PathOrder] ,
		1 AS [IsActive];

Note: This new RetHrs value does not affect the retention period of existing backup files.

For more information, see “About: Backup file retention”.

____Minion Enterprise Hint____ Minion Enterprise comes with a suite of queries to pull valuable information. For example, you can easily query to find out how much space is saved when you set backup retention to two days instead of four; or how much space backups take up per server.  And this information is available not just for one server, but for your entire enterprise.
See http://www.MidnightSQL.com/Minion  for more information, or  email us today at Support@MidnightDBA.com for a demo!' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'A log of all backup files (whether they originate from a backup, a copy, or a move). A backup that is striped to 10 files will have 10 rows in this table. A backup that has one file, but is then copied to one other location, will have two rows in this table.

Note: With dynamic backup tuning, a backup could have 3 files one day, 10 files the next, 5 the next, and so on.

Many of the fields in this table are taken directly from BACKUP HEADERONLY. Refer to the BACKUP HEADERONLY article on MSDN: https://msdn.microsoft.com/en-us/library/ms178536.aspx ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 17 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'As part of your backup routine, you can choose to copy your backup files to multiple locations, move your backup files to a location, or both.  This section will walk you through the steps of setting up a file copy and move operation. For more information, see the section “About: Copy and move backup files”.

Note: Currently, Minion Backup can''t copy or move files to or from Microsoft Azure Blobs.  However, you can do a primary backup to an Azure Blob.

The basic steps to configure move operations for backup files are: 
  1. Set the FileAction and FileActionTime fields in Minion.BackupSettings, for the appropriate database(s) and backup type(s). 
  2. Insert one row per operation into the Minion.BackupSettingsPath table. 

The two sections above – “How to: Copy files to a location after backup (single and multiple locations)” and “How to: Move files to a location after backup” – detail the setup for copy and move operations. The only difference for a scenario where you wish to copy and move a backup is that the FileAction field in Minion.BackupSettings must be set to “MoveCopy” (instead of MOVE or COPY).' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 12 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'You can schedule code to run before or after backups, using precode and postcode. Pre- and postcode can be configured: 
  * Before or after database backups (either for one database, or for each of several databases in an operation)
  * Before or after the entire backup operation

NOTE: Unless otherwise specified, pre- and postcode will run in the context of the Minion Backup’s database (wherever the Minion Backup objects are stored); it was a design decision not to limit the code that can be run to a specific database.  Therefore, always use “USE” statements – or, for stored procedures, three-part naming convention – for pre- and postcode.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 7 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup offers you a choice of scheduling options: 
  * You can use the Minion.BackupSettingsServer table to configure flexible backup scheduling scenarios; 
  * Or, you can use the traditional approach of one job per backup schedule; 
  * Or, you can use a hybrid approach that employs a bit of both options.

For more information about backup schedules, see “About: Backup Schedules”.

----Table based scheduling----
When Minion Backup is installed, it uses a single backup job to run the stored procedure Minion.BackupMaster with no parameters, every 30 minutes.  When the Minion.BackupMaster procedure runs without parameters, it uses the Minion.BackupSettingsServer table to determine its runtime parameters (including the schedule of backup jobs per backup type). This is how MB operates by default, to allow for the most flexible backup scheduling with as few jobs as possible.

This document explains table based scheduling in the Quick Start section “Table based scheduling”.

----Parameter based scheduling (traditional approach) ----
Other SQL Server native backup solutions traditionally use one backup job per schedule. That usually means at a minimum: one job for system database full backups, one job for user database full backups, and one job for log backups.

To use the traditional approach of one job per backup schedule: 
  1. Disable or delete the MinionBackup-Auto job. 
  2. Configure new jobs for each backup schedule scenario you need. 

Note: We highly recommend always using the Minion.BackupMaster stored procedure to run backups. While it is possible to use Minion.BackupDB to execute backups, doing so will bypass much of the configuration and logging benefits that Minion Backup was designed to provide.

Run Minion.BackupMaster with parameters: The procedure takes a number of parameters that are specific to the current maintenance run.  (For full documentation of Minion.BackupMaster parameters, see the “Minion.BackupMaster” section.)

To configure traditional, one-job-per-schedule backups, you might configure three new jobs: 
  
  * MinionBackup-SystemFull, to run full backups for system databases nightly at 9pm. The job step should be something similar to:
EXEC Minion.BackupMaster @DBType = ''System''
	, @BackupType = ''Full''
	, @StmtOnly = 0
	, @ReadOnly = 1;

  * MinionBackup-UserFull, to run full backups for user databases nightly at 10pm. The job step should be something similar to:
EXEC Minion.BackupMaster @DBType = ''User''
	, @BackupType = ''Full''
	, @StmtOnly = 0
	, @ReadOnly = 1;

  * MinionBackup-Log, to run log backups for user databases hourly. The job step should be something similar to:
EXEC Minion.BackupMaster @DBType = ''User''
	, @BackupType = ''Log''
	, @StmtOnly = 0
	, @ReadOnly = 2;

----Hybrid scheduling----
It is possible to use both methods – table based scheduling, and traditional scheduling – by one job that runs Minion.BackupMaster with no parameters, and one or more jobs that run Minion.BackupMaster with parameters. 

We recommend against this, as hybrid scheduling has little advantage over either method, and increases the complexity of your backup scenario. However, it may be that there are as yet unforeseen situations where hybrid backup scheduling might be very useful. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 9 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Using the Minion.BackupMaster stored procedure, you can choose whether or not to include READ_ONLY databases in the backup routine: 
  * @ReadOnly = 1 will include READ_ONLY databases in the backup routine. This is the default option.
  * @ReadOnly = 2 will NOT include READ_ONLY databases in the backup routine.
  * @ReadOnly = 3 will ONLY include READ_ONLY databases in the backup routine.

To backup only databases that are not marked READ_ONLY, run the procedure Minion.BackupMaster with the parameter @ReadOnly set to 2. For example, to back up only the read/write user databases, use the following call:
EXEC [Minion].[BackupMaster]
		@DBType = ''User'' ,
		@BackupType = ''Full'', 
		@Include = ''All'',
		@ReadOnly = 2;

To back up only the READ_ONLY databases, use the following call:
EXEC [Minion].[BackupMaster]
		@DBType = ''User'' ,
		@BackupType = ''Full'', 
		@Include = ''All'',
		@ReadOnly = 3; ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 10 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'By default, Minion Backup is configured to back up all databases. As you fine tune your backup scenarios and schedules, you may want to configure specific subsets of databases to be backed up with different options, or at different times. 

You can limit the set of databases to be backed up in a single operation via an explicit list, LIKE expressions, or regular expressions. In the following two sections, we will work through the way to do this first via table based scheduling, and then in traditional scheduling.

NOTE: The use of the regular expressions include and exclude features are not supported in SQL Server 2005. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 11 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'By default, Minion Backup is configured to back up all databases. As you fine tune your backup scenarios and schedules, you may want to exclude certain databases from scheduled backup operations, or even from all backup operations. 

You can exclude databases from all backup operations via the Exclude column in Minion.BackupSettings. Or, you can exclude databases from a backup operation via an explicit list, LIKE expressions, or regular expressions. In the following three sections, we will work through Exclude=1, then excluding databases from table based scheduling, and finally excluding from traditional scheduling.

NOTE: The use of the regular expressions include and exclude features are not supported in SQL Server 2005.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 4 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Default settings for the whole system are stored in the Minion.BackupSettings table.  To specify settings for a specific database that override those defaults (for that database), insert a row for that database to the Minion.BackupSettings table.  For example, we want to fine tune settings for DB1, so we use the following statement: 

INSERT	INTO Minion.BackupSettings
		( [DBName] ,
		  [Port] ,
		  [BackupType] ,
		  [Exclude] ,
		  [GroupOrder] ,
		  [GroupDBOrder] ,
		  [Mirror] ,
		  [DelFileBefore] ,
		  [DelFileBeforeAgree] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [DynamicTuning] ,
		  [Verify] ,
		  [ShrinkLogOnLogBackup] ,
		  [MinSizeForDiffInGB] ,
		  [DiffReplaceAction] ,
		  [Encrypt] ,
		  [Checksum] ,
		  [Init] ,
		  [Format] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB1'' AS [DBName] ,
	1433 AS [Port] ,
	''All'' AS [BackupType] ,
	0 AS [Exclude] ,
	50 AS [GroupOrder] ,
	0 AS [GroupDBOrder] ,
	0 AS [Mirror] ,
	0 AS [DelFileBefore] ,
	0 AS [DelFileBeforeAgree] ,
	''Local'' AS [LogLoc] ,
	90 AS [HistRetDays] ,
	1 AS [DynamicTuning] ,
	''0'' AS [Verify] ,
	1 AS [ShrinkLogOnLogBackup] ,
	20 AS [MinSizeForDiffInGB] ,
	''Log'' AS [DiffReplaceAction] ,
	0 AS [Encrypt] ,
	1 AS [Checksum] ,
	1 AS [Init] ,
	1 AS [Format] ,
	1 AS [IsActive] ,
	''DB1 is high priority; better backup order and history retention.'' AS [Comment];

Minion Backup comes with a utility stored procedure, named Minion.CloneSettings, for easily creating insert statements like the example above. For more information, see the “Minion.CloneSettings” section below.

IMPORTANT: 
  * If you enter a row for a database and/or backup type, that row completely overrides the settings for that particular database (and/or backup type). For example, the row inserted above will be the source of all settings – even if they are NULL – for all DB1 database backups. For more information, see the “Configuration Settings Hierarchy” section above.

  * Follow the Configuration Settings Hierarchy Rule: If you provide a database-specific row, be sure that all backup types are represented in the table for that database. For example, if you insert a row for DBName=’DB1’, BackupType=’Full’, then also insert a row for DBName=’DB1’, BackupType=’All’ (or individual rows for DB1 log and DB1 differential backups). Once you configure the settings context at the database level, the context stays at the database level (and not the default ‘MinionDefault’ level). 

  * A quick note about log backups: In SQL Server, a database must have had a full backup before a log backup can be taken. Minion Backup prevents this; if you try to take a log backup, and the database doesn''t have a restore base, then the system will remove the log backup from the list. MB will not attempt to take a log backup until there''s a full backup in place.  Though it may seem logical to perform a full backup instead of a full, we do not do this, because log backups can be taken very frequently; we don''t want to make what is usually a quick operation into a very long operation. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 5 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'When you first install an instance of Minion Backup, default settings for the whole system are stored in the Minion.BackupSettings table row where DBName=’MinionDefault’ and BackupType=’All’.  To change settings for all databases on the server, update the values for that default row. 
For example, you might want to verify backups after the batch (after all backups for one operation are complete):

UPDATE	Minion.BackupSettings
SET	Verify=''AfterBatch''
WHERE	DBName = ''MinionDefault''
	AND BackupType = ''All'';

WARNING: “Verify” for backups must be used with caution.  Verifying backups can take a long time, and you could hold up subsequent backups while running the verify.  If you would like to run verify, we recommend using AfterBatch.  

Over time, you may have entered one or more database-specific rows for individual databases and/or backup types (e.g., DBName=’DB1’ and BackupType=’Full’). In this case, the settings in the default “MinionDefault/All” row do not apply to those database/backup types. You can of course update the entire table – both the default row, and any database-specific rows – with new settings, to be sure that the change is universal for that instance. So, if you want the history retention days to be 90 (instead of the default, 60 days), run the following: 

UPDATE	Minion.BackupSettings
SET	HistRetDays = 90;

__Minion Enterprise Hint__ Minion Enterprise, in conjunction with Minion Backup, can manage – not just gather and view, but manage – backup settings across all SQL Server instances, centrally. One classic case: you can change backup location for hundreds of servers, using a simple UPDATE statement in the Minion Enterprise central repository.
See http://www.MidnightSQL.com/Minion  for more information, or email us today at Support@MidnightDBA.com for a demo. ' AS [DetailText]
	, NULL AS [Datatype];

GO
--1.4--
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 20 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'With the MinionSetupMaster.ps1 PowerShell script, you can install Minion Backup on a single instance, or on dozens or hundreds of servers at once, just as easily as you would install it on a single instance.

IMPORTANT: The destination database must exist on each server you install Minion Backup to. Partly for this reason, we recommend installing MB to the master database. If you choose to install to another database (for example, a user database named “DBAdmin”), verify that the database exists on all target servers.

For more information, see the “Minion Install Guide.docx”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 6 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'You can choose the order in which databases will be maintained.  For example, let’s say that you want your databases backed up in this order: 
  1. [YourDatabase] (it’s the most important database on your system)
  2. [Semi]
  3. [Lame]
  4. [Unused]

In this case, we would insert a row into the Minion.BackupSettings table for each one of the databases, specifying either GroupDBOrder, GroupOrder, or both, as needed.  

NOTE: For GroupDBOrder and GroupOrder, higher numbers have a greater “weight” - they have a higher priority - and will be backed up earlier than lower numbers.  Note also that these columns are TINYINT, so weighted values must fall between 0 and 255.

NOTE: When you insert a row for a database, the settings in that row override all of the default backup settings for that database.  So, inserting a row for [YourDatabase] means that ONLY backup settings from that row will be used for [YourDatabase]; none of the default settings will apply to [YourDatabase].

NOTE: Any databases that rely on the default system-wide settings (represented by the row where DBName=’MinionDefault’) will be backed up according to the values in the MinionDefault columns GroupDBOrder and GroupOrder.  By default, these are both 0 (lowest priority), and so non-specified databases would be backed up last.  

Because we have so few databases in this example, the simplest method is to assign the heaviest “weight” to YourDatabase, and lesser weights to the other databases, in decreasing order.  In our example, we would insert four rows. Note that, for brevity, we use far fewer columns in our examples than you would need in an actual environment: 

-- Insert BackupSettings row for [YourDatabase], GroupOrder=255 (first)
INSERT  INTO [Minion].[BackupSettings]
        ( [DBName] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [LogLoc] ,
          [HistRetDays] ,
          [ShrinkLogOnLogBackup] ,
          [ShrinkLogThresholdInMB] ,
          [ShrinkLogSizeInMB] 
		)
SELECT  ''YourDatabase'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        255 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [ShrinkLogThresholdInMB] ,
        0 AS [ShrinkLogSizeInMB];


-- Insert BackupSettings row for “Semi”, GroupOrder=150 (after [YourDatabase])
INSERT  INTO [Minion].[BackupSettings]
        ( [DBName] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [LogLoc] ,
          [HistRetDays] ,
          [ShrinkLogOnLogBackup] ,
          [ShrinkLogThresholdInMB] ,
          [ShrinkLogSizeInMB] 
		)
SELECT  ''Semi'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        150 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [ShrinkLogThresholdInMB] ,
        0 AS [ShrinkLogSizeInMB];

-- Insert BackupSettings row for “Lame”, GroupOrder=100 (after “Semi”)
INSERT  INTO [Minion].[BackupSettings]
        ( [DBName] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [LogLoc] ,
          [HistRetDays] ,
          [ShrinkLogOnLogBackup] ,
          [ShrinkLogThresholdInMB] ,
          [ShrinkLogSizeInMB] 
		)
SELECT  ''Lame'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        100 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [ShrinkLogThresholdInMB] ,
        0 AS [ShrinkLogSizeInMB];

-- Insert BackupSettings row for “Unused”, GroupOrder=50 (after [Lame])
INSERT  INTO [Minion].[BackupSettings]
        ( [DBName] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [LogLoc] ,
          [HistRetDays] ,
          [ShrinkLogOnLogBackup] ,
          [ShrinkLogThresholdInMB] ,
          [ShrinkLogSizeInMB] 
		)
SELECT  ''Unused'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        50 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [ShrinkLogThresholdInMB] ,
        0 AS [ShrinkLogSizeInMB];

For a more complex ordering scheme, we could divide databases up into groups, and then order the backups both by group, and within each group. The pseudocode for this example might be:
  * Insert rows for databases YourDatabase and Semi, both with GroupOrder = 200
     - Row YourDatabase: GroupDBOrder = 255
     - Row Semi: GroupDBOrder = 100
  * Insert rows for databases Lame and Unused, both with GroupOrder = 100
     - Row YourDatabase: Lame = 255
     - Row Semi: Unused = 100

The resulting backup order would be as follows:
  1. YourDatabase 
  2. Semi
  3. Lame
  4. Unused' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table stores the certificate, encryption, and thumbprint data for each backup encryption scenario you define. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 15 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.

Valid inputs: 
<specific database name>
MinionDefault' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 67 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion by MidnightDBA is a creation of Jen and Sean McCown, owners of MinionWare, LLC and MidnightSQL Consulting, LLC.

We formed MinionWare, LLC to create Minion Enterprise: an enterprise management solution for centralized SQL Server management and alerting. This solution allows your database administrator to manage an enterprise of one, hundreds, or even thousands of SQL Servers from one central location. Minion Enterprise provides not just alerting and reporting, but backups, maintenance, configuration, and enforcement.  Go to www.MinionWare.net for details and to request a free 90 day trial.

In our “MidnightSQL” consulting work, we perform a full range of databases services that revolve around SQL Server.  We’ve got over 30 years of experience between us and we’ve seen and done almost everything there is to do.  We have two decades of experience managing large enterprises, and we bring that straight to you.  Take a look at www.MidnightSQL.com for more information on what we can do for you and your databases.

Under the “MidnightDBA” banner, we make free technology tutorials, blogs, and a live weekly webshow (DBAs@Midnight).  We cover various aspects of SQL Server and PowerShell, technology news, and whatever else strikes our fancy.  You’ll also find recordings of our classes – we speak at user groups and conferences internationally – and of our webshow.  Check all of that out at www.MidnightDBA.com 

We are both “MidnightDBA” and “MidnightSQL”…the terms are nearly interchangeable, but we tend to keep all of our free stuff under the MidnightDBA banner, and paid services under MidnightSQL Consulting, LLC.  Feel free to call us the MidnightDBAs, those MidnightSQL guys, or just “Sean” and “Jen”.  We’re all good.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'First, it would be a burden to require users to have CLR installed on every single server on the network.  Not only that, but the database setting would have to be set to UNTRUSTWORTHY for the things MB needs to do; or else, we would have a far more complex scenario on hand, and that level of complication just for backups is not a good setup.  

Using SQL CLR would also put us in the business of having to support different .NET framework versions, which would also complicate things. 

Cmdshell is the best choice because it’s simple to lock down to only administrators, and it adds no extra “gotchas”.  There were times when it would have been easier to use CLR, but we simply can’t require that everyone enables CLR.  

Just be sure to lock down cmdshell. For instructions on this, see this article by Sean: http://www.midnightdba.com/DBARant/?p=1243

And for further reading, here is the link to one of Sean’s rants on the topic: http://www.midnightdba.com/DBARant/?p=1204' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 65 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Version          Release Date          Changes
1.0          June 2015                Initial release.
1.1          October 2015          Issues resolved:
Fixed mixed collation issues.
     * Fixed issue where Verify was being called regardless of whether there were files that needed verifying.
     * Data Waiter port wasn’t being configured correctly so there were circumstances where the data wasn’t being shipped to the other servers.
     * Greatly enhanced Data Waiter performance.  Originally, if a server were down, the rows would be errored out and saved to try for the next execution.  Each row would have to timeout.  If the server stayed offline for an extended period you could accumulate a lot of error rows waiting to be pushed and since they all timed out, the job time began to increase exponentially.  Now, the server connection is tried once, and if the server is still down then all of the rows are instantly errored out.  Therefore, there is only one timeout incurred for each server that’s down, instead of one timeout for each row.  This greatly stabilizes your job times when you have sync servers that are offline.
     * Fixed an issue where the ‘Missing’ parameter wasn’t being handled properly in some circumstances.
     * Fixed issue where Master was discarding differential backups in simple mode.
     * Fixed issue where Master wasn’t displaying DBs in proper order.  They were being run in the proper order, but the query that shows what ran wasn’t sorting.
     * Master SP wasn’t handling Daily schedules properly.
     * Reduce DNS lookups by using ‘.’ when connecting to the local box instead of the machine name which causes a DNS lookup and could overload a DNS server. 
     * SQL Server 2008 R2 SP1 service consideration.  The DMV sys.dm_server_services didn’t show up until R2 SP1.  The Master SP only checked for 10.5 when querying this DMV.  If a server is 10.5 under SP1, then this fails because the DMV isn’t there.  Now we check the full version number so this shouldn’t happen again.
     * Master SP not logging error when a schedule can’t be chosen.
     * Situation where differentials will be errored out if they don’t have a base backup.  Now they’ll just be removed from the list.
     * HeaderOnly data not getting populated on 2014 CU1 and above.  MS added 3 columns to the result set so we had to update for this.
     * Increased shrinkLog variable sizes to accommodate a large number of files.
     * Fixed international language issue with decimals.
     * Push to Minion error handling improved.  There were some errors being generated that ended SP execution, but those errors weren’t being pushed to the Minion repository.
New features:
     * You can now take NUL backups so you can kick start your backup tuning scenario.  For more information, see the section titled “About: Backing up to NUL”.
1.2          September 2016          Issues resolved:
     * Installer issue: it wasn’t including new table columns needed because Microsoft changed the Restore Headeronly output.
     * Backups failed if SSAS is installed on the server and the service is turned off.
     * Incorrect error logic when reporting an error back to the Agent.
     * StatusMonitor job should not have a schedule.
     * Not logging the error properly when you don''t have Powershell scripts enabled.  It will now show up in the Minion.BackupLogDetails table.
     * Sometimes @@Servername and the machine name aren''t the same.  It''s the machine name you want to go by, so it now uses SERVERPROPERTY(''MachineName'').
     * Log shipping primaries being removed from backups when they shouldn’t be.
     * Scheduler table wasn’t honoring high-level schedules (FirstOfMonth, etc.) under certain circumstances.
  New features:
     * New database groups feature. See Minion.DBMaintDBGroups.
     * New FrequencyMins column in Minion.BackupSettingsServer allows you to schedule repeating backups less frequently than the job runs.
     * New @TestDateTime parameter for Minion.BackupMaster allows you to test what schedule will be used at a give date and time.
     * Currently when a backup fails, the errors are logged to the Minion.BackupLogDetails table and the job succeeds.  We’ve had feedback from users that they want the job to fail when a backup fails.  So now if there are failures or warnings, you can set the job to fail using the Minion.BackupMaster parameters @FailJobOnError and @FailJobOnWarning, or the Minion.BackupSettingsServer columns FailJobOnError and FailJobOnWarning.
1.3          February 2017          New features:
     * Other minor bug fixes. 
     * Increased international support.
     * Inline tokens.
     * Enhanced restore functionality.
     * New fields in Minion.BackupSettingsPath.
     * Keyword search in Minion.HELP.
1.4          April 2017          Issues resolved:
     * Creating "Christmas tree folders" when using robocopy with multiple files.
     * Missing a couple entries in the InlineTokens table.
     * Some sync commands being written to SyncCmds table even though SyncLogs is 0.
     * Wasn’t logging properly when a DB is in an AG.
	 * Fixed formatting issues in Minion.HELP.
	 * Wrong restore location when restoring to a named instance and the path is being converted from a local drive.  The instance name was being included in the UNC path.
  New features:
     * Added delete for SyncCmds' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This stored procedure is called by the backup routine to perform the backup file action – MOVE or COPY – you specified in the table.  Minion.BackupFileAction will MOVE or COPY any number of files to any number of locations.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'The Minion.Backup DB stored procedure performs backups for a single database.  Minion.Backup DB is the procedure that creates and runs the actual backup statements for databases which meet the criteria stored in the settings table (Minion.BackupSettings).  

IMPORTANT: We HIGHLY recommend using Minion.BackupMaster for all of your backup operations, even when backing up a single database.  Do not call Minion.BackupDB to perform backups.

The Minion.Backup Master procedure makes all the decisions on which databases to back up, and what order they should be in.  It’s certainly possible to call Minion.BackupDB manually, to back up an individual database, but we instead recommend using the Minion.BackupMaster procedure (and just include the single database using the @Include parameter).  First, it unifies your code, and therefore minimizes your effort.  By calling the same procedure every time you reduce your learning curve and cut down on mistakes.  Second, future functionality may move to the Minion.BackupMaster procedure; if you get used to using Minion.Backup Master now, then things will always work as intended. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This stored procedure is responsible for deleting backup files from disk, which have aged out according to the RetHrs column in the Minion.BackupFiles table.  It is called from Minion.BackupDB, and can be run either before or after the backup. Minion.BackupFilesDelete can also be run manually, with a custom retention hours setting. 

Note: This routine will never delete a file where IsArchive = 1 in Minion.BackupFiles. Archive files are saved indefinitely.

For more information, see “About: Backup file retention”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 54 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Updates Minion.BackupLogDetails with the percent complete of running backups. 

The Minion.BackupMaster stored procedure starts the “MinionBackupStatusMonitor” job, which calls Minion.BackupStatusMonitor, at the beginning of a backup batch; and stops the job when the backup batch is complete. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This procedure will generate restore statements based on existing backup files.

For full or differential backups, the procedure will generate a “restore database” statement based on the most recent backup of that backup type. For log backups, the procedure will generate a list of “restore log” statements, starting with the first log backup taken after the most recent full backup; and ending with the most recent log backup. In other words, @BackupType=’Log’ will generate statements to roll through all recent log backups. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 52 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This is a key “Data Waiter” procedure. It prepares log data to be pushed across to target servers.

The master backup procedure Minion.BackupMaster calls Minion.BackupSyncLogs, which loads log data to the Minion.SyncCmds table as insert and delete statements. 

For more information, see “How to: Synchronize backup settings and logs among instances” and “About: Synchronizing settings and log data with the Data Waiter”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 53 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This is a key “Data Waiter” procedure. It prepares settings data to be pushed across to target servers.

The master backup procedure Minion.BackupMaster calls Minion.BackupSyncSettings, which loads a TRUNCATE TABLE statement to the Minion.SyncCmds table; then loads settings data to the table as insert statements. 

Note: We chose to truncate and fully reinitialize settings data on sync partners; and to just push INSERT/UPDATE/DELETE statements for log data changes to sync partners; because settings tables tend to be far smaller tables than log tables, and it makes sense to get the full current “snapshot” of settings from the primary server.

For more information, see “How to: Synchronize backup settings and logs among instances” and “About: Synchronizing settings and log data with the Data Waiter”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, ' The Minion.Backup Master is the central procedure of Minion Backup. It uses the parameter and/or table data to make all the decisions on which databases to back up, and what order they should be in.  This stored procedure calls the Minion.Backup DB stored procedure once per each database specified in the parameters; or, if @Include = “All” is specified, per each eligible database in sys.databases.

In addition, Minion.BackupMaster performs extensive logging, runs configured pre- and postcode, enables and disables the status monitor job (which updates log files for Live Insight, providing percent complete for each backup), determines AG backup location, performs file actions (such as copy and move), and runs the Data Waiter feature to synchronize log and settings data across instances. 

In short, Minion.BackupMaster decides on, runs, or causes to run every feature in Minion Backup.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This stored procedure builds and returns a backup statement, along with associated data. The Minion.BackupDB procedure calls it to generate backup statements. 

You can also use Minion.BackupStmtGet to determine which backup options and settings will be used for a given backup. This is particularly helpful for testing your settings and backup tuning thresholds.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 57 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Use this stored procedure to get help on any Minion Backup object without leaving Management Studio. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This is a key “Data Waiter” procedure. It pushes log and settings data to Minion Backup tables on other SQL Server instances, which are configured as synchronization partners. 

Minion.SyncPush is meant to be run as an automated process most of the time. The automated Data Waiter process pulls sync server name (target server), sync database name (the target database), and port from the Minion.SyncServer table. 

Adding or repairing a sync partner is a manual process. In that case, you would supply all the parameters to Minion.SyncPush, including @Process=’All’, to push all existing records to the target server.

For more information, see “How to: Synchronize backup settings and logs among instances” and “About: Synchronizing settings and log data with the Data Waiter”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 59 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'When you install Minion Backup, it creates two new jobs:

  * MinionBackup-Auto – Runs every half hour. This job consults the Minion.BackupSettingsServer table to determine what, if any, backups are slated to run at that time. By default, the Minion.BackupSettingsServer table is configured with Saturday full backups, daily weekday differential backups, and log backups every half hour. 

  * MinionBackup-StatusMonitor – Monitor job that updates the log tables with “backup percentage complete” data. By default, this job runs continuously, updating every 10 seconds, while a Minion Backup operation is running. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup offers you a choice of scheduling options: 
  * You can use the Minion.BackupSettingsServer table to configure flexible backup scheduling scenarios; 
  * Or, you can use the traditional approach of one job per backup schedule; 
  * Or, you can use a hybrid approach that employs a bit of both options.

For more information, see “Changing Schedules” in the Quick Start section, and “How to: Change backup schedules”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 56 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This procedure allows you to generate an insert statement for a table, based on a particular row in that table.

We made this procedure flexible: you can enter in the name of any Minion table, and a row ID, and it will generate the insert statement for you.

WARNING: This generates a clone of an existing row as an INSERT statement. Before you run that insert, be sure to change key identifying information - e.g., the DBName - before you run the INSERT statement; you would not want to insert a completely identical row.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 62 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup provides a “Data Waiter” feature, which syncs backup settings and backup logs between instances of SQL Server. This is especially useful in failover situations – for example, Availability Groups, replication scenarios, or mirrored partners – so that all the latest backup settings and logs are available, regardless of which node is the primary at any given time.

Note: This feature is informally known as the Data Waiter, because it goes around and gives data to all of your destination tables. (Get it??)

For detailed instructions on configuring the Data Waiter, see “How to: Synchronize backup settings and logs among instances”.

IMPORTANT: When you enable log sync or settings sync for a schedule, it becomes possible for the Data Waiter to cause the backup job to run very long, if there are synch commands that fail (for example, due to a downed sync partner). Consider setting the timeout to a lower value in Minion.SyncServer, to limit the amount of time that the Data Waiter will wait.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'In SQL Server, we can adjust high level settings to improve server performance.  Similarly, we can adjust settings in individual backup statements to improve the performance of backups themselves. A backup tuning primer is well beyond the scope of this document; to learn about backup tuning, please see the recording of our Backup Tuning class at http://bit.ly/1O6Rsh3 (download demo code at http://bit.ly/1Os6yzz). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 61 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, '
The backup file deletion cycle is this:
  1. Backup file retention settings are configured in the Minion.BackupSettingsPath table. 
  2. Each time Minion Backup takes a backup, it logs one row per backup file in the Minion.BackupFiles table. These rows include, among other data, the RetHrs (retention in hours) field for that file.
  3. The procedure Minion.BackupFilesDelete runs with every backup operation; it checks the Minion.BackupFiles table to see which files should be deleted. And, of course, it deletes them.

IMPORTANT: As the RetHrs field in Minion.BackupSettingsPath is just the configuration value, not the configured retention value. In other words, updating the RetHrs field in Minion.BackupSettingsPath has no effect on the existing backup files’ retention settings; that field only sets the retention for future backup files.

If you reduce the RetHrs value in Minion.BackupSettingsPath, and would like it to also apply to the existing backup files (regardless of their current retention settings), you have two options: 
  * Use Minion.BackupFilesDelete with a custom retention, or 
  * Update the Minion.BackupFiles log table.

Minion.BackupFilesDelete procedure: You can call the Minion.BackupFilesDelete stored procedure for your specified database – or, for @DBName=’All’ – and pass in a specific retention hours using the @RetHrs parameter. For example, to delete all YourDatabase backup files – full, diff, and log – older than 24 hours, run the following: 
EXEC [Minion].[BackupFilesDelete]
      @DBName =''YourDatabase'',
      @RetHrs = 24 , 
      @Delete = 1 ;

Minion.BackupFiles table: Update RetHrs in the Minion.BackupFiles table manually for that database. For example:
UPDATE  Minion.BackupFiles
SET     RetHrs = 24
WHERE   DBName = ''YourDatabase'';

Then, you can either call Minion.BackupFilesDelete manually, or wait for it to run as scheduled. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Allows you to exclude databases from index maintenance (or all maintenance), based off of regular expressions. 
Note that this procedure is shared between Minion modules. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table holds the commands used to synchronize settings and log tables to target servers (which are configured in the Minion.SyncServer table). Minion.SyncCmds is both a log table and a work table: the synchronization process uses Minion.SyncCmds to push the synchronization commands to target servers, and it is also a log of those commands (complete and incomplete).

At the end of a backup, Minion Backup writes logged data to this table as INSERT commands. So, everything MB wrote to the log tables is automatically entered into this table as a command, to be used on the target instances.  The same thing happens with changes to settings: when you configure Minion Backup to synchronize settings to a server, it writes those settings as commands in this table, to be run on the target servers. 

For more information, see the sections “How to: Synchronize backup settings and logs among instances”, “Minion.SyncServer”, and “Minion.SyncErrorCmds”.

Note: This table is used by Minion Backup, as well as (if installed) Minion Reindex, and other Minion modules.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Configure the synchronization server information per database here in Minion.SyncServer. 

For more information, see the sections “How to: Synchronize backup settings and logs among instances”, “Minion.SyncCmds”, and “Minion.SyncErrorCmds”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 45 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table is for internal use only. Do not modify in any way.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table holds synchronization commands that have failed, to be retried again later. 

For more information, see the sections “How to: Synchronize backup settings and logs among instances”, “Minion.SyncServer”, and “Minion.SyncCmds”.

Note: This table has the potential to very large, if a replica is down for a long time, or if many replicas are down. In that case, it might be wise to turn off synchronization for that particular server, and if necessary, clear that server’s records from Minion.SyncErrorCmds and reinitialize it as a new partner.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 46 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Two separate procedures execute backup operations for Minion Backup: one procedure runs per database, and the other is a “Master” procedure that performs run time logic and calls the DB procedure as appropriate.

In addition, Minion Backup comes with a Help procedure to provide information about the system itself.

Backup procedures:
  * Minion.BackupMaster – This procedure makes all the decisions on which databases to back up, and what order they should be in.  
  * Minion.BackupDB – This procedure is called by Minion.BackupMaster to perform backup for a single database.  
  * Minion.HELP – Display help on Minion Backup objects and concepts.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table holds the thresholds used to determine when to change the tuning of a backup. 

For more information, see the sections “About: Dynamic Backup Tuning Thresholds” and “How to: Set up dynamic backup tuning thresholds”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 36 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, ' This table holds high level debugging data from backup runs where debugging was enabled. Both the Minion.BackupMaster and the Minion.BackupDB stored procedures allow you to enable debugging.

Note: The data in Minion.BackupDebug and Minion.BackupDebugLogDetails is useful to Minion support. Contact us through www.MinionWare.net for help with your backup scenarios and debugging.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 37 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table holds detailed debugging data from backup runs where debugging was enabled. Note: The data in Minion.BackupDebug and Minion.BackupDebugLogDetails is useful to Minion support. Contact us through www.MinionWare.net for help with your backup scenarios and debugging.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 38 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table is no longer in use, and was removed as of Minion Backup 1.3.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 27 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'The tables in Minion Backup fall into two categories: those that store configured settings, and those that log operational information. 

The settings tables are: 

  * Minion.BackupCert – This table allows you to configure which types of certificates to back up, and the password to use when backing them up. 

  * Minion.BackupEncryption – This table stores data for each backup encryption scenario you define.  

  * Minion.BackupRestoreSettingsPath – This table stores the path settings for restore scenarios. In other words, here is where you define the paths and file names the system will restore to. 

  * Minion.BackupRestoreTuningThresholds – This table holds thresholds used to determine when to change the tuning of a restore; and the tuning settings per threshold. 

  * Minion.BackupSettings – This table holds backup settings at the default level, database level, and backup type level.  You may insert rows to define backup settings per database, per type, per type and database; or, you can rely on the system-wide default settings (defined in the “MinionDefault” row); or a combination of these.  

  * Minion.BackupSettingsPath – This table holds location configurations for each type of backup.  In other words, here is where you define the paths the system will back up to. 

  * Minion.BackupSettingsServer – This table contains server-level backup settings. The backup job (MinionBackup-AUTO) runs regularly in conjunction with this table to provide a wide range of backup options, all without introducing additional jobs. 

  * Minion.BackupTuningThresholds – This table holds thresholds used to determine when to change the tuning of a backup; and the tuning settings per threshold.  

  * Minion.DBMaintRegexLookup – Allows you to include or exclude databases from backup (or from reindex, checkdb, or all maintenance), based off of regular expressions.   

  * Minion.SyncServer – This table allows you to define synchronization partners: instances to push settings and/or log data to. 

Logs:  

  * Minion.BackupFileListOnly – A Log of RESTORE FILELISTONLY output for each backup taken  

  * Minion.BackupFiles – A log of all backup files (whether they originate from a database backup, a certificate backup, a copy, or a move). Note that a backup that is striped to 10 files will have 10 rows in this table. 

  * Minion.BackupLog – Holds a database-level summary of the backup operation per database.  Each row contains the database name, operation status, the start and end time of the backup, and much more.  This is updated as each backup occurs, so that you have Live Insight into active operations. 

  * Minion.BackupLogDetails – Holds a log of backup activity at the database level. 

  * Minion.SyncCmds – a log of commands used to synchronize settings and log tables to configured synchronization servers. This table is both a log table and a work table: the synchronization process uses Minion.SyncCmds to push the synchronization commands to target servers, and it is also a log of those commands (complete and incomplete). 

  * Minion.SyncErrorCmds – a log of synchronization commands that have failed, to be retried again later.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 25 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'In an Availability Group (AG), you can perform backups on any  node, including secondary nodes: those that are not currently the primary. In this way you can “offload” backups to conserve resources on your primary node.  What’s more, an AG scenario includes the definition of a preferred server, or even a list of weighted preferences. 

Minion Backup allows you to configure which server you would like to perform backups on in an Availability Group. You can set your backups to run on a specific server, or to run on the AG preferred server (whichever one that happens to be at the time of backup). By default, backups in Availability Groups are performed on the current primary node.

Let’s take an example, where DB9 is part of an AG with two nodes. We would like DB9 full and log backups to be performed on the Server1 instance; but assign differential backups to the AG primary. We will then enter one row for DB9 / All, setting the PreferredServer column to ‘Server1’; and one row for DB9 / Diff, setting PreferredServer to ‘AGPreferred’: 
INSERT  INTO Minion.BackupSettings
        ( [DBName] ,
          [Port] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [Mirror] ,
          [DelFileBefore] ,
          [DelFileBeforeAgree] ,
          [LogLoc] ,
          [HistRetDays] ,
          [DynamicTuning] ,
          [Verify] ,
          [PreferredServer] ,
          [ShrinkLogOnLogBackup] ,
          [Encrypt] ,
          [Checksum] ,
          [Init] ,
          [Format] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB9'' AS [DBName] ,
        NULL AS [Port] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        0 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        0 AS [Mirror] ,
        0 AS [DelFileBefore] ,
        0 AS [DelFileBeforeAgree] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        1 AS [DynamicTuning] ,
        ''0'' AS [Verify] ,
        ''Server1'' AS [PreferredServer] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [Encrypt] ,
        1 AS [Checksum] ,
        1 AS [Init] ,
        1 AS [Format] ,
        1 AS [IsActive] ,
        NULL AS [Comment];

INSERT  INTO Minion.BackupSettings
        ( [DBName] ,
          [Port] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [Mirror] ,
          [DelFileBefore] ,
          [DelFileBeforeAgree] ,
          [LogLoc] ,
          [HistRetDays] ,
          [DynamicTuning] ,
          [Verify] ,
          [PreferredServer] ,
          [ShrinkLogOnLogBackup] ,
          [Encrypt] ,
          [Checksum] ,
          [Init] ,
          [Format] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB9'' AS [DBName] ,
        NULL AS [Port] ,
        ''Diff'' AS [BackupType] ,
        0 AS [Exclude] ,
        0 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        0 AS [Mirror] ,
        0 AS [DelFileBefore] ,
        0 AS [DelFileBeforeAgree] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        1 AS [DynamicTuning] ,
        ''0'' AS [Verify] ,
        ''AGPreferred'' AS [PreferredServer] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [Encrypt] ,
        1 AS [Checksum] ,
        1 AS [Init] ,
        1 AS [Format] ,
        1 AS [IsActive] ,
        NULL AS [Comment];

Important notes: 
  * Availability groups cannot run differential backups on secondary nodes. If you accidentally specify differentials on a server and that server isn’t primary, the differential backups simply won’t run.
  
  * If you use a specific server name for PreferredServer (as opposed to AGPreferred), it is enforced. In our example above, we set PreferredServer=Server1 for full and log backups. If the Server1 node is down, full and log backups will simply not run for DB9.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table contains server-level backup settings. Specifically, each row represents a backup scenario as defined by the database type, backup type, day, begin and end time, and maximum number of backups per timeframe.  The backup job (MinionBackup-AUTO) runs regularly in conjunction with this table to provide a wide range of backup options, all without introducing additional jobs.
In addition, you can enable settings synchronization, and/or log synchronization, for any or all of the backup scenarios. (So for example, Minion Backup can synchronize settings and logs with the weekly full backups.)
For more information, see the “About: Backup Schedules” section.
Minion.BackupSettingsServer ships with a full set of schedules in place.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 21 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup provides the option of shrinking log files after log backups.

To enable this for the database YourDatabase:
  1. If it does not exist already, insert a row into Minion.BackupSettings with DBName = ‘YourDatabase’ and ‘BackupType=’All’. (Alternately, you could provide any combination of rows to cover all three types of backups – full, differential, and log – for YourDatabase.)
  2. Update the row in Minion.BackupSettings for YourDatabase with the following values: 
     a. ShrinkLogOnLogBackup – Set this to 1, to enable the feature.
     b. ShrinkLogThresholdInMB – The minimum size (in MB) the log file must be before Minion Backup will shrink it. For example, you may not want to shrink any log file under 1024MB; so set this field to 1024.
     c. ShrinkLogSizeInMB – The size (in MB) the log file shrink should target. 

Notes about log shrink on log backup: 
  * The ShrinkLogSizeInMB field represents how big you would like the log file to be after a file shrink.   This setting applies for EACH log file, not for all log files totaled. If you specify 1024 as the size here, and you have three log files for your database, Minion Backup will attempt to shrink each of the three log files down to 1024MB (so you’ll end up with at least 3072MB of logs).
  * Minion Backup also helps you monitor your VLFs. Just before a log backup is taken, we store the number of VLFs in the Minion.BackupLogDetails table, in the “VLFs” column. This can help you troubleshoot log performance issues.
  * MB also tracks the log size before the shrink. You can find this number in the _ table, columns “PreBackupLogSizeInMB” and “SizeInMB”.
  * The log file shrink on log backup is AG-aware. If you back up the log on a secondary replica of an Availability Group, SQL Server is unable to shrink that file. So instead, Minion Backup will shrink the log on the AG primary. The AG will then, in its own time, shrink the log file of the replica(s).' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 22 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'As far as Minion Backup is concerned, there are only two types of certificates: server certificates, and database certificates. Once you enable and configure a certificate type for backup, certificates are automatically backed up with every full database backup. 

To configure certificate backups: 
1.	Enable the certificate backups in the Minion.BackupCert table.
2.	Configure the certificate backup location in the Minion.BackupSettingsPath table.

Let’s walk through an example.  We will first enable, then configure both server certificates and database certificates for backup to a single backup location.

First, enable the certificate backups: Insert one row for each certificate type to the Minion.BackupCert table:
INSERT INTO Minion.BackupCert (CertType,CertPword,BackupCert)
SELECT ''ServerCert'', Minion.EncryptTxt(''S00persecr1tpa55''), 1;

INSERT INTO Minion.BackupCert (CertType,CertPword,BackupCert)
SELECT ''DatabaseCert'', Minion.EncryptTxt(''duB15secr1tpa55''), 1;

Note that the password is stored encrypted, so you must use the Minion.EncryptTxt function to encrypt the password on insert.

Next, configure the certificate backup location: Insert one row per certificate type (BackupType=’ServerCert’, and BackupType=’DatabaseCert’) to the Minion.BackupSettingsPath table:
-- Server certificate: 
INSERT  INTO Minion.BackupSettingsPath
        ( [DBName] ,
          [isMirror] ,
          [BackupType] ,
          [BackupLocType] ,
          [BackupDrive] ,
          [BackupPath] ,
          [ServerLabel] ,
          [RetHrs] ,
          [PathOrder] ,
          [IsActive] ,
          [AzureCredential] ,
          [Comment]
        )
SELECT  ''MinionDefault'' AS [DBName] ,
        0 AS [isMirror] ,
        ''ServerCert'' AS [BackupType] ,
        ''Local'' AS [BackupLocType] ,
        ''C:\'' AS [BackupDrive] ,
        ''SQLBackups\'' AS [BackupPath] ,
        NULL AS [ServerLabel] ,
        24 AS [RetHrs] ,
        0 AS [PathOrder] ,
        1 AS [IsActive] ,
        NULL AS [AzureCredential] ,
        ''Server certificate backup target.'' AS [Comment];

-- Database certificate: 
INSERT  INTO Minion.BackupSettingsPath
        ( [DBName] ,
          [isMirror] ,
          [BackupType] ,
          [BackupLocType] ,
          [BackupDrive] ,
          [BackupPath] ,
          [ServerLabel] ,
          [RetHrs] ,
          [PathOrder] ,
          [IsActive] ,
          [AzureCredential] ,
          [Comment]
        )
SELECT  ''MinionDefault'' AS [DBName] ,
        0 AS [isMirror] ,
        ''DatabaseCert'' AS [BackupType] ,
        ''Local'' AS [BackupLocType] ,
        ''C:\'' AS [BackupDrive] ,
        ''SQLBackups\'' AS [BackupPath] ,
        NULL AS [ServerLabel] ,
        24 AS [RetHrs] ,
        0 AS [PathOrder] ,
        1 AS [IsActive] ,
        NULL AS [AzureCredential] ,
        ''Database certificate backup target.'' AS [Comment];

Note: For certificate backup settings paths, the database name (DBName) doesn’t really apply; we use DBName=‘MinionDefault’ here, but you could just as easily use DBName=’Certificate’, or any other non-null value.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'This table allows you to configure backup path destinations; and backup file copy and move settings. You may insert rows for individual databases, backup types, and copy/move settings, to override the default path settings for that database and backup type.

IMPORTANT: We highly recommend backing up to UNC paths, instead of to locally defined drives. Especially in the context of the Data Waiter feature, UNC paths allow a smoother transition between replicas or to a warm failover server. For more information, see “About: Synchronizing settings and log data with the Data Waiter”.

Several “How To” sections provide instructions for copy, move, and mirror scenarios that use the Minion.BackupSettingsPath table: 
  * How to: Set up mirror backups
  * How to: Copy files after backup (single and multiple locations)
  * How to: Move files to a location after backup
  * How to: Copy and move backup files
  * How to: Back up to multiple files in a single location
  * How to: Back up to multiple locations

Also see the discussion below, after the columns description.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 26 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'In SQL Server, we can adjust high level settings to improve server performance.  Similarly, we can adjust settings in individual backup statements to improve backup performance. A backup tuning primer is beyond the scope of this document; to learn about backup tuning, please see the recording of our Backup Tuning class at http://bit.ly/1O6Rsh3 (download demo code at http://bit.ly/1Os6yzz).

Once you are familiar with the backup tuning process, you can perform an analysis, and then set up specific thresholds in the Minion.BackupTuningThresholds table. It is a “Thresholds” table, because you configure a different collection of backup tuning settings for different sized databases (thereby, defining backup tuning thresholds). As your database grows and shrinks, Minion Backup will use the settings you’ve defined for those sizes, so that backups always stay at peak performance.

IMPORTANT: The “dynamic backup tuning thresholds” topic is a complicated one. We highly recommend you first read the “About: Dynamic Backup Tuning Thresholds” section before you begin.

The basic steps to set up dynamic backup tuning thresholds are: 
  1. Perform your backup tuning analysis for a database.
  2. Enable backup tuning for that database, if it is not already enabled. 
  3. Enter threshold settings in Minion.BackupTuningThresholds.

The examples that follow will walk you through a few scenarios of backup tuning threshold use, and demonstrate important features of the dynamic backup tuning module.  

NOTE: All of these examples are just for the sake of example; the settings we use for these examples are not recommendations and have no bearing on your particular environment.  We DO NOT recommend using these numbers without proper analysis of your particular system.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 300 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'You don’t actually need Minion Backup on the target server, in order to use MB’s restore functionality. Let’s walk through this. 

Let’s say you want to restore from a server named Prod1 (which has MB on it) to a server named QA5. To set this up with Minion Backup:

  1. On Prod1, add a row to Minion.BackupRestoreSettingsPath with ServerName=’QA5’ and DBName = ‘MinionDefault’ (to make it applicable to all databases), and configure other settings as appropriate.
 
  2. On Prod1, configure restore tuning settings in Minion.BackupRestoreTuningThresholds.
 
  3. Now you can run the procedure ‘Minion.BackupRestoreDB’ to generate the restore statements. Run once for each backup type (e.g., once for Full and once for Log). The SP will automatically generate the statement for the latest backup(s) for that database.
 
  4. Run the statements on QA5.  

If you like, you can automate this with PowerShell – use POSH to connect to Prod1, run the SP, and use the output for restores.' AS [DetailText]
	, NULL AS [Datatype];
GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Purpose' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Purpose' AS [DetailHeader]
	, 'Minion.BackupSettings contains the essential backup settings, including backup order, history retention, pre-and postcode, native backup settings (like format), and more. 

Minion.BackupSettings is installed with default settings already in place, via the system-wide default row (identified by DBName = “MinionDefault” and BackupType = “All”).  If you do not need to fine tune your backups at all, no action is required, and all backups will use this default configuration.  

Important: Do not delete the MinionDefault row, or alter the DBName or BackupType columns for this row!

To override these default settings for a specific database, insert a new row for the individual database with the desired settings.  Note that any database with its own entry in Minion.BackupSettings retrieves ALL its configuration data from that row.  For example, if you enter a row for [YourDatabase] and leave the ShrinkLogOnLogBackup column at NULL, Minion Backup does NOT retrieve that value from the “MinionDefault” row; in this case, ShrinkLogOnLogBackup for YourDatabase would default to off (“no”). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 19 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Minion Backup allows you to back up to multiple files, and to back those files up to multiple locations. You can configure multi-location backups in just two steps: 
1.	Configure the number of backup files in the Minion.BackupTuningThresholds table.
2.	Configure the backup locations in the Minion.BackupSettingsPath table.

When this is configured, backups will proceed as defined; multiple backup files will be placed on multiple paths in a round robin fashion. 

Let us take the example of backing up the DB1 database to four files on two separate drives, for full backups and differential backups.

First, configure the number of backup files in Minion.BackupTuningThresholds. Log backups in this example will be backed up to one file, while full and differential backups will be backed up to four. We can configure this with two rows – one for BackupType=Log and NumberOfFiles=1, and one for BackupType=All and NumberOfFiles=4: 
INSERT  INTO Minion.BackupTuningThresholds
        ( [DBName] ,
          [BackupType] ,
          [SpaceType] ,
          [ThresholdMeasure] ,
          [ThresholdValue] ,
          [NumberOfFiles] ,
          [Buffercount] ,
          [MaxTransferSize] ,
          [Compression] ,
          [BlockSize] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        ''DataAndIndex'' AS [SpaceType] ,
        ''GB'' AS [ThresholdMeasure] ,
        0 AS [ThresholdValue] ,
        4 AS [NumberOfFiles] ,
        0 AS [Buffercount] ,
        0 AS [MaxTransferSize] ,
        NULL AS [Compression] ,
        0 AS [BlockSize] ,
        1 AS [IsActive] ,
        ''DB1 full and differential.'' AS [Comment];

INSERT  INTO Minion.BackupTuningThresholds
        ( [DBName] ,
          [BackupType] ,
          [SpaceType] ,
          [ThresholdMeasure] ,
          [ThresholdValue] ,
          [NumberOfFiles] ,
          [Buffercount] ,
          [MaxTransferSize] ,
          [Compression] ,
          [BlockSize] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        ''Log'' AS [BackupType] ,
        ''DataAndIndex'' AS [SpaceType] ,
        ''GB'' AS [ThresholdMeasure] ,
        0 AS [ThresholdValue] ,
        1 AS [NumberOfFiles] ,
        0 AS [Buffercount] ,
        0 AS [MaxTransferSize] ,
        NULL AS [Compression] ,
        0 AS [BlockSize] ,
        1 AS [IsActive] ,
        ''DB1 log.'' AS [Comment];

Note that the code above omits BeginTime, EndTime, and DayOfWeek. These fields are optional; they may be used to limit the days and times at which the threshold in question applies. As we want these new threshold settings to apply at all time, we can comfortably leave these three fields NULL.

Next, configure the backup locations. We can define multiple backup paths for DB1, and additionally, order the paths (using the PathOrder field) to determine which path will be use first. In this example, we will use two rows to configure two paths: 
INSERT  INTO Minion.BackupSettingsPath
        ( [DBName] ,
          [IsMirror] ,
          [BackupType] ,
          [BackupLocType] ,
          [BackupDrive] ,
          [BackupPath] ,
          [ServerLabel] ,
          [RetHrs] ,
          [FileActionMethod] ,
          [FileActionMethodFlags] ,
          [PathOrder] ,
          [IsActive] ,
          [AzureCredential] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        0 AS [IsMirror] ,
        ''All'' AS [BackupType] ,
        ''Local'' AS [BackupLocType] ,
        ''E:\'' AS [BackupDrive] ,
        ''SQLBackups\'' AS [BackupPath] ,
        NULL AS [ServerLabel] ,
        24 AS [RetHrs] ,
        NULL AS [FileActionMethod] ,
        NULL AS [FileActionMethodFlags] ,
        50 AS [PathOrder] ,
        1 AS [IsActive] ,
        NULL AS [AzureCredential] ,
        ''DB1 location 1.'' AS [Comment];

INSERT  INTO Minion.BackupSettingsPath
        ( [DBName] ,
          [IsMirror] ,
          [BackupType] ,
          [BackupLocType] ,
          [BackupDrive] ,
          [BackupPath] ,
          [ServerLabel] ,
          [RetHrs] ,
          [FileActionMethod] ,
          [FileActionMethodFlags] ,
          [PathOrder] ,
          [IsActive] ,
          [AzureCredential] ,
          [Comment]
        )
SELECT  ''DB1'' AS [DBName] ,
        0 AS [IsMirror] ,
        ''All'' AS [BackupType] ,
        ''Local'' AS [BackupLocType] ,
        ''F:\'' AS [BackupDrive] ,
        ''SQLBackups\'' AS [BackupPath] ,
        NULL AS [ServerLabel] ,
        24 AS [RetHrs] ,
        NULL AS [FileActionMethod] ,
        NULL AS [FileActionMethodFlags] ,
        10 AS [PathOrder] ,
        1 AS [IsActive] ,
        NULL AS [AzureCredential] ,
        ''DB1 location 2.'' AS [Comment];

Note that PathOrder is a weighted measure, meaning that higher numbers means higher precedence. DB1 location 1 has PathOrder of 50, while DB1 location 2 has a PathOrder of 10; so, DB1 location 1 will be selected first.

Once the files and paths are configured, the DB1 backups will be placed as follows: 
  * DB1 full (or differential) backups will stripe to four files. These will be placed on the defined paths in a round robin fashion: 
  * file1 is created on location 1; 
  * file2 is created on location 2; 
  * file3 is created on location 1; and
  * file4 is created on location 2.
  * DB1 log backups have only one file defined, so Minion Backup selects the target path for DB1 that has the heaviest weight: in this case, DB1 location 1.

The use of the Minion.BackupTuningThresholds table is detailed much more thoroughly in the “How to: Set up dynamic backup tuning thresholds” section, and in the “Minion.BackupTuningThresholds” section.

And for more information on backup paths, see “Minion.BackupSettingsPath”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 23 AS [ObjectID]
	, 'Introduction' AS [DetailName]
	, 15 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Starting in SQL Server 2014, you can perform backups that create encrypted backup files. To set up backup encryption in Minion Backup: 
1.	Create a Database Master Key for the master database; and create a certificate to use for backup encryption. For instructions and details, see the MSDN article on Backup Encryption: https://msdn.microsoft.com/library/dn449489%28v=sql.120%29.aspx 
2.	Enable encryption for one or more backups by setting Encrypt = 1 in Minion.BackupSettings.
3.	Configure encryption by inserting one or more rows into Minion.BackupEncryption.

Note: Encrypted backups are only available in SQL Server 2014 and beyond.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 16 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'CertType' AS [DetailName]
	, 17 AS [Position]
	, 'Column' AS [DetailType]
	, 'CertType' AS [DetailHeader]
	, 'Certificate type.  Valid inputs: ServerCert, DatabaseCert' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'CertPword' AS [DetailName]
	, 18 AS [Position]
	, 'Column' AS [DetailType]
	, 'CertPword' AS [DetailHeader]
	, 'Certificate password. This is the password used to protect the certificate backup. ' AS [DetailText]
	, 'varbinary' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 18 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'BackupCert' AS [DetailName]
	, 19 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupCert' AS [DetailHeader]
	, 'Flag that determines whether or not to back up this certificate type. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 12 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Database precode and postcode' AS [DetailHeader]
	, 'Database precode and postcode run before and after an individual database; or, if there are multiple databases in the backup batch, before and after each database backup. Database precode and postcode presents several options:
  * run code before or after a single database 
  * run code before or after each and every database 
  * run code before or after each of a few databases 
  * run code before or after all but a few databases

To run code before or after a single database, insert a row for the database into Minion.BackupSettings.  Populate the column DBPreCode to run code before the backup operations for that database; populate the column DBPostCode to run code before the backup operations after that database.  For example: 
INSERT  INTO Minion.BackupSettings
        ( [DBName] ,
          [Port] ,
          [BackupType] ,
          [Exclude] ,
          [GroupOrder] ,
          [GroupDBOrder] ,
          [Mirror] ,
          [DelFileBefore] ,
          [DelFileBeforeAgree] ,
          [LogLoc] ,
          [HistRetDays] ,
          [DBPreCode] ,
          [DBPostCode] ,
          [DynamicTuning] ,
          [Verify] ,
          [ShrinkLogOnLogBackup] ,
          [ShrinkLogThresholdInMB] ,
          [ShrinkLogSizeInMB] ,
          [Encrypt] ,
          [Checksum] ,
          [Init] ,
          [Format] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''DB5'' AS [DBName] ,
        NULL AS [Port] ,
        ''All'' AS [BackupType] ,
        0 AS [Exclude] ,
        0 AS [GroupOrder] ,
        0 AS [GroupDBOrder] ,
        0 AS [Mirror] ,
        0 AS [DelFileBefore] ,
        0 AS [DelFileBeforeAgree] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        ''EXEC master.dbo.GenericSP1;'' AS [DBPreCode] ,
        ''EXEC master.dbo.GenericSP2;'' AS [DBPostCode] ,
        1 AS [DynamicTuning] ,
        ''0'' AS [Verify] ,
        0 AS [ShrinkLogOnLogBackup] ,
        0 AS [ShrinkLogThresholdInMB] ,
        0 AS [ShrinkLogSizeInMB] ,
        0 AS [Encrypt] ,
        1 AS [Checksum] ,
        1 AS [Init] ,
        1 AS [Format] ,
        1 AS [IsActive] ,
        NULL AS [Comment];

To run code before or after each and every database, update the MinionDefault row AND every database-specific rows (if any) in Minion.BackupSettings, populating the column DBPreCode or DBPostCode. For example: 
UPDATE	[Minion].[BackupSettings]
SET		DBPreCode = ''EXEC master.dbo.GenericSP1;'' ,
		DBPostCode = ''EXEC master.dbo.GenericSP1;''
WHERE	DBName = ''MinionDefault''
		AND BackupType = ''All'';

UPDATE	[Minion].[BackupSettings]
SET		DBPreCode = ''EXEC master.dbo.GenericSP1;'',
		DBPostCode = ''EXEC master.dbo.GenericSP1;''
WHERE	DBName = ''DB5'' 
AND BackupType = ''All'';

To run code before or after each of a few databases, insert one row for each of the databases into Minion.BackupSettings, populating the DBPreCode column and/or DBPostCode column as appropriate.  

To run code before or after all but a few databases, update the MinionDefault row in Minion.BackupSettings, populating the DBPreCode column and/or the DBPostCode column as appropriate.  This will set up the execution code for all databases.  Then, to prevent that code from running on a handful of databases, insert a row for each of those databases to Minion.BackupSettings, and keep the DBPreCode and DBPostCode columns set to NULL.  

For example, if we want to run the stored procedure dbo.SomeSP before each database except databases DB1, DB2, and DB3, we would: 
  1. Update row in Minion.BackupSettings for “MinionDefault”, setting PreCode to ‘EXEC dbo.SomeSP;’
  2. Insert a row to Minion.BackupSettings for [DB1], establishing all appropriate settings, and setting DBPreCode to NULL.  
  3. Insert a row to Minion.BackupSettings for [DB2], establishing all appropriate settings, and setting DBPreCode to NULL.  
  4. Insert a row to Minion.BackupSettings for [DB3], establishing all appropriate settings, and setting DBPreCode to NULL.  

Note: The Minion.BackupSettings columns DBPreCode and DBPostCode are in effect whether you are using table based scheduling – that is, running Minion.BackupMaster without parameters – or using parameter based scheduling. (This is not the case for batch precode and postcode, which the next section covers.)' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 26 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 20 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 1: Modify existing, default tuning thresholds' AS [DetailHeader]
	, 'Minion Backup is installed with default backup tuning threshold settings, defined by the row DBName=’MinionDefault’, BackupType=’All’, and ThresholdValue=0.  You can modify the settings for all backups – assuming, of course, that no new threshold rows have been added – by updating this row. For example, to change the number of files at the default level, run a simple update statement: 
UPDATE	[Minion].BackupTuningThresholds
SET	NumberOfFiles = 2
WHERE	DBName = ''MinionDefault'';

These default settings will apply for all databases where DynamicTuning is enabled (in Minion.BackupSettings), and that don’t otherwise have tuning settings defined.

Note that the threshold you enter represents the LOWER threshold (the “floor”). This is why the “MinionDefault” row has a ThresholdValue of 0.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'MaintType' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaintType' AS [DetailHeader]
	, '	The type of maintenance that this row applies to.

Valid values:
All
Backup
Reindex
CheckDB' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 23 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Encrypt backups for one database' AS [DetailHeader]
	, 'First, create a Database Master Key and certificate. See the MSDN article on Backup Encryption for instructions and details: https://msdn.microsoft.com/library/dn449489%28v=sql.120%29.aspx 

Next, enable encryption for one or more backups. In our example, we will enable encrypted backups for the DB1 database, all backup types: 
INSERT	INTO Minion.BackupSettings
		( [DBName] ,
		  [Port] ,
		  [BackupType] ,
		  [Exclude] ,
		  [GroupOrder] ,
		  [GroupDBOrder] ,
		  [Mirror] ,
		  [DelFileBefore] ,
		  [DelFileBeforeAgree] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [DynamicTuning] ,
		  [Verify] ,
		  [Encrypt] ,
		  [Checksum] ,
		  [Init] ,
		  [Format] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB1'' AS [DBName] ,
	NULL AS [Port] ,
	''All'' AS [BackupType] ,
	0 AS [Exclude] ,
	0 AS [GroupOrder] ,
	0 AS [GroupDBOrder] ,
	0 AS [Mirror] ,
	0 AS [DelFileBefore] ,
	0 AS [DelFileBeforeAgree] ,
	''Local'' AS [LogLoc] ,
	60 AS [HistRetDays] ,
	1 AS [DynamicTuning] ,
	NULL AS [Verify] ,
	1 AS [Encrypt] ,
	1 AS [Checksum] ,
	1 AS [Init] ,
	1 AS [Format] ,
	1 AS [IsActive] ,
	NULL AS [Comment];

Finally, configure encryption. In this example, we will use the same certificate for all DB1 backup types. So, insert one row into Minion.BackupEncryption:
INSERT  INTO Minion.BackupEncryption
        ( [DBName] ,
          [BackupType] ,
          [CertType] ,
          [CertName] ,
          [EncrAlgorithm] ,
          [ThumbPrint] ,
          [IsActive]
        )
SELECT  ''DB1'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        ''BackupEncryption'' AS [CertType] ,
        ''DB1cert'' AS [CertName] ,
        ''TRIPLE_DES_3KEY'' AS [EncrAlgorithm] ,
        ''0x63855BE98E7E87B08B836243C342CCC2A0DC2B54'' AS [ThumbPrint] ,
        1 AS [IsActive];

Note: You can find the thumbprint and certificate name from master.sys.certificates. Check the MSDN article above for valid encryption algorithms.

You can of course use different settings for different backup types: you can use different certificates, and even different encryption algorithms for all databases and all backup types, to maximize security. You could even configure precode to change certificates and algorithms fairly easily even on a monthly basis. The choice is yours.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 24 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 20 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Data Waiter serves one partner' AS [DetailHeader]
	, 'There are several examples of two-partner scenarios. For example, you might want to sync settings and log data to a log shipping partner. That way, if you ever have to “fail over” to the log partner, you’ll already have Minion Backup installed and configured there with all the latest settings, and with a history of backups complete. 

Let’s walk through an example where we want to sync our primary server’s MB settings and logs to a sync partner. The primary instance is Server1, and the target instance is Server2.

First, install Minion Backup on Server2 (the destination instance), just like you would install it on any other instance. MB is smart enough not to attempt backing up databases that are offline. 

Next, configure the synchronization partners in the Minion.SyncServer table on Server1:
INSERT  INTO Minion.SyncServer
        ( [Module] ,
          [DBName] ,
          [SyncServerName] ,
          [SyncDBName] ,
          [Port] ,
          [ConnectionTimeoutInSecs]
        )
SELECT  ''Backup'' AS [Module] ,
        ''master'' AS [DBName] ,	-- DB in which Minion is installed locally
        ''Server2'' AS [SyncServerName] , -- Name of the sync partner
        ''master'' AS [SyncDBName] ,	-- DB in which Minion is installed on the sync partner
        1433 AS [Port] ,		-- Port of the sync partner
        10 AS [ConnectionTimeoutInSecs];

Enable the Data Waiter for settings and/or logs, in the Minion.BackupSettingsServer table on Server1. We are not only enabling the Data Waiter, but also choosing the schedule on which we want the synchronizations to run. It’s a good idea to sync logs very frequently, as MB is always adding to the log. But settings can be synchronized less frequently. 

In our example, we will enable log synchronization on a frequent schedule (in this case, an hourly log backup schedule); and enable settings sync on a less frequent schedules (a weekly system database full backup):
-- Enable log synchronization
UPDATE  Minion.BackupSettingsServer
SET     SyncLogs = 1
WHERE   DBType = ''System''
        AND BackupType = ''Full''
        AND Day = ''Sunday'';

-- Enable settings synchronization
UPDATE  Minion.BackupSettingsServer
SET     SyncSettings = 1
WHERE   DBType = ''User''
        AND BackupType = ''Log''
        AND Day = ''Daily'';

IMPORTANT: In Minion Backup 1.0, when you enabled log sync or settings sync for a schedule, it became possible for the Data Waiter to cause the backup job to run very long, if there were synch commands that failed (for example, due to a downed sync partner). This issue has been greatly improved in Minion Backup 1.1; a downed sync partner will produce at maximum two timeouts (instead of one timeout per row).

Run the Minion.BackupSyncSettings procedure, to prepare a snapshot of settings data.
EXEC Minion.BackupSyncSettings;

Run Minion.SyncPush on Server1, to initialize the sync partner. This will push the current settings and the contents of the log files to the Server2 sync partner. While we could run Minion.SyncPush once (with @Tables = ‘All’ and @Process = ‘All’), it is more efficient to run it once for logs (with @Process=’All’) and once for settings (with @Process=’New’): 
EXEC Minion.SyncPush
	  @Tables = ''Logs''
	, @SyncServerName = NULL
	, @SyncDBName = NULL
	, @Port = NULL
	, @Process = ''All''
	, @Module = ''Backup'';

EXEC Minion.SyncPush
	  @Tables = ''Settings''
	, @SyncServerName = NULL
	, @SyncDBName = NULL
	, @Port = NULL
	, @Process = ''New''
	, @Module = ''Backup'';

Note: The three middle parameters – SyncServerName, SyncDBName, and Port – should be left NULL, as we have already configured the target sync server in Minion.SyncServer. These parameters are used for ad hoc synchronization scenarios. 

From this point forward, Minion Backup will continue to synchronize settings and log data to the Server2 sync partner. If Server2 is unavailable at any point, MB will track those entries that failed to synchronize; when the instance becomes available again, the Data Waiter will roll through the changes to bring Server2 back up to date.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 10 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Include databases in table based scheduling' AS [DetailHeader]
	, 'Table based scheduling pulls backup schedules and other options from the Minion.BackupSettingsServer table. In this table, you have the following options for configuring which databases to include in backup operations: 

  * To include all databases in a backup operation, set Include = ‘All’ (or NULL) for the relevant row(s). 
  * To include a specific list of databases, set Include = a comma delimited list of those database names, and/or LIKE expressions.  (For example: ‘YourDatabase, DB1, DB2’, or ‘YourDatabase, DB%’.)
  * To include databases based on regular expressions, set Include = ‘Regex’.  Then, configure the regular expression in the Minion.DBMaintRegexLookup table.

We will use the following sample data as we demonstrate each of these options. This is a subset of Minion.BackupSettingsServer columns:
ID DBType BackupType Day      BeginTime EndTime  Include Exclude
1  System Full       Daily    22:00:00  22:30:00 NULL    NULL
2  User   Full       Friday   23:00:00  23:30:00 DB1,DB2 NULL
3  User   Full       Saturday 23:00:00  23:30:00 DB10%   NULL
4  User   Full       Sunday   23:00:00  23:30:00 Regex   NULL
5  User   Log        Daily    00:00:00  23:59:00 NULL    NULL

And, these is the contents of the Minion.DBMaintRegexLookup table:
Action  MaintType Regex
Include Backup    DB[3-5](?!\d)

Based on this data, Minion Backup would perform backups as follows: 
  * Full system database backups run daily at 10pm.
  * Full user database backups for DB1 and DB2 run Fridays at 11pm.
  * Full user database backups for all databases beginning with “DB10” run Saturdays at 11pm.
  * Full user database backups for databases included in the regular expressions table (Minion.DBMaintRegexLookup), run Sundays at 11pm. (This particular regular expression includes DB3, DB4, and DB5, but does not include any database with a 2 digit number at the end, such as DB35.)
  * User log backups run daily (as often as the backup job runs).

Note that you can create more than one regular expression in Minion.DBMaintRegexLookup. For example: 
  * To use Regex to include DB3, DB4, and DB5: insert a row like the example above, where Regex = ’DB[3-5](?!\d)’.
  * To use Regex to include any database beginning with the word “Market” followed by a number: insert a row where Regex=’Market[0-9]’.
  * With these two rows, a backup operation with @Include=’Regex’ will backup both the DB3-DB5 databases, and the databases Marketing4 and Marketing308 (and similar others, if they exist). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 11 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Exclude a database from all backups' AS [DetailHeader]
	, 'To exclude a database – for example, DB13 – from all backups, just insert a database-specific row for that database into Minion.BackupSettings, with BackupType=All and Exclude=1: 
INSERT  INTO Minion.BackupSettings
        ( [DBName] ,
          [BackupType] ,
          [Exclude] ,
          [LogLoc] ,
          [HistRetDays] ,
          [IsActive]
        )
SELECT  ''DB13'' AS [DBName] ,
        ''All'' AS [BackupType] ,
        1 AS [Exclude] ,
        ''Local'' AS [LogLoc] ,
        60 AS [HistRetDays] ,
        1 AS [IsActive] ;

This insert has a bare minimum of options, as the row is only intended to exclude DB13 from the backup routine. We recommend configuring individual database rows with the full complement of settings if there is a chance that backups may be re-enabled for that database in the future.

IMPORTANT: Exclude=1 can be overridden by an explicit Include. For more information, see “Include and Exclude Precedence”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'ParseMethod' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ParseMethod' AS [DetailHeader]
	, 'The definition of the dynamic part.

Typically, this is a TSQL expression that resolves to the value desired. For example, the ParseMethod for “Millisecond” is 

DATEPART(MILLISECOND, @ExecutionDateTime)' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name

Valid inputs: 
<specific database name>
MinionDefault' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Configuration Settings Hierarchy' AS [DetailHeader]
	, 'The basic configuration for backup – including most of the BACKUP DATABASE and BACKUP LOG options – is stored in a table: Minion.BackupSettings.  A default row in Minion.BackupSettings (DBName=’MinionDefault’) provides settings for any database that doesn’t have its own specific settings.  

There is a hierarchy of granularity in Minion.BackupSettings, where more specific configuration levels completely override the less specific levels. That is:

  1. The MinionDefault row applies to all databases that do NOT have any database-specific rows.
  
  2. A MinionDefault row with BackupType=’Full’ (or Log, or Diff) provides settings for that backup type, for all databases that do NOT have any database-specific rows. This overrides the MinionDefault / All row.
  
  3. A database-specific row with BackupType=’All’ causes all of that database’s backup settings to come from that particular row (not from a MinionDefault row).
  
  4. A database-specific row with BackupType=’Full’ (or Log, or Diff) causes all of that database’s backup settings for that backup type to come from that particular row (not from a MinionDefault row, nor from the database-specific row where backupType=’All’).

----The Configuration Settings Hierarchy Rule----
If you provide a database-specific row, be sure that all backup types are represented in the table for that database. For example, if you insert a row for DBName=’DB1’, BackupType=’Full’, then also insert a row for DBName=’DB1’, BackupType=’All’ (or, alternately, two rows for DBName=’DB1’: one for Diff, and one for Log). Once you configure the settings context at the database level, the context stays at the database level, and not the default ‘MinionDefault’ level. 

This document refers to the Configuration Hierarchy Settings Rule throughout, in situations where we must insert additional row(s) to provide for all backup types.

Note: “Exclude” is a minor exception to the hierarchy rules. If Exclude=1 for a database where BackupType=’All’, then all backups for that database are excluded.

Other tables hold additional backup configuration settings, and follow a similar hierarchy pattern. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, '@DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'SYSNAME' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'Action' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'Action' AS [DetailHeader]
	, 'Action to perform with this regular expression.
Valid inputs: INCLUDE, EXCLUDE' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 62 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Moving Parts' AS [DetailHeader]
	, 'A complete Data Waiter scenario has several moving parts on the primary instance: 
  * The Minion.SyncServer table allows you to configure synchronization partners (i.e., server to which you would like the primary instance to share data). 
  * The fields “SyncLogs” and “SyncSettings” in the Minion.BackupSettingsServer table allow you to enable log and/or settings synchronization for one or more schedules. So, if you enable SyncSettings on a weekly schedule, your settings will be synchronized weekly; enable log settings on a log backup schedule that runs hourly, and the log settings will synchronize hourly.
  * The Minion.BackupSyncLogs procedure loads INSERT/UPDATE/DELETE statements, designed to bring log data up to date, to the Minion.SyncServer table.
  * The Minion.BackupSyncSettings procedure loads a snapshot of the settings data (TRUNCATE / INSERT) to the Minion.SyncServer table.
  * The Minion.SyncCmds table holds the synchronization commands that are to be pushed to sync partners.
  * The Minion.SyncPush procedure pushes data to sync partners. We use this to initialize the synch partner in the beginning; and Minion Backup uses it to keep sync partners up to date.
  * The Minion.SyncErrorCmds table holds synchronization commands that failed to push to sync partners. In tandem with the Minion.SyncCmds “ErroredServers” field, Minion.SyncErrorCmds allows the Data Waiter to retry only those statements that failed, and only on those sync partners where they failed.

When enabled and set up, the Data Waiter synchronizes the following tables among configured instances:
  * all settings tables, except the Minion.SyncServer table (because that table’s data is only applicable on the current instance).
  * all log tables, except:
     - Minion.BackupDebug
     - Minion.BackupDebugLogDetails
     - Minion.BackupHeaderOnlyWork
     - Minion.SyncCmds
     - Minion.SyncErrorCmds
     - Minion.Work' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Introduction' AS [DetailHeader]
	, 'Once you are familiar with the backup tuning process, you can perform an analysis, and then set up specific thresholds in the Minion.BackupTuningThresholds table. It is a “Thresholds” table, because you cannot tune a backup once and disregard database growth; backup tuning settings must change as a database grows. So, Minion Backup allows you to configure a different collection of backup tuning settings for different sized databases (thereby, defining backup tuning thresholds). As your database grows and shrinks, Minion Backup will use the settings you’ve defined for those sizes, so that backups always stay at peak performance.

Note: You can get more specific information about the Minion.BackupTuningThresholds table in the “Minion.BackupTuningThresholds” section.

As a small example, here is a limited rowset for Minion.BackupTuningThresholds, which shows different backup tuning settings for a single database at various sizes, and for two different backup types:

DBName BackupType SpaceType    ThresholdMeasure ThresholdValue NumberOfFiles Buffercount MaxTransferSize
DB1    Full       DataAndIndex GB               0              2             30          1048576
DB1    Full       DataAndIndex GB               50             5             50          2097152
DB1    Diff       DataAndIndex GB               0              2             30          1048576
DB1    Log        Log          GB               0              1             15          1048576

This sample data shows two threshold levels for DB1 full backups: one for databases larger than 50GB, and one for databases above 0GB. Note that the threshold value is a “floor” threshold: so, if DB1 is 25GB, it will use the 0GB threshold settings; if it is 60GB, it will use the 0GB threshold settings.  The sample data also shows just one threshold level each for DB1 log backups and DB1 differential backups.

Of course, we could add additional rows for each type, for different size thresholds. This is what puts the “dynamic” in “dynamic backup tuning”; Minion Backup will automatically change to the new group of settings when your database passes the defined threshold. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ID' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ID' AS [DetailHeader]
	, 'Primary key row identifier.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Table based scheduling' AS [DetailHeader]
	, 'When Minion Backup is installed, it uses a single backup job to run the stored procedure Minion.BackupMaster with no parameters, every 30 minutes.  When the Minion.BackupMaster procedure runs without parameters, it uses the Minion.BackupSettingsServer table to determine its runtime parameters (including the schedule of backup jobs per backup type). This is how MB operates by default, to allow for the most flexible backup scheduling with as few jobs as possible.
Table based scheduling presents multiple advantages: 
  * A single backup job – Multiple backup jobs are, to put it simply, a pain. They’re a pain to update and slow to manage, as compared with using update and insert statements on a table.
  * Fast, repeatable configuration – Keeping your backup schedules in a table saves loads of time, because you can enable and disable schedules, change frequency and time range, etc. all with an update statements. This also makes standardization easier: write one script to alter your backup schedules, and run it across all Minion Backup instances (instead of changing dozens or hundreds of jobs).
  * Mass updates across instances – With a simple PowerShell script, you can take that same script and run it across hundreds of SQL Server instances, standardizing your entire enterprise all at once.
  * Transparent scheduling – Multiple backup jobs tend to obscure the backup scenario, because each piece of the configuration is displayed in separate windows. Table based scheduling allows you to see all aspects of the backup schedule in one place, easily and clearly.
  * Boundless flexibility – Table based scheduling provides an amazing degree of flexibility that would be very troublesome to implement with multiple jobs. With one job, you can schedule all of the following: 
     - System full backups three days a week.
     - User full backups on weekend days and Wednesday.
     - DB1 log backups between 7am and 5pm on weekdays.
     - All other user log backups between 1am and 11pm on all days.
     - Differential backups for DB2 at 2am and 2pm.
     - Read only backups on the first of every month.
     - …and each of these can also use dynamic backup tuning, which can also be slated for different file sizes, applicable at different times and days of the week and year.
     - …and each of these can also stripe across multiple files, to multiple locations, and/or copy to secondary locations, and/or mirror to a secondary location.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@Tables' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The category of table that you want to sync: log tables, settings tables, or both.
Note: NULL is equivalent to All.
Valid inputs:
NULL
All
Logs
Settings' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 57 AS [ObjectID]
	, '@Module' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The name of the module to retrieve help for.  

Valid inputs include:
NULL
Reindex' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, '@DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Database name' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@DBType' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The type of database.
Valid inputs: System, User' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 56 AS [ObjectID]
	, '@TableName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The name of the table to generate an insert statement for. 

Note: This can be in the format "Minion.BackupSettings" or just "BackupSettings".' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 54 AS [ObjectID]
	, '@IntervalInSecs' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The amount of time to wait before updating the table again (in the format ''h:m:ss''). Default value = ‘0:00:05’ (5 seconds).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, '@DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, ' Database name.' AS [DetailText]
	, 'Sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 52 AS [ObjectID]
	, '@ExecutionDateTime' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The date of the backup batch to synchronize.' AS [DetailText]
	, 'Datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 53 AS [ObjectID]
	, '@ExecutionDateTime' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The date of the backup batch to synchronize.' AS [DetailText]
	, 'Datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, '@DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Database name. 
The value ‘All’ will delete files for all databases on the instance.
Valid options: <database name>, All' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, '@DBName' AS [DetailName]
	, 20 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'Sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 20 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why should I run Minion.BackupMaster instead of Minion.BackupDB? ' AS [DetailHeader]
	, 'We HIGHLY recommend using Minion.BackupMaster for all of your backup operations, even when backing up a single database.  To explore the “why”, let’s look at each of the two procedures briefly.
  * The Minion.BackupDB stored procedure creates and runs the actual backup statement for a single database, using the settings stored in the Minion.BackupSettings table.
  * The Minion.BackupMaster procedure makes all the decisions on which databases to back up, and what order they should be in. It calls Minion.BackupDB to perform a backup per database, within a single backup batch.

So why run Minion.BackupMaster?
  * It unifies your code, and therefore minimizes your effort.  By calling the same procedure every time you reduce your learning curve and cut down on mistakes.  
  * Future functionality may move to the Minion.BackupMaster procedure; if you get used to using Minion.Backup Master now, then things will always work as intended.
  * Minion.BackupMaster takes advantage of rich include and exclude functionality, including regular expressions, like expressions, and comma-delimited lists. Even better, when run without parameters, it takes advantage of rich table-based scheduling and all the benefits associated.
  * The master SP performs extensive logging, and it enables Live Insight via the status monitor job (which updates each backup percentage complete as it runs). 
  * Minion.BackupMaster runs configured pre- and postcode, determines AG backup location, performs file actions (such as copy and move), and runs the Data Waiter feature to synchronize log and settings data across instances. 

In short, Minion.BackupMaster decides on, runs, or causes to run every feature in Minion Backup.  Don’t shortcut your features list by running Minion.BackupDB. Use Minion.BackupMaster! ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'ServerName' AS [DetailName]
	, 20 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerName' AS [DetailHeader]
	, 'The name of the server to restore to. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'Module' AS [DetailName]
	, 21 AS [Position]
	, 'Column' AS [DetailType]
	, 'Module' AS [DetailHeader]
	, 'The name of the module to retrieve help for.  

Valid inputs include:
Reindex
Backup
CheckDB' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ExecutionDateTime' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionDateTime' AS [DetailHeader]
	, 'Date and time the entire backup operation took place.  ' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, '@RetHrs' AS [DetailName]
	, 22 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Delete files older than the number of hours specified here. 
NULL will cause the SP to use the retention hours (RetHrs) field in the Minion.BackupFiles table.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'MaintType' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaintType' AS [DetailHeader]
	, 'Maintenance type to which this applies.
Valid inputs: All, Reindex, Backup, CheckDB' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database type. 
Valid values: User, System' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, '@BackupType' AS [DetailName]
	, 22 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Backup type.
Valid inputs: Full, Log, Diff' AS [DetailText]
	, 'VARCHAR' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type.
Valid inputs: ALL, Full, Diff, Log
Note that ALL encompasses full, differential, and log backups.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'DBType' AS [DetailName]
	, 22 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBType' AS [DetailHeader]
	, 'Database type. 
Valid values: User, System' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type.
Valid inputs: Full, Diff, Log' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'SpaceType' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'SpaceType' AS [DetailHeader]
	, 'The way in Minion Backup determines the size of the database (e.g., data only, data and index, etc.)
Note that this column is ignored for log backups, but you should put “Log” here anyway for rows where BackupType=Log, because it’s descriptive. 
Valid inputs: DataAndIndex, Data, File, Log' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, '@StmtOnly' AS [DetailName]
	, 24 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Generate back up statements without running the statements.' AS [DetailText]
	, 'BIT' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'SyncServerName' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncServerName' AS [DetailHeader]
	, 'Name of the target server, or of the target category, where you want to ship the table entries to. 
  * Use “AGReplica” if the database is in an Availability Group. Minion Backup will automatically ship to all the replicas for that AG.
  * Use “MirrorPartner” if the databases is mirrored, and you want to sync to the mirroring partner.
  * Use “LogShippingPartner” in a log shipping scenario. 
  * Or use the specific server name.
If you have either a server that isn’t one of those three, OR an AG replica where you only want to send to 1 or 2 replicas, you can enter in server names manually.
Single server: “servername\instancename”, e.g. “Server1”, “Server2\SQL”.
If you have multiple servers, you don’t need multiple rows; just use pipes: “Server1|Server2\SQL|Server3”. One example of where this would be useful: if you routinely do restores to a development server from a production server, you can sync the logs from the production server to the development server.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'Regex' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'Regex' AS [DetailHeader]
	, 'Regular expression to match a database name, or set of database names.' AS [DetailText]
	, 'nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, '@Delete' AS [DetailName]
	, 24 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Delete files. Defaults to 1.
@Delete=0 will return a list of the files that will be deleted, and the amount of space that would be freed.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'STATUS' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'STATUS' AS [DetailHeader]
	, 'Current status of the backup operation.  If Live Insight is being used the status updates will appear here.  When finished, this column will typically either read ‘Complete’ or ‘Complete with warnings’.

If, for example, the backup process was halted midway through the operation, the Status would reflect the step in progress at the time the operation stopped.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'isMirror' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'isMirror' AS [DetailHeader]
	, 'Is a backup mirror location.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'CertType' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'CertType' AS [DetailHeader]
	, 'Certificate type. Valid inputs: BackupEncryption' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Port' AS [DetailName]
	, 24 AS [Position]
	, 'Column' AS [DetailType]
	, 'Port' AS [DetailHeader]
	, 'Port number for the instance.  If this is NULL, we assume the port number is 1433.

Minion Backup includes the port number because certain operations that are shelled out to sqlcmd require it.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 10 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Include databases in traditional scheduling' AS [DetailHeader]
	, 'We refer the common practice of configuring backups in separate jobs (to allow for multiple schedules) as “traditional scheduling”. Shops that use traditional scheduling will run Minion.BackupMaster with parameters configured for each particular backup run.

You have the following options for configuring which databases to include in backup operations: 
  * To include all databases in a backup operation, set @Include = ‘All’ (or NULL). 
  * To include a specific list of databases, set @Include = a comma delimited list of those database names, and/or LIKE expressions.  (For example: ‘YourDatabase, DB1, DB2’, or ‘YourDatabase, DB%’.)
  * To include databases based on regular expressions, set @Include = ‘Regex’.  Then, configure the regular expression in the Minion.DBMaintRegexLookup table.

The following example executions will demonstrate each of these options. 

First, to run full user backups on all databases, we would execute Minion.BackupMaster with these (or similar) parameters:
-- @Include = NULL for all databases
EXEC Minion.BackupMaster 
	@DBType = ''User'', 
	@BackupType = ''Full'', 
	@StmtOnly = 1,
    	@Include = NULL,
	@Exclude=NULL,
	@ReadOnly=1;

To include a specific list of databases:
-- @Include = a specific database list (YourDatabase, all DB1% DBs, and DB2)
EXEC Minion.BackupMaster 
	@DBType = ''User'', 
	@BackupType = ''Full'', 
	@StmtOnly = 1,
    	@Include = ''YourDatabase,DB1%,DB2'',
	@Exclude=NULL,
	@ReadOnly=1;

To include databases based on regular expressions, first insert the regular expression into the Minion.DBMaintRegexLookup table, and then execute Minion.BackupMaster with @Include=’Regex’: 
INSERT  INTO Minion.DBMaintRegexLookup
        ( [Action] ,
          [MaintType] ,
          [Regex]
        )
SELECT  ''Include'' AS [Action] ,
        ''Backup'' AS [MaintType] ,
        ''DB[3-5](?!\d)'' AS [Regex]
-- @Include = ''Regex'' for regular expressions
EXEC Minion.BackupMaster 
	@DBType = ''User'', 
	@BackupType = ''Full'', 
	@StmtOnly = 1,
    @Include = ''Regex'',
	@Exclude=NULL,
	@ReadOnly=1;

For information on Include/Exclude precedence (that applies to both the Minion.BackupSettingsServer columns, and to the parameters), see “Include and Exclude Precedence”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 11 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Exclude databases in table based scheduling' AS [DetailHeader]
	, 'Table based scheduling pulls backup schedules and other options from the Minion.BackupSettingsServer table. In this table, you have the following options for configuring which databases to exclude from backup operations: 
  * To exclude a specific list of databases, set Exclude = a comma delimited list of those database names, and/or LIKE expressions.  (For example: ‘YourDatabase, DB1, DB2’, or ‘YourDatabase, DB%’.)
  * To exclude databases based on regular expressions, set Exclude = ‘Regex’.  Then, configure the regular expression in the Minion.DBMaintRegexLookup table.

We will use the following sample data as we demonstrate each of these options. This is a subset of Minion.BackupSettingsServer columns:
ID DBType BackupType Day      BeginTime EndTime  Include Exclude
1  System Full       Daily    22:00:00  22:30:00 NULL    NULL
2  User   Full       Friday   23:00:00  23:30:00 NULL    DB1,DB2
3  User   Full       Saturday 23:00:00  23:30:00 NULL    DB10%
4  User   Full       Sunday   23:00:00  23:30:00 NULL    Regex
5  User   Log        Daily    00:00:00  23:59:00 NULL    NULL

And, these is the contents of the Minion.DBMaintRegexLookup table:
Action  MaintType Regex
Exclude Backup    DB[3-5](?!\d)

Based on this data, Minion Backup would perform backups as follows: 
  * Full system database backups run daily at 10pm.
  * Full user database backups for all databases – except DB1 and DB2 – run Fridays at 11pm.
  * Full user database backups for all databases – except those beginning with “DB10” – run Saturdays at 11pm.
  * Full user database backups for all databases – except for those excluded via the regular expressions table (Minion.DBMaintRegexLookup) – run Sundays at 11pm. (This particular regular expression excludes DB3, DB4, and DB5 from backups, but does not exclude any database with a 2 digit number at the end, such as DB35.)
  * User log backups run daily (as often as the backup job runs).

Note that you can create more than one regular expression in Minion.DBMaintRegexLookup. For example: 
  * To use Regex to exclude DB3, DB4, and DB5: insert a row like the example above, where Regex = ’DB[3-5](?!\d)’.
  * To use Regex to exclude any database beginning with the word “Market” followed by a number: insert a row where Regex=’Market[0-9]’.
  * With these two rows, a backup operation with @Exclude=’Regex’ will exclude both the DB3-DB5 databases, and the databases Marketing4 and Marketing308 (and similar others, if they exist) from backups.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ExecutionDateTime' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionDateTime' AS [DetailHeader]
	, 'Date and time the entire backup operation took place.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 28 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, '
Discussion' AS [DetailHeader]
	, 'You can back certificates up to as many locations as you like. For example, to back up server certificates to two location, insert one row for each target location into Minion.BackupSettingsPath with BackupType = ‘ServerCert’, and the remaining fields populated as specified in the “How to: Configure certificate backups” section. 

Note that certificate entries in Minion.BackupSettingsPath do not need to populate DBName. We use DBName=‘MinionDefault’ in the examples given, but one could just as easily use DBName=’Certificate’, DBName=’ServerCert’, or any other non-null value. The important thing is that BackupType must be set to ‘ServerCert’ or ‘DatabaseCert’.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 12 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Batch precode and postcode' AS [DetailHeader]
	, 'Batch precode and postcode run before and after an entire backup operation. 

To run code before or after a backup batch, update (or insert) the appropriate row in Minion.BackupSettingsServer. In that row, populate the BatchPreCode column to run code before the backup operation; and populate the column BatchPostCode to run code after the backup operation.  For example: 
UPDATE  Minion.BackupSettingsServer
SET	BatchPreCode = ''EXEC master.dbo.BackupPrep;'' ,
        	BatchPostCode = ''EXEC master.dbo.BackupCleanup;''
WHERE   DBType = ''User''
        AND BackupType = ''Full''
        AND Day = ''Saturday'';

IMPORTANT: The Minion.BackupSettingServer columns BatchPreCode and BatchPostCode are only in effect for table based scheduling – that is, running Minion.BackupMaster without parameters. If you use parameter based scheduling, the only way to enact batch precode or batch postcode is with additional job steps.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 23 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Encrypt backups for all databases' AS [DetailHeader]
	, 'You also have the option to configure backup encryption for all databases very easily, as long as you don’t mind using the same certificate and algorithm for all of them. Just follow the instructions for a single database, as outlined above, with the following changes: 
  * Instead of inserting a row to Minion.BackupSettings, update the MinionDefault / All row to enable backup encryption.
  * Instead of inserting a row to Minion.BackupEncryption for a single database, insert a row for MinionDefault.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'System requirements' AS [DetailHeader]
	, '   *  SQL Server 2008* or above.
   *  The sp_configure setting xp_cmdshell must be enabled**.
   *  PowerShell 2.0 or above; execution policy set to RemoteSigned.
  
*There is a special edition of Minion Backup specifically for SQL Server 2005. But, be aware that this edition will not be enhanced or upgraded, some functionality is reduced, and it will have limited support.
** xp_cmdshell can be turned on and off with the database PreCode / PostCode options, to help comply with security policies. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 25 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 1: Proper Configuration' AS [DetailHeader]
	, 'Let us take a simple example, in which these are the contents of the Minion.BackupSettings table (not all columns are shown here):
ID DBName        BackupType	Exclude DBPreCode
1  MinionDefault All        0       ''Exec SP1;''
2  DB1           All        0       ''Exec SP1;''
3  DB1           Full       0       NULL

There are a total of 30 databases on this server. As backups run throughout the week, the settings for individual databases will be selected as follows: 
  * Full backups of database DB1 will use only the settings from the row with ID=3. 

  * Differential and log backups of database DB1 will use only the settings from the row with ID=2. 

  * All other database backups (full, log, and differential) will use the settings from the row with ID=1.

Note that a value left at NULL in one of these fields means that Minion Backup will use the setting that the SQL Server instance itself uses. So in our example, full backups of DB1 will run no precode; while all other backups will run ‘Exec SP1;’ as the database precode. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'RestoreType' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreType' AS [DetailHeader]
	, 'Restore type.

Valid inputs:
Full
Diff
Log
All' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'IsCustom' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsCustom' AS [DetailHeader]
	, 'Whether this is a custom dynamic part, or one that came with the product originally.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, '@DateLogic' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The date and time, in YYYYMMDDHHMMSS format. Used to select the correct records from Minion.BackupFiles.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, '@BackupType' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, ' Specifies full, log, or differential backups.

Valid inputs:
Full
Diff 
Log' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@BackupType' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Specifies full, log, or differential backups.
Valid inputs: Full, Log, Diff' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, '@BackupType' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Backup type. 
Valid inputs:  Full, Diff, Log' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 57 AS [ObjectID]
	, '@Name' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The name of the topic for which you would like help.  

If you run Minion.HELP by itself, or with a @Module specified, it will return a list of available topics.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@SyncServerName' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'This is the name of the target server you want to push the data to. Note that this parameter accepts a single server name, not a delimited list. ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Parameter Based Scheduling' AS [DetailHeader]
	, 'Other SQL Server native backup solutions traditionally use one backup job per schedule. Typically and at a minimum, that means one job for system database full backups, one job for user database full backups, and one job for log backups.

Note: Whether you use table based or parameter based scheduling, we highly recommend always using the Minion.BackupMaster stored procedure to run backups. While it is possible to use Minion.BackupDB to execute backups, doing so will bypass much of the configuration and logging benefits that Minion Backup was designed to provide. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 56 AS [ObjectID]
	, '@ID' AS [DetailName]
	, 25 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The ID number of the row you''d like to clone. See the discussion below.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Enabled by Default' AS [DetailHeader]
	, 'Default backup tuning settings are in effect the moment that Minion Backup is installed: the system comes installed with a default “MinionDefault” row in Minion.BackupTuningThresholds. These backup tuning settings are used for any database which does not have a specific set of thresholds defined for it; as well as for any database that has dynamic tuning disabled in Minion.BackupSettings. 

While this last point may seem inconsistent – after all, why should a database refer to the “MinionDefault” row in this table if dynamic tuning is disabled? – in fact, it makes perfect sense:
  * First, the default backup tuning settings cannot truly be said to be “dynamic”, as the dynamic aspect of backup tuning comes from having different settings for a database come into effect automatically as the database grows. The MinionDefault row in this table has a threshold size of 0GB, and so applies to databases of all sizes.
  * Second, most of the settings in the MinionDefault row are “passive”: NumberOfFiles is 1, which is the case for any backup where number of files is not specified. And Buffercount, MaxTransferSize, and BlockSize are zero, meaning SQL Server is free to choose the appropriate value for these settings at the time the backup runs. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 62 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Use Cases' AS [DetailHeader]
	, 'There are many situations where the Data Waiter feature will be very useful. The primary use case is in any HA/DR scenario where it is possible to “fail over” to another instance. A few of these use cases:
  * Four instances that host Availability Group replicas, where a secondary replica may become primary.
  * A database mirrored across two instances.
  * Several databases that are log shipped to a warm standby server.
  * A set of databases replicated to several subscriber servers.
  * A HA scenario using third party software, which involves multiple instances.

In each of these cases, the Data Waiter provides an additional layer of transparency to the failover process. After failover, you do not have to reconfigure the backup settings, nor to make sure that old backup files are deleted (so long as the backups are going to UNC).

IMPORTANT: We highly recommend backing up to UNC paths, instead of to locally defined drives. If you have backups going to UNC, and your HA/DR scenario fails over to another server, that server can continue backing up to (and deleting old files from) that same location. Conversely, if Minion Backup is configured to back up locally, it will not be able to delete files from the previous location.

After a failover, you should configure the new primary server’s Minion.SyncServer table to point to the other sync partner(s) in the Data Waiter scenario. This is very like a log shipping “failover”, where – once you have failed over to the secondary node – you need to set up log shipping in the other direction.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestoreType' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreType' AS [DetailHeader]
	, 'Restore type. 

Note that this can only be “Full”, because only a full restore will require a path.

Valid inputs:
Full' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 25 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why must I supply values for all backup types for a database in the settings tables? ' AS [DetailHeader]
	, 'Several settings tables – including Minion.BackupSettings, Minion.BackupSettingsPath, and Minion.BackupTuningThresholds – provide a MinionDefault / All row to provide settings for databases that do not have specific settings defined. In this way, there is a base level default that allows Minion Backup to function immediately upon installation.

We made a design decision to “keep in the scope” once any database-specific settings were defined. In other words, once the configuration context is at the database level, it stays at the database level. Therefore, if you define a database-specific row, you must be sure that all backup types are represented for that database. 

The reasoning behind this rule is this: It takes a conscious act (inserting a row) to change settings for a specific database. So, we don’t want the system to “fall back” on default values, possibly countermanding the intended configuration for that particular database. 

For more information, see “Backup tuning threshold precedence”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'ExecutionDateTime' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionDateTime' AS [DetailHeader]
	, 'Date and time the command took place.  ' AS [DetailText]
	, 'Datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'SyncServerName' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncServerName' AS [DetailHeader]
	, 'Name of the synchronization target server.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'GroupName' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'GroupName' AS [DetailHeader]
	, '	The name of the group. This is the identifier to be used in the @Include or @Exclude statement. ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 26 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 25 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 2: Tune backups for one database based on file size' AS [DetailHeader]
	, 'Now, we want to tune backups for our largest database: DB1. You have the option of basing tuning thresholds on data size only, on data and index size, or on file size. (Note that file size includes any unused space in the file; “data and index” does not.)  You also have the option to tune specifically for full, differential, or log backups; or for all three (BackupType=’All’). We choose to set DB1’s backup tuning thresholds based on file size, for all backup types.

First, perform your backup tuning analysis. Minion Backup is a huge help to your analysis, because it gathers and records the backup settings for EVERY backup (including Buffercount, MaxTransferSize, etc.) in Minion.BackupLogDetails. These recorded settings are the actual settings that SQL Server used to take the backup, whether or not those settings were supplied by you, or chosen by SQL Server itself.

Next, enable backup tuning for DB1. In this example, backup tuning is not enabled for the MinionDefault row, and DB1 does not have an individual row. So, we must add a row for DB1 to Minion.BackupSettings. 

Generate a template insert statement for DB1 using the Minion.CloneSettings procedure:
EXEC Minion.CloneSettings ''Minion.BackupSettings'', 1;

Modify this generated insert statement for your database, changing the DBName to ‘DB1’, and setting DynamicTuning to 1:
INSERT	INTO [Minion].BackupSettings
		( [DBName] ,
		  [Port] ,
		  [BackupType] ,
		  [Exclude] ,
		  [GroupOrder] ,
		  [GroupDBOrder] ,
		  [Mirror] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [DynamicTuning] 
		)
SELECT	''DB1'' AS [DBName] ,
		1433 AS [Port] ,
		''All'' AS [BackupType] ,
		0 AS [Exclude] ,
		0 AS [GroupOrder] ,
		0 AS [GroupDBOrder] ,
		0 AS [Mirror] ,
		''Local'' AS [LogLoc] ,
		60 AS [HistRetDays] ,
		1 AS [DynamicTuning] ;
				
(Note that the statement above is does not include all available fields.)

The next step is to set the backup tuning thresholds, by entering rows into Minion.BackupTuningThresholds.  In this example, our analysis showed that DB1 should have modest backup settings for any file size below 50GB, and slightly more aggressive settings for sizes above 50GB.  So, we will enter two rows: one for file size zero to 50GB, and one for file sizes 50GB and above.

IMPORTANT: The threshold you enter represents the LOWER threshold (the “floor”). Therefore, you must be sure to enter a threshold for file size 0. If, for this example, we only entered a threshold for file sizes 50GB and above, Minion Backup would use the default (“MinionDefault”) row values for file sizes below 50GB; however, this behavior is only a failsafe, and we do not recommend relying on it. If you specify thresholds for a database, be sure to cover the 0 floor threshold. 

The first row has a lower threshold of 0GB, and sets number of files=2, buffercount=30, and max transfer size=1mb (1048576 bytes):
INSERT	INTO Minion.BackupTuningThresholds
		( [DBName] ,
		  [BackupType] ,
		  [SpaceType] ,
		  [ThresholdMeasure] ,
		  [ThresholdValue] ,
		  [NumberOfFiles] ,
		  [Buffercount] ,
		  [MaxTransferSize] ,
		  [Compression] ,
		  [BlockSize] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB1'' AS [DBName] ,
		''All'' AS [BackupType] ,
		''File'' AS [SpaceType] ,     -- Tune backups by FILE size
		''GB'' AS [ThresholdMeasure] ,
		0 AS [ThresholdValue] ,
		2 AS [NumberOfFiles] ,
		30 AS [Buffercount] ,
		1048576 AS [MaxTransferSize] ,
		1 AS [Compression] ,
		0 AS [BlockSize] ,
		1 AS [IsActive] ,
		''Lowest threshold; values above zero.'' AS [Comment];

The second row has a lower threshold of 50GB, and sets number of files=5, buffercount=50, and max transfer size=2MB (2097152 bytes):
INSERT	INTO Minion.BackupTuningThresholds
		( [DBName] ,
		  [BackupType] ,
		  [SpaceType] ,
		  [ThresholdMeasure] ,
		  [ThresholdValue] ,
		  [NumberOfFiles] ,
		  [Buffercount] ,
		  [MaxTransferSize] ,
		  [Compression] ,
		  [BlockSize] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''DB1'' AS [DBName] ,
		''All'' AS [BackupType] ,
		''File'' AS [SpaceType] ,  -- Tune backups by FILE size
		''GB'' AS [ThresholdMeasure] ,
		50 AS [ThresholdValue] ,
		5 AS [NumberOfFiles] ,
		50 AS [Buffercount] ,
		2097152 AS [MaxTransferSize] ,
		1 AS [Compression] ,
		0 AS [BlockSize] ,
		1 AS [IsActive] ,
		''Higher threshold; values above 50GB.'' AS [Comment];

Note that these rows are for BackupType = ‘All’. If we wished to, we could instead tune different kinds of backups for DB1 separately from one another. In that case, we would have one or more rows each for DB1 full, DB1 differential, and DB1 log backups.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 24 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 25 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Data Waiter serves Availability Group members' AS [DetailHeader]
	, 'The Data Waiter is perfectly tailored for AG scenarios. After you configure each replica as a synchronization partner, the Availability Group can fail over to any replica.  Data Waiter ensures that the Minion Backup settings and logs will already be up to date on that replica when it fails over.

Let’s take an example of an Availability Group where any member may become primary.  The preferred replica is AG1, and secondary replicas are AG2 and AG3.

It is fairly simple to set up the Data Waiter among all nodes in the Availability Group, using the same process as outlined above. The basic steps are:
  1. Install Minion Backup on all replicas. Note that MB is smart enough not to attempt to back up databases where it’s not supposed to.
  2. Insert a row to Minion.SyncServer on the primary server, to define a synchronization partner.
  3. Set the SyncSettings and/or SyncLog bits in the Minion.BackupSettingsServer table for one or more backup types, to determine how often settings and log tables will synchronize.
  4. Run the Minion.BackupSyncSettings procedure, to prepare a snapshot of settings data.
  5. Run Minion.SyncPush to initialize the synchronization partners.

Let’s walk through these steps in more detail.

First, install Minion Backup on AG2 and AG3 (the destination instances), just like you would install it on any other instance. MB is smart enough not to attempt backing up databases that are offline. 

Configure backups normally for any databases that are not a part of the AG. For those databases that ARE members of the AG, you can do nothing at all; Minion Backup defaults to backing up AG databases on the AGPreferred replica, and will not attempt to back up an AG database that is not on the preferred server. 

Next, configure the synchronization partners in the Minion.SyncServer table on AG1:
INSERT  INTO Minion.SyncServer
        ( [Module] ,
          [DBName] ,
          [SyncServerName] ,
          [SyncDBName] ,
          [Port] ,
          [ConnectionTimeoutInSecs]
        )
SELECT  ''Backup'' AS [Module] ,
        ''master'' AS [DBName] ,	-- DB in which Minion is installed locally
        ''AGReplica'' AS [SyncServerName] , -- Automatically detects all AG replicas.
        ''master'' AS [SyncDBName] ,	-- DB in which Minion is installed on the sync partner
        1433 AS [Port] ,		-- Port of the sync partner
        10 AS [ConnectionTimeoutInSecs];

IMPORTANT: SyncServerName=’AGReplica’ causes the Data Waiter to push settings to all nodes of an Availability Group. Minion Backup is smart enough to detect all existing AG nodes. What’s more, MB will add a new node that is added subsequent to this configuration. For more information on SyncServerName options, see the “Minion.SyncServer” section.

Enable the Data Waiter for settings and/or logs, in the Minion.BackupSettingsServer table on AG1. We are not only enabling the Data Waiter, but also choosing the schedule on which we want the synchronizations to run. It’s a good idea to sync logs very frequently, as MB is always adding to the log. But settings can be synchronized less frequently. 

In our example, we will enable log synchronization on a frequent schedule (in this case, an hourly log backup schedule); and enable settings sync on a less frequent schedules (a weekly system database full backup):
-- Enable log synchronization
UPDATE  Minion.BackupSettingsServer
SET     SyncLogs = 1
WHERE   DBType = ''System''
        AND BackupType = ''Full''
        AND Day = ''Sunday'';

-- Enable settings synchronization
UPDATE  Minion.BackupSettingsServer
SET     SyncSettings = 1
WHERE   DBType = ''User''
        AND BackupType = ''Log''
        AND Day = ''Daily'';

IMPORTANT: When you enable log sync or settings sync for a schedule, it becomes possible for the Data Waiter to cause the backup job to run very long, if there are sync commands that fail (for example, due to a downed sync partner). Consider setting the timeout to a lower value in Minion.SyncServer, to limit the amount of time that the Data Waiter will wait.

Run the Minion.BackupSyncSettings procedure, to prepare a snapshot of settings data.
EXEC Minion.BackupSyncSettings;

Run Minion.SyncPush on AG1, to initialize the servers. This will push the current settings and the contents of the log files to the AG2 sync partner. While we could run Minion.SyncPush once (with @Tables = ‘All’ and @Process = ‘All’), it is more efficient to run it once for logs (with @Process=’All’) and once for settings (with @Process=’New’): 
EXEC Minion.SyncPush
	  @Tables = ''Logs''
	, @SyncServerName = NULL
	, @SyncDBName = NULL
	, @Port = NULL
	, @Process = ''All''
	, @Module = ''Backup'';

EXEC Minion.SyncPush
	  @Tables = ''Settings''
	, @SyncServerName = NULL
	, @SyncDBName = NULL
	, @Port = NULL
	, @Process = ''New''
	, @Module = ''Backup'';

Note: The three middle parameters – SyncServerName, SyncDBName, and Port – should be left NULL, as we have already configured the target sync server in Minion.SyncServer. These parameters are used for ad hoc synchronization scenarios. 

From this point forward, Minion Backup will continue to synchronize settings and log data to the AG2 sync partner. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ExecutionDateTime' AS [DetailName]
	, 25 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionDateTime' AS [DetailHeader]
	, 'Date and time the entire backup operation took place.  If the job were started through BackupMaster then all databases in that run have the same ExecutionDateTime.  If the job was run manually from Minion.BackupDB, then this value will only be for this database.  It will still have a matching row in the Minion.BackupLog table. ' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Day' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'Day' AS [DetailHeader]
	, 'The day or days to which the settings apply.

Valid inputs:
Daily
Weekday
Weekend
[an individual day, e.g., Sunday]
FirstOfMonth
LastOfMonth
FirstOfYear
LastOfYear

Note: Note that the least frequent “Day” settings – FirstOfYear, LastOfYear, FirstOfMonth, LastOfMonth – only apply to user databases, not to system databases.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'ThresholdMeasure' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'ThresholdMeasure' AS [DetailHeader]
	, 'The measure for our threshold value.
Valid inputs: GB' AS [DetailText]
	, 'char' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'SyncDBName' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncDBName' AS [DetailHeader]
	, 'Your management database, where the Minion objects reside. (This is either ‘master’, or your custom management database.)' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, '@ExecutionDateTime' AS [DetailName]
	, 26 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Date and time the backup took place.  
If this SP was called by Minion.BackupMaster, @ExecutionDateTime will be passed in, so this backup is included as part of the entire (multi-database) backup operation.' AS [DetailText]
	, 'DATETIME' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'Comments' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comments' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, '@EvalDateTime' AS [DetailName]
	, 26 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Evaluate the file age against this date and time.  
Defaults to NULL, which evaluates the file dates against the current time.  
Passing in your own value causes the delete process to compute file age against this hypothetical date, instead of the current date.  This lets you delete files, or see what files WOULD be deleted, as if it were a different datetime.  Combined with @Delete = 0, and you can see what files will be deleted on which day, and how much disk space you would save.
WARNING: If you set @EvalDateTime to a far enough date in the future (say, a year) and pass in @Delete=1, you will delete ALL of your backup files.' AS [DetailText]
	, 'Datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type.
Valid inputs: ALL, Full, Diff, Log, ServerCert, DatabaseCert, Move, Copy
Note that ALL encompasses full, differential, and log backups.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'CertName' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'CertName' AS [DetailHeader]
	, 'Certificate name. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type.

Valid inputs: All, Full, Diff, Log

Note that “All” encompasses full, differential, and log backups.  ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'DBType' AS [DetailName]
	, 26 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBType' AS [DetailHeader]
	, 'Database type.
Valid values: System, User' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type. 
Valid values: Full, Diff, Log' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'EncrAlgorithm' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'EncrAlgorithm' AS [DetailHeader]
	, 'Encryption algorithm. For a list of valid inputs, see the list of key_algorithm entries in the MSDN article https://msdn.microsoft.com/en-us/library/ms189446.aspx' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Exclude' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'Exclude' AS [DetailHeader]
	, 'Exclude database from backups.  

For more on this topic, see “How To: Exclude databases from backups”.
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 47 AS [ObjectID]
	, '@Debug' AS [DetailName]
	, 28 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Enable logging of special data to the debug tables.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'Port' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'Port' AS [DetailHeader]
	, 'The port to be used for the connection to the target SQL Server.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'ThresholdValue' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'ThresholdValue' AS [DetailHeader]
	, 'The correlating value to ThresholdMeasure. So. if ThresholdMeasure is GB, then ThresholdValue is the value – the number of gigabytes.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'ReadOnly' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'ReadOnly' AS [DetailHeader]
	, 'Backup readonly option; this decides whether or not to include ReadOnly databases in the backup, or to perform backups on only ReadOnly databases. 
A value of 1 includes ReadOnly databases; 2 excludes ReadOnly databases; and 3 only includes ReadOnly databases.
Valid values: 1, 2, 3' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 57 AS [ObjectID]
	, '@Keyword' AS [DetailName]
	, 28 AS [Position]
	, 'Param' AS [DetailType]
	, '@Keyword' AS [DetailHeader]
	, 'This flag forces @Name to behave as a keyword; Minion.Help will use it to search all topic headers and body, and return a list of topics. 

This flag is optional; if Minion.HELP does not find a topic named @Name, it will perform the keyword search anyway.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'BackupLocType' AS [DetailName]
	, 28 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupLocType' AS [DetailHeader]
	, 'Backup location type.
Valid inputs: Local, NAS, URL, NUL
Note: URL and NUL are the most important of these; this value is what the Minion Backup process uses. The remaining inputs (NAS and URL) are just information for you. However, once combined with Minion Enterprise, these are all important for reporting.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'BackupDrive' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupDrive' AS [DetailHeader]
	, 'Backup drive. This is only the drive letter of the backup destination.
Alternately, this value can be NUL if BackupLocType is NUL.
IMPORTANT: If this is drive, this must end with colon-slash (for example, ‘M:\’). If this is URL, use the base path (for example, ‘\\server2\’)' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 26 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 30 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 3: Tune backup types for all databases based on data + index size' AS [DetailHeader]
	, 'On another server, we would like to have tuning thresholds not for individual databases, but for different backup types. And, we would like to base the thresholds on data and index size, not on file size. The steps for this are the same as before: perform the tuning analysis, then make sure tuning is enabled for the databases, and finally, create the tuning thresholds.

To make sure tuning is enabled for ALL databases on an instance, just run an update statement on Minion.BackupSettings for all rows: 
UPDATE	Minion.BackupSettings
SET	DynamicTuning = 1; 	-- Updates ALL rows

To set the threshold values per backup type, generate and run one insert statement for each backup type. For our first entry, we configure settings for full backups by setting DBName to “MinionDefault”, BackupType to “Full”, and SpaceType to “DataAndIndex”:
INSERT	INTO Minion.BackupTuningThresholds
		( [DBName] ,
		  [BackupType] ,
		  [SpaceType] ,
		  [ThresholdMeasure] ,
		  [ThresholdValue] ,
		  [NumberOfFiles] ,
		  [Buffercount] ,
		  [MaxTransferSize] ,
		  [Compression] ,
		  [BlockSize] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''MinionDefault'' AS [DBName] ,
		''Full'' AS [BackupType] ,
		''DataAndIndex'' AS [SpaceType] ,  -- Tune backups by data and index size
		''GB'' AS [ThresholdMeasure] ,
		0 AS [ThresholdValue] ,
		10 AS [NumberOfFiles] ,
		500 AS [Buffercount] ,
		2097152 AS [MaxTransferSize] ,
		1 AS [Compression] ,
		0 AS [BlockSize] ,
		1 AS [IsActive] ,
		''Default values for all FULL backups.'' AS [Comment];

And the row for differential backups uses BackupType = ‘Diff’:
INSERT	INTO Minion.BackupTuningThresholds
		( [DBName] ,
		  [BackupType] ,
		  [SpaceType] ,
		  [ThresholdMeasure] ,
		  [ThresholdValue] ,
		  [NumberOfFiles] ,
		  [Buffercount] ,
		  [MaxTransferSize] ,
		  [Compression] ,
		  [BlockSize] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''MinionDefault'' AS [DBName] ,
		''Diff'' AS [BackupType] ,
		''DataAndIndex'' AS [SpaceType] ,  -- Tune backups by data and index size
		''GB'' AS [ThresholdMeasure] ,
		0 AS [ThresholdValue] ,
		5 AS [NumberOfFiles] ,
		100 AS [Buffercount] ,
		1048576 AS [MaxTransferSize] ,
		1 AS [Compression] ,
		0 AS [BlockSize] ,
		1 AS [IsActive] ,
		''Default values for all DIFF backups.'' AS [Comment];

And the row for log backups uses BackupType = ‘Log’:
INSERT	INTO Minion.BackupTuningThresholds
		( [DBName] ,
		  [BackupType] ,
		  [SpaceType] ,
		  [ThresholdMeasure] ,
		  [ThresholdValue] ,
		  [NumberOfFiles] ,
		  [Buffercount] ,
		  [MaxTransferSize] ,
		  [Compression] ,
		  [BlockSize] ,
		  [IsActive] ,
		  [Comment]
		)
SELECT	''MinionDefault'' AS [DBName] ,
		''Log'' AS [BackupType] ,
		''Log'' AS [SpaceType] ,  -- Log backups ignore this setting
		''GB'' AS [ThresholdMeasure] ,
		0 AS [ThresholdValue] ,
		1 AS [NumberOfFiles] ,
		30 AS [Buffercount] ,
		1048576 AS [MaxTransferSize] ,
		1 AS [Compression] ,
		0 AS [BlockSize] ,
		1 AS [IsActive] ,
		''Default values for all LOG backups.'' AS [Comment];

We have now configured basic tuning settings for each type of backup.  Of course, we could add additional rows for each type, for different size thresholds. This is what puts the “dynamic” in “dynamic backup tuning”; Minion Backup will automatically change to the new group of settings when your database passes the defined threshold.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'BeginTime' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'BeginTime' AS [DetailHeader]
	, 'The start time at which this schedule applies. 
IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'STATUS' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'STATUS' AS [DetailHeader]
	, 'Current status of the backup operation.  If Live Insight is being used the status updates will appear here.  When finished, this column will typically either read ‘Complete’ or ‘Complete with warnings’.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'GroupOrder' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'GroupOrder' AS [DetailHeader]
	, 'The backup order within a group.  Used solely for determining the order in which databases should be backed up.

By default, all databases have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects.

Higher numbers have a greater “weight” (they have a higher priority), and will be backed up earlier than lower numbers.  We recommend leaving some space between assigned back up order numbers (e.g., 10, 20, 30) so there is room to move or insert rows in the ordering.  

For more information, see “How To: Backup databases in a specific order”.
' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'NumberOfFiles' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'NumberOfFiles' AS [DetailHeader]
	, 'The number of files to use for the backup.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'GroupDef' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'GroupDef' AS [DetailHeader]
	, '	The database name, or wildcard string, to be included as part of this group. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'SyncDBName' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncDBName' AS [DetailHeader]
	, 'The target database name of the synchronization target server.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 34 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'Note that you can create more than one regular expression in Minion.DBMaintRegexLookup. For example: 
  * To use Regex to include only DB3, DB4, and DB5: insert a row like the example above, where Regex = ’DB[3-5](?!\d)’.
  * To use Regex to include any database beginning with the word “Market” followed by a number: insert a row where Regex=’Market[0-9]’.
  * With these two rows, a backup operation with @Include=’Regex’ will backup both the DB3-DB5 databases, and the databases Marketing4 and Marketing308 (and similar others, if they exist).

For more information, see “How To: Include databases in backups” and “How To: Exclude databases from backups”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Status' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'Status' AS [DetailHeader]
	, 'Current status of the sync for this command.  
Example values: In queue, Complete' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, '@BackupType' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Backup type.
Valid inputs: Full, Log, Diff' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@StmtOnly' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Allows you to generate backup statements only, instead of running them. This is a good option if you ever need to run backup statements manually.  ' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, '@DBSize' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Database size. This parameter makes it possible to test the settings of the database at various hypothetical sizes. See discussion below.' AS [DetailText]
	, 'Decimal' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'Minion.BackupFilesDelete is useful in a number of ways. Of course, it is run with every backup operation, to keep outdated backup files cleared out. 

The interesting part of this stored procedure is the functionality the parameters give you:
  * @DBName = ‘All’ will let you delete files for all databases on the server, based off of the other parameters.  This is a great breakthrough when you need to clean up all of the databases’ backup files.  One example of when you would need this, is if permissions to the SQL account were removed from the NAS, and the files hadn’t been deleting.  You have 500 databases on the server, and they all need to be cleaned up. @DBName=’All’ would take care of it.
  * @Delete = 0 will only report on what would be deleted, with the current parameter settings. (@Delete=0 is similar to PowerShell’s -WhatIf parameter.)
  * @RetHrs = NULL uses the RetHrs setting in the Minion.BackupSettings table.  Pass in your own value instead, and the procedure will use that instead.  This allows you to do custom cleanups.
  * @EvalDateTime = NULL evaluates the file dates against the current time.  Passing in your own value will evaluate the file dates against that time.  This is very useful, as it lets you delete files as if it were a different datetime.  Combined this with @Delete = 0, and you can see what files will be deleted on which day. 

___Minion Enterprise Hint___ We are planning a Minion Enterprise tool that will centrally delete backup files for all servers!
See http://www.MidnightSQL.com/Minion  for more information, or  email us today at Support@MidnightDBA.com for a demo!

Below are three examples of how you can use this procedure: 
  * Delete files for a single database.
  * Manually delete backup files, using a custom retention period.
  * Check to see what databases would be deleted, for a custom retention period and date.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Essential Guidelines' AS [DetailHeader]
	, 'There are three essential guidelines for setting dynamic backup tuning thresholds in Minion Backup: 
  * Any group of tuning thresholds – whether it is the MinionDefault group of settings, or a database-specific group of settings – must have one row with a “floor” setting of zero. 
  * Once you have defined a single database-specific row, all backup types for that database must be represented in one or more rows. (Note that each backup type must also, therefore, have a “floor” threshold of zero represented.) For more information about this rule, see “The Configuration Settings Hierarchy Rule” in the “Architecture Overview” section.
  * However, if there is a hole in your backup tuning threshold settings, the MinionDefault row acts as a failsafe. It is best to define your backup tuning settings thoughtfully and with foresight; but the failsafe is there, just in case of oversights. (This failsafe is the exception to The Configuration Settings Hierarchy Rule; no other table can rely on the MinionDefault row in this way.) ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 62 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Failure Handling' AS [DetailHeader]
	, 'In a Data Waiter scenario, if a synchronization partner becomes unavailable over the short term, Minion Backup will track those entries that failed to synchronize.  Each time Minion.SyncPush runs, it will attempt to push the failed entries to the downed server. So when the instance becomes available again, the Data Waiter will roll through the changes to bring the sync partner back up to date.

IMPORTANT: Settings and log data that fail to sync through the Data Waiter, do not obstruct the system in any way (though it may somewhat slow the Data Waiter process over time).  For example, the Data Waiter may fail to push a command to Server1, but it will still push that command (and future ones) to Server2. The Data Waiter simply tracks the commands that did not sync to Server1 and continues to retry them against that instance, either until they succeed, or until they become outdated and are archived.

Let’s take a look at different failed sync scenarios: 
  * Commands that fail to sync to all sync partners will have Pushed = 0, and ErroredServers = <a comma-delimited list of all sync partners to which the push failed> in Minion.SyncCmds.
  * Commands that fail to sync to some, but not all, sync partners will have Pushed = 1, and ErroredServers = <a comma-delimited list of all sync partners to which the push failed> in Minion.SyncCmds.
  * Any command that failed to synchronize to one or more partners will have an entry in Minion.SyncErrorCmds.

If a synchronization partner becomes unavailable over a long period of time, we advise that you disable the Data Waiter for that instance, and reinitialize it as if it were a new sync partner when it again becomes available.  The reason for this is, after even a week or two passes, it is more efficient to set up the partner again, instead of rolling through all the changes that have accumulated.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 56 AS [ObjectID]
	, '@WithTrans' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Include “BEGIN TRANSACTION” and “ROLLBACK TRANSACTION” clauses around the insert statement, for safety.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@SyncDBName' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'This is the name of the database on the new server that holds the Minion tables.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 57 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 30 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example' AS [DetailHeader]
	, 'Examples:
For introductory help, run:
EXEC Minion.HELP; 
For introductory help on Minion Backup, run: 
EXEC Minion.HELP ''Backup'';	
For help on a particular topic – in this case, the Top 10 Features – run: 
EXEC Minion.HELP ''Backup'', ''Top 10 Features'';
To search for a keyword or key hrase, use the @Keyword parameter: 
EXEC Minion.HELP ''Backup'', ''restore'', 1;
' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, '@BackupLoc' AS [DetailName]
	, 30 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Backup location (by category). You can restore from the primary backup location, from a copy location, a mirror location, or a move location.
Note: “Backup” and “Primary” both mean the primary backup location.
Valid inputs: Backup, Primary, Mirror, Copy, Move' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why isn’t my log backup working for this database? ' AS [DetailHeader]
	, 'The most likely causes are: 
  * The database could be in the wrong recovery mode; or 
  * The database has never had a full backup before; or
  * The backups are misconfigured.

Recovery mode: Only databases in full or bulk logged mode allow log backups.  Check that your database is in either full or bulk logged mode.  For more information on SQL Server recovery models, see https://msdn.microsoft.com/en-us/library/ms189275.aspx 

Full backups: In SQL Server, a database must have had a full backup before a log backup can be taken. So Minion Backup prevents this: if you try to take a log backup, and the database doesn''t have a restore base, then the system will remove the log backup from the list. It will not attempt to take a log backup until there''s a full backup in place.  Though it may seem logical to perform a full backup instead of a full, we do not do this, because log backups can be taken very frequently; we don''t want to make what is usually a quick operation into a very long operation.

Other: If neither of these is the issue try the following: 
  * Check the Minion.BackupLog and Minion.BackupLogDetails to see if log backups are being attempted and failing, for this database. 
  * Check Minion.BackupSettings to be sure that either (a) the database in question has rows defined to cover all backup types, or (b) the database has NO database-specific rows defined, and therefore will use the MinionDefault settings.
  * Check Minion.BackupSettingsPath to be sure that (a) the database in question has rows defined to cover all backup types, or (b) the database has NO database-specific rows defined, and therefore will use the MinionDefault settings.

And as always, get support from us at www.MinionWare.net if you need it. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 30 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 2: Improper Configuration' AS [DetailHeader]
	, 'Now let’s walk through another simple example, in which these are the contents of the Minion.BackupSettings table (not all columns are shown here):
ID DBName        BackupType Exclude DBPreCode
1  MinionDefault All        0	    ''Exec SP1;''
2  DB1           Diff       0       ''EXEC SP1;''
3  DB1           Full       0       NULL

There are a total of 30 databases on this server. As backups run throughout the week, the settings for individual databases will be selected as follows: 
  * Full backups of database DB1 will use only the settings from the row with ID=3. 

  * Differential backups of database DB1 will use only the settings from the row with ID=2. 

  * Log backups of database DB1 will fail, because no row exists that covers DB1 / log backups. Again: because we have specified settings for DB1 at the database level, Minion Backup will NOT use the MinionDefault settings for DB1. 

  * All other database backups (full, log, and differential) will use the settings from the row with ID=1.

DB1 log backup failures will show up in the log tables (most easily viewable in Minion.BackupLogDetails, which will show a status that begins with “FATAL ERROR”). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'Definition' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'Definition' AS [DetailHeader]
	, 'This is the official description of the dynamic part. 

Example (BackupTypeExtension): “Returns a dynamic backup file extension based on the backup type.”' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion: Hierarchy and Precedence' AS [DetailName]
	, 30 AS [Position]
	, 'Information' AS [DetailType]
	, 'Discussion: Hierarchy and Precedence' AS [DetailHeader]
	, 'There is an order of precedence to these settings, from least frequent (First/LastOfYear) to most frequent (daily); the least frequent setting, when it applies, takes precedence over all others. For example, if today is the first of the year, and there is a FirstOfYear setting, that’s the one it runs. 
The full list, from most frequent, to least frequent (and therefore of highest precedence), is: 
  1. Daily
  2. Weekday / Weekend
  3. Monday / Tuesday / Wednesday / Thursday / Friday / Saturday / Sunday
  4. FirstOfMonth / LastOfMonth
  5. FirstOfYear / LastOfYear
Note that the least frequent “Day” settings – FirstOfYear, LastOfYear, FirstOfMonth, LastOfMonth – only apply to user databases, not to system databases. System databases may have “Day” set to a day of the week (e.g., Tuesday), Daily, or NULL (which is equivalent to “Daily”).' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'FileType' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileType' AS [DetailHeader]
	, 'The category of files that this row configures.

FileType can contain either the value “FileName” or the value “FileType”. 
•	“FileName” means that the TypeName field (below) is the name of a file (without the extension).
•	“FileType” means that TypeName is mdf, ndf, ldf, or All.

Valid values: 
FileType
FileName' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'SpaceType' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'SpaceType' AS [DetailHeader]
	, 'The way in Minion Backup determines the size of the database (e.g., data only, data and index, etc.)

Valid inputs:
DataAndIndex
Data
File' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'ThumbPrint' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'ThumbPrint' AS [DetailHeader]
	, 'A globally unique hash of the certificate. See https://msdn.microsoft.com/en-us/library/ms189774.aspx' AS [DetailText]
	, 'varbinary' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Op' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'Op' AS [DetailHeader]
	, 'The operation that was performed. For example: Backup, Copy, or Move.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 11 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 30 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Exclude databases in traditional scheduling' AS [DetailHeader]
	, 'We refer the common practice of configuring backups in separate jobs (to allow for multiple schedules) as “traditional scheduling”. Shops that use traditional scheduling will run Minion.BackupMaster with parameters configured for each particular backup run.
You have the following options for configuring which databases to exclude from backup operations: 
  * To exclude a specific list of databases, set @Exclude = a comma delimited list of those database names, and/or LIKE expressions.  (For example: ‘YourDatabase, DB1, DB2’, or ‘YourDatabase, DB%’.)
  * To exclude databases based on regular expressions, set @ Exclude = ‘Regex’.  Then, configure the regular expression in the Minion.DBMaintRegexLookup table.

The following example executions will demonstrate each of these options. 

First, to exclude a specific list of databases:
-- @Exclude = a specific database list (YourDatabase, all DB1% DBs, and DB2)
EXEC Minion.BackupMaster 
	@DBType = ''User'', 
	@BackupType = ''Full'', 
	@StmtOnly = 1,
    	@Include = NULL,
	@Exclude=''YourDatabase,DB1%,DB2'',
	@ReadOnly=1;

To exclude databases based on regular expressions, first insert the regular expression into the Minion.DBMaintRegexLookup table, and then execute Minion.BackupMaster with @Exclude=’Regex’: 
INSERT  INTO Minion.DBMaintRegexLookup
        ( [Action] ,
          [MaintType] ,
          [Regex]
        )
SELECT  ''Exclude'' AS [Action] ,
        ''Backup'' AS [MaintType] ,
        ''DB[3-5](?!\d)'' AS [Regex]
-- @Exclude = ''Regex'' for regular expressions
EXEC Minion.BackupMaster 
	@DBType = ''User'', 
	@BackupType = ''Full'', 
	@StmtOnly = 1,
@Include = NULL,
	@Exclude=''Regex'',
	@ReadOnly=1;

For information on Include/Exclude precedence (that applies to both the Minion.BackupSettingsServer columns, and to the parameters), see “Include and Exclude Precedence”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'StmtOnly' AS [DetailName]
	, 30 AS [Position]
	, 'Column' AS [DetailType]
	, 'StmtOnly' AS [DetailHeader]
	, 'Only generated backup statements, instead of running them.  ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 24 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 30 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Using Data Waiter with parallel backup schedules' AS [DetailHeader]
	, 'The Minion.BackupSettingsServer table allows Minion Backup to run one job for multiple backup schedules and options. However, this does not allow for taking more than one backup set at the same time. 

For example, a company that wishes to take a differential backup of DB1 every 4 hours, and take transaction log backups of DB2 every 15 minutes, will not be able to accomplish the simultaneous differential and transaction log backup that must happen on every fourth hour. To achieve this, we must implement a second job – which does not rely on the Minion.BackupSettingsServer table – with its own schedule, for either the DB1 differential or the DB2 transaction log backups. For our example, we will use the DB1 differential backups as the target of the second job. And we will assume that the Data Waiter scenario has already been implemented as described in the previous sections.

Because the DB1 backup job has an independent schedule, it cannot use the settings or schedule from Master.BackupSettingsServer, and the backup procedure call must therefore include all the necessary parameters – including, as of MB 1.1, @SyncSettings and @SyncLog, to allow DB1 to continue participating in the Data Waiter.

The step for our new job may then look something like this: 
EXEC [Minion].[BackupMaster]
	@DBType = ''User'' ,
	@BackupType = ''Diff'', 
	@Include = ''DB1'',
	@SyncSettings = 1,
	@SyncLogs = 1,
	@StmtOnly = 0;

And of course, we must disable the existing DB1 differential schedule: 
UPDATE  Minion.BackupSettingsServer
SET     IsActive = 0 	-- Deactivate the schedule!
      , Comment = ''DB1 requires parallel backups; so it has a separate job, [Backup-DB1-Diff].''
        + ISNULL(Comment, '''')
WHERE   DBType = ''User''
        AND BackupType = ''Diff''
        AND [Day] = ''Daily''
        AND [Include] = ''DB1'';

Now, the DB1 differentials may run in parallel with any other backup operations (as scheduled in Minion.BackupSettingsServer), and the Data Waiter scenario is uninterrupted.

IMPORTANT: As with all other Minion.BackupMaster parameters, the @SyncSettings and @SyncLogs parameters are only used if @BackupType is not null. @BackupType = NULL signals the procedure to use the settings in Minion.BackupSettingsServer.

IMPORTANT: The @SyncSettings and @SyncLogs parameters do not, by themselves, implement a Data Waiter scenario. The DW scenario must be implemented as described in the beginning of this section (“How to: Synchronize backup settings and logs among instances”).' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'NumDBsOnServer' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'NumDBsOnServer' AS [DetailHeader]
	, 'Number of databases on server.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 29 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'The current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'Buffercount' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'Buffercount' AS [DetailHeader]
	, 'From MSDN.Microsoft.com: “Specifies the total number of I/O buffers to be used for the backup operation. You can specify any positive integer; however, large numbers of buffers might cause "out of memory" errors because of inadequate virtual address space in the Sqlservr.exe process.”' AS [DetailText]
	, 'Smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'GroupDBOrder' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'GroupDBOrder' AS [DetailHeader]
	, 'Group to which this database belongs.  Used solely for determining the order in which databases should be backed up.

By default, all databases have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects.

Higher numbers have a greater “weight” (they have a higher priority), and will be backed up earlier than lower numbers.  The range of GroupDBOrder weight numbers is 0-255.

For more information, see “How To: Backup databases in a specific order”.
' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'EndTime' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'EndTime' AS [DetailHeader]
	, 'The end time at which this schedule applies. 
IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'BackupPath' AS [DetailName]
	, 32 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupPath' AS [DetailHeader]
	, 'Backup path. This is only the path (for example, ‘SQLBackups\’) of the backup destination.
Alternately, this value can be NUL if BackupLocType is NUL.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'FileName' AS [DetailName]
	, 33 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileName' AS [DetailHeader]
	, 'The name of the file, without the extension.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'NumDBsProcessed' AS [DetailName]
	, 34 AS [Position]
	, 'Column' AS [DetailType]
	, 'NumDBsProcessed' AS [DetailHeader]
	, 'Number of databases processed in this backup operation.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Mirror' AS [DetailName]
	, 34 AS [Position]
	, 'Column' AS [DetailType]
	, 'Mirror' AS [DetailHeader]
	, 'Back up to a secondary mirror location.  

Note: This option is only available in SQL Server Enterprise edition.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'MaxForTimeframe' AS [DetailName]
	, 34 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaxForTimeframe' AS [DetailHeader]
	, 'Maximum number of iterations within the specified timeframe (BeginTime to EndTime).
For more information, see “Table based scheduling” in the “Quick Start” section.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'MaxTransferSize' AS [DetailName]
	, 34 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaxTransferSize' AS [DetailHeader]
	, 'Max transfer size, as specified in bytes. This must be a multiple of 64KB.
Note that a value of 0 will allow Minion Backup to use the SQL Server default value, typically 1MB.
From MSDN.Microsoft.com: “Specifies the largest unit of transfer in bytes to be used between SQL Server and the backup media. The possible values are multiples of 65536 bytes (64 KB) ranging up to 4194304 bytes (4 MB).”' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'FileExtension ' AS [DetailName]
	, 34 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileExtension' AS [DetailHeader]
	, 'The file extension, with the period. For example: “.bak”.

Both NULL AND ‘MinionDefault’ will cause MB to use the default extension as appropriate: for backup files, ‘.bak’ or ‘.trn’, and for certificate backups, ‘.cer’ and  ‘.pvk’. 

This field accepts Inline Tokens.

Examples: 
NULL
MinionDefault
.bak
%BackupTypeExtension%' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'Escape' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'Escape' AS [DetailHeader]
	, 'The character used to “escape” a normally meaningful character. 
For example, if your database is actually named [My%DB], you can define an escape character (like |) to make the system recognize % as a character, not a wildcard. So, your database name would be entered as My|%DB, Escape=’|’.' AS [DetailText]
	, 'char' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'ObjectName' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'ObjectName' AS [DetailHeader]
	, 'The name of the table being synced (without the schema name attached).
Example values: BackupSyncCmds, BackupLogDetails, BackupFiles' AS [DetailText]
	, 'Sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'Port' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'Port' AS [DetailHeader]
	, 'Port number of the synchronization target server.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PctComplete' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'PctComplete' AS [DetailHeader]
	, 'Backup percent complete (e.g., 50% complete).' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 35 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why isn’t my log file shrinking after a log backup? ' AS [DetailHeader]
	, 'Make sure that you’ve set all three of the “Shrink” fields in Minion.BackupSettings for the proper database and backup type. (We often find that when a log file won’t shrink after log backup, it’s because the “Shrink” fields were configured for BackupType=’Full’ instead of ‘All’ or ‘Log’). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@Port' AS [DetailName]
	, 35 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'The port to be used for the connection to the new SQL Server.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 62 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 35 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Enabling Data Waiter while using parameter based scheduling' AS [DetailHeader]
	, 'Minion Backup uses table based scheduling by default, which retrieves schedule and other server-level settings from the Minion.BackupSettingsServer table.  In fact, the Data Waiter settings and log synchronization options are enabled in Minion.BackupSettingsServer. 

If you choose to use parameter based scheduling instead of table based, then the Data Waiter will not run automatically. You must instead set up synchronization as you normally would, and then create a job to run the Data Waiter stored procedures. Check www.MinionWare.net for additional instructions.

For more information on the Data Waiter process, see “How to: Synchronize backup settings and logs among instances”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 35 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Important Backup Tuning Concepts' AS [DetailHeader]
	, 'Here is a quick review of important backup tuning threshold concepts in Minion Backup: 
  * Tune your own: The settings we use for these examples are just that: examples. They are not recommendations, and have no bearing on your particular environment. We DO NOT recommend using the example number in this document, without proper analysis of your particular system.
  * Default Settings: Minion Backup is installed with a default backup tuning threshold setting, defined by the row DBName=’MinionDefault’, BackupType=’All’, and ThresholdValue=0.  These settings are in effect for any database with DynamicTuning enabled in the Minion.BackupSettings.
  * Space Types: You have the option of basing our tuning thresholds on data size only, on data and index size, or on file size. File size includes any unused space in the file; “data and index” does not.
  * Available Data: Minion Backup is a huge help to your analysis, because it gathers and records the backup settings for EVERY backup (including Buffercount, MaxTransferSize, etc.) in Minion.BackupLogDetails, whether or not it was a tuned backup.
  * Floor Thresholds: The thresholds in Minion.BackupTuningThresholds represent the LOWER threshold (the “floor”). Therefore, you must be sure to enter a threshold for file size 0. 
  * Settings Precedence: Minion Backup has a hierarchy of settings, where the most specific setting takes precedence. See the “Backup Tuning Threshold Precedence” section below.  ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 35 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 1: Delete files for a single database' AS [DetailHeader]
	, '-- Delete files for a single database.
EXEC [Minion].[BackupFilesDelete]
	@DBName = ''DB1'', 
		@RetHrs = NULL,  -- Use the configured retention period.
	@Delete = 1,	
	@EvalDateTime = NULL;' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 35 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Example: Get statement for DB1 log backup' AS [DetailHeader]
	, 'EXEC [Minion].[BackupStmtGet] 
@DBName = ''DB1'', 
@BackupType = ''Log'', 
@DBSize = NULL;' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@Include' AS [DetailName]
	, 35 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Use @Include to run backups on a specific list of databases, or databases that match a LIKE expression. Alternately, set @Include=’All’ or @Include=NULL to run maintenance on all databases.
If, during the last backup run, there were backups that failed, and you need to back them up now, just call this procedure with @Include = ''Missing''. The SP will search the log for the backups that failed in the previous batch (for a given BackupType and DBType), and back them up now. Note that the BackupType and DBType must match the errored out backups. 
Valid inputs: NULL, Regex, Missing, <comma-separated list of DBs including wildcard searches containing ''%''>
For more information, see “How to: Include databases in backups”.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, '@ManualRun' AS [DetailName]
	, 35 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Determines whether or not to log the backup action.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, '@StmtOnly' AS [DetailName]
	, 35 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Generate log statements only. Currently, @StmtOnly = 1 is the only valid input. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 35 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 3: The “Exclude” Exception' AS [DetailHeader]
	, 'Here we will demonstrate the effect of “Exclude” in rows of BackupType=’All’. In this example, these are the contents of the Minion.BackupSettings table (not all columns are shown here):
ID DBName        BackupType Exclude DBPreCode
1  MinionDefault All        0       ''EXEC SP1;''
2  DB1           All        1       ''Exec SP1;''
3  DB1           Full       0       NULL

There are a total of 30 databases on this server. As backups run throughout the week, the settings for individual databases will be selected as follows: 
  * Backups of all types for database DB1 will be excluded, because of the row with ID=2. The log will not display failed backups for DB1; there will simply be no entry in the log for DB1 backups, as they are excluded.

  * Even full backups of database DB1 will be excluded. 

  * All other database backups (full, log, and differential) will use the settings from the row with ID=1.

For more information, see the configuration sections in “How To” Topics: Basic Configuration (such as “How to: Configure settings for a single database”), and “Minion.BackupSettings”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
--1.4--
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 35 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Install' AS [DetailHeader]
	, 'This entire document is available within the Minion Backup product using the stored procedure Minion.HELP.  

View the “Minion Install Guide.docx” (in the extracted MinionWare folder) for full instructions and information on the installer. The basic steps to installing Minion Backup are: 

  1. Download MinionMaintenance1.1.zip from MinionWare.net and extract all files. Note: If you have never used a MinionWare product, extract the “MinionWare” folder and files to the location of your choice.  If you have an existing MinionWare folder from previous downloads, extract the files there. 

  2. Open Powershell as administrator, and use Get-ExecutionPolicy to determine the current execution policy. If it is Unrestricted or RemoteSigned, the script should be able to run. Otherwise, use Set-ExecutionPolicy RemoteSigned 

  3. For each of the following files, right-click and select Properties, and select “Unblock”. (This allows you to run scripts downloaded from the web using RemoteSigned.) 
    * …\MinionWare\MinionSetupMaster.ps1 
    * …\MinionWare\MinionSetup.ps1 
    * …\MinionWare\Includes\BackupInclude.ps1 

  4. Run MinionSetupMaster.ps1 in the PowerShell window as follows:  
      .\MinionSetupMaster.ps1 <servername> <DBName> <Product> 
 
      Examples:  
      .\MinionSetupMaster.ps1 localhost master Backup 
      or  
      .\MinionSetupMaster.ps1 YourServer master Backup 

Note that you can install multiple products, and to multiple servers. For more information, see the “Minion Install Guide.docx”. 

Once MinionSetupMaster.ps1 has been run, nothing else is required.  From here on, Minion Backup will run nightly to back up all non-TempDB databases.  The backup routine automatically handles databases as they are created, dropped, or renamed.  

For simplicity, this Quick Start guide assumes that you have installed Minion Backup on one server, named “YourServer”.

Note: You can also use the “MinionSetupMaster.ps1” PowerShell script to install Minion Backup on dozens or hundreds of servers at once, just as easily as you would install it on a single instance.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'ThresholdMeasure' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'ThresholdMeasure' AS [DetailHeader]
	, 'The measure for our threshold value.

Valid inputs:
GB' AS [DetailText]
	, 'char' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'TypeName' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'TypeName' AS [DetailHeader]
	, 'The name or type of file that this row configures; either a file name, or a file type (as specified in FileType).

Valid values: 
<the logical file name>
mdf
ndf
ldf
All' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion: Overlapping Schedules, and MaxForTimeframe' AS [DetailName]
	, 35 AS [Position]
	, 'Information' AS [DetailType]
	, 'Discussion: Overlapping Schedules, and MaxForTimeframe' AS [DetailHeader]
	, 'The Minion.BackupSettingsServer table allows you to have backup schedule settings that overlap. For example, we could perform a differential backup at the top of every hour, and then log backups every 5 minutes. For this scenario, we would: 
  * Insert one row for the differential backup, with a MaxForTimeframe value of 24 and FrequencyMins set to 60. 
  * Insert one row for log backups, with a MaxForTimeframe value of 288 (or more, as there are only 288 5-minute increments in a day).
  * Set the backup job MinionBackup-AUTO to run every 5 minutes.

The sequence of job executions then goes like this: 
  1. At 8:00am, the MinionBackup-AUTO job will run.
  2. Minion Backup determines that a differential backup is slated for that hour. 
  3. MB will execute the differential backup, which takes precedence over the log backup. The log backup is not executed during this run.
  4. MB also increments the differential CurrentNumBackups for that timeframe. 
  5. At 8:05, the MinionBackup-AUTO job will run again.
  6. Minion Backup determines that the differential backup has already happened within the last 60 minutes. (The differential is limited to one per hour via the MaxForTimeframe field.) [][]
  7. MB executes the log backup, and increments the differential CurrentNumbackups.

And, so on.
Important: The MaxForTimeframe field may limit you when running manual backups. Specifically, when you run Minion.BackupMaster with @BackupType=NULL). For example, if only one full backup is slated for Saturday, and it has already run, then CurrentNumBackups will be 1.  As the daily MaxForTimeframe value is 1, executing Minion.BackupMaster will fail, because the max has been reached. Even a manual run won’t let you run that backup. You would have to either reset the count, change MaxForTimeframe to 2 (and then change it back after the manual run), or run Minion.BackupMaster with @BackupType populated.
Note that the above paragraph does not apply for instances when you run Minion.BackupMaster with @BackupType populated with a value (a true “manual backup”). In this case – with @BackupType populated – no reference is made to Minion.BackupSettingsServer at all. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'The current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Status' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'Status' AS [DetailHeader]
	, 'Current status of the file operation.  ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 35 AS [ObjectID]
	, 'ConnectionTimeoutInSecs' AS [DetailName]
	, 35 AS [Position]
	, 'Column' AS [DetailType]
	, 'ConnectionTimeoutInSecs' AS [DetailHeader]
	, '…It’s in the name.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DelFileBefore' AS [DetailName]
	, 36 AS [Position]
	, 'Column' AS [DetailType]
	, 'DelFileBefore' AS [DetailHeader]
	, 'Delete the backup file before taking the new backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'TotalBackupSizeInMB' AS [DetailName]
	, 36 AS [Position]
	, 'Column' AS [DetailType]
	, 'TotalBackupSizeInMB' AS [DetailHeader]
	, 'Total size of all backup files, in MB.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'CurrentNumBackups' AS [DetailName]
	, 36 AS [Position]
	, 'Column' AS [DetailType]
	, 'CurrentNumBackups' AS [DetailHeader]
	, 'Count of backup attempts for the particular DBType, BackupType, and Day, for the current timeframe  (BeginTime to EndTime)' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'Compression' AS [DetailName]
	, 36 AS [Position]
	, 'Column' AS [DetailType]
	, 'Compression' AS [DetailHeader]
	, 'From MSDN.Microsoft.com: “In SQL Server 2008 Enterprise and later versions only, specifies whether backup compression is performed on this backup, overriding the server-level default.”' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 37 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Include and Exclude Precedence' AS [DetailHeader]
	, 'Minion Backup allows you to specify lists of databases to include in a backup routine, in several different ways. First of all, databases are always divided into “system” and “user” databases. 

--Include and Exclude strings--
Within those divisions, the primary means of identifying what databases should be backed up in a given operation is by the use of Include and Exclude strings. As noted in the following section (“Run Time Configuration”), Include and Exclude can be defined as part of either a table configured schedule, or a parameter based schedule.

The important point to understand now, however, is how Include and Exclude work at a basic level. Include and Exclude may each have one of three kinds of values: 

  * ‘All’ or NULL (which also means ‘All’)
  * ‘Regex’
  * An explicit, comma-delimited list of database names and LIKE expressions (e.g., @Include=’DB1,DB2%’).

Note: For this initial discussion, we are ignoring the existence of the Exclude bit, while we introduce the Include and Exclude strings. We’ll fold the Exclude bit concept back in at the end of the section.

The following table outlines the interaction of Include and Exclude:
                Exclude=’All’       Exclude=Regex      Exclude= 
			    or IS NULL                             [Specific list]
			   ----------------------------------------------------------
Include=’All’  | Run all backups    Run all, minus     Run all, minus 
or IS NULL     |                    regex exclude  	  explicit exclude
               |					  
Include=Regex  | Run only databases Run only databases Run only databases 
               | that match the     that match the     that match the  
               | configured RegEx   configured RegEx   configured RegEx  
               | expression         expression         expression
               | 
Include=       | Run only specific  Run only specific  Run only specific
[Specific list]| includes           includes           includes


Note that regular expressions phrases are defined in a special settings table (Minion.DBMaintRegexLookup).

Let us look at a handful of scenarios, using this table: 
  * Include IS NULL, Exclude IS NULL – Run all backups.
  * Include = ‘All’, Exclude = ‘DB%’ – Run all backups except those beginning with “DB”.
  * Include=’Regex’, Exclude=’DB2’ – Run only databases that match the configured RegEx expression. (The Exclude is ignored.)

IMPORTANT: You will note that Exclude is ignored in any case where Include is not ‘All’/NULL.  Whether Include is Regex or is a specific list,  an explicit Include should be the final word. The reason for this rule is that we never want a scenario where a database simply cannot  be backed up.

--Exclude bit--
In addition to the Include and Exclude strings, Minion Backup also provides an “Exclude” bit in the primary settings table (Minion.BackupSettings) that allows you to exclude backups for a particular database, or a particular database and backup type.

The following table outlines the interaction of the Include string and the Exclude bit:
                Exclude=0          Exclude=1
			   ----------------------------------------------------------
Include=’All’  | Run all backups    Run all, minus excluded 
or IS NULL	   |                    databases’ backup types 
               | 
Include=Regex  | Run only databases Run only databases that 
               | that match the     match the configured RegEx 
               | configured RegEx   expression 
               | expression 	
               | 
Include=       | Run only specific  Run only specific includes
[Specific list]| includes

Let us look at a handful of scenarios, using this table: 

  * Include IS NULL, Exclude bit=0 – Run all backups.
  * Include = ‘All’, Exclude = 1 for DB2 / All – Run all backups except DB2.
  * Include=’Regex’, Exclude=1 for DB2 / All – Run only databases that match the configured RegEx expression. (The Exclude bit is ignored.)

IMPORTANT: You will note that the Exclude bit, like the Exclude string, is ignored in any case where Include is not ‘All’/NULL.  Whether Include is Regex or is a specific list,  an explicit Include should be the final word. The reason for this rule is that we never want a scenario where a database simply cannot  be backed up. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ReadOnly' AS [DetailName]
	, 38 AS [Position]
	, 'Column' AS [DetailType]
	, 'ReadOnly' AS [DetailHeader]
	, 'Backup readonly option; this decides whether or not to include ReadOnly databases in the backup, or to perform backups on only ReadOnly databases. 
A value of 1 includes ReadOnly databases; 2 excludes ReadOnly databases; and 3 only includes ReadOnly databases.
Valid values: 1, 2 , 3' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DelFileBeforeAgree' AS [DetailName]
	, 38 AS [Position]
	, 'Column' AS [DetailType]
	, 'DelFileBeforeAgree' AS [DetailHeader]
	, 'Signifies that you know deleting the backup file first is a bad idea (because it leaves you without a backup, should your current backup fail), but that you agree anyway.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'BlockSize' AS [DetailName]
	, 38 AS [Position]
	, 'Column' AS [DetailType]
	, 'BlockSize' AS [DetailHeader]
	, 'From MSDN.Microsoft.com: “Specifies the physical block size, in bytes. The supported sizes are 512, 1024, 2048, 4096, 8192, 16384, 32768, and 65536 (64 KB) bytes. The default is 65536 for tape devices and 512 otherwise. Typically, this option is unnecessary because BACKUP automatically selects a block size that is appropriate to the device. Explicitly stating a block size overrides the automatic selection of block size.”' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'NumConcurrentBackups' AS [DetailName]
	, 38 AS [Position]
	, 'Column' AS [DetailType]
	, 'NumConcurrentBackups' AS [DetailHeader]
	, 'For future use.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'ServerLabel' AS [DetailName]
	, 39 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerLabel' AS [DetailHeader]
	, 'A user-customized label for the server name.  It can be the name of the server, server\instance, or a label for a server.  
This is used for the backup file path.  
This comes in handy especially in Availability groups; if on day 1 we are on AG node 1, and on day 2 we are on AG node 2, we don’t want the backups to save to different physical locations based on that name change.  We instead provide a label for all databases on the instance – whether or not they’re in an AG – so backups will all be in a central place (and so that cleaning up old backups is not an onerous chore).
As this is just a label meant to group backup files, you could conceivably use it any which way you like; for example, one label for AG databases, and another for non-AG, etc.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'LastRunDateTime' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'LastRunDateTime' AS [DetailHeader]
	, 'The last time a backup ran that applied to this particular scenario (DBType, BackupType, Day, and timeframe).' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'BeginTime' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'BeginTime' AS [DetailHeader]
	, 'The start time at which this threshold applies. 
IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, '	The current row is valid (active), and should be used in the Minion Backup process. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'SyncCmdID' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncCmdID' AS [DetailHeader]
	, 'Command identity number, from the Minion.SyncCmds table.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Op' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'Op' AS [DetailHeader]
	, 'Operation being performed on table.
Example values: INSERT, UPDATE, DELETE, TRUNCATE' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 40 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion: The Resultset' AS [DetailHeader]
	, 'Minion.BackupStmtGet returns one row per backup file. The procedure returns the backup command, as well as a long list of related items (such as server name, backup path, path order, compression, etc.). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@Exclude' AS [DetailName]
	, 40 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Use @Exclude to skip backups for a specific list of databases, or databases that match a LIKE expression. 
Examples of valid inputs include:
DBname
DBName1, DBname2, etc.
DBName%, YourDatabase, Archive%

For more information, see “How To: Exclude databases from backups”.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 40 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 2: Delete files forall databases, using a custom retention period' AS [DetailHeader]
	, '-- Delete files forall databases, using a custom retention period.
EXEC [Minion].[BackupFilesDelete]
	@DBName = ''All'', 
	@RetHrs = 24,	-- Pass in specific hrs to do a custom delete.
	@Delete = 1,	
	@EvalDateTime = NULL;' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 40 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Backup Tuning Threshold Precedence' AS [DetailHeader]
	, 'Minion Backup has a hierarchy of settings, where the most specific setting takes precedence.  The precedence for backup tuning threshold settings is as follows: 

Precedence Level DBName        Backuptype
Highest          DB1           Full, or Diff, or Log
High             DB1           All
Low              MinionDefault Full, or Diff, or Log
Lowest           MinionDefault All

Note: If you define a database-specific row, we highly recommend that you provide tuning settings for all backup types, for that database. For example, if you insert one row for YourDatabase with backup type Full, you should also insert a row for YourDatabase and backup type All (or two additional rows, one each for differential and log). 

Let’s look at an example set of backup tuning threshold settings:

ID DBName        BackupType isActive
1  MinionDefault All        1
2  MinionDefault Full       1
3  MinionDefault Log        1
4  DB1           All        1
5  DB1           Full       1

Using these settings, let’s look at which settings will be used when:
  * For a DB1 full backup, Minion Backup will use row 5: DBName=DB1, BackupType=Full.
  * For a DB1 differential or log backup, Minion Backup will use row 4: DBName=DB1, BackupType=All. 
  * For a DB2 full backup, Minion Backup will use row 2 (DBName=MinionDefault, BackupType=Full).
  * For a DB2 differential backup, Minion Backup will use row 1 (DBName=MinionDefault, BackupType=All).

Note: If you are unsure of what backup tuning settings will be used, you can double check; use the Minion.BackupStmtGet stored procedure, which will build (but not run) the backup statement for you.  For more information, see “Minion.BackupStmtGet”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 40 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why doesn’t Minion Backup offer a “shrink data file after full backup” feature? ' AS [DetailHeader]
	, 'This is by design. Shrinking the data file is not recommended. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@Process' AS [DetailName]
	, 40 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Which records to you want to process: just the new ones, or all of them.
Most of the time, you will want to run with “New”. “All” is used for bringing on new servers when you want to push all the records in the table to that server.
Valid inputs: 
All
New' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'LogLoc' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'LogLoc' AS [DetailHeader]
	, 'Determines whether log data is only stored on the local (client) server, or on both the local server and the central Minion (repository) server.  Valid inputs: Local, Repo' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ExecutionEndDateTime' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionEndDateTime' AS [DetailHeader]
	, 'Date and time the entire backup operation completed.  ' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 40 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Run Time Configuration' AS [DetailHeader]
	, 'The main Minion Backup stored procedure – Minion.BackupMaster – can be run in one of two ways: with table configuration, or with parameters.

Run Minion.BackupMaster using table configuration: If you run Minion.BackupMaster without parameters, the procedure uses the Minion.BackupSettingsServer table to determine its runtime parameters (including the schedule of backup jobs per backup type, and which databases to Include and Exclude). This is how MB operates by default, to allow for the most flexible backup scheduling with as few jobs as possible. 

For more information, see the sections “How To: Change Backup Schedules”, “Minion.BackupSettingsServer”, and “Minion.BackupMaster”.

Run Minion.BackupMaster with parameters: The procedure takes a number of parameters that are specific to the current maintenance run.  For example: 

  * Use @DBType to specify ‘System’ or ‘User’ databases.
  * Use @BackupType to specify Full, Log, or Diff backups.
  * Use @StmtOnly to generate backup statements, instead of running them.  
  * Use @Include to back up a specific list of databases, or databases that match a LIKE expression.  Alternately, set @Include=’All’ or @Include=NULL to back up all databases.
  * Use @Exclude to exclude a specific list of databases from backup.
  * Use @ReadOnly to (1) include ReadOnly databases, (2) exclude ReadOnly databases, or (3) only include ReadOnly databases.

For more information, see the section “How To: Change Backup Schedules” and “Minion.BackupMaster”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 253 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion: Sample row for missing backups' AS [DetailName]
	, 40 AS [Position]
	, 'Information' AS [DetailType]
	, 'Discussion: Sample row for missing backups' AS [DetailHeader]
	, 'Remember that you can run Minion.BackupMaster with Include=’Missing’ (either in the parameter, or in Minion.BackupSettingsServer, if you’re using table based scheduling) to check for incomplete backups from the last run, for a given database type and backup type (e.g., ‘User’, ‘Diff’)

The Minion.BackupSettingsServer includes a sample row – the Include=’Missing’ row, which is inactive by default –to check for missing differential backups. The row is scheduled to run once at 5:00am (but it won’t, unless you set isActive = 1). This is an example that you could enable, to give your routine an automatic check for missing backups.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestoreDrive' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreDrive' AS [DetailHeader]
	, 'The drive to restore to. This is only the drive letter of the restore destination.

IMPORTANT: If this is drive, this must end with colon-slash (for example, ‘M:\’). If this is URL, use the base path (for example, ‘\\server2\’) ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'ThresholdValue' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'ThresholdValue' AS [DetailHeader]
	, 'The correlating value to ThresholdMeasure. So, if ThresholdMeasure is GB, then ThresholdValue is the value – the number of gigabytes. ' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DBName' AS [DetailName]
	, 40 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBName' AS [DetailHeader]
	, 'Database name.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ExecutionRunTimeInSecs' AS [DetailName]
	, 42 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExecutionRunTimeInSecs' AS [DetailHeader]
	, 'The duration, in seconds, of the entire backup operation.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'EndTime' AS [DetailName]
	, 42 AS [Position]
	, 'Column' AS [DetailType]
	, 'EndTime' AS [DetailHeader]
	, 'The end time at which this threshold applies. 
IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'RetHrs ' AS [DetailName]
	, 42 AS [Position]
	, 'Column' AS [DetailType]
	, 'RetHrs' AS [DetailHeader]
	, 'Number of hours to retain the backup files.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'HistRetDays' AS [DetailName]
	, 42 AS [Position]
	, 'Column' AS [DetailType]
	, 'HistRetDays' AS [DetailHeader]
	, 'Number of days to retain a history of backups (in Minion Backup log tables).

Minion Backup does not modify or delete backup information from the MSDB database.

Note: This setting is also optionally configurable at the backup level, and also at the BackupType level.  So, you can keep log history for different amounts of time for log backups than you do for full backups.' AS [DetailText]
	, 'smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Include' AS [DetailName]
	, 42 AS [Position]
	, 'Column' AS [DetailType]
	, 'Include' AS [DetailHeader]
	, 'The value to pass into the @Include parameter of the Minion.BackupMaster job; in other words, the databases to include in this attempt. This may be left NULL (meaning “all databases”).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Exclude' AS [DetailName]
	, 44 AS [Position]
	, 'Column' AS [DetailType]
	, 'Exclude' AS [DetailHeader]
	, 'The value to pass into the @Exclude parameter of the Minion.BackupMaster job; in other words, the databases to exclude from this attempt. This may be left NULL (meaning “no exclusions”).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'DayOfWeek' AS [DetailName]
	, 44 AS [Position]
	, 'Column' AS [DetailType]
	, 'DayOfWeek' AS [DetailHeader]
	, 'The day or days to which the settings apply.
Valid inputs: Weekday, Weekend, [an individual day, e.g., Sunday]' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPreCode' AS [DetailName]
	, 44 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPreCode' AS [DetailHeader]
	, 'Precode set to run before the entire backup operation. This code is set in the Minion.SettingsServer table.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'MinionTriggerPath' AS [DetailName]
	, 44 AS [Position]
	, 'Column' AS [DetailType]
	, 'MinionTriggerPath' AS [DetailHeader]
	, 'UNC path where the Minion logging trigger file is located.  

Not applicable for a standalone Minion Backup instance.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 45 AS [Position]
	, 'Discussion' AS [DetailType]
	, ' Logging' AS [DetailHeader]
	, 'As a Minion Backup routine runs, it keeps logs of all activity. The two primary log tables are:
  * Minion.BackupLog – a log of activity at the batch level.
  * Minion.BackupLogDetails – a log of activity at the database level.

The Status column for the current backup run is updated continually in each of these tables while the batch is running.  This way, status information (Live Insight) is available to you while backup is still running, and historical data is available after the fact for help in planning future operations, reporting, troubleshooting, and more.

Minion Backup logs additional information in a number of other tables, including: 
  * Minion.BackupDebug – Log of high level debug data.
  * Minion.BackupDebugLogDetails – Log of detailed debug data.
  * Minion.BackupFileListOnly – log of RESTORE FILELISTONLY output for each backup taken 
  * Minion.BackupFiles – a log of all backup files (whether they originate from a database backup, a certificate backup, a copy, or a move). Note that a backup that is striped to 10 files will have 10 rows in this table. 
  * Minion.SyncCmds – a log of commands used to synchronize settings and log tables to configured synchronization servers. This table is both a log table and a work table: the synchronization process uses Minion.SyncCmds to push the synchronization commands to target servers, and it is also a log of those commands (complete and incomplete).
  * Minion.SyncErrorCmds – a log of synchronization commands that have failed, to be retried again later.

Minion Backup maintains all log tables are automatically. The retention period for all log tables is set in the HistoryRetDays field in Minion.BackupSettings. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 45 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Change Schedules' AS [DetailHeader]
	, 'Minion Backup offers a choice of scheduling options. This quick start section covers the default method of scheduling: table based scheduling. We will cover parameter based schedules, and hybrid schedules, in the section titled “How To: Change Backup Schedules”.

--Table based scheduling--

In conjunction with the “MinionBackup-AUTO” job, the Minion.BackupSettingsServer table allows you to configure flexible backup scheduling scenarios. By default, Minion Backup comes installed with the following scenario: 
•	The MinionBackup-Auto job runs once every 30 minutes, checking the Minion.BackupSettingsServer table to determine what backup should be run.
•	In Minion.BackupSettingsServer:
•	Full system backups are scheduled daily at 10:00pm.
•	Full user backups are scheduled on Saturdays at 11:00pm.
•	Differential backups for user databases are scheduled daily except Saturdays (weekdays and on Sunday) at 11:00pm.
•	Log backups for user databases run daily as often as the MinionBackup-AUTO job runs (every 30 minutes).

The following table displays the first few columns of this default scenario in Minion.BackupSettingsServer: 

ID DBType BackupType Day	  ReadOnly BeginTime  EndTime  MaxForTimeframe
1  System Full       Daily	  1        22:00:00   22:30:00 1
2  User   Full       Saturday 1        23:00:00   23:30:00 1
3  User   Diff       Weekday  1        23:00:00   23:30:00 1
4  User   Diff       Sunday	  1        23:00:00   23:30:00 1
5  User   Log        Daily	  1        00:00:00   23:59:00 48

Let’s walk through three different schedule changes. 

Scenario 1: Run log backups every 15 minutes, instead of half hourly. To change the default setup in order to run log backups every 15 minutes, change the MinionBackup-AUTO job schedule to run once every 15 minutes, and update the BackupType=’Log’ row in Minion.BackupSettingsServer to increase the “MaxForTimeframe” value to 96 or more (as there will be a maximum of 96 log backups per day).

Scenario 2: Run full backups daily, and no differential backups. To change the default setup in order to run daily full backups and eliminate differential backups altogether: 
1.	Update the DBType=’User’, BackupType=‘Full’ row in Minion.BackupSettingsServer, setting the Day field to “Daily”.
2.	Update the BackupType=’Diff’ rows in Minion.BackupSettingsServer, setting the isActive fields to 0.

Scenario 3: Run differential backups twice daily.  To change the default setup in order to differential backups twice daily, insert two new rows to Minion.BackupSettingsServer for BackupType=’Diff’, one for weekdays and one for Sundays, as follows: 

INSERT  INTO Minion.BackupSettingsServer
        ( [DBType],
          [BackupType] ,
          [Day] ,
          [ReadOnly] ,
          [BeginTime] ,
          [EndTime] ,
          [MaxForTimeframe] ,
          [SyncSettings] ,
          [SyncLogs] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''User'' AS DBType,
        ''Diff'' AS [BackupType] ,
        ''Weekday'' AS [Day] ,
        1 AS [ReadOnly] ,
        ''06:00:00'' AS [BeginTime] ,
        ''07:00:00'' AS [EndTime] ,
        1 AS [MaxForTimeframe] ,
        0 AS [SyncSettings] ,
        0 AS [SyncLogs] ,
        1 AS [IsActive] ,
        ''Weekday morning differentials'' AS [Comment];

INSERT  INTO Minion.BackupSettingsServer
        ( [DBType],
          [BackupType] ,
          [Day] ,
          [ReadOnly] ,
          [BeginTime] ,
          [EndTime] ,
          [MaxForTimeframe] ,
          [SyncSettings] ,
          [SyncLogs] ,
          [IsActive] ,
          [Comment]
        )
SELECT  ''User'' AS DBType,
        ''Diff'' AS [BackupType] ,
        ''Sunday'' AS [Day] ,
        1 AS [ReadOnly] ,
        ''06:00:00'' AS [BeginTime] ,
        ''07:00:00'' AS [EndTime] ,
        1 AS [MaxForTimeframe] ,
        0 AS [SyncSettings] ,
        0 AS [SyncLogs] ,
        1 AS [IsActive] ,
        ''Sunday morning differentials'' AS [Comment];

These will provide a second differential backup at 6:00am on weekdays and Sundays, to supplement the existing differential backup in the evenings. The contents of Minion.BackupSettingsServer will then look (in part) like this: 
ID  DBType  BackupType Day      ReadOnly BeginTime EndTime  MaxForTimeframe
1   System  Full       Daily    1        22:00:00  22:30:00 1
2   User    Full       Saturday 1        23:00:00  23:30:00 1
3   User    Diff       Weekday  1        23:00:00  23:30:00 1
4   User    Diff       Sunday   1        23:00:00  23:30:00 1
5   User    Log        Daily    1        00:00:00  23:59:00 48
6   User    Diff       Weekday  1        06:00:00  07:00:00 1
7   User    Diff       Sunday   1        06:00:00  07:00:00 1

Important notes: 
•	Always set the MaxForTimeframe field. This determines how many of the given backup may be taken in the defined timeframe. In the insert statement above, MaxForTimeframe is set to 1, because we only want to allow 1 differential backup operation during the 6:00am hour.
•	The backup job should run as often as your most frequent backup. For example, if log backups should run every 5 minutes, schedule the job for every 5 minutes. And be sure to set the MaxForTimeframe sufficiently high enough to allow all of the log backups. In this case, we take log backups every 5 minutes for each 24 hour period, meaning up to 288 log backups a day; so, we could set MaxForTimeframe = 288, or any number higher (just to be sure). ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'Buffercount' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'Buffercount' AS [DetailHeader]
	, 'From MSDN.Microsoft.com: “Specifies the total number of I/O buffers to be used for the backup operation. You can specify any positive integer; however, large numbers of buffers might cause "out of memory" errors because of inadequate virtual address space in the Sqlservr.exe process.” ' AS [DetailText]
	, 'smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestorePath' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestorePath' AS [DetailHeader]
	, 'The path to restore to. This is only the path (for example, ‘SQLBackups\’) of the restore destination.

This field accepts Inline Tokens. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 60 AS [ObjectID]
	, 'Discussion: Using FrequencyMins' AS [DetailName]
	, 45 AS [Position]
	, 'Information' AS [DetailType]
	, 'Discussion: Using FrequencyMins' AS [DetailHeader]
	, 'The FrequencyMins column allows you to run the SQL Agent backup job as often as you like, but to space backups out by a set interval. Let’s say that the backup job runs every 5 minutes, but log backups should only run every 30 minutes. Just set FrequencyMins = 30 for the Log backup row(s).

One scenario where this might apply is needing a job to run every 5 minutes, so that user database backups can start as soon as possible after system database backups.  Without FrequencyMins, this would cause the log backups to run every time the job runs. With log backups FrequencyMins=30, the job will see that it hasn’t yet been 30 minutes since the last log backup, and it won’t take log backups yet.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ServerLabel' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerLabel' AS [DetailHeader]
	, 'The user-customized label for the server name.  
For more information, see the ServerLabel column in Minion.BackupSettingsPath.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, '	For your reference only. You can label each row with a short description and/or purpose. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Cmd' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'Cmd' AS [DetailHeader]
	, 'The synchronization command to be pushed to one or more sync partners.' AS [DetailText]
	, 'Nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'STATUS' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'STATUS' AS [DetailHeader]
	, 'Status of the last synchronization attempt.

Values include “Initial attempt failed”, and “Fatal error on [servername]”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ServerLabel' AS [DetailName]
	, 45 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerLabel' AS [DetailHeader]
	, 'A user-customized label for the server name.  It can be the name of the server, server\instance, or a label for a server.  
For more information, see the ServerLabel column in Minion.BackupSettingsPath.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 58 AS [ObjectID]
	, '@Module' AS [DetailName]
	, 45 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Valid inputs: Backup' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 55 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 45 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion: The DBSize Parameter' AS [DetailHeader]
	, 'The DBSize parameter is especially cool.  When you run Minion.BackupStmtGet with a specific @DBSize, the procedure generates the backup statement for the database as if the database were currently that size.  Of course, with normal, untuned backups this would have no impact; but when you use backup tuning thresholds, the size of the database determines which settings will be used. 

Let’s say your database is 50GB, but you want to know if you’ve configured the dynamic settings correctly for it when it reaches 100GB.  You can use the @DBSize parameter to test the settings like this:
EXEC [Minion].[BackupStmtGet] 
	@DBName = ''AdventureWorks'',
    @BackupType = ''Log'', 
	@DBSize = 100;

This procedure will not run the backup, delete any files, or do any other action; it only generates the backup statements and returns them, along with backup files and other information.  Feel free to use this as much as you like to help you make sure your configuration is what you expect.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 45 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Business Aware Dynamic Backup Tuning' AS [DetailHeader]
	, 'What’s more, Minion Backup’s dynamic backup tuning can be made “business aware”, in a sense. For example, configure one set of tuning thresholds for weekday business hours, and another set for after hours and weekends. Or, perhaps you need a different set of configurations for Monday, because that’s the busiest day. 

Here is a high-level overview of one way to set up “business aware” backup tuning scenarios: 
  1. Perform your backup tuning analysis, and determine the settings for two scenarios: 
     a. one low-resource scenario for times when the server is busy (say, weekdays); and 
     b. one high-resource scenario for when the server is largely unused (e.g., on the weekend).
  
  2. Insert rows to Minion.BackupTuningThresholds for the low-resource scenario, and set IsActive=1.
  
  3. Insert additional rows to Minion.BackupTuningThresholds for the high-resource scenario, and set IsActive=0.
  
  4. Set up your backup routine with precode that checks the day of the week; 
     a. If the day is Saturday or Sunday, the precode sets isActive=1 in Minion.BackupTuningThresholds for the high-resource scenario, and isActive=0 for the low-resource scenario. 
     b. Otherwise, the precode enables the low-resource scenario, and disables the high-resource scenario. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 49 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 45 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 3: Play “what if”; check to see what databases would be deleted' AS [DetailHeader]
	, '-- Play “what if”; check to see what databases would be deleted.
EXEC [Minion].[BackupFilesDelete]
	@DBName = ''All'', 
	@RetHrs = NULL,   
	@Delete = 0,	-- 0: report files that will be deleted.
	@EvalDateTime = ''6/1/2015 06:00:00''; 	-- The SP will pretend this is the current date.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@ReadOnly' AS [DetailName]
	, 45 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Use @ReadOnly to 
(1) include ReadOnly databases, (2) exclude ReadOnly databases, or (3) only include ReadOnly databases.' AS [DetailText]
	, 'Tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 45 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Why isn’t MB using my backup tuning thresholds? ' AS [DetailHeader]
	, 'There are a few possibilities:
  * Check the log of the latest backups for your database in Minion.BackupLogDetails. Compare the logged backup tuning values that were used (NumberOfFiles, Buffercount, MaxTransferSize, and Compression) against the settings you expect to be used from Minion.BackupTuningThresholds.
  * Check if you have disabled dynamic tuning for that database, or for all databases. Check the DynamicTuning column in Minion.BackupSettings.
  * Perhaps you have not set a threshold that includes your database at its present size. Check Minion.BackupTuningThresholds to determine that: 
     - rows are defined for your database (DBName, BackupType)
     - the rows for your data the appropriate rows are active (IsActive=1), 
     - your database is larger than the threshold you’re expecting it to use (SpaceType, ThresholdMeasure, ThresholdValue). One common mistake is to omit a “floor” value of zero for a particular database; this causes that database to use the MinionDefault values in Minion.BackupTuningThresholds, instead. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DBPreCode' AS [DetailName]
	, 46 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPreCode' AS [DetailHeader]
	, 'Code to run for a database, before the backup operation begins for that database.  

For more on this topic, see “How To: Run code before or after backups”.
' AS [DetailText]
	, 'Nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'SyncSettings' AS [DetailName]
	, 46 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncSettings' AS [DetailHeader]
	, 'Whether or not to perform a synchronization of settings tables during this particular run. 
For more information, see “How to: Synchronize backup settings and logs among instances”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 46 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'Whether the current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'FileActionMethod' AS [DetailName]
	, 46 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionMethod' AS [DetailHeader]
	, 'Used to specify the program to use to perform the COPY/MOVE actions.  
Note: NULL and COPY are the same.  And while the setting is called COPY, it uses PowerShell COPY or MOVE commands as needed.  
Valid inputs: NULL (same as COPY), COPY, MOVE, XCOPY, ROBOCOPY, ESEUTIL

Note that ESEUTIL requires additional setup. For more on this topic, see “How to Topics: Backup Mirrors and File Actions” and “About: Copy and move backup files”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPostCode' AS [DetailName]
	, 46 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPostCode' AS [DetailHeader]
	, 'Precode set to run after the entire backup operation. This code is set in the Minion.SettingsServer table.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPreCodeStartDateTime' AS [DetailName]
	, 48 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPreCodeStartDateTime' AS [DetailHeader]
	, 'Start date of the batch precode.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'FileActionMethodFlags' AS [DetailName]
	, 48 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionMethodFlags' AS [DetailHeader]
	, 'Used to supply flags for the method specified in FileActionMethod.  The flags will be appended to the end of the command; this is the perfect way to provide specific functionality like preserving security, attributes, etc.  
For more on this topic, see “How to Topics: Backup Mirrors and File Actions” and “About: Copy and move backup files”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 33 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 48 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'SyncLogs' AS [DetailName]
	, 48 AS [Position]
	, 'Column' AS [DetailType]
	, 'SyncLogs' AS [DetailHeader]
	, 'Whether or not to perform a synchronization of log tables during this particular run. 
For more information, see “How to: Synchronize backup settings and logs among instances”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DBPostCode' AS [DetailName]
	, 48 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPostCode' AS [DetailHeader]
	, 'Code to run for a database, after the backup operation completes for that database.  

For more on this topic, see “How To: Run code before or after backups”.
' AS [DetailText]
	, 'nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'PushToMinion' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'PushToMinion' AS [DetailHeader]
	, 'Save these values to the central Minion server, if it exists.  Modifies values for this particular database on the central Minion server.

A value of NULL indicates that this feature is off.  Functionality not yet supported.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'NETBIOSName' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'NETBIOSName' AS [DetailHeader]
	, 'The name of the server from which the backup is taken.  
If the instance is on a cluster, this will be the name of the cluster node SQL Server was running on. If it’s part of an Availability Group, the NETBIOSName will be the physical name of the Availability Group replica. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'BatchPreCode' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPreCode' AS [DetailHeader]
	, 'Precode to run before the entire backup operation.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'LastAttemptDateTime' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'LastAttemptDateTime' AS [DetailHeader]
	, 'Date last attempted to synchronize the command to the target server.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Pushed' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'Pushed' AS [DetailHeader]
	, 'Whether it was successfully pushed to all servers.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'Example 1' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Example 1' AS [DetailHeader]
	, 'Let’s create a group named XYZ with Action=Include, and databases ‘DB1,DB2,DB3’; and, Action=Exclude, with databases ‘DB1,DB2’.  
ID  Action    MaintType  GroupName   GroupDef   Escape   IsActive   Comment
1   Include   Backup     XYZ         DB1        NULL     1          XYZ: DB1
2   Include   Backup     XYZ         DB2        NULL     1          XYZ: DB2
3   Include   Backup     XYZ         DB3        NULL     1          XYZ: DB3
4   Exclude   Backup     XYZ         DB1        NULL     1          XYZ: DB1
5   Exclude   Backup     XYZ         DB2        NULL     1          XYZ: DB2

Then, a run of Minion.BackupMaster with @Include=’DBGROUP:XYZ’ would include only databases DB1, DB2, and DB3. And if you run Minion.BackupMaster with @Exclude=’DBGROUP:XYZ’, it would only exclue databases DB1, and DB2.
Note that in many cases, the list of databases for Include and the one for Exclude will be the same. Just know that they don’t HAVE to be; you can include 3 databases, and exclude 4, or whatever you need.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 63 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Tuning Log Backups' AS [DetailHeader]
	, 'Log backups are interesting, because the size of the database doesn’t matter for a log file backup. If your database is small, but a process has blown the log up to a huge size, the size of the data file has no impact whatsoever on the log backup. You need to perform a backup tuning analysis for log file backups, just like for any other backup type. After all, you wouldn’t want to back up a 5MB log file to 10 files!

Any time you have a row in Minion.BackupTuningThresholds with BackupType = ''Log'', Minion Backup will automatically use the space used in the log as the measure for “SpaceType”.  So for example, if you have a 100GB log file that is 10% used, the space used in the log file is 10GB; Minion Backup uses this measure – the 10GB – to determine when the threshold should change. 

Though the value of SpaceType does not change anything in regards to log backups, we still recommend you set SpaceType equal to “Log” whenever the BackupType = ''Log'', because it is a visual reminder of how the threshold is calculated. 

This feature is meant to keep a huge log from taking hours to process, while other logs are filling up (because they can''''t back up yet because of the big one).  So, keep a safety net for yourself, and put in a couple tuning options for your logs.  If they grow really big, the payoff of tuned log backups is considerable; well-tuned log backups take a fraction of the time they ordinarily would.  

Note: The backup tuning thresholds feature does not shrink the log file.  To shrink the log file, see the three “ShrinkLog%” columns in the Minion.BackupSettings table.  These two features – Dynamic Backup Tuning and Shrink Log on Log Backup – work very well together to keep your system running without intervention from you. (You’re welcome!) For more information on shrinking the log, see “How to: Shrink log files after log backup”. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 64 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'About: Backing up to NUL' AS [DetailHeader]
	, 'As of Minion Backup 1.1, you can now take NUL backups to kick start your backup tuning scenario.  This is used to get your theoretical limit for your backups.  The theoretical limit is how fast your backups could theoretically go; it is an important step in tuning your backups.  
The column definition for the Minion.BackupSettingsPath table accepts NUL as a valid value for the BackupLocType, BackupDrive, and BackupPath columns.  The routine only cares about the BackupLocType column, but we advise you to put NUL in all three columns, because it makes your intent very clear.

The backup files for a NUL backup don’t actually exist, so there’s nothing to delete.  However, the system behaves just as if the files do exist, and it marks them as deleted based on the schedule outlined in the Minion.BackupSettingsPath table.

When you search for files that are still on the drive in the Minion.BackupFilesDelete stored procedure, it automatically excludes NUL backups from the result set.

IMPORTANT: Minion Backup itself does nothing to help you run the NUL backup just once.  You must run the NUL backup, and then remember to either disable the setting, or switch it to an actual destination.  The PreCode can really help with this because you can set it to flip the settings on specific days, or even just for a single specific day if you use the date itself.  But, there is no automatic mechanism that makes the system only run NUL once and then go back to normal operation.

For more information on how to use NUL to tune your backups, see our recorded webinar on the MidnightDBA.com Events page: http://midnightdba.itbookworm.com/EventVids/SQLSAT90BackupTuning/SQLSAT90BackupTuning.wmv' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@Debug' AS [DetailName]
	, 50 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Enable logging of special data to the debug tables.

For more information, see “Minion.BackupDebug” and “Minion.BackupDebugLogDetails”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@SyncSettings' AS [DetailName]
	, 50 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Enable synchronization of backup settings among instances in an existing Data Waiter scenario. For more information see, “How to: Synchronize backup settings and logs among instances”.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 50 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Generate restore statement, from the mirror location, for the most recent DB1 full backup' AS [DetailHeader]
	, 'EXEC [Minion].BackupRestoreDB
	@DBName = ''DB1'',
	@BackupType  = ''Log'' ,
	@BackupLoc = ''Mirror'' ,
	@StmtOnly = 1; ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 48 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'Note: This procedure only takes the first “move” command, because the file won''t be there anymore if you try to move it twice. But, you can have as many copies as you like.

Warning: You should be careful as this can run for a very long time and could increase the time of your backups if you run this inline. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Can I back up to Azure? ' AS [DetailHeader]
	, 'Yes, you can back up to Azure. Currently, Minion Backup can''t copy or move files to or from Microsoft Azure Blobs.  However, you can do a primary backup to an Azure Blob.

Minion Backup cannot delete files or create directories on Azure Blobs. ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'PathOrder' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'PathOrder' AS [DetailHeader]
	, 'If a backup goes to multiple drives, or is copied to multiple drives, then PathOrder is used to determine the order in which the different drives are used.
IMPORTANT: Like all ranking fields in Minion, PathOrder is a weighted measure. Higher numbers have a greater “weight” - they have a higher priority - and will be used earlier than lower numbers.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'NETBIOSName' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'NETBIOSName' AS [DetailHeader]
	, 'NetBIOS name.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestoreFileName' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreFileName' AS [DetailHeader]
	, 'The name of the file, without the extension. ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'MaxTransferSize' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaxTransferSize' AS [DetailHeader]
	, 'Max transfer size, as specified in bytes. This must be a multiple of 64KB.

Note that a value of 0 will allow Minion Backup to use the SQL Server default value, typically 1MB.

From MSDN.Microsoft.com: “Specifies the largest unit of transfer in bytes to be used between SQL Server and the backup media. The possible values are multiples of 65536 bytes (64 KB) ranging up to 4194304 bytes (4 MB).” ' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 3 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 50 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Alerting' AS [DetailHeader]
	, 'Minion Backup doesn’t include an alerting mechanism, though you can write one easily using the log tables. The jobs will almost always show a “succeeded” status, even if one or more backups fail; the error and failed backup will be recorded in the log.  

Here is one example of an alerting mechanism. Ideally, you could create a stored procedure, and simply call that procedure in step 2 of your backup job(s). 

---- Declare variables (could be SP parameters)
DECLARE @profile_name sysname = ''Server DBMail'' ,
    @recipients VARCHAR(MAX) = ''SQLsupport@Company.com'';

---- Declare and set internal variables
DECLARE @Query NVARCHAR(MAX) ,
    @Subject NVARCHAR(255); 

SET @Query = ''SELECT  ID ,
        ExecutionDateTime ,
        ServerLabel ,
        @@SERVERNAME AS Servername ,
        STATUS ,
        PctComplete ,
        DBName 
FROM    master.Minion.BackupLogDetails
WHERE   ExecutionDateTime = ( SELECT    MAX(ExecutionDateTime)
                              FROM      master.Minion.BackupLogDetails
                            )
        AND STATUS NOT IN (''All Complete'', ''Complete'');'';

SELECT  @Subject = @@Servername + '' ALERT: Log backup failed'';

---- Execute query to pull the rowcount
EXEC sp_executesql @Query;

---- If query returned rows, email to recipients
IF @@ROWCOUNT > 0
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients,
		@query = @Query ,
		@subject = @Subject,
		@attach_query_result_as_file = 0 ;

Important notes: 
  * This is just one example of how you could code a backup alert for Minion Backup. Review and modify this code for your own use, if you like, or grow your own.
  * We do not recommend basing alerts off of Status=’Complete’, because a successful backup run will not always be marked “Complete”. It will be “All Complete” if the backup batch was run by Minion.BackupMaster, and “Complete” if run by Minion.BackupDB.

__Minion Enterprise Hint__  Minion Backup doesn’t include an alerting mechanism, though you can write one easily using the log tables. Minion Enterprise provides central backup reporting and alerting. The ME alert for all databases includes the reasons why any backups fail, across the entire enterprise. Further, you can set customized alerting thresholds at various levels (server, database, and backup type).  For example, you might set the alert thresholds for some servers to alert on missing backups after a day; for a handful of databases, to alert at half a day; for log backups, alert on 5 hours; and for development servers, not at all. The choice is yours.
See http://www.MidnightSQL.com/Minion  for more information, or email us today at Support@MidnightDBA.com for a demo! ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPreCodeEndDateTime' AS [DetailName]
	, 50 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPreCodeEndDateTime' AS [DetailHeader]
	, 'End date of the batch precode.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPreCodeTimeInSecs' AS [DetailName]
	, 52 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPreCodeTimeInSecs' AS [DetailHeader]
	, 'Batch precode time to run, in seconds.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'BatchPostCode' AS [DetailName]
	, 52 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPostCode' AS [DetailHeader]
	, 'Precode to run after the entire backup operation.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 52 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'The current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DynamicTuning' AS [DetailName]
	, 52 AS [Position]
	, 'Column' AS [DetailType]
	, 'DynamicTuning' AS [DetailHeader]
	, 'Enables dynamic tuning.

For more on dynamic tuning, see “How to: Set up dynamic backup tuning thresholds”.
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'AzureCredential' AS [DetailName]
	, 54 AS [Position]
	, 'Column' AS [DetailType]
	, 'AzureCredential' AS [DetailHeader]
	, 'The name of the credential used to back up to a Microsoft Azure Blob.
When you take a backup to a Microsoft Azure Blob (with TO URL=’…’), you must set up a credential under security so you can access that blob. You have to pass that into the backup statement (WITH CREDNTIAL=’…’).
See https://msdn.microsoft.com/en-us/jj720558 ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Verify' AS [DetailName]
	, 54 AS [Position]
	, 'Column' AS [DetailType]
	, 'Verify' AS [DetailHeader]
	, 'Specifies when the RESTORE VERIFYONLY operation is to happen.  

Warning: Just as with the FileActionTime column, this setting must be used with caution.  Verifying backups can take a long time, and you could hold up subsequent backups while running the verify.  We recommend using AfterBatch.  

(Note that the FileAction operation is processed before the Verify operation.)

Valid inputs: NULL (meaning do not run verify), AfterBackup, AfterBatch

See http://msdn.microsoft.com/en-us/library/ms188902.aspx 
' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 54 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'Whether the current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPostCodeStartDateTime' AS [DetailName]
	, 54 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPostCodeStartDateTime' AS [DetailHeader]
	, 'Start date of the batch postcode.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 1 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 55 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Change Default Settings' AS [DetailHeader]
	, 'Minion Backup stores default settings for the entire instance in a single row (where DBName=’MinionDefault’ and BackypType=’All’) in the Minion.BackupSettings table.

WARNING: Do not delete the MinionDefault row, or rename the DBName for the MinionDefault row, in Minion.BackupSettings!

To change the default settings, run an update statement on the MinionDefault row in Minion.BackupSettings.  For example:
UPDATE  Minion.BackupSettings
SET     [Exclude] = 0 ,
        [LogLoc] = ''Local'' ,
        [HistRetDays] = 60 ,
        [ShrinkLogOnLogBackup] = 0 ,
        [ShrinkLogThresholdInMB] = 0 ,
        [ShrinkLogSizeInMB] = 0 
WHERE   [DBName] = ''MinionDefault''
        AND BackupType = ''All'';


WARNING: Choose your settings wisely; these settings can have a massive impact on your backups.  For example, if you want to verify the backup for YourDatabase, but accidentally set the Verify option for the default instance, all of the additional verify operations would cause an unexpected delay.  

For more information on these settings, see the “Minion.BackupSettings” section.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'BlockSize' AS [DetailName]
	, 55 AS [Position]
	, 'Column' AS [DetailType]
	, 'BlockSize' AS [DetailHeader]
	, 'From MSDN.Microsoft.com: “Specifies the physical block size, in bytes. The supported sizes are 512, 1024, 2048, 4096, 8192, 16384, 32768, and 65536 (64 KB) bytes. The default is 65536 for tape devices and 512 otherwise. Typically, this option is unnecessary because BACKUP automatically selects a block size that is appropriate to the device. Explicitly stating a block size overrides the automatic selection of block size.” ' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestoreFileExtension' AS [DetailName]
	, 55 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreFileExtension' AS [DetailHeader]
	, 'The file extension, with the period. For example: “.mdf”. 

NULL and MinionDefault will give the file its original file extension.

This field accepts Inline Tokens.

Examples: 
NULL
MinionDefault
.mdf
%BackupTypeExtension%' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 55 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Specifies full, log, or differential backups.
Example values: Full, Log, Diff, Private Key, Certificate' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 255 AS [ObjectID]
	, 'Example 2' AS [DetailName]
	, 55 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Example 2' AS [DetailHeader]
	, 'Let’s create a more complicated group, with a like expression and a DB name for Include (and the same for Exclude). 
ID  Action    MaintType   GroupName   GroupDef  Escape   IsActive  Comment
1   Include   Backup      MBRY        DB%       NULL     1         All DB% databases.
2   Include   Backup      MBRY        Minion    NULL     1         Minion database.
3   Exclude   Backup      MBRY        DB%       NULL     1         All DB% databases.
4   Exclude   Backup      MBRY        Minion    NULL     1         Minion database.

Now when we run Minion.BackupMaster with @Include=’DBGROUP:MBRY’, the Minion database and all of the DB% databases will be included in the backup.
And of course, running Minion.BackupMaster with @Exclude=’DBGROUP:MBRY’ will run backups for everything except the Minion database and all of the DB% databases.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsClustered' AS [DetailName]
	, 55 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsClustered' AS [DetailHeader]
	, 'Flag: is clustered.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'Attempts' AS [DetailName]
	, 55 AS [Position]
	, 'Column' AS [DetailType]
	, 'Attempts' AS [DetailHeader]
	, 'How many times it has attempted to send. ' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 51 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 55 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Generate log restore statements for all log backups since the most recent DB1 full backup' AS [DetailHeader]
	, 'EXEC [Minion].BackupRestoreDB
	@DBName = ''DB1'',
	@BackupType  = ''Log'' ,
	@BackupLoc = ''Primary'' ,
	@StmtOnly = 1; ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 50 AS [ObjectID]
	, '@SyncLogs' AS [DetailName]
	, 55 AS [Position]
	, 'Param' AS [DetailType]
	, 'Param' AS [DetailHeader]
	, 'Enable synchronization of backup logs among instances in an existing Data Waiter scenario. For more information see, “How to: Synchronize backup settings and logs among instances”.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 66 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 55 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'You guys are the MidnightDBAs, and you run MidnightSQL. What’s with “MinionWare”? ' AS [DetailHeader]
	, 'MidnightDBA is the banner for our free training. MidnighSQL Consulting, LLC is our actual consulting business. And now, we’ve spun up MinionWare, LLC as our software company. We released our new SQL Server management solution, Minion Enterprise, under the MinionWare banner. And now, all the little Minion guys will live together on www.MinionWare.net.  

Minion Reindex, Minion Backup, and other Minion modules are, and will continue to be free. Minion Enterprise is real enterprise software, and we’d love the chance to prove to you that it’s worth paying for. Get in touch at www.MinionWare.net and let’s do a demo, and get you a free 90 day trial! ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 56 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'PreferredServer' AS [DetailName]
	, 56 AS [Position]
	, 'Column' AS [DetailType]
	, 'PreferredServer' AS [DetailHeader]
	, 'The server on which you would like to perform backups in an Availability Group.

A NULL in this field defaults to the current AG primary (if in an AG scenario). This field is ignored for databases not in an AG scenario.

Valid inputs: 
NULL, AGPreferred, <specific server or server\instance name> 

For more on this topic, see “How to: Set up backups on Availability Groups”.
' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 56 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPostCodeEndDateTime' AS [DetailName]
	, 56 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPostCodeEndDateTime' AS [DetailHeader]
	, 'End date of the batch postcode.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'BatchPostCodeTimeInSecs' AS [DetailName]
	, 58 AS [Position]
	, 'Column' AS [DetailType]
	, 'BatchPostCodeTimeInSecs' AS [DetailHeader]
	, 'Batch precode time to run, in seconds.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'ShrinkLogOnLogBackup' AS [DetailName]
	, 58 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogOnLogBackup' AS [DetailHeader]
	, 'Turn on log shrink after log backups.

For more on this topic, see “How to: Shrink log files after backup”.
' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsInAG' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsInAG' AS [DetailHeader]
	, 'Flag: is in an Availability Group.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'ShrinkLogThresholdInMB' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogThresholdInMB' AS [DetailHeader]
	, 'How big (in MB) the log file is before Minion Backup will shrink it.  For example, if a log file is 1% full, but the file is only 1 GB, we probably don’t want to shrink it.

Note that you could force a shrink after every log backup by setting this to 0, but we don’t advise it.

For more on this topic, see “How to: Shrink log files after backup”.
' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 43 AS [ObjectID]
	, 'ErroredServers' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'ErroredServers' AS [DetailHeader]
	, 'Comma delimited list of servers to which this command failed to push. (The Data Waiter will retry these commands, and update the lists, automatically.)' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 44 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 60 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'The synchronization logging process, along with Minion.SyncErrorCmds, makes it easy to bring a target server (subscriber) up to date if it has been unavailable for a time. For example, if a target server is shut down for a day, once it restarts, MB can easily replay those commands starting from the time the server went down.

Let us take the case where YourServer is set to synchronize with its three Availability Group replicas, and one of those replicas is down.  The sync commands that fail to run against the downed replica will be logged here for as long as the replica is down. When that replica comes back online, Minion Backup will run through all the saved commands, bringing the replica’s tables back in sync with the primary tables. (Note that the other replicas will have been kept up to date this entire time.) ' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'IncludeDBs' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'IncludeDBs' AS [DetailHeader]
	, 'A comma-delimited list of database names, and/or wildcard strings, to include in the backup operation.
When this is ‘All’ or ‘null’, the operation processed all (non-excluded) databases.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupLocType' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupLocType' AS [DetailHeader]
	, 'Backup location type.
Example values: Local, NAS, URL
Note: URL is the most important of these, and is used by the Minion Backup process. The remaining inputs are user defined, as they’re just information for you. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'BackupLocation' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupLocation' AS [DetailHeader]
	, 'The location of the backup file to restore from. E.g., original backup location, copy location, or mirror location.

Backup and Primary mean the same thing; it is the original backup location recorded by Minion Backup.  Mirror, Copy, and Move mean the mirror (or copy or move) location, as recorded by MB.

Valid value: 
Backup
Primary
Mirror
Copy
Move' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'Replace' AS [DetailName]
	, 60 AS [Position]
	, 'Column' AS [DetailType]
	, 'Replace' AS [DetailHeader]
	, 'Whether to enable the WITH REPLACE restore option. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'ExcludeDBs' AS [DetailName]
	, 62 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExcludeDBs' AS [DetailHeader]
	, 'A comma-delimited list of database names, and/or wildcard strings, to exclude from the backup operation.

When this is ‘null’, the operation excluded no databases (except those excluded by configuration in Minion.BackupSettings).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'ShrinkLogSizeInMB' AS [DetailName]
	, 62 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogSizeInMB' AS [DetailHeader]
	, 'The size (in MB) the log file shrink should target.  In other words, how big you would like the log file to be after a file shrink.  

This setting applies for EACH log file, not for all log files totaled. If you specify 1024 as the size here, and you have three log files for your database, Minion Backup will attempt to shrink each of the three log files down to 1024MB (so you’ll end up with at least 3072MB of logs).

For more on this topic, see “How to: Shrink log files after backup”.
' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'MinSizeForDiffInGB' AS [DetailName]
	, 64 AS [Position]
	, 'Column' AS [DetailType]
	, 'MinSizeForDiffInGB' AS [DetailHeader]
	, 'The minimum size of a database (in GB) in order to perform differentials; databases under this size will not get differential backups.

A value of NULL or 0 means that there is no restriction on whether to take differential backups.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'RegexDBsIncluded' AS [DetailName]
	, 64 AS [Position]
	, 'Column' AS [DetailType]
	, 'RegexDBsIncluded' AS [DetailHeader]
	, 'A list of databases included in the backup operation via the Minion Backup regular expressions feature.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'WithFlags' AS [DetailName]
	, 65 AS [Position]
	, 'Column' AS [DetailType]
	, 'WithFlags' AS [DetailHeader]
	, 'Additional WITH flags. You can use any of the standard RESTORE statement WITH options, using a comma-delimited list. Note that log backup restores are automatically restored with NORECOVERY.

Example:
NORECOVERY' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'RestoreDBName' AS [DetailName]
	, 65 AS [Position]
	, 'Column' AS [DetailType]
	, 'RestoreDBName' AS [DetailHeader]
	, 'The name to give the newly restored database.

This field accepts Inline Tokens. ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsPrimaryReplica' AS [DetailName]
	, 65 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsPrimaryReplica' AS [DetailHeader]
	, 'Flag: is the primary replica.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupDrive' AS [DetailName]
	, 65 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupDrive' AS [DetailHeader]
	, 'Backup drive. This is only the drive letter of the backup destination.
IMPORTANT: If this is drive, this must end with colon-slash (for example, ‘M:\’). If this is URL, use the base path (for example, ‘\\server2\’)' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'DiffReplaceAction' AS [DetailName]
	, 66 AS [Position]
	, 'Column' AS [DetailType]
	, 'DiffReplaceAction' AS [DetailHeader]
	, 'If a database does not meet the MinSizeForDiffInGB limit, perform another action instead of a differential backup (e.g., perform a log backup instead).

While Minion Backup allows you to perform a full backup in lieu of a differential, understand that this could increase the expected time of the backup jobs.

A NULL value means the same as “Skip”.

Full
Log
Skip
NULL' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 41 AS [ObjectID]
	, 'RegexDBsExcluded' AS [DetailName]
	, 66 AS [Position]
	, 'Column' AS [DetailType]
	, 'RegexDBsExcluded' AS [DetailHeader]
	, 'A list of databases excluded from the backup operation via the Minion Backup regular expressions feature.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'LogProgress' AS [DetailName]
	, 68 AS [Position]
	, 'Column' AS [DetailType]
	, 'LogProgress' AS [DetailHeader]
	, 'Track the progress of backup operations for this database.  

Status is tracked in the Minion.BackupLog table.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'ServerLabel' AS [DetailName]
	, 70 AS [Position]
	, 'Column' AS [DetailType]
	, 'ServerLabel' AS [DetailHeader]
	, 'A user-customized label for the server name.  It can be the name of the server, server\instance, or a label for a server.  

This is used for the restore file path.  

Cannot contain an Inline Token. ' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'BeginTime' AS [DetailName]
	, 70 AS [Position]
	, 'Column' AS [DetailType]
	, 'BeginTime' AS [DetailHeader]
	, 'The start time at which this threshold applies. 

IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0). ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupPath' AS [DetailName]
	, 70 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupPath' AS [DetailHeader]
	, 'Backup path. This is only the path (for example, ‘SQLBackups\’) of the backup destination.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'FileAction' AS [DetailName]
	, 70 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileAction' AS [DetailHeader]
	, 'Move or copy the backup file.  

A value of NULL means this setting has no move or copy operations.
If COPY or MOVE is specified, at least one corresponding COPY entry (or a single corresponding MOVE entry, as appropriate) is required in the Minion.BackupSettingsPath table, to determine the path to copy or move to.  IMPORTANT: If there is no corresponding COPY or MOVE entry, this setting will generate no error; there will just be no copy. 

Valid inputs:
NULL, COPY, MOVE, CopyMove

For more on this topic, see “About: Copy and move backup files”. 
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBType' AS [DetailName]
	, 70 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBType' AS [DetailHeader]
	, 'Database type. 
Valid values: User , System' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'FileActionTime' AS [DetailName]
	, 72 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionTime' AS [DetailHeader]
	, 'The time at which to perform the COPY or MOVE FileAction.  

Valid inputs: AfterBackup, AfterBatch 

For more on this topic, see “About: Copy and move backup files”.
' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Encrypt' AS [DetailName]
	, 74 AS [Position]
	, 'Column' AS [DetailType]
	, 'Encrypt' AS [DetailHeader]
	, 'Encrypt the backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FullPath' AS [DetailName]
	, 75 AS [Position]
	, 'Column' AS [DetailType]
	, 'FullPath' AS [DetailHeader]
	, 'The full path without filename. For example: “C:\SQLBackups\Server1\DB1”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'EndTime' AS [DetailName]
	, 75 AS [Position]
	, 'Column' AS [DetailType]
	, 'EndTime' AS [DetailHeader]
	, 'The end time at which this threshold applies. 

IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds), on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0). ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'PathOrder' AS [DetailName]
	, 75 AS [Position]
	, 'Column' AS [DetailType]
	, 'PathOrder' AS [DetailHeader]
	, 'Not currently in use. ' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupType' AS [DetailName]
	, 75 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupType' AS [DetailHeader]
	, 'Backup type. 
Valid values: Full, Diff, Log' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 31 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 75 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'The Minion.BackupSettingsPath table comes with one default row: DBName=’MinionDefault’ and isMirror=0. If all of your backups are going to same location, you only need to update this row with your backup location.

You can also insert additional rows to configure the backup file target for an individual database, to override the default backup settings for that database.

You can also insert a row with BackupType=’MOVE’, to move a backup file after the backup operations are complete; and/or one or more rows with BackupType=’COPY’ to copy a backup file. Both MOVE and COPY operations are performed at a time designated by the FileActionTime field in the Minion.BackupSettings table. For example, if FileActionTime is set to ‘AfterBackup’, then a MOVE or COPY specified here in Minion.BackupSettingsPath will happen immediately after that backup (instead of at the end of the entire backup operation).

To backup a server certificate or database certificate, you must insert a row with BackupType = ‘ServerCert’. Server certificate backups don’t make use of the DBName field, so you can set it to ‘MinionDefault’, to signify that it applies universally. To backup a database certificate, you must insert an individual row for each –– either DBName = ‘MinionDefault’ and BackupType = ‘DatabaseCert’, or BackupType=’DatabaseCert’ for a specific database. 

Minion Backup will not back up certificates without an explicit BackupType=’ServerCert’ / ‘DatabaseCert’ row(s). You can have multiple certificate backup path rows for the same database (or for the server) going to multiple locations, all with isActive = 1. This is because certificates are so important to the restoration of a database, that Minion Backup allows you to back up the certificates to multiple locations. If you have five rows for DB2 database certificate backups, and all are set to isActive = 1, then all five of them are valid and will be executed. For more information, see the “How to: Configure certificate backups” section.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Name' AS [DetailName]
	, 76 AS [Position]
	, 'Column' AS [DetailType]
	, 'Name' AS [DetailHeader]
	, 'The name of the backup set.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx 
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'ExpireDateInHrs' AS [DetailName]
	, 78 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExpireDateInHrs' AS [DetailHeader]
	, 'Number of hours until the backup set for this backup can be overwritten.  

If both ExpireDateInHrs and RetainDays are both used, RetainDays takes precedence.

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FullFileName' AS [DetailName]
	, 80 AS [Position]
	, 'Column' AS [DetailType]
	, 'FullFileName' AS [DetailHeader]
	, 'The full path (drive, path, and file name) of the backup file. For example: “C:\SQLBackups\Server1\DB11of1LogDB120150514085245.TRN”' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 80 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'The current row is valid (active), and should be used in the Minion Backup process. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'DayOfWeek' AS [DetailName]
	, 80 AS [Position]
	, 'Column' AS [DetailType]
	, 'DayOfWeek' AS [DetailHeader]
	, 'The day or days to which the settings apply.

Valid inputs:
Weekday
Weekend
[an individual day, e.g., Sunday] ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'RetainDays' AS [DetailName]
	, 80 AS [Position]
	, 'Column' AS [DetailType]
	, 'RetainDays' AS [DetailHeader]
	, 'The number of days that must elapse before this backup media set can be overwritten.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupStartDateTime' AS [DetailName]
	, 80 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupStartDateTime' AS [DetailHeader]
	, 'Date and time of backup start.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Descr' AS [DetailName]
	, 82 AS [Position]
	, 'Column' AS [DetailType]
	, 'Descr' AS [DetailHeader]
	, 'Description of the backup set.  Note: this must be no more than 255 characters.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Checksum' AS [DetailName]
	, 84 AS [Position]
	, 'Column' AS [DetailType]
	, 'Checksum' AS [DetailHeader]
	, 'Verify each page for checksum and torn page (if enabled and available) and generate a checksum for the entire backup.

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 85 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'Whether the current row is valid (active), and should be used in the Minion Backup process. ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 251 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 85 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FileName' AS [DetailName]
	, 85 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileName' AS [DetailHeader]
	, 'Base file name, without extension. For example, “1of1LogDB120150514085245”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupEndDateTime' AS [DetailName]
	, 85 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupEndDateTime' AS [DetailHeader]
	, 'Date and time of backup end.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Init' AS [DetailName]
	, 86 AS [Position]
	, 'Column' AS [DetailType]
	, 'Init' AS [DetailHeader]
	, 'Overwrite the existing backup set.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Format' AS [DetailName]
	, 88 AS [Position]
	, 'Column' AS [DetailType]
	, 'Format' AS [DetailHeader]
	, 'Overwrite the existing media header.  Note that Format=1 is equivalent to Format=1 AND Init=1; therefore, FORMAT=1 will override the Init setting.

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'CopyOnly' AS [DetailName]
	, 90 AS [Position]
	, 'Column' AS [DetailType]
	, 'CopyOnly' AS [DetailHeader]
	, 'Perform a copy-only backup.  Copy only backups do not affect the normal sequence of backups.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx 
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupTimeInSecs' AS [DetailName]
	, 90 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupTimeInSecs' AS [DetailHeader]
	, 'Backup time, measured in seconds.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DateLogic' AS [DetailName]
	, 90 AS [Position]
	, 'Column' AS [DetailType]
	, 'DateLogic' AS [DetailHeader]
	, 'The date and time, in YYYYMMDDHHMMSS format. For example, 20150514085245. This is used in generating the backup filename.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 252 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 90 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose. ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Skip' AS [DetailName]
	, 92 AS [Position]
	, 'Column' AS [DetailType]
	, 'Skip' AS [DetailHeader]
	, 'Skip the check of the backup set’s expiration before overwriting.

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'BackupErrorMgmt' AS [DetailName]
	, 94 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupErrorMgmt' AS [DetailHeader]
	, 'Rollup of the two BACKUP flags – STOP_ON_ERROR and CONTINUE_AFTER_ERROR.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Extension' AS [DetailName]
	, 95 AS [Position]
	, 'Column' AS [DetailType]
	, 'Extension' AS [DetailHeader]
	, 'The file extension. For example, “.TRN”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MBPerSec' AS [DetailName]
	, 95 AS [Position]
	, 'Column' AS [DetailType]
	, 'MBPerSec' AS [DetailHeader]
	, 'Backup rate, in megabytes per second.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'MediaName' AS [DetailName]
	, 96 AS [Position]
	, 'Column' AS [DetailType]
	, 'MediaName' AS [DetailHeader]
	, 'The backup set’s media name.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'MediaDescription' AS [DetailName]
	, 98 AS [Position]
	, 'Column' AS [DetailType]
	, 'MediaDescription' AS [DetailHeader]
	, 'Description of the media set.  Note: this must be no more than 255 characters.  

See http://msdn.microsoft.com/en-us/library/ms186865.aspx
' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'IsActive' AS [DetailName]
	, 100 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsActive' AS [DetailHeader]
	, 'The current row is valid (active), and should be used in the Minion Backup process.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'RetHrs' AS [DetailName]
	, 100 AS [Position]
	, 'Column' AS [DetailType]
	, 'RetHrs' AS [DetailHeader]
	, 'Number of hours to retain the backup files.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupCmd' AS [DetailName]
	, 100 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupCmd' AS [DetailHeader]
	, 'The T-SQL command used to back up the database.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Comment' AS [DetailName]
	, 102 AS [Position]
	, 'Column' AS [DetailType]
	, 'Comment' AS [DetailHeader]
	, 'For your reference only. You can label each row with a short description and/or purpose.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsMirror' AS [DetailName]
	, 105 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsMirror' AS [DetailHeader]
	, 'Is a backup mirror location.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'SizeInMB' AS [DetailName]
	, 105 AS [Position]
	, 'Column' AS [DetailType]
	, 'SizeInMB' AS [DetailHeader]
	, 'Backup file size, in megabytes.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'StmtOnly' AS [DetailName]
	, 110 AS [Position]
	, 'Column' AS [DetailType]
	, 'StmtOnly' AS [DetailHeader]
	, 'Flag: only generate statement.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ToBeDeleted' AS [DetailName]
	, 110 AS [Position]
	, 'Column' AS [DetailType]
	, 'ToBeDeleted' AS [DetailHeader]
	, 'Date that the file is set to be deleted.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Discussion' AS [DetailName]
	, 110 AS [Position]
	, 'Discussion' AS [DetailType]
	, 'Discussion' AS [DetailHeader]
	, 'The Minion.BackupSettings table comes with a row with “MinionDefault” as the DBName value, and “All” as the BackupType.  This row defines the system-wide defaults.  

Important: Any row inserted for an individual database overrides only ALL of the values, whether or not they are specified.  Refer to the following for an example:

ID DBName        BackupType Exclude  …  DBPreCode 
1  MinionDefault All        0        …  EXEC specialCode;
2  YourDatabase  Full       0        …  NULL

The first row, “MinionDefault”, is the set of default values to use for all the databases in the SQL Server instance.  These values will be used for backup for all databases that do not have an additional row in this table.

The second row, [YourDatabase], specifies some values for YourDatabase.  This row completely overrides the “DefaultMinion” values for Full backups on YourDatabase.  

When full backups are performed for YourDatabase, only the values from the YourDatabase/Full row will be used.  So, even though the system-wide default (as specified in the MinionDefault row) for DBPreCode is ‘EXEC specialCode;’, Full backups on YourDatabase will NOT use that default value.  Because DBPreCode is NULL for YourDatabase/Full, Full backups will perform no pre code for YourDatabase.  

For more information, see the “Configuration Settings Hierarchy” section in “Architecture Overview”.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 110 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 1: Weekly full, daily differential, hourly log backups' AS [DetailHeader]
	, 'We could use this table to define the following backup time scenarios:
  * Full system backups on Sunday, one time between 6pm and 7pm.
  * Full user backups on Sunday, one time between 8pm and 9pm.
  * Differential backups on every other day (Monday-Saturday), one time each between 8pm and 9pm.
  * Log backups hourly (except when differential or full backups are running).

To do this, we would set the MinionBackup-AUTO backup job to run once hourly, and define the following rows. (Note that some of the table columns are omitted, for presentation purposes.)

ID DBType BackupType Day      ReadOnly BeginTime EndTime  MaxForTimeframe
5  System Full       Sunday   1        18:00:00  19:00:00 1
6  User   Full       Sunday   1        20:00:00  21:00:00 1
7  User   Diff       Weekday  1        20:00:00  21:00:00 1
8  User   Diff       Saturday 1        20:00:00  21:00:00 1
9  User   Log        Sunday   1        00:00:00  23:59:59 24
	
We do not have to specifically time the log backups to avoid the 8pm differential and full backup windows; because both differential and full backups take precedence over log backups. So when the 8pm job begins, it will see the differential or full backup slated, and discard the log backup for that hour. In other words, the job run history would look like this: 
  * Sunday 7pm – user log backup, system full backup
  * Sunday 8pm – user full backup
  * Sunday 9pm – user log backup
  * Continuing hourly log backups…
  * Monday 7pm – user log backup
  * Monday 8pm – user diff backups
  * Etc...' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 30 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 115 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example: Set custom configuration for Full backups on database ‘YourDatabase’' AS [DetailHeader]
	, 'INSERT	INTO [Minion].[BackupSettings]
		( [DBName] ,
		  [BackupType] ,
		  [Exclude] ,
		  [LogLoc] ,
		  [HistRetDays] ,
		  [ShrinkLogOnLogBackup] ,
		  [ShrinkLogThresholdInMB] ,
		  [ShrinkLogSizeInMB] ,
		  [Name] ,
		  [ExpireDateInHrs] ,
		  [RetainDays] ,
		  [Descr] ,
		  [Checksum] ,
		  [Init] ,
		  [Format] ,
		  [MediaName] ,
		  [MediaDescription]
		)
SELECT	''YourDatabase'' AS [DBName] ,
		''All'' AS [BackupType] ,
		0 AS [Exclude] ,
		''Local'' AS [LogLoc] ,
		60 AS [HistRetDays] ,
		1 AS [ShrinkLogOnLogBackup] ,
		1 AS [ShrinkLogThresholdInMB] ,
		1024 AS [ShrinkLogSizeInMB] ,
		''Backup name'' AS [Name] ,
		5 AS [ExpireDateInHrs] ,
		2 AS [RetainDays] ,
		''backup desc'' AS [Descr] ,
		1 AS [Checksum] ,
		1 AS [Init] ,
		1 AS [Format] ,
		''MediaName'' AS [MediaName] ,
		''MediaDesc'' AS [MediaDescription];' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DeleteDateTime' AS [DetailName]
	, 115 AS [Position]
	, 'Column' AS [DetailType]
	, 'DeleteDateTime' AS [DetailHeader]
	, 'Date that the file was deleted.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'READONLY' AS [DetailName]
	, 115 AS [Position]
	, 'Column' AS [DetailType]
	, 'READONLY' AS [DetailHeader]
	, 'Backup readonly option; this decides whether or not to include ReadOnly databases in the backup, or to perform backups on only ReadOnly databases. 
A value of 1 includes ReadOnly databases; 2 excludes ReadOnly databases; and 3 only includes ReadOnly databases.
Valid values: 1, 2, 3' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupGroupOrder' AS [DetailName]
	, 120 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupGroupOrder' AS [DetailHeader]
	, 'Group to which this table belongs.  Used solely for determining the order in which tables should be backed up.
Most of the time this will be 0.  However, if you choose to take advantage of this feature a row in Minion.BackupSettings will get you there.  This is a weighted list so higher numbers are more important and will be processed first. 
For more information, see “How To: Back up databases in a specific order”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsDeleted' AS [DetailName]
	, 120 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsDeleted' AS [DetailHeader]
	, 'Whether the file has been deleted.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 32 AS [ObjectID]
	, 'Example' AS [DetailName]
	, 120 AS [Position]
	, 'Example' AS [DetailType]
	, 'Example 2: Daily full, differential every 4 hours, log backups every 15 minutes' AS [DetailHeader]
	, 'We could use this table to define the following backup time scenarios:
  * Full system backups daily, one time between 9pm and 9:30pm.
  * Full user backups daily, one time between 10pm and 10:30pm.
  * Differential backups every 4 hours (except when full backups are running), starting at 2:00am.
  * Log backups every 15 minutes (except when differential or full backups are running).

To do this, we would set the MinionBackup-AUTO backup job to run every 15 minutes, and define the following rows. (Note that some of the table columns are omitted, for presentation purposes.)

ID DBType BackupType Day   ReadOnly BeginTime EndTime  MaxForTimeframe
5  System Full       Daily 1        21:00:00  21:30:00 1
6  User   Full       Daily 1        22:00:00  22:30:00 1
7  User   Diff       Daily 1        02:00:00  02:30:00 1
8  User   Diff       Daily 1        06:00:00  06:30:00 1
9  User   Diff       Daily 1        10:00:00  10:30:00 1
10 User   Diff       Daily 1        14:00:00  14:30:00 1
11 User   Diff       Daily 1        18:00:00  18:30:00 1
12 User   Log        Daily 1        00:00:00  23:59:59 96

In short, we need one row each for: 
  * full daily system backups
  * full daily user backups
  * full log backups (these run every 15 minutes)

And additionally, one row per each differential backup timeframe (2am, 6am, 10am, 2pm, and 6pm). We don’t take a differential at 10pm, of course, because that is when the full backup will run.

Note: The 10pm user log backups will be replaced by the 10pm user full backups.' AS [DetailText]
	, NULL AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsArchive' AS [DetailName]
	, 125 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsArchive' AS [DetailHeader]
	, 'Whether the file is marked as “Archived”, which protects the file from being deleted at any time.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupGroupDBOrder' AS [DetailName]
	, 125 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupGroupDBOrder' AS [DetailHeader]
	, 'Group to which this database belongs.  Used solely for determining the order in which databases should be backed up.
By default, all databases have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects.
Higher numbers have a greater “weight” (they have a higher priority), and will be backed up earlier than lower numbers.  The range of GroupDBOrder weight numbers is 0-255.
For more information, see “How To: Backup databases in a specific order”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'NumberOfFiles' AS [DetailName]
	, 130 AS [Position]
	, 'Column' AS [DetailType]
	, 'NumberOfFiles' AS [DetailHeader]
	, 'Number of backup files. 
Note that this is not at all related to the number of files in the database itself.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupSizeInMB' AS [DetailName]
	, 130 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupSizeInMB' AS [DetailHeader]
	, 'The size of the entire backup, in MB.' AS [DetailText]
	, 'numeric' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Buffercount' AS [DetailName]
	, 135 AS [Position]
	, 'Column' AS [DetailType]
	, 'Buffercount' AS [DetailHeader]
	, 'Total number of I/O buffers to be used for the backup operation. From the output of Trace Flag 3213.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupName' AS [DetailName]
	, 135 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupName' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupDescription' AS [DetailName]
	, 140 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupDescription' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MaxTransferSize' AS [DetailName]
	, 140 AS [Position]
	, 'Column' AS [DetailType]
	, 'MaxTransferSize' AS [DetailHeader]
	, 'The largest unit of transfer (in bytes) to be used between SQL Server and the backup media. From the output of Trace Flag 3213. ' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ExpirationDate' AS [DetailName]
	, 145 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExpirationDate' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MemoryLimitInMB' AS [DetailName]
	, 145 AS [Position]
	, 'Column' AS [DetailType]
	, 'MemoryLimitInMB' AS [DetailHeader]
	, 'How much memory the system has available for backups. From the output of Trace Flag 3213.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'TotalBufferSpaceInMB' AS [DetailName]
	, 150 AS [Position]
	, 'Column' AS [DetailType]
	, 'TotalBufferSpaceInMB' AS [DetailHeader]
	, 'How much memory used to process the backup. From the output of Trace Flag 3213.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Compressed' AS [DetailName]
	, 150 AS [Position]
	, 'Column' AS [DetailType]
	, 'Compressed' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'POSITION' AS [DetailName]
	, 155 AS [Position]
	, 'Column' AS [DetailType]
	, 'POSITION' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileSystemIOAlignInKB' AS [DetailName]
	, 155 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileSystemIOAlignInKB' AS [DetailHeader]
	, 'The disk block size. From the output of Trace Flag 3213.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'SetsOfBuffers' AS [DetailName]
	, 160 AS [Position]
	, 'Column' AS [DetailType]
	, 'SetsOfBuffers' AS [DetailHeader]
	, 'From the output of Trace Flag 3213.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DeviceType' AS [DetailName]
	, 160 AS [Position]
	, 'Column' AS [DetailType]
	, 'DeviceType' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'UserName' AS [DetailName]
	, 165 AS [Position]
	, 'Column' AS [DetailType]
	, 'UserName' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Verify' AS [DetailName]
	, 165 AS [Position]
	, 'Column' AS [DetailType]
	, 'Verify' AS [DetailHeader]
	, 'Specifies when the RESTORE VERIFYONLY operation is to happen.  ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Compression' AS [DetailName]
	, 170 AS [Position]
	, 'Column' AS [DetailType]
	, 'Compression' AS [DetailHeader]
	, 'Flag: Whether backup compression is performed on this backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DatabaseName' AS [DetailName]
	, 170 AS [Position]
	, 'Column' AS [DetailType]
	, 'DatabaseName' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'sysname' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DatabaseVersion' AS [DetailName]
	, 175 AS [Position]
	, 'Column' AS [DetailType]
	, 'DatabaseVersion' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileAction' AS [DetailName]
	, 175 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileAction' AS [DetailHeader]
	, 'Action to take with the backup file(s) (MOVE, COPY, or NULL).' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileActionTime' AS [DetailName]
	, 180 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionTime' AS [DetailHeader]
	, 'The time at which to perform the COPY or MOVE FileAction.  
Example values: AfterBackup, AfterBatch ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DatabaseCreationDate' AS [DetailName]
	, 180 AS [Position]
	, 'Column' AS [DetailType]
	, 'DatabaseCreationDate' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupSizeInBytes' AS [DetailName]
	, 185 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupSizeInBytes' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileActionBeginDateTime' AS [DetailName]
	, 185 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionBeginDateTime' AS [DetailHeader]
	, 'Date and time of the file action start.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileActionEndDateTime' AS [DetailName]
	, 190 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionEndDateTime' AS [DetailHeader]
	, 'Date and time of the file action end.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FirstLSN' AS [DetailName]
	, 190 AS [Position]
	, 'Column' AS [DetailType]
	, 'FirstLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'LastLSN' AS [DetailName]
	, 195 AS [Position]
	, 'Column' AS [DetailType]
	, 'LastLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileActionTimeInSecs' AS [DetailName]
	, 195 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileActionTimeInSecs' AS [DetailHeader]
	, 'File action time, measured in seconds.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'UnCompressedBackupSizeMB' AS [DetailName]
	, 200 AS [Position]
	, 'Column' AS [DetailType]
	, 'UnCompressedBackupSizeMB' AS [DetailHeader]
	, 'Size of the uncompressed backup, in megabytes.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'CheckpointLSN' AS [DetailName]
	, 200 AS [Position]
	, 'Column' AS [DetailType]
	, 'CheckpointLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DatabaseBackupLSN' AS [DetailName]
	, 205 AS [Position]
	, 'Column' AS [DetailType]
	, 'DatabaseBackupLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'CompressedBackupSizeMB' AS [DetailName]
	, 205 AS [Position]
	, 'Column' AS [DetailType]
	, 'CompressedBackupSizeMB' AS [DetailHeader]
	, 'Size of the compressed backup, in megabytes.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'CompressionRatio' AS [DetailName]
	, 210 AS [Position]
	, 'Column' AS [DetailType]
	, 'CompressionRatio' AS [DetailHeader]
	, 'Backup compression ratio. 
As noted in the MSDN Backup Compression article, “a 3:1 compression ratio indicates that you are saving about 66% on disk space”.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupStartDate' AS [DetailName]
	, 210 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupStartDate' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'COMPRESSIONPct' AS [DetailName]
	, 215 AS [Position]
	, 'Column' AS [DetailType]
	, 'COMPRESSIONPct' AS [DetailHeader]
	, 'Backup compression ratio, in percent. 
As noted in the MSDN Backup Compression article, “a 3:1 compression ratio indicates that you are saving about 66% on disk space”.' AS [DetailText]
	, 'numeric' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupFinishDate' AS [DetailName]
	, 215 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupFinishDate' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'SortOrder' AS [DetailName]
	, 220 AS [Position]
	, 'Column' AS [DetailType]
	, 'SortOrder' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupRetHrs' AS [DetailName]
	, 220 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupRetHrs' AS [DetailHeader]
	, 'Number of hours to retain the backup files.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupLogging' AS [DetailName]
	, 225 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupLogging' AS [DetailHeader]
	, 'Whether log data is only stored on the local (client) server, or on both the local server and the central Minion (repository) server.  
Example values: Local, Repo' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'CODEPAGE' AS [DetailName]
	, 225 AS [Position]
	, 'Column' AS [DetailType]
	, 'CODEPAGE' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'UnicodeLocaleId' AS [DetailName]
	, 230 AS [Position]
	, 'Column' AS [DetailType]
	, 'UnicodeLocaleId' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupLoggingRetDays' AS [DetailName]
	, 230 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupLoggingRetDays' AS [DetailHeader]
	, 'Number of days to retain a history of backups (in Minion Backup log tables).
Minion Backup does not modify or delete backup information from the MSDB database.' AS [DetailText]
	, 'smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DelFileBefore' AS [DetailName]
	, 235 AS [Position]
	, 'Column' AS [DetailType]
	, 'DelFileBefore' AS [DetailHeader]
	, 'Whether backup files are to be deleted before or after the current backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'UnicodeComparisonStyle' AS [DetailName]
	, 235 AS [Position]
	, 'Column' AS [DetailType]
	, 'UnicodeComparisonStyle' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'CompatibilityLevel' AS [DetailName]
	, 240 AS [Position]
	, 'Column' AS [DetailType]
	, 'CompatibilityLevel' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPreCode' AS [DetailName]
	, 240 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPreCode' AS [DetailHeader]
	, 'Code that ran before the backup operation begans for that database.  ' AS [DetailText]
	, 'nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPostCode' AS [DetailName]
	, 245 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPostCode' AS [DetailHeader]
	, 'Code that ran after the backup operation completed for that database.  ' AS [DetailText]
	, 'nvarchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'SoftwareVendorId' AS [DetailName]
	, 245 AS [Position]
	, 'Column' AS [DetailType]
	, 'SoftwareVendorId' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'SoftwareVersionMajor' AS [DetailName]
	, 250 AS [Position]
	, 'Column' AS [DetailType]
	, 'SoftwareVersionMajor' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPreCodeStartDateTime' AS [DetailName]
	, 250 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPreCodeStartDateTime' AS [DetailHeader]
	, 'The date and time that the database precode began.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPreCodeEndDateTime' AS [DetailName]
	, 255 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPreCodeEndDateTime' AS [DetailHeader]
	, 'The date and time that the database precode ended.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'SoftwareVersionMinor' AS [DetailName]
	, 255 AS [Position]
	, 'Column' AS [DetailType]
	, 'SoftwareVersionMinor' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'SovtwareVersionBuild' AS [DetailName]
	, 260 AS [Position]
	, 'Column' AS [DetailType]
	, 'SovtwareVersionBuild' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPreCodeTimeInSecs' AS [DetailName]
	, 260 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPreCodeTimeInSecs' AS [DetailHeader]
	, 'The duration of the database precode run.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPostCodeStartDateTime' AS [DetailName]
	, 265 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPostCodeStartDateTime' AS [DetailHeader]
	, 'The date and time that the database postcode began.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'MachineName' AS [DetailName]
	, 265 AS [Position]
	, 'Column' AS [DetailType]
	, 'MachineName' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'Flags' AS [DetailName]
	, 270 AS [Position]
	, 'Column' AS [DetailType]
	, 'Flags' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPostCodeEndDateTime' AS [DetailName]
	, 270 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPostCodeEndDateTime' AS [DetailHeader]
	, 'The date and time that the database postcode ended.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DBPostCodeTimeInSecs' AS [DetailName]
	, 275 AS [Position]
	, 'Column' AS [DetailType]
	, 'DBPostCodeTimeInSecs' AS [DetailHeader]
	, 'The duration of the database postcode run.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BindingID' AS [DetailName]
	, 275 AS [Position]
	, 'Column' AS [DetailType]
	, 'BindingID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'RecoveryForkID' AS [DetailName]
	, 280 AS [Position]
	, 'Column' AS [DetailType]
	, 'RecoveryForkID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IncludeDBs' AS [DetailName]
	, 280 AS [Position]
	, 'Column' AS [DetailType]
	, 'IncludeDBs' AS [DetailHeader]
	, 'Databases included in the backup batch.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ExcludeDBs' AS [DetailName]
	, 285 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExcludeDBs' AS [DetailHeader]
	, 'Databases excluded from the backup batch.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'COLLATION' AS [DetailName]
	, 285 AS [Position]
	, 'Column' AS [DetailType]
	, 'COLLATION' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FamilyGUID' AS [DetailName]
	, 290 AS [Position]
	, 'Column' AS [DetailType]
	, 'FamilyGUID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'RegexDBsExcluded' AS [DetailName]
	, 290 AS [Position]
	, 'Column' AS [DetailType]
	, 'RegexDBsExcluded' AS [DetailHeader]
	, 'Databases excluded from the backup batch via regular expressions.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Verified' AS [DetailName]
	, 295 AS [Position]
	, 'Column' AS [DetailType]
	, 'Verified' AS [DetailHeader]
	, 'Specifies whether the RESTORE VERIFYONLY operation was performed.  ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'HasBulkLoggedData' AS [DetailName]
	, 295 AS [Position]
	, 'Column' AS [DetailType]
	, 'HasBulkLoggedData' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsSnapshot' AS [DetailName]
	, 300 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsSnapshot' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'VerifyStartDateTime' AS [DetailName]
	, 300 AS [Position]
	, 'Column' AS [DetailType]
	, 'VerifyStartDateTime' AS [DetailHeader]
	, 'The date and time that RESTORE VERIFYONLY began.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'VerifyEndDateTime' AS [DetailName]
	, 305 AS [Position]
	, 'Column' AS [DetailType]
	, 'VerifyEndDateTime' AS [DetailHeader]
	, 'The date and time that RESTORE VERIFYONLY began.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsReadOnly' AS [DetailName]
	, 305 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsReadOnly' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsSingleUser' AS [DetailName]
	, 310 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsSingleUser' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'VerifyTimeInSecs' AS [DetailName]
	, 310 AS [Position]
	, 'Column' AS [DetailType]
	, 'VerifyTimeInSecs' AS [DetailHeader]
	, 'The duration of the RESTORE VERIFYONLY run.' AS [DetailText]
	, 'Int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsInit' AS [DetailName]
	, 315 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsInit' AS [DetailHeader]
	, 'Flag: Overwrite the existing backup set.  ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'HasBackupChecksums' AS [DetailName]
	, 315 AS [Position]
	, 'Column' AS [DetailType]
	, 'HasBackupChecksums' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsDamaged' AS [DetailName]
	, 320 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsDamaged' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsFormat' AS [DetailName]
	, 320 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsFormat' AS [DetailHeader]
	, 'Flag: Overwrite the existing media header.  Note that Format=1 is equivalent to Format=1 AND Init=1; therefore, FORMAT=1 would have overriden the Init setting.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsCheckSum' AS [DetailName]
	, 325 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsCheckSum' AS [DetailHeader]
	, 'Flag: Verify each page for checksum and torn page (if enabled and available) and generate a checksum for the entire backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BeginsLogChain' AS [DetailName]
	, 325 AS [Position]
	, 'Column' AS [DetailType]
	, 'BeginsLogChain' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'HasIncompleteMeatdata' AS [DetailName]
	, 330 AS [Position]
	, 'Column' AS [DetailType]
	, 'HasIncompleteMeatdata' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Descr' AS [DetailName]
	, 330 AS [Position]
	, 'Column' AS [DetailType]
	, 'Descr' AS [DetailHeader]
	, '' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsCopyOnly' AS [DetailName]
	, 335 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsCopyOnly' AS [DetailHeader]
	, 'Flag: Perform a copy-only backup.  ' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsForceOffline' AS [DetailName]
	, 335 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsForceOffline' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'IsCopyOnly' AS [DetailName]
	, 340 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsCopyOnly' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsSkip' AS [DetailName]
	, 340 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsSkip' AS [DetailHeader]
	, 'Flag: Skip the check of the backup set’s expiration before overwriting.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupName' AS [DetailName]
	, 345 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupName' AS [DetailHeader]
	, 'Backup name.' AS [DetailText]
	, 'Varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'FirstRecoveryForkID' AS [DetailName]
	, 345 AS [Position]
	, 'Column' AS [DetailType]
	, 'FirstRecoveryForkID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'ForkPointLSN' AS [DetailName]
	, 350 AS [Position]
	, 'Column' AS [DetailType]
	, 'ForkPointLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupErrorMgmt' AS [DetailName]
	, 350 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupErrorMgmt' AS [DetailHeader]
	, 'Rollup of the two BACKUP flags – STOP_ON_ERROR and CONTINUE_AFTER_ERROR.  ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MediaName' AS [DetailName]
	, 355 AS [Position]
	, 'Column' AS [DetailType]
	, 'MediaName' AS [DetailHeader]
	, 'The backup set’s media name.  ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'RecoveryModel' AS [DetailName]
	, 355 AS [Position]
	, 'Column' AS [DetailType]
	, 'RecoveryModel' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DifferentialBaseLSN' AS [DetailName]
	, 360 AS [Position]
	, 'Column' AS [DetailType]
	, 'DifferentialBaseLSN' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MediaDescription' AS [DetailName]
	, 360 AS [Position]
	, 'Column' AS [DetailType]
	, 'MediaDescription' AS [DetailHeader]
	, 'Description of the media set.  ' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ExpireDateInHrs' AS [DetailName]
	, 365 AS [Position]
	, 'Column' AS [DetailType]
	, 'ExpireDateInHrs' AS [DetailHeader]
	, 'Number of hours until the backup set for this backup can be overwritten.  
If both ExpireDateInHrs and RetainDays are both used, RetainDays takes precedence.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'DifferentialBaseGUID' AS [DetailName]
	, 365 AS [Position]
	, 'Column' AS [DetailType]
	, 'DifferentialBaseGUID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupTypeDescription' AS [DetailName]
	, 370 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupTypeDescription' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'RetainDays' AS [DetailName]
	, 370 AS [Position]
	, 'Column' AS [DetailType]
	, 'RetainDays' AS [DetailHeader]
	, 'The number of days that must elapse before this backup media set can be overwritten.  ' AS [DetailText]
	, 'smallint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'MirrorBackup' AS [DetailName]
	, 375 AS [Position]
	, 'Column' AS [DetailType]
	, 'MirrorBackup' AS [DetailHeader]
	, 'Flag: Mirror backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'BackupSetGUID' AS [DetailName]
	, 375 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupSetGUID' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'CompressedBackupSize' AS [DetailName]
	, 380 AS [Position]
	, 'Column' AS [DetailType]
	, 'CompressedBackupSize' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DynamicTuning' AS [DetailName]
	, 380 AS [Position]
	, 'Column' AS [DetailType]
	, 'DynamicTuning' AS [DetailHeader]
	, 'Flag: Enable dynamic tuning.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ShrinkLogOnLogBackup' AS [DetailName]
	, 385 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogOnLogBackup' AS [DetailHeader]
	, 'Flag: Turn on log shrink after log backups.' AS [DetailText]
	, 'Bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 39 AS [ObjectID]
	, 'CONTAINMENT' AS [DetailName]
	, 385 AS [Position]
	, 'Column' AS [DetailType]
	, 'CONTAINMENT' AS [DetailHeader]
	, 'See the MSDN article “RESTORE HEADERONLY”.' AS [DetailText]
	, 'tinyint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ShrinkLogThresholdInMB' AS [DetailName]
	, 390 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogThresholdInMB' AS [DetailHeader]
	, 'How big (in MB) the log file is before Minion Backup will shrink it.  ' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'ShrinkLogSizeInMB' AS [DetailName]
	, 395 AS [Position]
	, 'Column' AS [DetailType]
	, 'ShrinkLogSizeInMB' AS [DetailHeader]
	, 'The size (in MB) the log file shrink should target.  In other words, how big you would like the log file to be after a file shrink.  
This setting applies for EACH log file, not for all log files totaled.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PreBackupLogSizeInMB' AS [DetailName]
	, 400 AS [Position]
	, 'Column' AS [DetailType]
	, 'PreBackupLogSizeInMB' AS [DetailHeader]
	, 'Log size in MB before the backup.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PreBackupLogUsedPct' AS [DetailName]
	, 405 AS [Position]
	, 'Column' AS [DetailType]
	, 'PreBackupLogUsedPct' AS [DetailHeader]
	, 'Log percent used before the backup.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PostBackupLogSizeInMB' AS [DetailName]
	, 410 AS [Position]
	, 'Column' AS [DetailType]
	, 'PostBackupLogSizeInMB' AS [DetailHeader]
	, 'Log size in MB after the backup.' AS [DetailText]
	, 'float' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PostBackupLogUsedPct' AS [DetailName]
	, 415 AS [Position]
	, 'Column' AS [DetailType]
	, 'PostBackupLogUsedPct' AS [DetailHeader]
	, 'Log percent used after the backup.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PreBackupLogReuseWait' AS [DetailName]
	, 420 AS [Position]
	, 'Column' AS [DetailType]
	, 'PreBackupLogReuseWait' AS [DetailHeader]
	, 'Log reuse wait description, before the backup.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'PostBackupLogReuseWait' AS [DetailName]
	, 425 AS [Position]
	, 'Column' AS [DetailType]
	, 'PostBackupLogReuseWait' AS [DetailHeader]
	, 'Log reuse wait description, after the backup.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'VLFs' AS [DetailName]
	, 430 AS [Position]
	, 'Column' AS [DetailType]
	, 'VLFs' AS [DetailHeader]
	, 'The number of Virtual Log Files.' AS [DetailText]
	, 'bigint' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'FileList' AS [DetailName]
	, 435 AS [Position]
	, 'Column' AS [DetailType]
	, 'FileList' AS [DetailHeader]
	, 'A comma delimited list of backup files, in the format “DISK = ‘<full file path>’, DISK = ‘<full file path>’”.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsTDE' AS [DetailName]
	, 440 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsTDE' AS [DetailHeader]
	, 'Flag: Is a TDE database.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupCert' AS [DetailName]
	, 445 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupCert' AS [DetailHeader]
	, 'Flag: Certificate backups enabled.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'CertPword' AS [DetailName]
	, 450 AS [Position]
	, 'Column' AS [DetailType]
	, 'CertPword' AS [DetailHeader]
	, 'Certificate password. This is the password 
used to protect the certificate backup.' AS [DetailText]
	, 'varbinary' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'IsEncryptedBackup' AS [DetailName]
	, 455 AS [Position]
	, 'Column' AS [DetailType]
	, 'IsEncryptedBackup' AS [DetailHeader]
	, 'Flag: Is an encrypted backup.' AS [DetailText]
	, 'bit' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupEncryptionCertName' AS [DetailName]
	, 460 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupEncryptionCertName' AS [DetailHeader]
	, 'Backup encryption certificate name.' AS [DetailText]
	, 'nchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupEncryptionAlgorithm' AS [DetailName]
	, 465 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupEncryptionAlgorithm' AS [DetailHeader]
	, 'Backup encryption certificate algorithm.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'BackupEncryptionCertThumbPrint' AS [DetailName]
	, 470 AS [Position]
	, 'Column' AS [DetailType]
	, 'BackupEncryptionCertThumbPrint' AS [DetailHeader]
	, 'Backup encryption certificate thumbprint, a globally unique hash of the certificate.' AS [DetailText]
	, 'varbinary' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DeleteFilesStartDateTime' AS [DetailName]
	, 475 AS [Position]
	, 'Column' AS [DetailType]
	, 'DeleteFilesStartDateTime' AS [DetailHeader]
	, 'The date and time that the file deletion began.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DeleteFilesEndDateTime' AS [DetailName]
	, 480 AS [Position]
	, 'Column' AS [DetailType]
	, 'DeleteFilesEndDateTime' AS [DetailHeader]
	, 'The date and time that the file deletion completed.' AS [DetailText]
	, 'datetime' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'DeleteFilesTimeInSecs' AS [DetailName]
	, 485 AS [Position]
	, 'Column' AS [DetailType]
	, 'DeleteFilesTimeInSecs' AS [DetailHeader]
	, 'The duration of the file deletion run.' AS [DetailText]
	, 'int' AS [Datatype];

GO
INSERT INTO #HelpObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [Datatype]) 
SELECT 42 AS [ObjectID]
	, 'Warnings' AS [DetailName]
	, 490 AS [Position]
	, 'Column' AS [DetailType]
	, 'Warnings' AS [DetailHeader]
	, 'Warnings.' AS [DetailText]
	, 'varchar' AS [Datatype];

GO

GO
--------------------------------
----- END: INSERTS GO HERE -----
--------------------------------

--&--------------------------------------------
-- 4. Insert all HelpObjects

INSERT  INTO Minion.HELPObjects
        ( [Module] ,
          [ObjectName] ,
          [ObjectType] ,
          [MinionVersion] ,
          [GlobalPosition]
        )
        SELECT  [Module] ,
                [ObjectName] ,
                [ObjectType] ,
                [MinionVersion] ,
                [GlobalPosition]
        FROM    #HelpObjects;


--&--------------------------------------------
-- 5. Update #HelpObjects and #HelpObjectDetails with the new object IDs from Minion.HelpObjects
UPDATE  HO
SET     NewObjectID = MHO.ID
FROM    #HelpObjects AS HO
        JOIN Minion.HELPObjects AS MHO ON ISNULL(HO.[Module], '') = ISNULL(MHO.[Module],'')
                AND ISNULL(HO.[ObjectName], '') = ISNULL(MHO.[ObjectName],'')
                AND ISNULL(HO.[ObjectType], '') = ISNULL(MHO.[ObjectType],'')
                AND ISNULL(HO.[MinionVersion], 1) = ISNULL(MHO.[MinionVersion],1)
                AND ISNULL(HO.[GlobalPosition], 1) = ISNULL(MHO.[GlobalPosition],1);

UPDATE  HDO
SET     HDO.ObjectID = HO.NewObjectID ,
        updated = 1
FROM    #HelpObjectDetail HDO
        JOIN #HelpObjects HO ON HDO.ObjectID = HO.ID;


--&--------------------------------------------
-- 6. Insert all HelpObjectDetail rows
INSERT  INTO Minion.HELPObjectDetail
        ( [ObjectID] ,
          [DetailName] ,
          [Position] ,
          [DetailType] ,
          [DetailHeader] ,
          [DetailText] ,
          [DataType] 
        )
        SELECT  [ObjectID] ,
                [DetailName] ,
                [Position] ,
                [DetailType] ,
                [DetailHeader] ,
                [DetailText] ,
                [Datatype] 
        FROM    #HelpObjectDetail
        ORDER BY [ObjectID] ,
                [Position];


--&--------------------------------------------
-- 7. Cleanup

DROP TABLE #HelpObjectDetail;
DROP TABLE #HelpObjects;


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-----------------------------------END Help Data Insert-----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

