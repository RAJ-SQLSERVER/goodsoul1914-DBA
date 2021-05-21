-- DEMO: Multibase Differential Backups
-- Blog post resource: http://bit.ly/Yn90Sy
-- MSDN resource: http://bit.ly/13DhksY
USE master;
GO

-- 1) Create the database
CREATE DATABASE Test4Backup ON PRIMARY (
	name = N'Test4Backup_Primary_File1',
	filename = N'D:\Documents\MSSQL\DATA\Test4Backup_Primary_File1.mdf'
	),
	filegroup SECONDARY (
	name = N'Test4Backup_Secondary_File1',
	filename = N'D:\Documents\MSSQL\DATA\Test4Backup_Secondary_File1.ndf'
	),
	(
	name = N'Test4Backup_Secondary_File2',
	filename = N'D:\Documents\MSSQL\DATA\Test4Backup_Secondary_File2.ndf'
	) log ON (
	name = N'Test4Backup_log',
	filename = N'D:\Documents\MSSQL\LOG\Test4Backup_log.ldf'
	);
GO

-- Check database properties
sp_helpdb Test4Backup;

-- 2) Take a full database backup
BACKUP DATABASE Test4Backup TO DISK = N'D:\Documents\MSSQL\BACKUP\0_Test4Backup.bak'
WITH init,
	stats;
GO

-- 3) Take a differential backup
BACKUP DATABASE Test4Backup TO DISK = N'D:\Documents\MSSQL\BACKUP\1_Test4Backup_DIFF.bak'
WITH differential,
	init,
	stats;
GO

-- 4) Take a filegroup backup of the secondary filegroup
BACKUP DATABASE Test4Backup filegroup = 'secondary' TO DISK = N'D:\Documents\MSSQL\BACKUP\2_Test4Backup_FG2.bak'
WITH init,
	stats;
GO

-- 5) Take a file backup of the file in the primary filegroup
BACKUP DATABASE Test4Backup FILE = 'Test4Backup_Primary_File1' TO DISK = N'D:\Documents\MSSQL\BACKUP\3_Test4Backup_FGPRI.bak'
WITH init,
	stats;
GO

-- 6) Take a file backup of the second file in the secondary filegroup
BACKUP DATABASE Test4Backup FILE = 'Test4Backup_Secondary_File2' TO DISK = N'D:\Documents\MSSQL\BACKUP\4_Test4Backup_FG2_F2.bak'
WITH init,
	stats;
GO

-- 7) Take a differential backup 
BACKUP DATABASE Test4Backup TO DISK = N'D:\Documents\MSSQL\BACKUP\5_Test4Backup_DIFF_2.bak'
WITH differential,
	init,
	stats;
GO

-- 8) To check the sequence of the restore operations, read the LSNs: 
-- for the full database backup in step #2
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\0_Test4Backup.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\0_Test4Backup.bak';

-- for the differential backup in step #3
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\1_Test4Backup_DIFF.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\1_Test4Backup_DIFF.bak';

-- for the filegroup backup in step #4
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\2_Test4Backup_FG2.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\2_Test4Backup_FG2.bak';

-- for the filegroup backup in step #5
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\3_Test4Backup_FGPRI.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\3_Test4Backup_FGPRI.bak';

-- for the file backup in step #6
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\4_Test4Backup_FG2_F2.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\4_Test4Backup_FG2_F2.bak';

-- for the differential backup in step #7
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\5_Test4Backup_DIFF_2.bak';

RESTORE filelistonly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\5_Test4Backup_DIFF_2.bak';

/*****************************************************************
	BACKUP			FirstLSN				DifferentialBaseLSN
	---------------|-----------------------|-------------------------
	FULL			45000000020200084		0
	DIFF_1			45000000026000034		45000000020200084 (1)
											45000000020200084 (2_1)
											45000000020200084 (2_2)
	FG2				45000000027900034		45000000020200084 (1)
											45000000020200084 (2_1)
											45000000020200084 (2_2)
	FGPRI			45000000031000037		45000000020200084 (1)
											45000000027900034 (2_1)
											45000000027900034 (2_2)
	FG2_F2			45000000033700034		45000000031000037 (1)
											45000000027900034 (2_1)
											45000000027900034 (2_2)
	DIFF_2			45000000035600035		45000000031000037 (1)
											45000000027900034 (2_1)
											45000000033700034 (2_2)
*****************************************************************/
-- Let's try restoring the database from the FULL and LATEST DIFFERENTIAL
DROP DATABASE Test4Backup;
GO

-- Restore FULL backup
RESTORE DATABASE Test4Backup
FROM DISK = N'D:\Documents\MSSQL\BACKUP\0_Test4Backup.bak'
WITH norecovery,
	stats;
GO

RESTORE DATABASE Test4Backup
FROM DISK = N'D:\Documents\MSSQL\BACKUP\5_Test4Backup_DIFF_2.bak'
WITH stats;
GO

--Msg 3136, Level 16, State 1, Line 117
--This differential backup cannot be restored because the database has not been restored to the correct earlier state.
--Msg 3013, Level 16, State 1, Line 117
--RESTORE DATABASE is terminating abnormally.
--------------------------------------------------------------------------------
-- To find out the efficient restore sequence
-- start with the FULL backup and check the FirstLSN of the restored backup
-- and the DifferentialBaseLSN of the backups yet to be restored
--------------------------------------------------------------------------------
-- Drop database prior to restoring
DROP DATABASE Test4Backup;
GO

-- Restore FULL backup
RESTORE DATABASE Test4Backup
FROM DISK = N'D:\Documents\MSSQL\BACKUP\0_Test4Backup.bak'
WITH norecovery,
	stats;
GO

RESTORE DATABASE Test4Backup filegroup = 'secondary'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\2_Test4Backup_FG2.bak'
WITH norecovery,
	stats;
GO

RESTORE DATABASE Test4Backup FILE = 'Test4Backup_Primary_File1'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\3_Test4Backup_FGPRI.bak'
WITH norecovery,
	stats;
GO

RESTORE DATABASE Test4Backup FILE = 'Test4Backup_Secondary_File2'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\4_Test4Backup_FG2_F2.bak'
WITH norecovery,
	stats;
GO

RESTORE DATABASE Test4Backup
FROM DISK = N'D:\Documents\MSSQL\BACKUP\5_Test4Backup_DIFF_2.bak'
WITH stats;
GO


