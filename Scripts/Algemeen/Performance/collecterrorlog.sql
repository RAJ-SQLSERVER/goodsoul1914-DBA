SET NOCOUNT ON;
PRINT 'Errorlogs';
PRINT '---------';

DECLARE @i TINYINT,
        @res INT;
SET @i = 0;
WHILE (@i < 255)
BEGIN
    IF (0 = @i)
    BEGIN
        PRINT 'ERRORLOG';
        EXEC @res = master.dbo.xp_readerrorlog;
    END;
    ELSE
    BEGIN
        PRINT 'ERRORLOG.' + CAST(@i AS VARCHAR(3));
        EXEC @res = master.dbo.xp_readerrorlog @i;
    END;
    IF (@@error <> 0)
       OR (@res <> 0)
        BREAK;
    SET @i = @i + 1;
END;