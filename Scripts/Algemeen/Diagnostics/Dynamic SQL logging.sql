-------------------------------------------------------------------------------
-- Dynamic SQL logging
-------------------------------------------------------------------------------

-- Logging table
DROP TABLE IF EXISTS dbo.logger;
CREATE TABLE dbo.logger
(
    run_hash UNIQUEIDENTIFIER,
    run_date DATETIME,
    user_name sysname,
    cpu_time_ms DECIMAL(18, 2),
    total_elapsed_time_ms DECIMAL(18, 2),
    physical_reads_mb DECIMAL(18, 2),
    logical_reads_mb DECIMAL(18, 2),
    writes_mb DECIMAL(18, 2),
    statement_text NVARCHAR(MAX),
    execution_text NVARCHAR(MAX),
    query_plan XML,
    is_final BIT
        DEFAULT 0,
    CONSTRAINT loggerino
        PRIMARY KEY (run_hash)
);
GO


-- Logger.sql
CREATE OR ALTER PROCEDURE dbo.logging
(
    @spid INT,
    @sql NVARCHAR(MAX),
    @query_plan XML,
    @guid_in UNIQUEIDENTIFIER,
    @guid_out UNIQUEIDENTIFIER OUTPUT
)
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

    /*variables for the variable gods*/
    DECLARE @run_hash UNIQUEIDENTIFIER = NEWID();
    DECLARE @cpu_time DECIMAL(18, 2);
    DECLARE @total_elapsed_time DECIMAL(18, 2);
    DECLARE @reads DECIMAL(18, 2);
    DECLARE @writes DECIMAL(18, 2);
    DECLARE @logical_reads DECIMAL(18, 2);

    /*first pass to collect initial metrics*/
    IF @guid_in IS NULL
    BEGIN
        INSERT dbo.logger (run_hash,
                           run_date,
                           user_name,
                           cpu_time_ms,
                           total_elapsed_time_ms,
                           physical_reads_mb,
                           logical_reads_mb,
                           writes_mb,
                           statement_text,
                           execution_text)
        SELECT @run_hash,
               SYSDATETIME(),
               SUSER_NAME(),
               cpu_time,
               total_elapsed_time,
               ((reads - logical_reads) * 8.) / 1024. AS "physical_reads_mb",
               (logical_reads * 8.) / 1024. AS "logical_reads_mb",
               (writes * 8.) / 1024. AS "writes_mb",
               @sql AS "statement_text",
               (
                   SELECT deib.event_info FROM sys.dm_exec_input_buffer(@spid, 0) AS deib
               ) AS "execution_text"
        FROM   sys.dm_exec_requests
        WHERE  session_id = @spid
        OPTION (RECOMPILE);

        SET @guid_out = @run_hash;
        RETURN;
    END;

    /*second pass to update metrics with final values*/
    IF @guid_in IS NOT NULL
    BEGIN
        UPDATE     l
        SET        l.cpu_time_ms = r.cpu_time - l.cpu_time_ms,
                   l.total_elapsed_time_ms = r.total_elapsed_time - l.total_elapsed_time_ms,
                   l.physical_reads_mb = (((reads - logical_reads) * 8.) / 1024.) - l.physical_reads_mb,
                   l.logical_reads_mb = ((r.logical_reads * 8.) / 1024.) - l.logical_reads_mb,
                   l.writes_mb = ((r.writes * 8.) / 1024.) - l.writes_mb,
                   l.query_plan = @query_plan,
                   l.is_final = CONVERT(BIT, 1)
        FROM       dbo.logger AS l
        CROSS JOIN sys.dm_exec_requests AS r
        WHERE      l.run_hash = @guid_in
                   AND r.session_id = @spid
        OPTION (RECOMPILE);
        RETURN;
    END;
END;
GO



DECLARE @i INT = 50;
DECLARE @sql NVARCHAR(MAX) = N'';
SET @sql += N'
	SELECT COUNT_BIG(*) AS records /* dbo.logging_test */
	FROM dbo.Badges AS b
	JOIN dbo.Users AS u ON b.UserId = u.Id
	WHERE u.Reputation > @i;

	SELECT @query_plan = detqp.query_plan
	FROM sys.dm_exec_requests AS der
	CROSS APPLY sys.dm_exec_text_query_plan(der.plan_handle, 0, -1) AS detqp
	WHERE der.session_id = @@SPID;';

DECLARE @guid UNIQUEIDENTIFIER;
DECLARE @query_plan XML;

EXEC dbo.logging @spid = @@SPID,
                 @sql = @sql,
                 @query_plan = NULL,
                 @guid_in = NULL,
                 @guid_out = @guid OUTPUT;

EXEC sys.sp_executesql @sql,
                       N'@i INT, @query_plan XML OUTPUT',
                       @i,
                       @query_plan = @query_plan OUTPUT;

SET @query_plan.modify('
declare namespace p = "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
delete //p:StmtSimple[2]');

EXEC dbo.logging @spid = @@SPID,
                 @sql = @sql,
                 @query_plan = @query_plan,
                 @guid_in = @guid,
                 @guid_out = NULL;
GO


SELECT   *
FROM     dbo.logger AS l
ORDER BY l.run_date;
GO
