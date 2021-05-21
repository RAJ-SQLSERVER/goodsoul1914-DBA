USE master;

/**********************
Create a dummy database
**********************/
CREATE DATABASE LogRestoreTest;

/**********
We full now
**********/
ALTER DATABASE LogRestoreTest

SET recovery FULL;

/*******************
Context is everthing
*******************/
USE LogRestoreTest;

/*******************************************
IF nothing changes, do we need a log backup?
*******************************************/
CREATE TABLE dbo.t1 (Id INT);

/**************************
Create a full backup, dummy
**************************/
BACKUP DATABASE LogRestoreTest TO DISK = 'D:\SQLBackup\LRT_FULL.bak'
WITH init,
	format,
	compression;

/************
Make a change
************/
INSERT INTO dbo.t1 (Id)
VALUES (1);

/****************
Take a log backup
****************/
BACKUP log LogRestoreTest TO DISK = 'D:\SQLBackup\LRT_LOG_1.trn'
WITH init,
	format,
	compression;

/******************
Make another change
******************/
INSERT INTO dbo.t1 (Id)
VALUES (2);

/**********************
Take another log backup
**********************/
BACKUP log LogRestoreTest TO DISK = 'D:\SQLBackup\LRT_LOG_2.trn'
WITH init,
	format,
	compression;

/******************
Make another change
******************/
INSERT INTO dbo.t1 (Id)
VALUES (3);

/**********************
Take another log backup
**********************/
BACKUP log LogRestoreTest TO DISK = 'D:\SQLBackup\LRT_LOG_3.trn'
WITH init,
	format,
	compression;

/**************
Exit stage left
**************/
USE master;

/**********************
Restore the full backup
**********************/
RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_FULL.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_STANDBY.tuf';

/**************************************
What happend if I try to jump restores?
**************************************/
RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_LOG_3.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_STANDBY.tuf';

/******************
What about to here?
******************/
RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_LOG_2.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_STANDBY.tuf';

/*********
Square one
*********/
RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_FULL.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_LOG_1.tuf';

RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_LOG_2.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_STANDBY.tuf';

RESTORE DATABASE LogRestoreTest
FROM DISK = 'D:\SQLBackup\LRT_LOG_3.bak'
WITH replace,
	standby = 'D:\SQLBackup\LRT_STANDBY.tuf';

/**************
Test table data
**************/
SELECT *
FROM LogRestoreTest.dbo.t1 AS t;

/*******************
Bring'er online, lad
*******************/
RESTORE DATABASE LogRestoreTest
WITH recovery;
