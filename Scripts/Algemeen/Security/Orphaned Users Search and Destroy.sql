---------------------------------------------------------------------------------------------------
-- Author: Patrick Slesicki
-- Date: 06/26/2018
-- Purpose: To find orphans on an instance and generate a script to drop them.
-- Notes: Use with caution. MS has users without logins for some databases.
-- History:
-- mm/dd/yyyy	Init	Description
------------	----	---------------------------------------------------------------------------
-- 03/06/2020	PLS		Major revision using sids as join fields rather than names.
---------------------------------------------------------------------------------------------------
DECLARE @SQL AS NVARCHAR(2000)
    = N'USE [?]
INSERT INTO #Orphan
	(
	DBName
	,IsReadOnly
	,UserName
	,UserType
	,DropScript
	)
SELECT
	DB_NAME()
	,(SELECT is_read_only FROM sys.databases WHERE name = DB_NAME())
	,dp.name
	,dp.type_desc
	,CASE
		WHEN (SELECT is_read_only FROM sys.databases WHERE name = DB_NAME()) = 0 THEN ''USE '' + QUOTENAME(DB_NAME()) + ''; DROP USER '' + QUOTENAME(dp.name) + '';''
		WHEN (SELECT is_read_only FROM sys.databases WHERE name = DB_NAME()) = 1 
			THEN ''USE master; ALTER DATABASE '' 
			+ QUOTENAME(DB_NAME()) + '' SET READ_WRITE WITH NO_WAIT; USE '' 
			+ QUOTENAME(DB_NAME()) + ''; DROP USER '' + QUOTENAME(dp.name) 
			+ ''; USE master; ALTER DATABASE '' + QUOTENAME(DB_NAME()) + '' SET READ_ONLY WITH NO_WAIT;''
		ELSE NULL
		END
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON dp.sid = sp.sid
WHERE
	dp.principal_id > 4
	AND dp.type IN (''G'', ''S'', ''U'')
	AND dp.name NOT IN(
		''MS_DataCollectorInternalUser''
		,''AllSchemaOwner''
		,''vssfadmin''
		,''TFSWITDDLADMIN''
		,''smsdbuser_ReadOnly''
		,''smsdbuser_ReadWrite''
		,''smsdbuser_ReportSchema''
		)
	AND dp.name NOT LIKE ''NT %''
	AND sp.sid IS NULL;
';

---------------------------------------------------------------------------------------------------
-- Drop the temp table if it exists and create the temp table
---------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#Orphan') IS NOT NULL
    DROP TABLE #Orphan;

CREATE TABLE #Orphan (DBName NVARCHAR(128),
                      IsReadOnly BIT,
                      UserName NVARCHAR(128),
                      UserType NVARCHAR(60),
                      DropScript NVARCHAR(4000));

---------------------------------------------------------------------------------------------------
-- Execute the dynamic sql statement
---------------------------------------------------------------------------------------------------
EXEC sys.sp_MSforeachdb @command1 = @SQL;

---------------------------------------------------------------------------------------------------
-- Get results
---------------------------------------------------------------------------------------------------
SELECT DBName,
       IsReadOnly,
       UserName,
       UserType,
       DropScript
  FROM #Orphan
 ORDER BY DBName,
          UserName;

---------------------------------------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------------------------------------
DROP TABLE #Orphan;
GO