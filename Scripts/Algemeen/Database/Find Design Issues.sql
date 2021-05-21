/*******************
 Find Design Issues 
*******************/
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS AS c
WHERE c.DATA_TYPE IN ('nvarchar', 'bigint', 'ntext')
	OR c.DATA_TYPE LIKE 'n%'
	OR c.CHARACTER_MAXIMUM_LENGTH > 125
	AND DATA_TYPE IN ('varchar', 'nvarchar')
	OR c.IS_NULLABLE = 'YES'
	OR c.COLUMN_NAME LIKE 'is%'
	AND c.DATA_TYPE <> 'bit'
	OR CHARINDEX('()', c.COLUMN_DEFAULT) > 0
	OR c.COLLATION_NAME <> 'SQL_Latin1_General_CP1_CI_AS'
	OR c.DATA_TYPE IN ('binary', 'varbinary');
