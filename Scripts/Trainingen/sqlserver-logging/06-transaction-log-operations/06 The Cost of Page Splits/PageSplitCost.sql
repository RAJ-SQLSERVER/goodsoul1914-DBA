USE master;
GO

IF DATABASEPROPERTYEX (N'PageSplitTest', N'Version') > 0
BEGIN
    ALTER DATABASE PageSplitTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PageSplitTest;
END;
GO

CREATE DATABASE PageSplitTest;
GO

USE PageSplitTest;
GO
SET NOCOUNT ON;
GO

-- Create a table to simulate roughly
-- 1000 byte rows
CREATE TABLE BigRows (c1 INT, c2 CHAR(1000));
GO
CREATE CLUSTERED INDEX BigRows_CL ON BigRows (c1);
GO

-- Insert some rows, leaving a gap
-- at c1 = 5
INSERT INTO BigRows
VALUES (1, 'a');
INSERT INTO BigRows
VALUES (2, 'a');
INSERT INTO BigRows
VALUES (3, 'a');
INSERT INTO BigRows
VALUES (4, 'a');
INSERT INTO BigRows
VALUES (6, 'a');
INSERT INTO BigRows
VALUES (7, 'a');
GO

-- Insert a row inside an explicit
-- transaction and see how much log
-- it generates
BEGIN TRAN;
INSERT INTO BigRows
VALUES (8, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Now let's insert the 'missing' key
-- value, which will split the page.
-- What's the log cost? 
BEGIN TRAN;
INSERT INTO BigRows
VALUES (5, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Wow

-- Now let's try the same thing again with
-- a row size of roughly 100 bytes
DROP TABLE BigRows;
GO
CREATE TABLE BigRows (c1 INT, c2 CHAR(100));
GO
CREATE CLUSTERED INDEX BigRows_CL ON BigRows (c1);
GO

-- Insert 66 rows
INSERT INTO BigRows
VALUES (1, 'a');
INSERT INTO BigRows
VALUES (2, 'b');
GO
INSERT INTO BigRows
VALUES (4, 'c');
GO 64

-- Insert a row inside an explicit
-- transaction and see how much log
-- it generates
BEGIN TRAN;
INSERT INTO BigRows
VALUES (5, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Now let's insert the 'missing' key
-- value, which will split the page.
-- What's the log cost?
BEGIN TRAN;
INSERT INTO BigRows
VALUES (3, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Wow - even worse!

-- Lastly let's try the same thing again with
-- a row size of roughly 10 bytes
DROP TABLE BigRows;
GO
CREATE TABLE BigRows (c1 INT, c2 CHAR(10));
GO
CREATE CLUSTERED INDEX BigRows_CL ON BigRows (c1);
GO

-- Insert 260 rows
INSERT INTO BigRows
VALUES (1, 'a');
GO 6
INSERT INTO BigRows
VALUES (3, 'c');
GO 254

-- Insert a row inside an explicit
-- transaction and see how much log
-- it generates
BEGIN TRAN;
INSERT INTO BigRows
VALUES (2, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Now let's insert the 'missing' key
-- value, which will split the page.
-- What's the log cost?
BEGIN TRAN;
INSERT INTO BigRows
VALUES (2, 'a');
GO

SELECT database_transaction_log_bytes_used
FROM sys.dm_tran_database_transactions
WHERE database_id = DB_ID (N'PageSplitTest');
GO

COMMIT TRAN;
GO

-- Even worse - skewed page split!
