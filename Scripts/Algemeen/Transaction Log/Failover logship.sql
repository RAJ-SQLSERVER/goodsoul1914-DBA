/*
Failover Log Shipping

To failover log shipping follow steps below:
- In primary server, disable LSBackup job related to desired primary database.
- In secondary server, right click on LSCopy and LSRestore jobs related to desired secondary database and start job at step in order.
- In secondary server, disable all jobs in step2.
- In primary server, take tail log backup with NORECOVERY option.
- In secondary server, restore tail log backup with RECOVERY option.
- In secondary server, configure log shipping.
- In both servers delete all those disabled jobs.
*/


-- Script to backup Log:----------
DECLARE @filepath VARCHAR(200);
SET @filepath = N'\\GPHIXSQL02\SQL_Tail_Backup\HIX_PRODUCTIE_Tail_Log.trn';
BACKUP LOG DBNAME
TO  DISK = @filepath
WITH NO_TRUNCATE,
     NOFORMAT,
     INIT,
     NAME = N'DBNAME-Tail Log Backup',
     SKIP,
     NOUNLOAD,
     NORECOVERY,
     STATS = 10;
GO

-- Script to restore Log:--------
DECLARE @filepath VARCHAR(200);
SET @filepath = N'\\GPHIXSQL02\SQL_Tail_Backup\HIX_PRODUCTIE_Tail_Log.trn';
RESTORE LOG DBNAME FROM DISK = @filepath WITH RECOVERY;
GO