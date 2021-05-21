-----------------------------------------------------------
-- Name: CollectIndexUsageStats.sql
--
-- Description: Collects index usage statistics over time.
--
-- Author: Bob Pusateri, http://www.bobpusateri.com
--
-- THIS SCRIPT IS PROVIDED "AS-IS" WITHOUT ANY WARRANTY.
-- DO NOT RUN THIS ON A PRODUCTION SYSTEM UNTIL YOU HAVE
--   COMPLETE UNDERSTANDING OF THE TASKS IT PERFORMS AND
--   HAVE TESTED IT ON A DEVELOPMENT SYSTEM.
-----------------------------------------------------------

-- I recommend putting these objects in a separate database 
-- (or your existing DBA database if you have one)
-- 
-- If your DBA database is not named 'DBATools', you'll want to replace it with your DB name
--     It is referenced several times in the script below
USE [DBATools];
GO

-- stores cumulative data from sys.dm_db_index_usage_stats DMV
CREATE TABLE [dbo].[IndexUsageStats_LastCumulative]
(
    [ServerNameID] [INT] NOT NULL,
    [DatabaseID] [SMALLINT] NOT NULL,
    [ObjectID] [INT] NOT NULL,
    [IndexID] [INT] NOT NULL,
    [LoadTime] [DATETIME2](0) NOT NULL,
    [User_Seeks] [BIGINT] NOT NULL,
    [User_Scans] [BIGINT] NOT NULL,
    [User_Lookups] [BIGINT] NOT NULL,
    [User_Updates] [BIGINT] NOT NULL,
    [System_Seeks] [BIGINT] NOT NULL,
    [System_Scans] [BIGINT] NOT NULL,
    [System_Lookups] [BIGINT] NOT NULL,
    [System_Updates] [BIGINT] NOT NULL,
    CONSTRAINT [PK_IUS_C]
        PRIMARY KEY CLUSTERED (
                                  [ServerNameID],
                                  [DatabaseID],
                                  [ObjectID],
                                  [IndexID]
                              )
);
GO

-- used for Server/DB/Schema/Table/Index name mapping
CREATE TABLE [dbo].[Names]
(
    [ID] [INT] IDENTITY(1, 1) NOT NULL,
    [Value] [NVARCHAR](260) NOT NULL,
    CONSTRAINT [PK_Names]
        PRIMARY KEY CLUSTERED ([ID])
);
GO

-- stores historical usage statistics
CREATE TABLE [dbo].[IndexUsageStats]
(
    [StatsDate] [DATETIME2](0) NOT NULL,
    [ServerNameID] [INT] NOT NULL,
    [DatabaseID] [SMALLINT] NOT NULL,
    [ObjectID] [INT] NOT NULL,
    [IndexID] [INT] NOT NULL,
    [DatabaseNameID] [INT] NOT NULL,
    [SchemaNameID] [INT] NOT NULL,
    [TableNameID] [INT] NOT NULL,
    [IndexNameID] [INT] NULL,
    [User_Seeks] [BIGINT] NOT NULL,
    [User_Scans] [BIGINT] NOT NULL,
    [User_Lookups] [BIGINT] NOT NULL,
    [User_Updates] [BIGINT] NOT NULL,
    [System_Seeks] [BIGINT] NOT NULL,
    [System_Scans] [BIGINT] NOT NULL,
    [System_Lookups] [BIGINT] NOT NULL,
    [System_Updates] [BIGINT] NOT NULL,
    CONSTRAINT [PK_IUS]
        PRIMARY KEY CLUSTERED (
                                  [StatsDate],
                                  [ServerNameID],
                                  [DatabaseID],
                                  [ObjectID],
                                  [IndexID]
                              ),
    CONSTRAINT [FK_IUS_Names_DB]
        FOREIGN KEY ([DatabaseNameID])
        REFERENCES [dbo].[Names] ([ID]),
    CONSTRAINT [FK_IUS_Names_Index]
        FOREIGN KEY ([IndexNameID])
        REFERENCES [dbo].[Names] ([ID]),
    CONSTRAINT [FK_IUS_Names_Schema]
        FOREIGN KEY ([SchemaNameID])
        REFERENCES [dbo].[Names] ([ID]),
    CONSTRAINT [FK_IUS_Names_Table]
        FOREIGN KEY ([TableNameID])
        REFERENCES [dbo].[Names] ([ID]),
    CONSTRAINT [CK_IUS_PositiveValues] CHECK ([User_Seeks] >= (0)
                                              AND [User_Scans] >= (0)
                                              AND [User_Lookups] >= (0)
                                              AND [User_Updates] >= (0)
                                              AND [System_Seeks] >= (0)
                                              AND [System_Scans] >= (0)
                                              AND [System_Lookups] >= (0)
                                              AND [System_Updates] >= (0)
                                             )
);
GO

