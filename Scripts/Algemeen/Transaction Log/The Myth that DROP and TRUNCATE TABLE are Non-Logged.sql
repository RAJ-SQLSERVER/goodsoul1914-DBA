
-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------

CREATE DATABASE [TruncateTest];
GO

ALTER DATABASE [TruncateTest] SET RECOVERY SIMPLE;
GO

USE [TruncateTest];
GO

CREATE TABLE [TestTable]
(
    [c1] INT IDENTITY,
    [c2] CHAR(8000)
        DEFAULT 'a'
);
GO

SET NOCOUNT ON;
GO

INSERT INTO [TestTable]
DEFAULT VALUES;
GO 10000

SELECT COUNT(*) AS N'RowCount'
FROM [TestTable];
GO

-------------------------------------------------------------------------------
-- Truncate
-------------------------------------------------------------------------------

BEGIN TRAN;
GO
TRUNCATE TABLE [TestTable];
GO
 
SELECT
    COUNT (*) AS N'RowCount'
FROM
    [TestTable];
GO

-------------------------------------------------------------------------------
-- Rollback
-------------------------------------------------------------------------------

ROLLBACK TRAN;
GO
 
SELECT
    COUNT (*) AS N'RowCount'
FROM
    [TestTable];
GO
/******************************************************************************

When a table is dropped or truncated, all the data file pages allocated for 
the table must be deallocated. 
The mechanism for this before SQL Server 2000 SP3 was as follows:


For each extent allocated to the table

Begin

    Acquire an eXclusive allocation lock on the extent
  
    Probe the page lock for each page in the extent (acquire the lock in 
	eXclusive mode, and immediately drop it, making sure no-one else has the 
	page locked)

    Do NOT release the extent lock, guaranteeing that no-one else can use 
	that extent
    
    Move to the next extent

End

******************************************************************************/

CHECKPOINT;
GO

TRUNCATE TABLE [TestTable];
GO

SELECT COUNT(*) AS N'LogRecCount'
FROM fn_dblog(NULL, NULL);
GO

SELECT *
FROM fn_dblog(NULL, NULL)
WHERE [Transaction Name] = 'DeferredAllocUnitDrop::Process'
GO
