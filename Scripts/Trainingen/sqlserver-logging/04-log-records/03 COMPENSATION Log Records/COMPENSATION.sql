RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

CREATE DATABASE DBMaint2012;
GO

USE DBMaint2012;
GO
SET NOCOUNT ON;
GO

-- Make sure the database is in SIMPLE
-- recovery model with no auto-stats (to avoid
-- unwanted log records)
ALTER DATABASE DBMaint2012 SET RECOVERY SIMPLE;
ALTER DATABASE DBMaint2012 SET AUTO_CREATE_STATISTICS OFF;
GO

-- Create a simple table with some records
CREATE TABLE test (c1 INT, c2 INT, c3 INT);

INSERT INTO test
VALUES (1, 1, 1);
INSERT INTO test
VALUES (2, 2, 2);
GO

-- Clear out the log (more on this in Module 5)
CHECKPOINT;
GO

-- Explicit transaction to insert a new record
BEGIN TRAN;
GO
INSERT INTO test
VALUES (3, 3, 3);
GO

SELECT *
FROM fn_dblog (NULL, NULL);
GO

-- Now roll it back
ROLLBACK TRAN;
GO

-- Look for COMPENSATION context
-- Look for LSN linkages
SELECT *
FROM fn_dblog (NULL, NULL);
GO

-- clear things out again
CHECKPOINT;
GO

-- Now multiple columns in multiple rows
BEGIN TRAN;
GO
UPDATE test
SET c1 = 8,
    c3 = 9;
GO

SELECT *
FROM fn_dblog (NULL, NULL);
GO

-- And roll it back
ROLLBACK TRAN;
GO

-- And look for just the after here
SELECT *
FROM fn_dblog (NULL, NULL);
GO