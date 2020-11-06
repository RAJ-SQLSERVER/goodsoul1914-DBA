/*
Original link: https://sqlundercover.com/2017/06/16/undercover-toolbox-sp_failedjobs-the-quick-way-to-check-for-failed-agent-jobs
*/

USE [DBA];
GO

/************************************************
Author: Adrian Buckman
Date: 16/06/2017
SQLUnderCover.com
************************************************/

CREATE PROCEDURE usp_FailedJobs
(
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
)
AS
BEGIN

    IF @FromDate IS NULL
    BEGIN
        SET @FromDate = DATEADD(DAY, -7, GETDATE());
    END;
    IF @ToDate IS NULL
    BEGIN
        SET @ToDate = GETDATE();
    END;

    SELECT Jobs.name,
           JobHistory.step_id,
           JobHistory.FailedRunDate,
           CAST(JobHistory.LastError AS VARCHAR(250)) AS LastError
    FROM msdb.dbo.sysjobs Jobs
        CROSS APPLY
    (
        SELECT TOP (1)
               JobHistory.step_id,
               JobHistory.run_date,
               CASE JobHistory.run_date
                   WHEN 0 THEN
                       NULL
                   ELSE
                       CONVERT(
                                  DATETIME,
                                  STUFF(STUFF(CAST(JobHistory.run_date AS NCHAR(8)), 7, 0, '-'), 5, 0, '-') + N' '
                                  + STUFF(
                                             STUFF(
                                                      SUBSTRING(CAST(1000000 + JobHistory.run_time AS NCHAR(7)), 2, 6),
                                                      5,
                                                      0,
                                                      ':'
                                                  ),
                                             3,
                                             0,
                                             ':'
                                         ),
                                  120
                              )
               END AS [FailedRunDate],
               [message] AS LastError
        FROM msdb.dbo.sysjobhistory JobHistory
        WHERE run_status = 0
              AND Jobs.job_id = JobHistory.job_id
        ORDER BY [FailedRunDate] DESC,
                 step_id DESC
    ) JobHistory
    WHERE Jobs.enabled = 1
          AND JobHistory.FailedRunDate >= @FromDate
          AND JobHistory.FailedRunDate <= @ToDate
          AND NOT EXISTS
    (
        SELECT [LastSuccessfulrunDate]
        FROM
        (
            SELECT CASE JobHistory.run_date
                       WHEN 0 THEN
                           NULL
                       ELSE
                           CONVERT(
                                      DATETIME,
                                      STUFF(STUFF(CAST(JobHistory.run_date AS NCHAR(8)), 7, 0, '-'), 5, 0, '-') + N' '
                                      + STUFF(
                                                 STUFF(
                                                          SUBSTRING(
                                                                       CAST(1000000 + JobHistory.run_time AS NCHAR(7)),
                                                                       2,
                                                                       6
                                                                   ),
                                                          5,
                                                          0,
                                                          ':'
                                                      ),
                                                 3,
                                                 0,
                                                 ':'
                                             ),
                                      120
                                  )
                   END AS [LastSuccessfulrunDate]
            FROM msdb.dbo.sysjobhistory JobHistory
            WHERE run_status = 1
                  AND Jobs.job_id = JobHistory.job_id
        ) JobHistory2
        WHERE JobHistory2.[LastSuccessfulrunDate] > JobHistory.[FailedRunDate]
    )
          AND NOT EXISTS
    (
        SELECT session_id
        FROM msdb.dbo.sysjobactivity JobActivity
        WHERE Jobs.job_id = JobActivity.job_id
              AND stop_execution_date IS NULL
              AND session_id =
              (
                  SELECT MAX(session_id)
                  FROM msdb.dbo.sysjobactivity JobActivity
                  WHERE Jobs.job_id = JobActivity.job_id
              )
    )
          AND Jobs.name <> 'syspolicy_purge_history'
    ORDER BY name;

END;
