DROP TABLE IF EXISTS ##TempExportData;

DECLARE @DBName         VARCHAR(100),
        @SQLStmt        NVARCHAR(4000),
        @ShellStmt      VARCHAR(8000),
        @OutputFilename VARCHAR(100);

--SELECT @OutputFilename = 'c:\temp\datadictionary.xlsx';

BEGIN TRY
    SELECT @DBName = DB_NAME ();
    SELECT @SQLStmt = N'USE ' + @DBName + N';'
                      + N'
						SELECT ''Database'' AS [Database Name],
							''Schema'' AS [Schema Name],
							''Table Name'' AS [Table Name],
							''Column Name'' AS [Column Name],
							''DataType'' AS [Data Type],
							''Length'' AS [Length],
							''Precision'' AS [Precision],
							''Scale'' AS [Scale],
							''IsNullable'' AS [IsNullable],
							''IsPrimaryKey'' AS [IsPrimaryKey],
							''Primary Key Constraint'' AS [PK Constraint],
							''IsIndexed'' AS [IsIndexed],
							''IsIncludedIndex'' AS [IsIncludedIndex],
							''Index Name'' AS [Index Name],
							''Foreign Key Constraint'' AS [FK Constraint],
							''Parent Table'' AS [Parent Table],
							''Default Constraint'' AS [Default Constraint],
							''Comments'' AS [Comments]
						INTO ##tempExportData
						FROM sys.tables
						UNION
						SELECT DB_NAME () AS "Database Name",
							   OBJECT_SCHEMA_NAME (T.object_id) AS "Schema Name",
							   T.name AS "Table Name",
							   C.name AS "Column Name",
							   UPPER (TY.name) AS "DataType",
							   CAST(C.max_length AS VARCHAR(10)) AS "Length",
							   CAST(C.precision AS VARCHAR(5)) AS "Precision",
							   CAST(C.scale AS VARCHAR(5)) AS "Scale",
							   IIF(C.is_nullable = 0, ''N'', ''Y'') AS "IsNullable",
							   IIF(ISNULL (I.is_primary_key, 0) = 0, ''N'', ''Y'') AS "IsPrimaryKey",
							   KC.name AS "Primary Key Constraint",
							   (CASE WHEN IC.index_column_id > 0 THEN ''Y'' ELSE ''N'' END) AS "IsIndexed",
							   IIF(ISNULL (is_included_column, 0) = 0, ''Y'', ''N'') AS "IsIncludedIndex",
							   I.name AS "Index Name",
							   OBJECT_NAME (FK.constraint_object_id) AS "Foreign Key Constraint",
							   OBJECT_NAME (FK.referenced_object_id) AS "Parent Table",
							   DC.name AS "Default Constraint",
							   EP.value AS "Comments"
						FROM sys.tables AS T
						INNER JOIN sys.all_columns AS C
							ON T.object_id = C.object_id
						INNER JOIN sys.types AS TY
							ON C.system_type_id = TY.system_type_id
							   AND C.user_type_id = TY.user_type_id
						LEFT JOIN sys.index_columns AS IC
							ON IC.object_id = T.object_id
							   AND C.column_id = IC.column_id
						LEFT JOIN sys.indexes AS I
							ON I.object_id = T.object_id
							   AND IC.index_id = I.index_id
						LEFT JOIN sys.foreign_key_columns AS FK
							ON FK.parent_object_id = T.object_id
							   AND FK.parent_column_id = C.column_id
						LEFT JOIN sys.key_constraints AS KC
							ON KC.parent_object_id = T.object_id
							   AND IC.index_column_id = KC.unique_index_id
						LEFT JOIN sys.default_constraints AS DC
							ON DC.parent_column_id = C.column_id
						LEFT JOIN sys.extended_properties AS EP
							ON EP.major_id = T.object_id
							   AND EP.minor_id = C.column_id;
						--ORDER BY T.[name], C.[column_id]';

    EXECUTE sp_executesql @SQLStmt;

    SELECT * FROM ##tempexportdata;

--SET @ShellStmt = 'bcp "' + ' SELECT * from ##TempExportData" queryout "' + @OutputFilename + '" -c -T -CRAW';
--EXEC master..xp_cmdshell @ShellStmt;

END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER () AS "ErrorNumber",
           ERROR_SEVERITY () AS "ErrorSeverity",
           ERROR_STATE () AS "ErrorState",
           ERROR_PROCEDURE () AS "ErrorProcedure",
           ERROR_LINE () AS "ErrorLine",
           ERROR_MESSAGE () AS "ErrorMessage";
END CATCH;