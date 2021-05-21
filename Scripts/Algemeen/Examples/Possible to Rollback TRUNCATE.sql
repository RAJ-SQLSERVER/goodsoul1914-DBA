-------------------------------------------------------------------------------
-- Possible to Rollback TRUNCATE
-------------------------------------------------------------------------------

-- create test table
CREATE TABLE TruncateTest
(
    ID INT
);
GO

INSERT INTO dbo.TruncateTest
(
    ID
)
SELECT 1
UNION ALL
SELECT 2
UNION ALL
SELECT 3;
GO

-- check the data before truncate
SELECT *
FROM dbo.TruncateTest;
GO

-- begin transaction
BEGIN TRAN;
-- truncate table
TRUNCATE TABLE dbo.TruncateTest;
GO
-- check the data after truncate
SELECT *
FROM dbo.TruncateTest;
GO
-- rollback transaction
ROLLBACK TRAN;
GO

-- check after rollback
SELECT *
FROM dbo.TruncateTest;
GO

-- cleanup
DROP TABLE dbo.TruncateTest;
GO
