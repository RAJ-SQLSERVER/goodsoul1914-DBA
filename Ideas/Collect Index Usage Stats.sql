﻿-
-- collects usage statistics
-- I run this once daily (can be run more often if you like)
CREATE PROCEDURE dbo.usp_CollectIndexUsageStats
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        -- get current stats for all online databases

        SELECT database_id,
               name
        INTO #dblist
        FROM sys.databases
        WHERE state = 0
              AND database_id != 2; -- skip TempDB

        CREATE TABLE #t (
            StatsDate      DATETIME2(0),
            ServerName     sysname,
            DatabaseID     SMALLINT,
            ObjectID       INT,
            IndexID        INT,
            DatabaseName   sysname,
            SchemaName     sysname,
            TableName      sysname,
            IndexName      sysname     NULL,
            User_Seeks     BIGINT,
            User_Scans     BIGINT,
            User_Lookups   BIGINT,
            User_Updates   BIGINT,
            System_Seeks   BIGINT,
            System_Scans   BIGINT,
            System_Lookups BIGINT,
            System_Updates BIGINT
        );

        DECLARE @DBID INT;
        DECLARE @DBNAME sysname;
        DECLARE @Qry NVARCHAR(2000);

        -- iterate through each DB, generate & run query
        WHILE (SELECT COUNT (*) FROM #dblist) > 0
        BEGIN
            SELECT TOP (1) @DBID = database_id,
                           @DBNAME = name
            FROM #dblist
            ORDER BY database_id;

            SET @Qry = N'
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
				WHERE s.database_id = ' + CONVERT (NVARCHAR, @DBID) + N';
				';

            EXEC sp_executesql @Qry;

            DELETE FROM #dblist
            WHERE database_id = @DBID;
        END; -- db while loop

        DROP TABLE #dblist;

        BEGIN TRAN;

        -- create ids for Server Name by inserting new ones into dbo.Names
        INSERT INTO DBA.dbo.Names (Value)
        SELECT DISTINCT RTRIM (LTRIM (t.ServerName)) AS "ServerName"
        FROM #t AS t
        LEFT JOIN DBA.dbo.Names AS n
            ON t.ServerName = n.Value
        WHERE n.ID IS NULL
              AND t.ServerName IS NOT NULL
        ORDER BY RTRIM (LTRIM (t.ServerName));

        -- same as above for DatabaseName
        INSERT INTO DBA.dbo.Names (Value)
        SELECT DISTINCT RTRIM (LTRIM (t.DatabaseName)) AS "DatabaseName"
        FROM #t AS t
        LEFT JOIN DBA.dbo.Names AS n
            ON t.DatabaseName = n.Value
        WHERE n.ID IS NULL
              AND t.DatabaseName IS NOT NULL
        ORDER BY RTRIM (LTRIM (t.DatabaseName));

        -- SchemaName
        INSERT INTO DBA.dbo.Names (Value)
        SELECT DISTINCT RTRIM (LTRIM (t.SchemaName)) AS "SchemaName"
        FROM #t AS t
        LEFT JOIN DBA.dbo.Names AS n
            ON t.SchemaName = n.Value
        WHERE n.ID IS NULL
              AND t.SchemaName IS NOT NULL
        ORDER BY RTRIM (LTRIM (t.SchemaName));

        -- TableName
        INSERT INTO DBA.dbo.Names (Value)
        SELECT DISTINCT RTRIM (LTRIM (t.TableName)) AS "TableName"
        FROM #t AS t
        LEFT JOIN DBA.dbo.Names AS n
            ON t.TableName = n.Value
        WHERE n.ID IS NULL
              AND t.TableName IS NOT NULL
        ORDER BY RTRIM (LTRIM (t.TableName));

        -- IndexName
        INSERT INTO DBA.dbo.Names (Value)
        SELECT DISTINCT RTRIM (LTRIM (t.IndexName)) AS "IndexName"
        FROM #t AS t
        LEFT JOIN DBA.dbo.Names AS n
            ON t.IndexName = n.Value
        WHERE n.ID IS NULL
              AND t.IndexName IS NOT NULL
        ORDER BY RTRIM (LTRIM (t.IndexName));

        -- Calculate Deltas
        INSERT INTO DBA.dbo.IndexUsageStats (StatsDate,
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
                                             System_Updates)
        SELECT t.StatsDate,
               s.ID AS "ServerNameID",
               t.DatabaseID,
               t.ObjectID,
               t.IndexID,
               d.ID AS "DatabaseNameID",
               c.ID AS "SchemaNameID",
               b.ID AS "TableNameID",
               i.ID AS "IndexNameID",
               CASE
                   -- if the previous cumulative value is greater than the current one, the server has been reset
                   -- just use the current value
                   WHEN t.User_Seeks - ISNULL (lc.User_Seeks, 0) < 0 THEN t.User_Seeks
                   -- if the prev value is less than the current one, then subtract to get the delta
                   ELSE t.User_Seeks - ISNULL (lc.User_Seeks, 0)
               END AS "User_Seeks",
               CASE
                   WHEN t.User_Scans - ISNULL (lc.User_Scans, 0) < 0 THEN t.User_Scans
                   ELSE t.User_Scans - ISNULL (lc.User_Scans, 0)
               END AS "User_Scans",
               CASE
                   WHEN t.User_Lookups - ISNULL (lc.User_Lookups, 0) < 0 THEN t.User_Lookups
                   ELSE t.User_Lookups - ISNULL (lc.User_Lookups, 0)
               END AS "User_Lookups",
               CASE
                   WHEN t.User_Updates - ISNULL (lc.User_Updates, 0) < 0 THEN t.User_Updates
                   ELSE t.User_Updates - ISNULL (lc.User_Updates, 0)
               END AS "User_Updates",
               CASE
                   WHEN t.System_Seeks - ISNULL (lc.System_Seeks, 0) < 0 THEN t.System_Seeks
                   ELSE t.System_Seeks - ISNULL (lc.System_Seeks, 0)
               END AS "System_Seeks",
               CASE
                   WHEN t.System_Scans - ISNULL (lc.System_Scans, 0) < 0 THEN t.System_Scans
                   ELSE t.System_Scans - ISNULL (lc.System_Scans, 0)
               END AS "System_Scans",
               CASE
                   WHEN t.System_Lookups - ISNULL (lc.System_Lookups, 0) < 0 THEN t.System_Lookups
                   ELSE t.System_Lookups - ISNULL (lc.System_Lookups, 0)
               END AS "System_Lookups",
               CASE
                   WHEN t.System_Updates - ISNULL (lc.System_Updates, 0) < 0 THEN t.System_Updates
                   ELSE t.System_Updates - ISNULL (lc.System_Updates, 0)
               END AS "System_Updates"
        FROM #t AS t
        INNER JOIN DBA.dbo.Names AS s
            ON t.ServerName = s.Value
        INNER JOIN DBA.dbo.Names AS d
            ON t.DatabaseName = d.Value
        INNER JOIN DBA.dbo.Names AS c
            ON t.SchemaName = c.Value
        INNER JOIN DBA.dbo.Names AS b
            ON t.TableName = b.Value
        LEFT JOIN DBA.dbo.Names AS i
            ON t.IndexName = i.Value
        LEFT JOIN DBA.dbo.IndexUsageStats_LastCumulative AS lc
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
        MERGE INTO DBA.dbo.IndexUsageStats_LastCumulative AS lc
        USING #t AS t
        INNER JOIN DBA.dbo.Names AS s
            ON t.ServerName = s.Value
        ON s.ID = lc.ServerNameID
           AND t.DatabaseID = lc.DatabaseID
           AND t.ObjectID = lc.ObjectID
           AND t.IndexID = lc.IndexID
        WHEN MATCHED THEN UPDATE SET lc.LoadTime = t.StatsDate,
                                     lc.User_Seeks = t.User_Seeks,
                                     lc.User_Scans = t.User_Scans,
                                     lc.User_Lookups = t.User_Lookups,
                                     lc.User_Updates = t.User_Updates,
                                     lc.System_Seeks = t.System_Seeks,
                                     lc.System_Scans = t.System_Scans,
                                     lc.System_Lookups = t.System_Lookups,
                                     lc.System_Updates = t.System_Updates
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
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
            VALUES (s.ID,
                    t.DatabaseID,
                    t.ObjectID,
                    t.IndexID,
                    t.StatsDate,
                    t.User_Seeks,
                    t.User_Scans,
                    t.User_Lookups,
                    t.User_Updates,
                    t.System_Seeks,
                    t.System_Scans,
                    t.System_Lookups,
                    t.System_Updates)
        WHEN NOT MATCHED BY SOURCE THEN DELETE;

        COMMIT TRAN;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @ErrorNumber INT;
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        DECLARE @ErrorProcedure NVARCHAR(126);
        DECLARE @ErrorLine INT;
        DECLARE @ErrorMessage NVARCHAR(2048);

        SELECT @ErrorNumber = ERROR_NUMBER (),
               @ErrorSeverity = ERROR_SEVERITY (),
               @ErrorState = ERROR_STATE (),
               @ErrorProcedure = ERROR_PROCEDURE (),
               @ErrorLine = ERROR_LINE (),
               @ErrorMessage = ERROR_MESSAGE ();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH;
END;
GO


