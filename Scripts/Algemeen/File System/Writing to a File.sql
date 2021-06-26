sp_configure 'show advanced options'
	,1
GO

RECONFIGURE;
GO

sp_configure 'Ole Automation Procedures'
	,1
GO

RECONFIGURE;
GO

CREATE PROCEDURE writeFile (
	@fileName NVARCHAR(MAX)
	,@fileContents NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE @OLE INT
	DECLARE @FileID INT
	DECLARE @outputCursor AS CURSOR;
	DECLARE @outputLine AS NVARCHAR(MAX);

	PRINT 'about to write file';
	PRINT @fileName;

	EXECUTE sp_OACreate 'Scripting.FileSystemObject'
		,@OLE OUTPUT

	EXECUTE sp_OAMethod @OLE
		,'OpenTextFile'
		,@FileID OUTPUT
		,@fileName
		,2
		,1

	DECLARE @sep CHAR(2);

	SET @sep = CHAR(13) + CHAR(10);
	SET @outputCursor = CURSOR
	FOR
	WITH splitter_cte AS (
			SELECT CAST(CHARINDEX(@sep, @fileContents) AS BIGINT) AS pos
				,CAST(0 AS BIGINT) AS lastPos
			
			UNION ALL
			
			SELECT CHARINDEX(@sep, @fileContents, pos + 1)
				,pos
			FROM splitter_cte
			WHERE pos > 0
			)

	SELECT SUBSTRING(@fileContents, lastPos + 1, CASE 
				WHEN pos = 0
					THEN 999999999
				ELSE pos - lastPos - 1
				END + 1) AS chunk
	FROM splitter_cte
	ORDER BY lastPos
	OPTION (MAXRECURSION 0);

	--DECLARE @loopCounter as BIGINT = 0;
	OPEN @outputCursor;

	FETCH NEXT
	FROM @outputCursor
	INTO @outputLine;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--set @loopCounter  = @loopCounter  + 1;
		EXECUTE sp_OAMethod @FileID
			,'Write'
			,NULL
			,@outputLine;

		--PRINT concat(@loopCounter, ': ', @outputLine);
		FETCH NEXT
		FROM @outputCursor
		INTO @outputLine;
	END

	CLOSE @outputCursor;

	DEALLOCATE @outputCursor;

	EXECUTE sp_OADestroy @FileID;
END

--
-- Replace C:\SQL_DATA\test.txt with your output file. The directory must exist and the account that SQL Server is running as will need permissions to write there.
EXEC writeFile @fileName = 'C:\temp\test.txt'
	,@fileContents = 'this is a test
some more text
go
go
even more';

