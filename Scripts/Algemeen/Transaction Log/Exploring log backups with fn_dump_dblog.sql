/****************************************************************************************
Listing 6.1: A template for temporarily switch a database to BULK_LOGGED recovery model
****************************************************************************************/

use [master];
go

backup LOG SampleDB to disk = '\\path\example\filename.trn';
go

alter database SampleDB set recovery bulk_logged with no_wait;
go

-- Perform minimally logged transactions here
-- Stop minimally logged transactions here
alter database SampleDB set recovery full with no_wait;
go

backup LOG SampleDB to disk = '\\path\example\filename.trn';
go

/***********************************
Listing 6.2: Checking our row counts
***********************************/

use DatabaseForLogBackups_RestoreCopy;

select COUNT(*)
from dbo.MessageTable1;

select COUNT(*)
from dbo.MessageTable2;

select COUNT(*)
from dbo.MessageTable3;

/*****************************************************************************
Listing 6.3: T-SQL script for a point in time restore of DatabaseForLogbackups
*****************************************************************************/

use [master];
go

--STEP 1: Restore the full backup. Leave database in restoring state

restore database DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Full.bak' with file = 1, move N'DatabaseForLogBackups' to N'D:\SQLData\DatabaseForLogBackups_RestoreCopy.mdf', move N'DatabaseForLogBackups_log' to N'D:\SQLData\DatabaseForLogBackups_RestoreCopy_1.ldf', norecovery, stats = 10;
go

--STEP 2: Completely restore 1st log backup. Leave database in restoring --        state

restore LOG DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log.trn' with file = 1, norecovery, stats = 10;
go

--STEP 3: P-I-T restore of 2nd log backup. Recover the database

restore LOG DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log_2.trn' with file = 1, nounload, stats = 10, stopat = N'January 30, 2012 3:34 PM', -- configure  your time here
recovery;
go

/****************************************************
Listing 6.4: Exploring log backups with fn_dump_dblog
****************************************************/

select *
from fn_dump_dblog (default, default, default, default, 'C:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log_2.trn', default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default);

/***********************************************
Listing 6.5: Spot the deliberate mistake, part 1
***********************************************/

use [master];
go

restore database DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Full.bak' with file = 1, move N'DatabaseForLogBackups' to N'D:\SQLData\DatabaseForLogBackups_RestoreCopy.mdf', move N'DatabaseForLogBackups_log' to N'D:\SQLData\DatabaseForLogBackups__RestoreCopy_1.ldf', stats = 10, recovery;
go

/*************************************
Listing 6.6: Perform a tail log backup
*************************************/

use master;
go

backup LOG DatabaseForLogBackups_RestoreCopy to disk = 'D:\SQLBackups\Chapter5\DatabaseForLogBackups_RestoreCopy_log_tail.trn' with norecovery;

/***********************************************
Listing 6.7: Spot the deliberate mistake, part 2
***********************************************/

--STEP 1: Restore the log backup

use [master];
go

restore database DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Full.bak' with file = 1, move N'DatabaseForLogBackups' to N'D:\SQLData\DatabaseForLogBackups_RestoreCopy.mdf', move N'DatabaseForLogBackups_log' to N'D:\SQLData\DatabaseForLogBackups__RestoreCopy_1.ldf', stats = 10, recovery;
go

--Step 2: Restore to the end of the first log backup

restore LOG DatabaseForLogBackups_RestoreCopy from disk = N'C:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log_1.trn' with file = 1, recovery, stats = 10;
go

/****************************************
Listing 6.8: Forcing one more fun failure
****************************************/

use [master];
go

restore database DatabaseForLogBackups_RestoreCopy from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Full.bak' with file = 1, move N'DatabaseForLogBackups' to N'D:\SQLData\DatabaseForLogBackups_RestoreCopy.mdf', move N'DatabaseForLogBackups_log' to N'D:\SQLData\DatabaseForLogBackups__RestoreCopy_1.ldf', norecovery, stats = 10, REPLACE;
go

restore LOG DatabaseForLogBackups from disk = N'D:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log_2.trn' with file = 1, norecovery, stats = 10;
go

restore LOG DatabaseForLogBackups from disk = N'C:\SQLBackups\Chapter5\DatabaseForLogBackups_Native_Log_1.trn' with file = 1, recovery, stats = 10;
go