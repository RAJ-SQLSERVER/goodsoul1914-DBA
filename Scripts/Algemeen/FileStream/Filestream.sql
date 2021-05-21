CREATE TABLE dbo.images (
    id        UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
    imageFile VARBINARY(MAX)   FILESTREAM
);
GO

INSERT INTO dbo.images (id, imageFile)
SELECT NEWID(), BulkColumn
FROM OPENROWSET(BULK 'c:/temp/Output.gif', SINGLE_BLOB) AS f;

INSERT INTO dbo.images (id, imageFile)
SELECT NEWID(), BulkColumn
FROM OPENROWSET(BULK 'c:/temp/K070601011.pdf', SINGLE_BLOB) AS f;
GO

SELECT * FROM dbo.images
GO
