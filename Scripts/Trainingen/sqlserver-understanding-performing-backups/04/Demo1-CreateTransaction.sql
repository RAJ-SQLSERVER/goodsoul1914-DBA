-- Demo script 2 for Backups and Log Clearing

USE [Company];
GO

BEGIN TRANSACTION;
GO

SET NOCOUNT ON;
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 3000

-- Clean up
COMMIT TRANSACTION;
GO