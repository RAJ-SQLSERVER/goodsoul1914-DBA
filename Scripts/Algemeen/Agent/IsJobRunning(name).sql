IF OBJECT_ID ('dbo.IsJobRunning') IS NULL
    EXEC ('CREATE FUNCTION dbo.IsJobRunning() RETURNS BIT BEGIN RETURN 1 END');
GO

CREATE OR ALTER FUNCTION dbo.IsJobRunning (@p_JobName VARCHAR(2000))
RETURNS BIT
AS
BEGIN
    DECLARE @returnValue BIT;
    SET @returnValue = 0;

    IF EXISTS (
        SELECT 1
        FROM msdb.dbo.sysjobactivity AS ja
        LEFT JOIN msdb.dbo.sysjobhistory AS jh
            ON ja.job_history_id = jh.instance_id
        JOIN msdb.dbo.sysjobs AS j
            ON ja.job_id = j.job_id
        JOIN msdb.dbo.sysjobsteps AS js
            ON ja.job_id = js.job_id
               AND ISNULL (ja.last_executed_step_id, 0) + 1 = js.step_id
        WHERE ja.session_id = (
            SELECT TOP (1) session_id
            FROM msdb.dbo.syssessions
            ORDER BY agent_start_date DESC
        )
              AND ja.start_execution_date IS NOT NULL
              AND ja.stop_execution_date IS NULL
              AND LTRIM (RTRIM (j.name)) = @p_JobName
    )
    BEGIN
        SET @returnValue = 1;
    END;

    RETURN @returnValue;
END;
GO

-- SELECT dbo.IsJobRunning('CW Labeling Staging')