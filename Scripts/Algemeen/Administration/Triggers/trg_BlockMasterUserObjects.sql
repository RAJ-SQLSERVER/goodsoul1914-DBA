USE master;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_BlockMasterUserObjects')
	DROP TRIGGER trg_BlockMasterUserObjects
GO

CREATE TRIGGER trg_BlockMasterUserObjects
ON DATABASE
FOR CREATE_TABLE, CREATE_VIEW, CREATE_PROCEDURE, CREATE_FUNCTION
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    PRINT 'Creation of user objects in master database is not allowed, please select a different database for your user objects!';
    ROLLBACK;
END;
GO