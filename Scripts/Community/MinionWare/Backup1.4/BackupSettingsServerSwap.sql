IF EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupSettingsServerSwap' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
DROP PROCEDURE Minion.BackupSettingsServerSwap
END
GO

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Minion.BackupSettingsServerSwap @Show BIT = 0
AS /*
	PURPOSE: 
		For failover scenarios, we can automatically detect whether the instance is running on the 
		primary or a secondary node, and make settings changes dynamically based on the server name. 
		THIS procedure does that: checks the current server name, and flips IsActive bits as appropriate,
		in settings tables.

	REQUIREMENTS:
		You must have a set of settings for each server (e.g., Server1 and Server2) in the following tables: 
			Minion.BackupSettings
			Minion.BackupSettingsPath
			Minion.BackupSettingsServer
			Minion.BackupTuningThresholds
		
		These rows should be identified with Comment LIKE '(Server1) description'. For example
			(Server1) Minion, All backups
			(Server1) testing, All backups
			(Server1) testing, Log backups

		WARNING: 
		This procedure will set IsActive=1 for ALL rows in the above tables, where Comment LIKE '(Servername)%'.
		So if you have rows that should remain inactive, make sure that the comment field doesn't contain a server name.

	USE: 
	This can be used as precode for index maintenance. It can also be used manually, if you like; but the point of this
	is to be automated.


	WARNING: If this SP finds the current server name in any of these four tables:
			Minion.BackupSettings
			Minion.BackupSettingsPath
			Minion.BackupSettingsServer
			Minion.BackupTuningThresholds
			...it will alter the settings by turning off IsActive for some, and on for others.
			
	PARAMETERS:
		@Show	Show the active rows for the settings tables.

WALKTHROUGH:
	0. Get the current server name.
	1. Set IsActive for the four settings tables.
	 
EXAMPLE EXECUTION: 
	EXEC Minion.BackupSettingsServerSwap;
	EXEC Minion.BackupSettingsServerSwap @Show=1;

*/

      BEGIN 

----------------------------------------------------
-- 0. Get the current server name.

            DECLARE @ServerName VARCHAR(100);
            SELECT  @ServerName = @@SERVERNAME;
            SET @ServerName = '(' + @ServerName + ')%';
			
----------------------------------
-- 1. Set IsActive for the four settings tables.

            DECLARE @SettingsMsg VARCHAR(100) = 'No changes: BackupSettings.'
                  , @SettingsPathMsg VARCHAR(100) = 'No changes: BackupSettingsPath.'
                  , @SettingsServerMsg VARCHAR(100) = 'No changes: BackupSettingsServer.'
                  , @TuningThresholdsMsg VARCHAR(100) = 'No changes: BackupTuningThresholds.';

            IF EXISTS ( SELECT  *
                        FROM    Minion.BackupSettings
                        WHERE   Comment LIKE @ServerName )
               BEGIN
                     UPDATE Minion.BackupSettings
                     SET    IsActive = 0;

                     UPDATE Minion.BackupSettings
                     SET    IsActive = 1
                     WHERE  Comment LIKE @ServerName;

                     SET @SettingsMsg = 'Updated: BackupSettings.';

               END;


            IF EXISTS ( SELECT  *
                        FROM    Minion.BackupSettingsPath
                        WHERE   Comment LIKE @ServerName )
               BEGIN
                     UPDATE Minion.BackupSettingsPath
                     SET    IsActive = 0;

                     UPDATE Minion.BackupSettingsPath
                     SET    IsActive = 1
                     WHERE  Comment LIKE @ServerName;

                     SET @SettingsPathMsg = 'Updated: BackupSettingsPath.';

               END;

            IF EXISTS ( SELECT  *
                        FROM    Minion.BackupSettingsServer
                        WHERE   Comment LIKE @ServerName )
               BEGIN
                     UPDATE Minion.BackupSettingsServer
                     SET    IsActive = 0;

                     UPDATE Minion.BackupSettingsServer
                     SET    IsActive = 1
                     WHERE  Comment LIKE @ServerName;

                     SET @SettingsServerMsg = 'Updated: BackupSettingsServer.';

               END;

            IF EXISTS ( SELECT  *
                        FROM    Minion.BackupTuningThresholds
                        WHERE   Comment LIKE @ServerName )
               BEGIN
                     UPDATE Minion.BackupTuningThresholds
                     SET    IsActive = 0;

                     UPDATE Minion.BackupTuningThresholds
                     SET    IsActive = 1
                     WHERE  Comment LIKE @ServerName;

                     SET @TuningThresholdsMsg = 'Updated: BackupTuningThresholds.';

               END;
----
            IF @Show = 1
               BEGIN
                     SELECT @SettingsMsg AS Msg
                          , *
                     FROM   Minion.BackupSettings
                     WHERE  IsActive = 1;

                     SELECT @SettingsPathMsg AS Msg
                          , *
                     FROM   Minion.BackupSettingsPath
                     WHERE  IsActive = 1;

                     SELECT @SettingsServerMsg AS Msg
                          , *
                     FROM   Minion.BackupSettingsServer
                     WHERE  IsActive = 1;

                     SELECT @TuningThresholdsMsg AS Msg
                          , *
                     FROM   Minion.BackupTuningThresholds
                     WHERE  IsActive = 1;


               END;
            RETURN 0;
      END;

