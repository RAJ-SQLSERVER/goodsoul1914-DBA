-- Grootte van alle tabellen in de huidige database
--------------------------------------------------------------------------------------------------
DECLARE @table TABLE (
	Id INT identity(1, 1),
	Name VARCHAR(256)
	);

INSERT INTO @table
SELECT b.name + '.' + a.name
FROM sys.tables AS a
INNER JOIN sys.schemas AS b ON a.schema_id = b.schema_id;

INSERT INTO @table
SELECT '-1';

DECLARE @result TABLE (
	TableName VARCHAR(256),
	TotalRows INT,
	Reserved VARCHAR(50),
	DataSize VARCHAR(50),
	IndexSize VARCHAR(50),
	UnusedSize VARCHAR(50)
	);
DECLARE @temp VARCHAR(256);
DECLARE @index INT;

SET @index = 1;

WHILE 1 = 1
BEGIN
	SELECT @temp = Name
	FROM @table
	WHERE Id = @index;

	IF @temp = '-1'
		BREAK;

	INSERT INTO @result (
		TableName,
		TotalRows,
		Reserved,
		DataSize,
		IndexSize,
		UnusedSize
		)
	EXEC sp_spaceused @temp;

	SET @index = @index + 1;
END;

SELECT c.name + '.' + b.name AS [table],
	a.*,
	CONVERT(INT, REPLACE(a.DataSize, ' KB', '')) AS SIZE
FROM @result AS a
INNER JOIN sys.tables AS b ON a.TableName = b.name
INNER JOIN sys.schemas AS c ON b.schema_id = c.schema_id
ORDER BY SIZE DESC;
GO


