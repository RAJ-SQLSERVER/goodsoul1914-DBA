/*
 The best way to decommission any table is to rename it first, 
 and if it does not break the functionality of the application, 
 we can drop the table and its dependencies. We decided that 
 after a review of the unused table completes; we will rename 
 the tables and later drop them.

 We decided to consider a table unused when user seek or user 
 scan or user update was not performed on any index of the 
 given table for two months. 
*/

CREATE OR ALTER PROCEDURE usp_GetUnusedTables @DatabaseName varchar(50)
AS
BEGIN
    /*Insert details of the tables */
    DECLARE @TableDetails_Query NVARCHAR(MAX);

    IF EXISTS
    (
        SELECT name
        FROM tempdb.sys.tables
        WHERE name LIKE '%#TableDetails%'
    )
        DROP TABLE #TableDetails;

    CREATE TABLE #TableDetails
    (
        [Database_Name] VARCHAR(50),
        [Schema_Name] VARCHAR(50),
        [Object_Id] BIGINT,
        [Table_Name] VARCHAR(500),
        [Modified_Date] DATETIME
    );

    SET @TableDetails_Query
        = N'INSERT INTO #TableDetails (
    [Database_Name]
    ,[Schema_Name]
    ,[Object_Id]
    ,[Table_Name]
    ,[Modified_Date]
    )
SELECT DatabaseName
    ,SchemaName
    ,ObjectId
    ,TableName
    ,ModifiedDate
FROM (
SELECT DISTINCT ' + N'''' + @DatabaseName + N''''
          + N' AS DatabaseName
    ,sch.NAME AS SchemaName
    ,tbl.object_id AS ObjectId
    ,tbl.NAME AS TableName
    ,tbl.modify_date AS ModifiedDate
FROM ' + @DatabaseName + N'.sys.tables AS tbl
INNER JOIN ' + @DatabaseName + N'.sys.schemas AS sch ON tbl.schema_id = sch.schema_id
LEFT JOIN ' + @DatabaseName
          + N'.sys.extended_properties AS ep ON ep.major_id = tbl.[object_id] /*Exclude System Tables*/
WHERE tbl.NAME IS NOT NULL
    AND sch.NAME IS NOT NULL
    AND (ep.[name] IS NULL OR ep.[name] <> ''microsoft_database_tools_support'')
    ) AS rd
WHERE rd.SchemaName IS NOT NULL
ORDER BY DatabaseName ASC
    ,TableName ASC';

    EXEC sp_executesql @TableDetails_Query;

    /*Insert Index usage*/
    IF EXISTS
    (
        SELECT name
        FROM tempdb.sys.tables
        WHERE name LIKE '%#Table_Usage%'
    )
        DROP TABLE #Table_Usage;

    CREATE TABLE #Table_Usage
    (
        [Database_Name] VARCHAR(150),
        [Object_Id] BIGINT,
        [Table_Name] NVARCHAR(128) NULL,
        [Last_User_Update] DATETIME NULL,
        [Last_User_Seek] DATETIME NULL,
        [Last_User_Scan] DATETIME NULL,
        [Last_User_Lookup] DATETIME NULL
    );

    DECLARE @TableUsage_Query NVARCHAR(MAX);

    SET @TableUsage_Query
        = N'INSERT INTO #Table_Usage (
    [Database_Name]
    ,[Object_Id]
    ,[Table_Name]
    ,[Last_User_Update]
    ,[Last_User_Seek]
    ,[Last_User_Scan]
    ,[Last_User_Lookup]
    )
SELECT DatabaseName
    ,ObjectId
    ,TableName
    ,LastUserUpdate
    ,LastUserSeek
    ,LastUserScan
    ,LastUserLookup
FROM (
    SELECT 
        ' + N'''' + @DatabaseName + N''''
          + N' AS DatabaseName
        ,indexusage.OBJECT_ID AS ObjectId
        ,obj.NAME AS TableName
        ,indexusage.last_user_update AS LastUserUpdate
        ,indexusage.last_user_seek AS LastUserSeek
        ,indexusage.last_user_scan AS LastUserScan
        ,indexusage.last_user_lookup AS LastUserLookup
    FROM ' + @DatabaseName + N'.sys.dm_db_index_usage_stats AS indexusage
    INNER JOIN ' + @DatabaseName
          + N'.sys.objects AS obj ON 
    indexusage.OBJECT_ID = obj.OBJECT_ID
        AND obj.NAME IS NOT NULL
 
        )as tbl';

    EXEC sp_executesql @TableUsage_Query;

    DECLARE @tableHTML NVARCHAR(MAX);
    DECLARE @Subject NVARCHAR(MAX);

    SET @Subject = N'List of Unused tables on ' + @DatabaseName;
    SET @tableHTML
        = N'      
<html>      
<Body>      
<style type="text/css">      
    table {font-size:9.0pt;font-family:verdana;text-align:left;}      
    tr {text-align:left;}      
    h3 {          
    display: block;      
    font-size: 15.0pt;      
    font-weight: bold;      
    font-family: verdana;      
    text-align:left;      
    }      
</style>      
<H4>List of unused tables on ' + @DatabaseName + N'</H4>' + N'<table border="1">'
          + N'<tr>      
<th>Database Name</th>      
<th>Schema Name</th>      
<th>Table Name</th>      
<th>Table Modified Date</th>      
<th>Last User Seek Occured on</th>      
<th>Last User Scan Occured on</th>      
<th>Last User Update Occured on</th>      
</tr>' + CAST(
         (
             SELECT ISNULL(TableDetails.Database_Name, '') AS 'TD',
                    '',
                    ISNULL(TableDetails.[Schema_Name], '') AS 'TD',
                    '',
                    ISNULL(TableDetails.[Table_Name], '') AS 'TD',
                    '',
                    ISNULL(TableDetails.[Modified_Date], '') AS 'TD',
                    '',
                    ISNULL(tableusage.[Last_User_Seek], '') AS 'TD',
                    '',
                    ISNULL(tableusage.[Last_User_Scan], '') AS 'TD',
                    '',
                    ISNULL(tableusage.[Last_User_Update], '') AS 'TD',
                    ''
             FROM #Table_Usage AS tableusage
                 INNER JOIN #TableDetails AS TableDetails
                     ON tableusage.Object_Id = TableDetails.Object_Id
             WHERE Last_User_Seek <= DATEADD(DAY, 0, GETDATE())
                   AND Last_User_Scan <= DATEADD(DAY, 0, GETDATE())
                   AND Last_User_Update <= DATEADD(DAY, 0, GETDATE())
             ORDER BY TableDetails.[Schema_Name] ASC,
                      TableDetails.[Table_Name] ASC
             FOR XML PATH('tr'), ROOT
         ) AS NVARCHAR(MAX)) + N'</table>       
</html>      
</Body>';

    /*Send Email*/

    EXEC msdb..sp_send_dbmail @profile_name = 'KPNMail',
                              @recipients = 'mboomaars@gmail.com',
                              @subject = @Subject,
                              @importance = 'High',
                              @body = @tableHTML,
                              @body_format = 'HTML';

END;
GO