-- collects usage statistics
-- I run this once daily (can be run more often if you like)
CREATE PROCEDURE [dbo].[CollectIndexUsageStats]
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- get current stats for all online databases

        SELECT database_id,
               name
        INTO #dblist
        FROM sys.databases
        WHERE [state] = 0
              AND database_id != 2; -- skip TempDB

        CREATE TABLE #t
        (
            StatsDate DATETIME2(0),
            ServerName sysname,
            DatabaseID SMALLINT,
            ObjectID INT,
            IndexID INT,
            DatabaseName sysname,
            SchemaName sysname,
            TableName sysname,
            IndexName sysname NULL,
            User_Seeks BIGINT,
            User_Scans BIGINT,
            User_Lookups BIGINT,
            User_Updates BIGINT,
            System_Seeks BIGINT,
            System_Scans BIGINT,
            System_Lookups BIGINT,
            System_Updates BIGINT
        );

        DECLARE @DBID INT;
        DECLARE @DBNAME sysname;
        DECLARE @Qry NVARCHAR(2000);

        -- iterate through each DB, generate & run query
        WHILE
        (SELECT COUNT(*) FROM #dblist) > 0
        BEGIN
            SELECT TOP (1)
                   @DBID = database_id,
                   @DBNAME = [name]
            FROM #dblist
            ORDER BY database_id;

            SET @Qry
                = N'
				INSERT INTO #t
				SELECT
					SYSDATETIME() AS StatsDate,
					@@SERVERNAME AS ServerName,
					s.database_id AS DatabaseID,
					s.object_id AS ObjectID,
					s.index_id AS IndexID,
					''' + @DBNAME
                  + N''' AS DatabaseName,
					c.name AS SchemaName,
					o.name AS TableName,
					i.name AS IndexName,
					s.user_seeks,
					s.user_scans,
					s.user_lookups,
					s.user_updates,
					s.system_seeks,
					s.system_scans,
					s.system_lookups,
					s.system_updates
				FROM sys.dm_db_index_usage_stats s
				INNER JOIN ' + @DBNAME + N'.sys.objects o ON s.object_id = o.object_id
				INNER JOIN ' + @DBNAME + N'.sys.schemas c ON o.schema_id = c.schema_id
				INNER JOIN ' + @DBNAME
                  + N'.sys.indexes i ON s.object_id = i.object_id and s.index_id = i.index_id
				WHERE s.database_id = ' + CONVERT(NVARCHAR, @DBID) + N';
				';

            EXEC sp_executesql @Qry;

            DELETE FROM #dblist
            WHERE database_id = @DBID;
        END; -- db while loop

        DROP TABLE #dblist;

        BEGIN TRAN;

        -- create ids for Server Name by inserting new ones into dbo.Names
        INSERT INTO DBATools.dbo.Names
        (
            Value
        )
        SELECT DISTINCT
               RTRIM(LTRIM(t.ServerName)) AS ServerName
        FROM #t t
            LEFT JOIN DBATools.dbo.Names n
                ON t.ServerName = n.Value
        WHERE n.ID IS NULL
              AND t.ServerName IS NOT NULL
        ORDER BY RTRIM(LTRIM(t.ServerName));

        -- same as above for DatabaseName
        INSERT INTO DBATools.dbo.Names
        (
            Value
        )
        SELECT DISTINCT
               RTRIM(LTRIM(t.DatabaseName)) AS DatabaseName
        FROM #t t
            LEFT JOIN DBATools.dbo.Names n
                ON t.DatabaseName = n.Value
        WHERE n.ID IS NULL
              AND t.DatabaseName IS NOT NULL
        ORDER BY RTRIM(LTRIM(t.DatabaseName));

        -- SchemaName
        INSERT INTO DBATools.dbo.Names
        (
            Value
        )
        SELECT DISTINCT
               RTRIM(LTRIM(t.SchemaName)) AS SchemaName
        FROM #t t
            LEFT JOIN DBATools.dbo.Names n
                ON t.SchemaName = n.Value
        WHERE n.ID IS NULL
              AND t.SchemaName IS NOT NULL
        ORDER BY RTRIM(LTRIM(t.SchemaName));

        -- TableName
        INSERT INTO DBATools.dbo.Names
        (
            Value
        )
        SELECT DISTINCT
               RTRIM(LTRIM(t.TableName)) AS TableName
        FROM #t t
            LEFT JOIN DBATools.dbo.Names n
                ON t.TableName = n.Value
        WHERE n.ID IS NULL
              AND t.TableName IS NOT NULL
        ORDER BY RTRIM(LTRIM(t.TableName));

        -- IndexName
        INSERT INTO DBATools.dbo.Names
        (
            Value
        )
        SELECT DISTINCT
               RTRIM(LTRIM(t.IndexName)) AS IndexName
        FROM #t t
            LEFT JOIN DBATools.dbo.Names n
                ON t.IndexName = n.Value
        WHERE n.ID IS NULL
              AND t.IndexName IS NOT NULL
        ORDER BY RTRIM(LTRIM(t.IndexName));

        -- Calculate Deltas
        INSERT INTO DBATools.dbo.IndexUsageStats
        (
            StatsDate,
            ServerNameID,
            DatabaseID,
            ObjectID,
            IndexID,
            DatabaseNameID,
            SchemaNameID,
            TableNameID,
            IndexNameID,
            User_Seeks,
            User_Scans,
            User_Lookups,
            User_Updates,
            System_Seeks,
            System_Scans,
            System_Lookups,
            System_Updates
        )
        SELECT t.StatsDate,
               s.ID AS ServerNameID,
               t.DatabaseID,
               t.ObjectID,
               t.IndexID,
               d.ID AS DatabaseNameID,
               c.ID AS SchemaNameID,
               b.ID AS TableNameID,
               i.ID AS IndexNameID,
               CASE
                   -- if the previous cumulative value is greater than the current one, the server has been reset
                   -- just use the current value
                   WHEN t.User_Seeks - ISNULL(lc.User_Seeks, 0) < 0 THEN
                       t.User_Seeks
                   -- if the prev value is less than the current one, then subtract to get the delta
                   ELSE
                       t.User_Seeks - ISNULL(lc.User_Seeks, 0)
               END AS User_Seeks,
               CASE
                   WHEN t.User_Scans - ISNULL(lc.User_Scans, 0) < 0 THEN
                       t.User_Scans
                   ELSE
                       t.User_Scans - ISNULL(lc.User_Scans, 0)
               END AS User_Scans,
               CASE
                   WHEN t.User_Lookups - ISNULL(lc.User_Lookups, 0) < 0 THEN
                       t.User_Lookups
                   ELSE
                       t.User_Lookups - ISNULL(lc.User_Lookups, 0)
               END AS User_Lookups,
               CASE
                   WHEN t.User_Updates - ISNULL(lc.User_Updates, 0) < 0 THEN
                       t.User_Updates
                   ELSE
                       t.User_Updates - ISNULL(lc.User_Updates, 0)
               END AS User_Updates,
               CASE
                   WHEN t.System_Seeks - ISNULL(lc.System_Seeks, 0) < 0 THEN
                       t.System_Seeks
                   ELSE
                       t.System_Seeks - ISNULL(lc.System_Seeks, 0)
               END AS System_Seeks,
               CASE
                   WHEN t.System_Scans - ISNULL(lc.System_Scans, 0) < 0 THEN
                       t.System_Scans
                   ELSE
                       t.System_Scans - ISNULL(lc.System_Scans, 0)
               END AS System_Scans,
               CASE
                   WHEN t.System_Lookups - ISNULL(lc.System_Lookups, 0) < 0 THEN
                       t.System_Lookups
                   ELSE
                       t.System_Lookups - ISNULL(lc.System_Lookups, 0)
               END AS System_Lookups,
               CASE
                   WHEN t.System_Updates - ISNULL(lc.System_Updates, 0) < 0 THEN
                       t.System_Updates
                   ELSE
                       t.System_Updates - ISNULL(lc.System_Updates, 0)
               END AS System_Updates
        FROM #t t
            INNER JOIN DBATools.dbo.Names s
                ON t.ServerName = s.Value
            INNER JOIN DBATools.dbo.Names d
                ON t.DatabaseName = d.Value
            INNER JOIN DBATools.dbo.Names c
                ON t.SchemaName = c.Value
            INNER JOIN DBATools.dbo.Names b
                ON t.TableName = b.Value
            LEFT JOIN DBATools.dbo.Names i
                ON t.IndexName = i.Value
            LEFT JOIN DBATools.dbo.IndexUsageStats_LastCumulative lc
                ON s.ID = lc.ServerNameID
                   AND t.DatabaseID = lc.DatabaseID
                   AND t.ObjectID = lc.ObjectID
                   AND t.IndexID = lc.IndexID
        ORDER BY StatsDate,
                 ServerName,
                 DatabaseID,
                 ObjectID,
                 IndexID;

        -- Update last cumulative values with the current ones
        MERGE INTO DBATools.dbo.IndexUsageStats_LastCumulative lc
        USING #t t
            INNER JOIN DBATools.dbo.Names s
                ON t.ServerName = s.Value
        ON s.ID = lc.ServerNameID
           AND t.DatabaseID = lc.DatabaseID
           AND t.ObjectID = lc.ObjectID
           AND t.IndexID = lc.IndexID
        WHEN MATCHED THEN
            UPDATE SET lc.LoadTime = t.StatsDate,
                       lc.User_Seeks = t.User_Seeks,
                       lc.User_Scans = t.User_Scans,
                       lc.User_Lookups = t.User_Lookups,
                       lc.User_Updates = t.User_Updates,
                       lc.System_Seeks = t.System_Seeks,
                       lc.System_Scans = t.System_Scans,
                       lc.System_Lookups = t.System_Lookups,
                       lc.System_Updates = t.System_Updates
        WHEN NOT MATCHED BY TARGET THEN
            INSERT
            (
                ServerNameID,
                DatabaseID,
                ObjectID,
                IndexID,
                LoadTime,
                User_Seeks,
                User_Scans,
                User_Lookups,
                User_Updates,
                System_Seeks,
                System_Scans,
                System_Lookups,
                System_Updates
            )
            VALUES
            (s.ID, t.DatabaseID, t.ObjectID, t.IndexID, t.StatsDate, t.User_Seeks, t.User_Scans, t.User_Lookups,
             t.User_Updates, t.System_Seeks, t.System_Scans, t.System_Lookups, t.System_Updates)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;

        COMMIT TRAN;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        DECLARE @ErrorNumber INT;
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        DECLARE @ErrorProcedure NVARCHAR(126);
        DECLARE @ErrorLine INT;
        DECLARE @ErrorMessage NVARCHAR(2048);

        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorProcedure = ERROR_PROCEDURE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorMessage = ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH;
END;
GO

-- displays usage statistics
CREATE VIEW [dbo].[vw_IndexUsageStats]
AS
SELECT s.StatsDate,
       vn.Value AS ServerName,
       dbn.Value AS DatabaseName,
       sn.Value AS SchemaName,
       tn.Value AS TableName,
       dn.Value AS IndexName,
       s.IndexID,
       s.User_Seeks,
       s.User_Scans,
       s.User_Lookups,
       s.User_Updates,
       s.System_Seeks,
       s.System_Scans,
       s.System_Lookups,
       s.System_Updates
FROM dbo.IndexUsageStats s
    INNER JOIN dbo.Names vn
        ON s.ServerNameID = vn.ID
    INNER JOIN dbo.Names dbn
        ON s.DatabaseNameID = dbn.ID
    INNER JOIN dbo.Names sn
        ON s.SchemaNameID = sn.ID
    INNER JOIN dbo.Names tn
        ON s.TableNameID = tn.ID
    LEFT JOIN dbo.Names dn
        ON s.IndexNameID = dn.ID;
GO
