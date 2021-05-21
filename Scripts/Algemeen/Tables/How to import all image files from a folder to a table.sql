-------------------------------------------------------------------------------
-- How to Import or load all the picture/image files from a folder to SQL 
-- Server Table
-------------------------------------------------------------------------------

USE Playground;
GO

CREATE TABLE dbo.MyPictures
(
    PictureId INT IDENTITY PRIMARY KEY,
    PictureFileName VARCHAR(100),
    PictureData VARBINARY(MAX),
    LoadedDateTime DATETIME
);

IF OBJECT_ID('tempdb..#FileList') IS NOT NULL
    DROP TABLE #FileList;


-- Folder path where files are present
DECLARE @SourceFolder VARCHAR(100);
SET @SourceFolder = 'C:\Temp\';

CREATE TABLE #FileList
(
    Id INT IDENTITY(1, 1),
    FileName NVARCHAR(255),
    Depth SMALLINT,
    FileFlag BIT
);

-- Load the file names from a folder to a table
INSERT INTO #FileList (FileName, Depth, FileFlag)
EXEC sys.xp_dirtree @SourceFolder, 10, 1;

-- Use Cursor to loop throught backups files
-- Select * From #FileList
DECLARE @FileName VARCHAR(500);

DECLARE Cur CURSOR FOR 
	SELECT FileName 
	FROM #FileList 
	WHERE FileFlag = 1;

OPEN Cur;
FETCH NEXT FROM Cur
INTO @FileName;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @InsertSQL NVARCHAR(MAX) = NULL;
    -- Prepare SQL Statement for insert
    SET @InsertSQL = N'INSERT INTO dbo.MyPictures(PictureFileName, LoadedDateTime,PictureData)
					 SELECT ''' + @FileName + N''',getdate(),BulkColumn 
					 FROM Openrowset( Bulk ''' + @SourceFolder + @FileName + N''', Single_Blob) as Image';

    -- Print and Execute SQL Insert Statement to load file
    PRINT @InsertSQL;
    EXEC (@InsertSQL);

    FETCH NEXT FROM Cur
    INTO @FileName;
END;
CLOSE Cur;
DEALLOCATE Cur;


SELECT *
FROM   dbo.MyPictures;