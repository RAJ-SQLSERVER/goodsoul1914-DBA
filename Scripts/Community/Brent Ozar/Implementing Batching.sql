USE StackOverflow2013;
GO

-- Backup
BACKUP DATABASE StackOverflow2013
TO  DISK = N'D:\SQLBackup\20201229_StackOverflow2013.bak'
WITH DIFFERENTIAL,
     NOFORMAT,
     INIT,
     NAME = N'StackOverflow2013-Full Database Backup',
     SKIP,
     NOREWIND,
     NOUNLOAD,
     COMPRESSION,
     STATS = 10,
     CHECKSUM;
GO
DECLARE @backupSetId AS INT;
SELECT @backupSetId = position
FROM msdb..backupset
WHERE database_name = N'StackOverflow2013'
      AND backup_set_id = (
          SELECT MAX (backup_set_id)
          FROM msdb..backupset
          WHERE database_name = N'StackOverflow2013'
      );

IF @backupSetId IS NULL
    BEGIN
        RAISERROR (N'Verify failed. Backup information for database ''StackOverflow2013'' not found.', 16, 1);
    END;

RESTORE VERIFYONLY
FROM DISK = N'D:\SQLBackup\20201229_StackOverflow2013.bak'
WITH FILE = @backupSetId,
     NOUNLOAD,
     NOREWIND;
GO


-- Restore
USE master;
ALTER DATABASE StackOverflow2013 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE StackOverflow2013
FROM DISK = N'D:\SQLBackup\WINSRV1\StackOverflow2013\FULL\WINSRV1_StackOverflow2013_FULL_20201228_181815.bak'
WITH FILE = 1,
     NORECOVERY,
     NOUNLOAD,
     REPLACE,
     STATS = 5;
RESTORE DATABASE StackOverflow2013
FROM DISK = N'D:\SQLBackup\20201229_StackOverflow2013.bak'
WITH FILE = 1,
     NOUNLOAD,
     STATS = 5;
ALTER DATABASE StackOverflow2013 SET MULTI_USER;
GO

/*

We have two tables:
    * A staging table with updates
    * A target table

We want to work through the rows gradually,
updating them in small batches to avoid
lock escalation and keep disk churn down.

Use two techniques combined:

    * The Fast Ordered Delete technique with a CTE
    * The OUTPUT clause to get updated IDs, dump
      that into a temp table and delete/mark rows

*/

/* Build a fake staging table */
SELECT *
INTO dbo.Users_Staging
FROM dbo.Users;
GO

/* Change some of their data randomly: */
UPDATE dbo.Users_Staging
SET Reputation = CASE
                     WHEN Id % 2 = 0 THEN Reputation + 100
                     ELSE Reputation
                 END,
    LastAccessDate = CASE
                         WHEN Id % 3 = 0 THEN GETDATE ()
                         ELSE LastAccessDate
                     END,
    DownVotes = CASE
                    WHEN Id % 10 = 0 THEN 0
                    ELSE DownVotes
                END,
    UpVotes = CASE
                  WHEN Id % 11 = 0 THEN 0
                  ELSE UpVotes
              END,
    Views = CASE
                WHEN Id % 7 = 0 THEN Views + 1
                ELSE Views
            END;
GO

/*  */
CREATE UNIQUE CLUSTERED INDEX Id ON dbo.Users_Staging (id);

/* The normal problem with updates is that they hit lock escalation */
UPDATE u
SET Age = us.Age,
    CreationDate = us.CreationDate,
    DisplayName = us.DisplayName,
    DownVotes = us.DownVotes,
    EmailHash = us.EmailHash,
    LastAccessDate = us.LastAccessDate,
    Location = us.Location,
    Reputation = us.Reputation,
    UpVotes = us.UpVotes,
    Views = us.Views,
    WebsiteUrl = us.WebsiteUrl,
    AccountId = us.AccountId
FROM dbo.Users AS u
INNER JOIN dbo.Users_Staging AS us
    ON u.Id = us.Id;
GO

/*
Then while it�s running, check the locks it�s holding in another window 
with sp_WhoIsActive @get_locks = 1:

<Database name="StackOverflow2013">
  <Locks>
    <Lock request_mode="S" request_status="GRANT" request_count="1" />
  </Locks>
  <Objects>
    <Object name="Users" schema_name="dbo">
      <Locks>
        <Lock resource_type="OBJECT" request_mode="X" request_status="GRANT" request_count="1" />
      </Locks>
    </Object>
    <Object name="Users_Staging" schema_name="dbo">
      <Locks>
        <Lock resource_type="OBJECT" request_mode="IS" request_status="GRANT" request_count="1" />
        <Lock resource_type="PAGE" page_type="*" index_name="Id" request_mode="S" request_status="GRANT" request_count="1" />
      </Locks>
    </Object>
  </Objects>
</Database>
*/


/* ETL proc to nibble off changed rows */
CREATE OR ALTER PROC dbo.usp_UsersETL @RowsAffected INT = NULL OUTPUT
AS
    BEGIN
        CREATE TABLE #RowsAffected (Id INT);

        BEGIN TRAN;

        WITH RowsToUpdate AS (SELECT TOP (1000) * FROM dbo.Users_Staging ORDER BY Id)
        UPDATE u
        SET Age = us.Age,
            CreationDate = us.CreationDate,
            DisplayName = us.DisplayName,
            DownVotes = us.DownVotes,
            EmailHash = us.EmailHash,
            LastAccessDate = us.LastAccessDate,
            Location = us.Location,
            Reputation = us.Reputation,
            UpVotes = us.UpVotes,
            Views = us.Views,
            WebsiteUrl = us.WebsiteUrl,
            AccountId = us.AccountId
        OUTPUT INSERTED.Id
        INTO #RowsAffected
        FROM RowsToUpdate AS us
        INNER JOIN dbo.Users AS u
            ON u.Id = us.Id;

        DELETE dbo.Users_Staging
        WHERE Id IN ( SELECT Id FROM #RowsAffected );

        COMMIT;

        SELECT @RowsAffected = COUNT (*)
        FROM #RowsAffected;
    END;
GO

EXEC dbo.usp_UsersETL;