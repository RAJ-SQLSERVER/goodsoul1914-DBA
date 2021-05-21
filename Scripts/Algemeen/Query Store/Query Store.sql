DECLARE @dbname sysname;
DECLARE dbCURSOR CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'
      AND user_access_desc = 'MULTI_USER'
      AND is_query_store_on = 1;
DECLARE @sql1 NVARCHAR(MAX)
    = N'select db_id() dbid, db_name() dbname, * from sys.query_store_runtime_stats_interval where start_time > dateadd (dd,-7, getdate())';
DECLARE @sql2 NVARCHAR(MAX)
    = N'select db_id() dbid, db_name() dbname, * from sys.query_store_runtime_stats where runtime_stats_interval_id in (select runtime_stats_interval_id from sys.query_store_runtime_stats_interval where start_time > dateadd (dd,-7, getdate()))';
DECLARE @sql3 NVARCHAR(MAX) = N'select db_id() dbid, db_name() dbname, * from   sys.query_store_query ';
DECLARE @sql4 NVARCHAR(MAX)
    = N'select db_id() dbid, db_name() dbname, query_text_id, statement_sql_handle, is_part_of_encrypted_module, has_restricted_text, substring (REPLACE (REPLACE (query_sql_text,CHAR(13), '' ''), CHAR(10), '' ''), 1, 256)  as  query_sql_text from sys.query_store_query_text';
DECLARE @sql5 NVARCHAR(MAX)
    = N'select db_id() dbid, db_name() dbname, plan_id, query_id, plan_group_id, engine_version, compatibility_level, query_plan_hash,  is_forced_plan from  sys.query_store_plan';


DECLARE @sql NVARCHAR(MAX);
OPEN dbCURSOR;
FETCH NEXT FROM dbCURSOR
INTO @dbname;
WHILE @@FETCH_STATUS = 0
BEGIN

    RAISERROR('--sys.query_store_runtime_stats_interval--', 0, 1) WITH NOWAIT;
    SET @sql = N'use [' + @dbname + N'] ' + @sql1;
    EXEC (@sql);
    RAISERROR(' ', 0, 1) WITH NOWAIT;

    RAISERROR('--sys.query_store_runtime_stats--', 0, 1) WITH NOWAIT;
    SET @sql = N'use [' + @dbname + N'] ' + @sql2;
    EXEC (@sql);
    RAISERROR(' ', 0, 1) WITH NOWAIT;

    RAISERROR('--sys.query_store_query--', 0, 1) WITH NOWAIT;
    SET @sql = N'use [' + @dbname + N'] ' + @sql3;
    EXEC (@sql);
    RAISERROR(' ', 0, 1) WITH NOWAIT;

    RAISERROR('--sys.query_store_query_text--', 0, 1) WITH NOWAIT;
    SET @sql = N'use [' + @dbname + N'] ' + @sql4;
    EXEC (@sql);
    RAISERROR(' ', 0, 1) WITH NOWAIT;

    RAISERROR('--sys.query_store_plan--', 0, 1) WITH NOWAIT;
    SET @sql = N'use [' + @dbname + N'] ' + @sql5;
    EXEC (@sql);
    RAISERROR(' ', 0, 1) WITH NOWAIT;


    FETCH NEXT FROM dbCURSOR
    INTO @dbname;
END;

CLOSE dbCURSOR;
DEALLOCATE dbCURSOR;



--select * from sys.query_store_runtime_stats

--EXEC sp_MSforeachdb 'use [?] select  db_id() ''database_id'', db_name() ''database_name'' ,  plan_id, query_id, query_plan_hash, REPLACE (REPLACE (query_plan ,CHAR(13), '' ''), CHAR(10), '' '')  query_plan from sys.query_store_plan'




