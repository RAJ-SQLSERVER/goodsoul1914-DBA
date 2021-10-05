USE master;
GO

IF DATABASEPROPERTYEX (N'KeyUpdateTest', N'Version') > 0
BEGIN
    ALTER DATABASE KeyUpdateTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE KeyUpdateTest;
END;
GO

CREATE DATABASE KeyUpdateTest;
GO

USE KeyUpdateTest;
GO
ALTER DATABASE KeyUpdateTest SET RECOVERY SIMPLE;
ALTER DATABASE KeyUpdateTest SET AUTO_CREATE_STATISTICS OFF;
ALTER DATABASE KeyUpdateTest SET AUTO_UPDATE_STATISTICS OFF;
GO

-- Create a table with a clustered index and a single
-- record
CREATE TABLE test (c1 INT, c2 VARCHAR(2000));

CREATE CLUSTERED INDEX test_cl ON test (c1);

INSERT INTO test
VALUES (1, REPLICATE ('Paul', 500));
GO

-- And clear the log
CHECKPOINT;
GO

-- Check out the data page
-- Get this SP from http://bit.ly/PJ33dW
EXEC sp_AllocationMetadata N'test';
GO

DBCC TRACEON(3604);
GO
DBCC PAGE(N'keyupdatetest', 1, XX, 2);
GO

-- Now do an update of the 4 byte key
BEGIN TRAN;
GO
UPDATE test
SET c1 = 2
WHERE c1 = 1;
GO

-- How much space is being used?
-- Other window... and explain...

COMMIT TRAN;
GO

-- Look at the log records
SELECT [Current LSN],
       Operation,
       Context,
       [Log Record Length],
       [Page ID],
       [Slot ID]
FROM fn_dblog (NULL, NULL);
GO

-- Check out the page to prove it
DBCC PAGE(N'keyupdatetest', 1, XX, 2);
GO

-- How about this case?
DROP TABLE test;
GO

CREATE TABLE test (c1 INT, c2 VARCHAR(4000));
GO
CREATE CLUSTERED INDEX test_cl ON test (c1);
GO

INSERT INTO test
VALUES (1, REPLICATE ('Paul', 1000));
GO
INSERT INTO test
VALUES (2, REPLICATE ('Andy', 1000));
GO
CHECKPOINT;
GO

-- Check out the page
EXEC sp_AllocationMetadata N'test';
GO

DBCC PAGE(N'keyupdatetest', 1, XX, 2);
GO

BEGIN TRAN;
GO
UPDATE test
SET c1 = 3
WHERE c1 = 1;
GO

-- Look how much space is used in the log!

COMMIT TRAN;
GO

SELECT [Current LSN],
       Operation,
       Context,
       [Log Record Length],
       [Page ID],
       [Slot ID]
FROM fn_dblog (NULL, NULL);
GO
