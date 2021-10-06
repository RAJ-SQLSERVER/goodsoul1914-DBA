USE [master]
GO
IF DB_ID('tsql_stackDemo') IS NOT NULL
BEGIN
	ALTER DATABASE [tsql_stackDemo] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [tsql_stackDemo];
END
GO

CREATE DATABASE [tsql_stackDemo];
GO

USE [tsql_stackDemo]
GO

-- Create a function to track it's usage
CREATE FUNCTION dbo.ReturnsTrue
(@TestValue INT)
RETURNS BIT
AS
BEGIN
	DECLARE @RetVal BIT = 1;
	RETURN(@RetVal);
END
GO

-- Create the last procedure in the nested calls
CREATE PROCEDURE [dbo].[CalledThird] (@input int)
AS 
BEGIN
	IF (@input = 100)
	BEGIN
		SELECT @input;
	END
	ELSE 
	BEGIN
		SELECT dbo.ReturnsTrue(@input);
	END
END
GO

-- Create the second procedure in the nested calls
CREATE PROCEDURE [dbo].[CalledSecond]
AS 
BEGIN
	EXECUTE dbo.CalledThird 1;
END

GO

-- Create the first procedure in the nested calls
CREATE PROCEDURE [dbo].[CalledFirst]
AS 
BEGIN
	EXECUTE dbo.CalledSecond;
END
GO

-- Create another first procedure that doesn't nest as far.
CREATE PROCEDURE [dbo].[OtherProcedure]
AS 
BEGIN
	-- Don't cause the function to be called
	EXECUTE dbo.CalledThird 100;
	-- Cause the function to be called
	EXECUTE dbo.CalledThird 1;
END
GO





