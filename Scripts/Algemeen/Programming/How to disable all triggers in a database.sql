
USE [Playground];
GO

DECLARE @TriggerName AS VARCHAR(500);
DECLARE @TableName AS VARCHAR(500);
DECLARE @SchemaName AS VARCHAR(100);

--Disable All Triggers in a Database in SQL Server
DECLARE DisableTrigger CURSOR FOR
SELECT     TBL.name AS TableName,
           SCHEMA_NAME(TBL.schema_id) AS Table_SchemaName,
           TRG.name AS TriggerName
FROM       sys.triggers AS TRG
INNER JOIN sys.tables AS TBL ON TBL.object_id = TRG.parent_id
                                AND TRG.is_disabled = 0
                                AND TBL.is_ms_shipped = 0;
OPEN DisableTrigger;
FETCH NEXT FROM DisableTrigger
INTO @TableName,
     @SchemaName,
     @TriggerName;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @SQL VARCHAR(MAX) = NULL;

    SET @SQL = 'Disable Trigger ' + @TriggerName + ' ON ' + @SchemaName + '.' + @TableName;

    EXEC (@SQL);
    PRINT 'Trigger ::' + @TriggerName + 'is disabled on ' + @SchemaName + '.' + @TableName;
    PRINT @SQL;

    FETCH NEXT FROM DisableTrigger
    INTO @TableName,
         @SchemaName,
         @TriggerName;
END;

CLOSE DisableTrigger;
DEALLOCATE DisableTrigger;



-- To check if all the triggers are disabled correctly in SQL Server Database, use below query

SELECT     TBL.name AS TableName,
           SCHEMA_NAME(TBL.schema_id) AS Table_SchemaName,
           TRG.name AS TriggerName,
           TRG.parent_class_desc,
           CASE
               WHEN TRG.is_disabled = 0 THEN
                   'Enable'
               ELSE
                   'Disable'
           END AS TRG_Status
FROM       sys.triggers AS TRG
INNER JOIN sys.tables AS TBL ON TBL.object_id = TRG.parent_id
                                AND TRG.is_disabled = 1; -- use this filter to get Disabled Triggers