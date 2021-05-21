IF OBJECT_ID('usp_DatabaseUsers') IS NOT NULL DROP PROC usp_DatabaseUsers;
GO

CREATE PROC dbo.usp_DatabaseUsers
(@database_name sysname = NULL)
AS
BEGIN
    IF OBJECT_ID('tempdb..#t') IS NOT NULL DROP TABLE #t;
    CREATE TABLE #t
    (
        DatabaseName sysname NULL,
        UserName sysname NULL,
        UserType NVARCHAR(MAX) NULL,
        DatabaseUserName sysname NULL,
        Role sysname NULL,
        PermissionType NVARCHAR(MAX) NULL,
        PermissionState NVARCHAR(MAX) NULL,
        ObjectType NVARCHAR(MAX) NULL,
        ObjectName NVARCHAR(MAX) NULL,
        ColumnName NVARCHAR(MAX) NULL
    );

    DECLARE @dbName sysname;
    DECLARE @dbCursor CURSOR;
    DECLARE @sql NVARCHAR(MAX);

    SET @dbCursor = CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE source_database_id IS NULL
          AND database_id > 4
          AND is_read_only = 0
          AND state_desc = 'ONLINE'
    ORDER BY name;

    OPEN @dbCursor;
    FETCH NEXT FROM @dbCursor
    INTO @dbName;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        SET @sql
            = N'  USE [' + @dbName + N']     INSERT INTO #t  SELECT ''[' + @dbName
              + N']'' As DatabaseName,    [UserName] = CASE princ.[type]   WHEN ''S'' THEN princ.[name]   WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI   WHEN ''G'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI   WHEN ''R'' THEN ''Database Role''   ELSE princ.[type]   END,   [UserType] = CASE princ.[type]   WHEN ''S'' THEN ''SQL User''   WHEN ''U'' THEN ''Windows User''   WHEN ''G'' THEN ''Windows Group''   WHEN ''R'' THEN ''Database Role''   ELSE princ.[type]        END,   [DatabaseUserName] = princ.[name],   [Role] = NULL,   [PermissionType] = perm.[permission_name],   [PermissionState] = perm.[state_desc],   [ObjectType] = obj.type_desc, [ObjectName] = OBJECT_NAME(perm.major_id),   [ColumnName] = col.[name]  FROM  sys.database_principals princ  LEFT OUTER JOIN sys.login_token ulogin ON princ.[sid] = ulogin.[sid]  LEFT OUTER JOIN sys.database_permissions perm   ON perm.[grantee_principal_id] = princ.[principal_id]  LEFT OUTER JOIN sys.columns col ON col.[object_id] = perm.major_id   AND col.[column_id] = perm.[minor_id]  LEFT OUTER JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]  WHERE  princ.[type] IN ( ''S'', ''U'', ''G'' )  UNION  SELECT  ''['
              + @dbName
              + N']'' As DatabaseName,    [UserName] = CASE memberprinc.[type]   WHEN ''S'' THEN memberprinc.[name]   WHEN ''U'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI   WHEN ''G'' THEN ulogin.[name] COLLATE Latin1_General_CI_AI        END,   [UserType] = CASE memberprinc.[type]   WHEN ''S'' THEN ''SQL User''   WHEN ''U'' THEN ''Windows User''   WHEN ''G'' THEN ''Windows Group''   WHEN ''R'' THEN ''Database Role''        END,   [DatabaseUserName] = memberprinc.[name],   [Role] = roleprinc.[name],   [PermissionType] = perm.[permission_name],   [PermissionState] = perm.[state_desc],   [ObjectType] = obj.type_desc,     [ObjectName] = OBJECT_NAME(perm.major_id),   [ColumnName] = col.[name]  FROM  sys.database_role_members members  INNER JOIN sys.database_principals roleprinc   ON roleprinc.[principal_id] = members.[role_principal_id]  INNER JOIN sys.database_principals memberprinc   ON memberprinc.[principal_id] = members.[member_principal_id]  LEFT OUTER JOIN sys.login_token ulogin   ON memberprinc.[sid] = ulogin.[sid]  LEFT OUTER JOIN sys.database_permissions perm   ON perm.[grantee_principal_id] = roleprinc.[principal_id]  LEFT OUTER JOIN sys.columns col ON col.[object_id] = perm.major_id   AND col.[column_id] = perm.[minor_id]  LEFT OUTER JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]     UNION  SELECT  ''['
              + @dbName
              + N']'' As DatabaseName,    [UserName] = ''{All Users}'',   [UserType] = ''{All Users}'',   [DatabaseUserName] = ''{All Users}'',   [Role] = roleprinc.[name],   [PermissionType] = perm.[permission_name],   [PermissionState] = perm.[state_desc],   [ObjectType] = obj.type_desc, [ObjectName] = OBJECT_NAME(perm.major_id),   [ColumnName] = col.[name]  FROM  sys.database_principals roleprinc  LEFT OUTER JOIN sys.database_permissions perm   ON perm.[grantee_principal_id] = roleprinc.[principal_id]  LEFT OUTER JOIN sys.columns col ON col.[object_id] = perm.major_id   AND col.[column_id] = perm.[minor_id]  INNER JOIN sys.objects obj ON obj.[object_id] = perm.[major_id]  WHERE  roleprinc.[type] = ''R''   AND  roleprinc.[name] = ''public''   AND  obj.is_ms_shipped = 0';

        PRINT @sql;
        EXECUTE sys.sp_executesql @sql;

        FETCH NEXT FROM @dbCursor
        INTO @dbName;
    END;

    CLOSE @dbCursor;
    DEALLOCATE @dbCursor;

    SELECT @@SERVERNAME AS ServerName,
           DatabaseName,
           UserName,
           UserType,
           DatabaseUserName,
           Role,
           PermissionType,
           PermissionState,
           ObjectType,
           ObjectName,
           ColumnName
    FROM #t
    WHERE (
        1 = (CASE
                 WHEN @database_name IS NULL THEN
                     1
                 ELSE
                     0
             END
            )
        OR DatabaseName = QUOTENAME(@database_name)
    )
    ORDER BY DatabaseName,
             DatabaseUserName;
    REVERT;
END;


--EXEC dbo.usp_DatabaseUsers
--EXEC dbo.usp_DatabaseUsers @database_name = N'AdventureWorksDW2016'