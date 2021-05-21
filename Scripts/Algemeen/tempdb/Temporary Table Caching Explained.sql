CREATE PROCEDURE dbo.Demo
AS
BEGIN
    CREATE TABLE #Demo
    (
        i INT
    );

    SELECT T.[name],
           T.[object_id],
           T.[type_desc],
           T.create_date
    FROM sys.tables AS T
    WHERE T.[name] LIKE N'#Demo%';

    DROP TABLE #Demo;

    SELECT T.[name],
           T.[object_id],
           T.[type_desc],
           T.create_date
    FROM sys.tables AS T
    WHERE T.[name] LIKE N'#________';
END;
GO

-- Cache a temporary object
EXECUTE dbo.Demo;
GO
-- Show the cached table
SELECT T.[name],
       T.[object_id],
       T.[type_desc],
       T.create_date
FROM tempdb.sys.tables AS T
WHERE T.[name] LIKE N'#________';

DECLARE @plan_handle VARBINARY(64);

-- Find the plan handle
SELECT @plan_handle = DECP.plan_handle
FROM sys.dm_exec_cached_plans AS DECP
    CROSS APPLY sys.dm_exec_plan_attributes(DECP.plan_handle) AS DEPA
    CROSS APPLY sys.dm_exec_sql_text(DECP.plan_handle) AS DEST
WHERE DECP.cacheobjtype = N'Compiled Plan'
      AND DECP.objtype = N'Proc'
      AND DEPA.attribute = N'objectid'
      AND CONVERT(INTEGER, DEPA.[value]) = OBJECT_ID(N'dbo.Demo', N'P');

-- Truncate the log
CHECKPOINT;

-- Evict the plan
DBCC FREEPROCCACHE(@plan_handle);

-- Show log entries
SELECT FD.[Current LSN],
       FD.SPID,
       FD.Operation,
       FD.Context,
       FD.AllocUnitName,
       FD.[Transaction Name],
       FD.[Transaction ID],
       FD.[Begin Time],
       FD.[End Time]
FROM sys.fn_dblog(NULL, NULL) AS FD;

-- Cached object not dropped yet
SELECT T.[name],
       T.[object_id],
       T.[type_desc],
       T.create_date
FROM tempdb.sys.tables AS T
WHERE T.[name] LIKE N'#________';

WAITFOR DELAY '00:00:05';

-- Show cleanup
SELECT FD.[Current LSN],
       FD.SPID,
       FD.Operation,
       FD.Context,
       FD.AllocUnitName,
       FD.[Transaction Name],
       FD.[Transaction ID],
       FD.[Begin Time],
       FD.[End Time]
FROM sys.fn_dblog(NULL, NULL) AS FD;

-- Gone!
SELECT T.[name],
       T.[object_id],
       T.[type_desc],
       T.create_date
FROM tempdb.sys.tables AS T
WHERE T.[name] LIKE N'#________';