-- Insight into the SQL Server Agent Job Schedules
---------------------------------------------------------------------------------------------------

SELECT [JobName] = [jobs].[name],
       [Category] = [categories].[name],
       [Owner] = SUSER_SNAME([jobs].[owner_sid]),
       [Enabled] = CASE [jobs].[enabled]
                       WHEN 1 THEN
                           'Yes'
                       ELSE
                           'No'
                   END,
       [Scheduled] = CASE [schedule].[enabled]
                         WHEN 1 THEN
                             'Yes'
                         ELSE
                             'No'
                     END,
       [Description] = [jobs].[description],
       [Occurs] = CASE [schedule].[freq_type]
                      WHEN 1 THEN
                          'Once'
                      WHEN 4 THEN
                          'Daily'
                      WHEN 8 THEN
                          'Weekly'
                      WHEN 16 THEN
                          'Monthly'
                      WHEN 32 THEN
                          'Monthly relative'
                      WHEN 64 THEN
                          'When SQL Server Agent starts'
                      WHEN 128 THEN
                          'Start whenever the CPU(s) become idle'
                      ELSE
                          ''
                  END,
       [Occurs_detail] = CASE [schedule].[freq_type]
                             WHEN 1 THEN
                                 'O'
                             WHEN 4 THEN
                                 'Every ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' day(s)'
                             WHEN 8 THEN
                                 'Every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' weeks(s) on '
                                 + LEFT(CASE
                                            WHEN [schedule].[freq_interval] & 1 = 1 THEN
                                                'Sunday, '
                                            ELSE
                                                ''
                                        END + CASE
                                                  WHEN [schedule].[freq_interval] & 2 = 2 THEN
                                                      'Monday, '
                                                  ELSE
                                                      ''
                                              END + CASE
                                                        WHEN [schedule].[freq_interval] & 4 = 4 THEN
                                                            'Tuesday, '
                                                        ELSE
                                                            ''
                                                    END + CASE
                                                              WHEN [schedule].[freq_interval] & 8 = 8 THEN
                                                                  'Wednesday, '
                                                              ELSE
                                                                  ''
                                                          END + CASE
                                                                    WHEN [schedule].[freq_interval] & 16 = 16 THEN
                                                                        'Thursday, '
                                                                    ELSE
                                                                        ''
                                                                END
                                        + CASE
                                              WHEN [schedule].[freq_interval] & 32 = 32 THEN
                                                  'Friday, '
                                              ELSE
                                                  ''
                                          END + CASE
                                                    WHEN [schedule].[freq_interval] & 64 = 64 THEN
                                                        'Saturday, '
                                                    ELSE
                                                        ''
                                                END, LEN(   CASE
                                                                WHEN [schedule].[freq_interval] & 1 = 1 THEN
                                                                    'Sunday, '
                                                                ELSE
                                                                    ''
                                                            END + CASE
                                                                      WHEN [schedule].[freq_interval] & 2 = 2 THEN
                                                                          'Monday, '
                                                                      ELSE
                                                                          ''
                                                                  END
                                                            + CASE
                                                                  WHEN [schedule].[freq_interval] & 4 = 4 THEN
                                                                      'Tuesday, '
                                                                  ELSE
                                                                      ''
                                                              END + CASE
                                                                        WHEN [schedule].[freq_interval] & 8 = 8 THEN
                                                                            'Wednesday, '
                                                                        ELSE
                                                                            ''
                                                                    END
                                                            + CASE
                                                                  WHEN [schedule].[freq_interval] & 16 = 16 THEN
                                                                      'Thursday, '
                                                                  ELSE
                                                                      ''
                                                              END + CASE
                                                                        WHEN [schedule].[freq_interval] & 32 = 32 THEN
                                                                            'Friday, '
                                                                        ELSE
                                                                            ''
                                                                    END
                                                            + CASE
                                                                  WHEN [schedule].[freq_interval] & 64 = 64 THEN
                                                                      'Saturday, '
                                                                  ELSE
                                                                      ''
                                                              END
                                                        ) - 1)
                             WHEN 16 THEN
                                 'Day ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' of every '
                                 + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)'
                             WHEN 32 THEN
                                 'The ' + CASE [schedule].[freq_relative_interval]
                                              WHEN 1 THEN
                                                  'First'
                                              WHEN 2 THEN
                                                  'Second'
                                              WHEN 4 THEN
                                                  'Third'
                                              WHEN 8 THEN
                                                  'Fourth'
                                              WHEN 16 THEN
                                                  'Last'
                                          END + CASE [schedule].[freq_interval]
                                                    WHEN 1 THEN
                                                        ' Sunday'
                                                    WHEN 2 THEN
                                                        ' Monday'
                                                    WHEN 3 THEN
                                                        ' Tuesday'
                                                    WHEN 4 THEN
                                                        ' Wednesday'
                                                    WHEN 5 THEN
                                                        ' Thursday'
                                                    WHEN 6 THEN
                                                        ' Friday'
                                                    WHEN 7 THEN
                                                        ' Saturday'
                                                    WHEN 8 THEN
                                                        ' Day'
                                                    WHEN 9 THEN
                                                        ' Weekday'
                                                    WHEN 10 THEN
                                                        ' Weekend Day'
                                                END + ' of every '
                                 + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)'
                             ELSE
                                 ''
                         END,
       [Frequency] = CASE [schedule].[freq_subday_type]
                         WHEN 1 THEN
                             'Occurs once at '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    )
                         WHEN 2 THEN
                             'Occurs every ' + CONVERT(VARCHAR, [schedule].[freq_subday_interval])
                             + ' Seconds(s) between '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    ) + ' and '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    )
                         WHEN 4 THEN
                             'Occurs every ' + CONVERT(VARCHAR, [schedule].[freq_subday_interval])
                             + ' Minute(s) between '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    ) + ' and '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    )
                         WHEN 8 THEN
                             'Occurs every ' + CONVERT(VARCHAR, [schedule].[freq_subday_interval])
                             + ' Hour(s) between '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    ) + ' and '
                             + STUFF(
                                        STUFF(
                                                 RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6),
                                                 5,
                                                 0,
                                                 ':'
                                             ),
                                        3,
                                        0,
                                        ':'
                                    )
                         ELSE
                             ''
                     END,
       [AvgDurationInSec] = CONVERT(DECIMAL(18, 2), [jobhistory].[AvgDuration]),
       [Next_Run_Date] = CASE [jobschedule].[next_run_date]
                             WHEN 0 THEN
                                 CONVERT(DATETIME, '1900/1/1')
                             ELSE
                                 CONVERT(
                                            DATETIME,
                                            CONVERT(CHAR(8), [jobschedule].[next_run_date], 112) + ' '
                                            + STUFF(
                                                       STUFF(
                                                                RIGHT('000000'
                                                                      + CONVERT(
                                                                                   VARCHAR(8),
                                                                                   [jobschedule].[next_run_time]
                                                                               ), 6),
                                                                5,
                                                                0,
                                                                ':'
                                                            ),
                                                       3,
                                                       0,
                                                       ':'
                                                   )
                                        )
                         END
