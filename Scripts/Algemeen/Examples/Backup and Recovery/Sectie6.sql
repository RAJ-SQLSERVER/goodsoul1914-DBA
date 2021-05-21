-- Drive with system databases has become corrupted 
----------------------------------------------------------------------
-- 1) Use the master database from a mirrored copy
-- Copy master and msdb files to an available drive on the troubled server
-- 2) Change startup parameters to point to the files on the new drive
-- 3) Start SQL Server instance in single user mode to modify other things
-- C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Binn\sqlservr -f -m
-- Check the list of logins
SELECT name
FROM master.sys.server_principals;

-- 4) Restore the master database from backup
RESTORE DATABASE master
FROM DISK = 'C:\Demos\master.bak'
WITH MOVE 'master' TO 'C:\Demos\master.mdf',
	MOVE 'mastlog' TO 'C:\Demos\mastlog.ldf',
	stats;
GO

-- Restore the msdb database
RESTORE DATABASE msdb
FROM DISK = 'C:\Demos\msdb.bak'
WITH MOVE 'msdb' TO 'C:\Demos\msdbdata.mdf',
	MOVE 'msdblog' TO 'C:\Demos\msdblog.ldf',
	stats;
GO

-- 5) Add your login to the sysadmin role
USE master;
GO

CREATE LOGIN [WS-SERVER1\Administrator]
FROM windows WITH default_database = master;
GO

ALTER SERVER ROLE [sysadmin] ADD member [WS-SERVER1\Administrator];
GO

-- 6) Modify other system database properties
ALTER DATABASE model modify FILE (
	name = modeldev,
	filename = 'C:\Demos\model.mdf'
	);
GO

ALTER DATABASE model modify FILE (
	name = modellog,
	filename = 'C:\Demos\modellog.ldf'
	);
GO

ALTER DATABASE msdb modify FILE (
	name = msdbdata,
	filename = 'C:\Demos\msdbdata.mdf'
	);
GO

ALTER DATABASE msdb modify FILE (
	name = msdblog,
	filename = 'C:\Demos\msdblog.ldf'
	);
GO

ALTER DATABASE tempdb modify FILE (
	name = tempdev,
	filename = 'C:\Demos\tempdev.mdf'
	);
GO

ALTER DATABASE msdb modify FILE (
	name = templog,
	filename = 'C:\Demos\templog.ldf'
	);
GO

-- 7) Restart SQL Server normally
-- 8) Custom logshipping scenario
-- Use existing log backups for log shipping (maintenance plan)
-- Configure ROBOCOPY job on standby
-- Configure PowerShell script on standby for restoring log backups
