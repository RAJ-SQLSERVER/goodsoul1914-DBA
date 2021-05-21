/*
	On Windows
*/

# Install
Install-Module -Name PendingReboot

# Run
Test-PendingReboot -Detailed -ComputerName localhost

/*
	On SQl Server
*/

SELECT name,
       is_dynamic,
       is_advanced,
       value_in_use,
       value
FROM sys.configurations
WHERE is_dynamic = 0
      AND value <> value_in_use;
IF @@ROWCOUNT >= 1
    SELECT 'Restart is needed' AS [Restart Needed?];
ELSE
    SELECT 'NO restart is needed' AS [Restart Needed?];
GO

/*
	Pending Restart for Authentication Type Change

	Some server level settings, when changed require a reboot to take effect. 
	For example, if you change the Authentication type, a restart of the SQL Server 
	service is needed for the change to take effect.

	In order to determine if a restart is needed, we need to look at two places, 
	the registry and a ServerProperty. 
*/

USE master;
GO

DECLARE @authmodeServerProp TINYINT = 0;
DECLARE @Restart VARCHAR(100);

SELECT @authmodeServerProp = CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
                                 WHEN 0 THEN
                                     2 --Set to Mixed, Windows and SQL authentication
                                 WHEN 1 THEN
                                     1 --Set to Windows Only
                             END;

DECLARE @AuthMode INT = NULL;

EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
                         N'Software\Microsoft\MSSQLServer\MSSQLServer',
                         N'LoginMode',
                         @AuthMode OUTPUT,
                         N'no_output';

IF @authmodeServerProp = @AuthMode
    SELECT @Restart = 'No pending restart of the service due to a change in the Authenication Mode.';
ELSE
    SELECT @Restart = 'The Authentication Mode has changed, look into restarting the service!';

SELECT CASE @authmodeServerProp
           WHEN 1 THEN
               'Windows Only'
           WHEN 2 THEN
               'Windows and SQL Authentication'
           ELSE
               'Something when wrong'
       END AS [ServerProperty],
       CASE @AuthMode
           WHEN 1 THEN
               'Windows Only Authentication'
           WHEN 2 THEN
               'Mixed Authentication'
           ELSE
               'There was a problem'
       END AS [Registry value],
       @Restart AS [RestartNeeded?];
GO

