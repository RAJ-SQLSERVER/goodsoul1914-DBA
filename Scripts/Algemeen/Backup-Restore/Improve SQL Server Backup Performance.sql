/*

The default value of buffercount parameter can also be calculated using the following formula: 
	
	NumberofBackupDevices * 3 + NumberofBackupDevices + (2 * NumberofVolumesInvolved) 
	
In my case this meant a buffercount equal to 7, 12, 17, 22 and 27 for 1, 2, 3, 4 and 5 disk devices respectively. 
You can also check these values for any backup command you run by checking the SQL error log after enabling trace flags 3605 and 3213.

*/

-------------------------------------------------------------------------------
-- Testing backup to nul device without compression
-------------------------------------------------------------------------------

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 7;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7;
GO

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 12;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12;
GO

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 17;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17;
GO

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 27;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27;
GO

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 37;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37;
GO

BACKUP DATABASE AdventureWorks2019 TO DISK = 'nul' WITH BUFFERCOUNT = 47;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47;
GO

--------------------------------------------------------------------------------------------------------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 131072;
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 524288;
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 1048576;
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 2097152;
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH MAXTRANSFERSIZE = 4194304;
GO

-----------------------------------------------------------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO

----------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO

----------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO

----------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul',
    DISK = 'nul'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO

-------------------------------------------------------------------------------
-- Testing backup to physical file device without compression
-------------------------------------------------------------------------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

--------------------------------------------------------------------------------------------------------------


BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO


-----------------------------------------------------------------


BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

-------------------------------------------------------------------------------
-- Testing backup to physical file device with compression
-------------------------------------------------------------------------------

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

--------------------------------------------------------------------------------------------------------------


BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO

BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO


-----------------------------------------------------------------


BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 7,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 12,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 17,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 27,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 37,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 131072,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 524288,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 1048576,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 2097152,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
BACKUP DATABASE AdventureWorks2019
TO  DISK = 'D:\SQLBackups\AdventureWorks2019.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20192.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20193.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20194.bak',
    DISK = 'D:\SQLBackups\AdventureWorks20195.bak'
WITH BUFFERCOUNT = 47,
     MAXTRANSFERSIZE = 4194304,
     COMPRESSION;
GO
xp_cmdshell 'del D:\SQLBackups\AdventureWorks2019*.bak';
GO
----------------