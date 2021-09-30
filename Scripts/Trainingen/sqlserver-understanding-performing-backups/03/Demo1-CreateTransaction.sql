-- Demo script 2 for How Much Log in a Full Backup

USE [Company];
GO

BEGIN TRANSACTION;
GO

INSERT INTO [RandomData] VALUES
	('Open transaction');
GO

-- Clean up
COMMIT TRANSACTION;
GO