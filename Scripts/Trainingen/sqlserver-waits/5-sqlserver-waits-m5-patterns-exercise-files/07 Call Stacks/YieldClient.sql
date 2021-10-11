USE YieldTest;
GO


SET NOCOUNT ON;
GO

DECLARE @a INT;
WHILE (1 = 1)
BEGIN
    SELECT @a = COUNT (*)
    FROM YieldTest.dbo.SampleTable
    WHERE c1 = 1;
END;
GO