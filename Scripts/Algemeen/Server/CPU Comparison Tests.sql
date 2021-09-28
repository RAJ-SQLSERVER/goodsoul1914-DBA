CREATE OR ALTER PROCEDURE #p
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i    BIGINT    = 0,
            @time DATETIME2 = SYSUTCDATETIME ();

    WHILE @i < 1000000
    BEGIN
        SET @i = @i + 1;
    END;

    SELECT cpu_time,
           DATEDIFF (MILLISECOND, @time, SYSUTCDATETIME ()) AS "elapsed_time"
    FROM sys.dm_exec_requests
    WHERE session_id = @@SPID;
END;
GO

EXEC #p;