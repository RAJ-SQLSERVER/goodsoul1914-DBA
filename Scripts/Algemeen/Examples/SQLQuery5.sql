CREATE TABLE dbo.Temp
(
    ID INT NOT NULL,
    Name CHAR(8000) NULL
);
GO

SET NOCOUNT ON;
GO

DECLARE @i INT;
SET @i = 1;

WHILE @i < 10000
BEGIN
    INSERT INTO dbo.Temp (ID, Name)
    VALUES (1, 'Tough cookie');
    SET @i = @i + 1;
END;
GO
