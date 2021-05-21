/******************************************************************************
	Backing up to multiple files on one volume
******************************************************************************/

-------------------------------------------------------------------------------
--	Backup to 1 file
-------------------------------------------------------------------------------
BACKUP DATABASE StackOverflow2010
TO  DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010.bak'
WITH NOFORMAT,
     NOINIT,
     NAME = N'StackOverflow2010-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10;
GO
-- BACKUP DATABASE processed 1141034 pages in 40.208 seconds (221.705 MB/sec)

-------------------------------------------------------------------------------
--	Backup to 2 files
-------------------------------------------------------------------------------
BACKUP DATABASE StackOverflow2010
TO  DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak'
WITH NOFORMAT,
     NOINIT,
     NAME = N'StackOverflow2010-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10;
GO
-- BACKUP DATABASE processed 1141037 pages in 63.406 seconds (140.591 MB/sec)

-------------------------------------------------------------------------------
--	Backup to 4 files
-------------------------------------------------------------------------------
BACKUP DATABASE StackOverflow2010
TO  DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-3.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-4.bak'
WITH NOFORMAT,
     NOINIT,
     NAME = N'StackOverflow2010-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10;
GO
-- BACKUP DATABASE processed 1141037 pages in 59.961 seconds (148.669 MB/sec)

-------------------------------------------------------------------------------
--	Backup to 8 files
-------------------------------------------------------------------------------
BACKUP DATABASE StackOverflow2010
TO  DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-3.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-4.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-5.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-6.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-7.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-8.bak'
WITH NOFORMAT,
     NOINIT,
     NAME = N'StackOverflow2010-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10;
GO
-- BACKUP DATABASE processed 1141034 pages in 58.825 seconds (151.539 MB/sec)


/******************************************************************************
	Backing up to multiple files on multiple volumes
******************************************************************************/

BACKUP DATABASE StackOverflow2010
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backups\StackOverflow2010.bak',
    DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak'
WITH NOFORMAT,
     NOINIT,
     NAME = N'StackOverflow2010-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10;
GO
-- 1141034 pages in 36.602 seconds (243.547 MB/sec)


/******************************************************************************
	Restoring from multiple files on one volume
******************************************************************************/

RESTORE DATABASE StackOverflow2010
FROM DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010.bak', DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak'
WITH FILE = 1,
     NOUNLOAD,
     STATS = 5;
GO


/******************************************************************************
	Restoring from multiple files on multiple volumes
******************************************************************************/

RESTORE DATABASE StackOverflow2010
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backups\StackOverflow2010.bak', DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2010-2.bak'
WITH FILE = 1,
     NOUNLOAD,
     STATS = 5;
GO