/**********************************************************************************************************************************************
* Title:	Create Database Snapshot
* Date:		2016-11-01
* Author:	Joe McDermott
* Link:		https://msdn.microsoft.com/en-us/library/ms175876(v=sql.110).aspx
* Notes:	This script will generate SQL based on the source database and tagert appended name in order to generate a database snapshot.
*			Please read comments at the end of variables. Debug is on by default.
* Amend:	2016-11-17, updated with dmv SQL and help given from Budd on SQL Server Central. Changed file path to be taken from sys.master_files. 
*			2020-05-13, uses current database if @SourceDatabase is left empty
**********************************************************************************************************************************************/
DECLARE @SourceDatabase VARCHAR(128) = '', -- Name of the database you want to snapshot from. 
	@SnapshotAppend VARCHAR(128) = REPLACE(CONVERT(VARCHAR, GETDATE(), 112), '-', '') + REPLACE(CONVERT(VARCHAR, GETDATE(), 8), ':', ''),
	@FilePath VARCHAR(200) = NULL, -- Edit if you want the snapshot to reside somewhere else. (Example: 'C:\Override\Path\') 
	@FileSql VARCHAR(3000) = '',
	@SnapSql NVARCHAR(4000) = N'',
	@Debug BIT = 1;

IF DB_ID(@SourceDatabase) IS NULL
	SELECT @SourceDatabase = name
	FROM sys.sysdatabases
	WHERE dbid = DB_ID();

/********************************************************
1. Set the file path location of the snapshot data files.
********************************************************/
IF @FilePath = ''
	SET @FilePath = NULL;

/******************************************************************
2. Dynamicly build up a list of files for the database to snapshot.
******************************************************************/
SELECT @FileSql = @FileSql + CASE 
		WHEN @FileSql <> ''
			THEN + ','
		ELSE ''
		END + '		
		( NAME = ' + mf.name + ', FILENAME = ''' + ISNULL(@FilePath, LEFT(mf.physical_name, LEN(mf.physical_name) - 4)) + '_' + @SnapshotAppend + '.ss'')'
FROM sys.master_files AS mf
INNER JOIN sys.databases AS db ON db.database_id = mf.database_id
WHERE db.STATE = 0 -- Only include database online.
	AND mf.type = 0 -- Only include data files.
	AND db.name = @SourceDatabase;

/***********************************
3. Build the create snapshot syntax.
***********************************/
SET @SnapSql = N'
CREATE DATABASE ' + @SourceDatabase + N'_' + @SnapshotAppend + N'
    ON ' + @FileSql + N'
    AS SNAPSHOT OF ' + @SourceDatabase + N';';

/***********************************
4. Print or execute the dynamic sql.
***********************************/
IF @Debug = 1
BEGIN
	PRINT @SnapSql;
END;
ELSE
BEGIN
	EXEC sp_executesql @stmt = @SnapSql;
END;
GO


