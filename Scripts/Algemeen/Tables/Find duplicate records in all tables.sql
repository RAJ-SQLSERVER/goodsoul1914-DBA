-------------------------------------------------------------------------------
-- Find duplicate records in all tables
-------------------------------------------------------------------------------


USE Credit;
GO

DECLARE @SchemaName VARCHAR(100);
DECLARE @TableName VARCHAR(100);
DECLARE @DatabaseName VARCHAR(100);

--Create Temp Table to Save Results 
IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #results;

CREATE TABLE #results
(
    databasename VARCHAR(100),
    schemaname VARCHAR(100),
    tablename VARCHAR(100),
    columnlist VARCHAR(MAX),
    duplicatevalue VARCHAR(MAX),
    totaltablerowcount INT,
    duplicaterowcnt INT
);

DECLARE cur CURSOR FOR
SELECT TABLE_CATALOG,
       TABLE_SCHEMA,
       TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE';

OPEN cur;

FETCH NEXT FROM cur
INTO @DatabaseName,
     @SchemaName,
     @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    --Get List of the Columns from Table without Identity Column 
    DECLARE @ColumnList NVARCHAR(MAX) = NULL;

    SELECT     @ColumnList = COALESCE(@ColumnList + '],[', '') + c.name
    FROM       sys.columns AS c
    INNER JOIN sys.tables AS t ON c.object_id = t.object_id
    WHERE      OBJECT_NAME(c.object_id) = @TableName
               AND SCHEMA_NAME(t.schema_id) = @SchemaName
               AND c.is_identity = 0;

    SET @ColumnList = N'[' + @ColumnList + N']';

    --Print @ColumnList 
    DECLARE @ColumnListConcat VARCHAR(MAX) = NULL;

    SET @ColumnListConcat
        = REPLACE(
              REPLACE(
                  REPLACE(REPLACE(@ColumnList, '[', 'ISNULL(Cast(['), ']', '] AS VARCHAR(MAX)),''NULL'')'),
                  ',ISNULL',
                  '+ISNULL'
              ),
              '+',
              '+'',''+'
          );

    --Create Dynamic Query for Finding duplicate Records 
    DECLARE @DuplicateSQL NVARCHAR(MAX) = NULL;

    SET @DuplicateSQL
        = N';With CTE as   (select  ''' + @DatabaseName + N''' AS DBName,' + N'''' + @SchemaName + N''' AS SchemaName,'
          + N'''' + @TableName + N''' AS TableName,' + N'''' + @ColumnList + N''' AS ColumnList,' + @ColumnListConcat
          + N' AS ColumnConcat,    (Select count(*) from [' + @SchemaName + N'].[' + @TableName
          + N'] With (Nolock))             AS TotalTableRowCount    ,RN = row_number()             over(PARTITION BY '
          + @ColumnList + N'  order by ' + @ColumnList + N')             from [' + @SchemaName + N'].[' + @TableName
          + N']  ) Select * From CTE WHERE RN>1';

    PRINT @DuplicateSQL;

    INSERT INTO #results
    EXEC (@DuplicateSQL);

    FETCH NEXT FROM cur
    INTO @DatabaseName,
         @SchemaName,
         @TableName;
END;

CLOSE cur;

DEALLOCATE cur;

SELECT *
FROM   #results;
--drop table #Results 