FROM [msdb].[dbo].[sysjobs] AS [jobs] WITH (NOLOCK)
    LEFT OUTER JOIN [msdb].[dbo].[sysjobschedules] AS [jobschedule] WITH (NOLOCK)
        ON [jobs].[job_id] = [jobschedule].[job_id]
    LEFT OUTER JOIN [msdb].[dbo].[sysschedules] AS [schedule] WITH (NOLOCK)
        ON [jobschedule].[schedule_id] = [schedule].[schedule_id]
    INNER JOIN [msdb].[dbo].[syscategories] [categories] WITH (NOLOCK)
        ON [jobs].[category_id] = [categories].[category_id]
    LEFT OUTER JOIN
    (
        SELECT [job_id],
               [AvgDuration] = (SUM((([run_duration] / 10000 * 3600) + (([run_duration] % 10000) / 100 * 60)
                                     + ([run_duration] % 10000) % 100
                                    )
                                   ) * 1.0
                               ) / COUNT([job_id])
        FROM [msdb].[dbo].[sysjobhistory] WITH (NOLOCK)
        WHERE [step_id] = 0
        GROUP BY [job_id]
    ) AS [jobhistory]
        ON [jobhistory].[job_id] = [jobs].[job_id];
GO


-- List of jobs with name, steps, last run date/time, next_run_date/time
---------------------------------------------------------------------------------------------------
SELECT name,
       CONVERT(VARCHAR(16), date_created, 120) AS date_created,
       sysjobsteps.step_id,
       sysjobsteps.step_name,
       LEFT(CAST(sysjobsteps.last_run_date AS VARCHAR), 4) + '-'
       + SUBSTRING(CAST(sysjobsteps.last_run_date AS VARCHAR), 5, 2) + '-'
       + SUBSTRING(CAST(sysjobsteps.last_run_date AS VARCHAR), 7, 2) AS last_run_date,
       CASE
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 6 THEN
               SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 2) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 3, 2) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 5, 2)
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 5 THEN
               '0' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 1) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 2, 2) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 4, 2)
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 4 THEN
               '00:' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 2) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 3, 2)
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 3 THEN
               '00:' + '0' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 1) + ':'
               + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 2, 2)
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 2 THEN
               '00:00:' + CAST(sysjobsteps.last_run_time AS VARCHAR)
           WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 1 THEN
               '00:00:' + '0' + CAST(sysjobsteps.last_run_time AS VARCHAR)
       END AS last_run_time,
       LEFT(CAST(sysjobschedules.next_run_date AS VARCHAR), 4) + '-'
       + SUBSTRING(CAST(sysjobschedules.next_run_date AS VARCHAR), 5, 2) + '-'
       + SUBSTRING(CAST(sysjobschedules.next_run_date AS VARCHAR), 7, 2) AS next_run_date,
       CASE
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 6 THEN
               SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 2) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 3, 2)
               + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 5, 2)
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 5 THEN
               '0' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 1) + ':'
               + SUBSTRING(CAST(next_run_time AS VARCHAR), 2, 2) + ':'
               + SUBSTRING(CAST(next_run_time AS VARCHAR), 4, 2)
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 4 THEN
               '00:' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 2) + ':'
               + SUBSTRING(CAST(next_run_time AS VARCHAR), 3, 2)
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 3 THEN
               '00:' + '0' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 1) + ':'
               + SUBSTRING(CAST(next_run_time AS VARCHAR), 2, 2)
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 2 THEN
               '00:00:' + CAST(next_run_time AS VARCHAR)
           WHEN LEN(CAST(next_run_time AS VARCHAR)) = 1 THEN
               '00:00:' + '0' + CAST(next_run_time AS VARCHAR)
       END AS next_run_time
