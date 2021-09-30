USE [SlowLogFile];
GO

SET NOCOUNT ON;

WHILE (1=1)
BEGIN
	UPDATE [BadKeyTable] SET c1 = c1 + 1;
END;
GO