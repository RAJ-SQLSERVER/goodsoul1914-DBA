-------------------------------------------------------------------------------
-- How to Manually Take Tail Log Transaction Log Backup
-------------------------------------------------------------------------------

BACKUP LOG Playground
TO  DISK = N'D:\SQLBackup\Playground_Tlog.bak'
WITH NO_TRUNCATE,
     COPY_ONLY,
     NOFORMAT,
     NOINIT,
     NAME = N'Playground_Tail_LogTbackup',
     SKIP,
     NORECOVERY,
     STATS = 10;
GO