FROM msdb.dbo.sysjobs
    LEFT JOIN msdb.dbo.sysjobschedules
        ON sysjobs.job_id = sysjobschedules.job_id
    INNER JOIN msdb.dbo.sysjobsteps
        ON sysjobs.job_id = sysjobsteps.job_id
ORDER BY sysjobs.job_id,
         sysjobsteps.step_id;
GO


-- Overview of jobs and their outcome
---------------------------------------------------------------------------------------------------
WITH sess
AS (SELECT session_id
    FROM msdb.dbo.syssessions AS SESS
    WHERE SESS.agent_start_date =
    (
        SELECT MAX(agent_start_date) FROM msdb.dbo.syssessions
    )),
     hist
AS (SELECT JOBHIST.job_id,
           MAX(JOBHIST.run_date) AS LastExecutionDate,
           SUM(   CASE
                      WHEN JOBHIST.run_status = 1 THEN
                          1
                      ELSE
                          0
                  END
              ) AS RunsSuccessfull,
           SUM(   CASE
                      WHEN JOBHIST.run_status = 0 THEN
                          1
                      ELSE
                          0
                  END
              ) AS RunsError
    FROM msdb.dbo.sysjobhistory AS JOBHIST
    WHERE JOBHIST.step_id = 0
    GROUP BY JOBHIST.job_id),
     lasthist
