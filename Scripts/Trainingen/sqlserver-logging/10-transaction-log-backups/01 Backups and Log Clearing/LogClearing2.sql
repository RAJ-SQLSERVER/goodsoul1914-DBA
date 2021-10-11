USE master;
GO

SET NOCOUNT ON;
GO

-- Start the long-running transaction
BEGIN TRAN;
GO

INSERT INTO DBMaint2012.dbo.BigTable
DEFAULT VALUES;
GO 1000

-- Now switch-back...

COMMIT TRAN;
GO