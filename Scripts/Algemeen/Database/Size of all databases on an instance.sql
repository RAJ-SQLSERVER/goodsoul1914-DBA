CREATE TABLE ##alldatabasesizes (
	dbname VARCHAR(1024)
	,type_desc VARCHAR(1024)
	,name VARCHAR(1024)
	,size INT
	);

EXECUTE Sp_msforeachdb 'USE [?];
 
INSERT INTO ##AllDatabaseSizes 
SELECT db_name() as dbName, REPLACE(type_desc, ''ROWS'', ''DATA''), 
name, size / 128 as SizeInMB FROM [?].sys.database_files'

SELECT @@SERVERNAME AS [server]
	,*
FROM ##alldatabasesizes;

DROP TABLE ##alldatabasesizes