AS (SELECT LASTHIST.job_id,
           LASTHIST.run_status AS LastRunStatus
    FROM msdb.dbo.sysjobhistory AS LASTHIST
    WHERE LASTHIST.instance_id =
    (
        SELECT MAX(SUB.instance_id) AS MaxId
        FROM msdb.dbo.sysjobhistory AS SUB
        WHERE SUB.job_id = LASTHIST.job_id
    ))
SELECT JOB.name AS JobName,
       JOB.description AS JobDescription,
       CAT.name AS Category,
       JOB.enabled AS IsJobEnabled,
       ISNULL(SCH.enabled, 0) AS IsScheduled,
       (
           SELECT COUNT(*)
           FROM msdb.dbo.sysjobsteps AS STP
           WHERE STP.job_id = JOB.job_id
       ) AS StepsCnt,
       hist.RunsSuccessfull,
       hist.RunsError,
       CASE ISNULL(   LASTACT.run_status,
                      CASE
                          WHEN SJA.start_execution_date IS NULL THEN
                              -2
                          ELSE
                              -1
                      END
                  )
           WHEN -2 THEN
               'No recent activity'
           WHEN -1 THEN
               'Is running'
           WHEN 0 THEN
               'Failed'
           WHEN 1 THEN
               'Succeeded'
           WHEN 2 THEN
               'Retry'
           WHEN 3 THEN
               'Canceled'
           WHEN 4 THEN
               'In progress'
           ELSE
               'Unkown'
       END AS LastActivityStatus,
       CASE lasthist.LastRunStatus
           WHEN 0 THEN
               'Failed'
           WHEN 1 THEN
               'Succeeded'
           WHEN 2 THEN
               'Retry'
           WHEN 3 THEN
               'Canceled'
           WHEN 4 THEN
               'In progress'
           ELSE
               'Unkown'
       END AS LastRunStatus,
       hist.LastExecutionDate,
       JSD.next_run_date AS NextScheduledRunDate
FROM msdb.dbo.sysjobs AS JOB
    INNER JOIN msdb.dbo.syscategories AS CAT
        ON JOB.category_id = CAT.category_id
    LEFT JOIN hist
        ON JOB.job_id = hist.job_id
    LEFT JOIN msdb.dbo.sysjobschedules AS JSD
        ON JOB.job_id = JSD.job_id
    LEFT JOIN msdb.dbo.sysschedules AS SCH
        ON JSD.schedule_id = SCH.schedule_id
    CROSS APPLY sess
    INNER JOIN msdb.dbo.sysjobactivity AS SJA
        ON JOB.job_id = SJA.job_id
           AND sess.session_id = SJA.session_id
    LEFT JOIN msdb.dbo.sysjobhistory AS LASTACT
        ON SJA.job_history_id = LASTACT.instance_id
    LEFT JOIN lasthist
        ON JOB.job_id = lasthist.job_id
ORDER BY JobName;
GO


-- Jobs overview
---------------------------------------------------------------------------------------------------
SELECT sj.name AS [Job Name],
       sj.description AS [Job Description],
       SUSER_SNAME(sj.owner_sid) AS [Job Owner],
       sj.date_created AS [Date Created],
       sj.enabled AS [Job Enabled],
       sj.notify_email_operator_id,
       sj.notify_level_email,
       sc.name AS CategoryName,
       s.enabled AS [Sched Enabled],
       js.next_run_date,
       js.next_run_time
FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
    INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK)
        ON sj.category_id = sc.category_id
    LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK)
        ON sj.job_id = js.job_id
    LEFT OUTER JOIN msdb.dbo.sysschedules AS s WITH (NOLOCK)
        ON js.schedule_id = s.schedule_id
ORDER BY sj.name
OPTION (RECOMPILE);