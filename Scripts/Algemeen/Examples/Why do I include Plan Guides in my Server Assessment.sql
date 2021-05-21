/*
	Plan guides let you optimize the performance of queries when you cannot or do 
	not want to directly change the text of the actual query in SQL Server 2019 (15.x). 
	Plan guides influence the optimization of queries by attaching query hints or a 
	fixed query plan to them.

	The code below will check every database and return a row for each plan guide found. 
	In addition, it will return the query and whether or not it is enabled.
*/

CREATE TABLE #PGInfo
(
    DBName VARCHAR(128),
    GuideName VARCHAR(500),
    CreateDate DATETIME,
    ModifiedDate DATETIME,
    IsEnabled BIT,
    QueryStatement VARCHAR(300),
    Type NVARCHAR(MAX)
);

EXECUTE master.sys.sp_MSforeachdb @command1 = 'USE [?] 
		INSERT INTO #PGInfo   
		SELECT
         DB_Name()
          , Name
          , create_date
          , modify_date
          , is_disabled
          , query_text
          , scope_type
        FROM sys.plan_guides ';
SELECT DBName,
       GuideName,
       CreateDate,
       ModifiedDate,
       IsEnabled,
       QueryStatement,
       [Type]
FROM #PGInfo;

IF @@ROWCOUNT = 0
    SELECT 'No Plan Guides were found in any databases.';

DROP TABLE #PGInfo;