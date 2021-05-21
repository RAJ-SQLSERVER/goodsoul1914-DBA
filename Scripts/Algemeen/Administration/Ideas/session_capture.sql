CREATE TABLE [dbo].[session_capture] (
    [date_captured]               [DATETIME]      NULL,
    [session_id]                  [SMALLINT]      NULL,
    [database_id]                 [SMALLINT]      NULL,
    [host_name]                   [NVARCHAR](256) NULL,
    [command]                     [NVARCHAR](32)  NULL,
    [sql_text]                    [XML]           NULL,
    [wait_type]                   [NVARCHAR](120) NULL,
    [wait_time]                   [INT]           NULL,
    [wait_resource]               [NVARCHAR](512) NULL,
    [last_wait_type]              [NVARCHAR](120) NULL,
    [total_elapsed_time]          [INT]           NULL,
    [blocking_session_id]         [INT]           NULL,
    [blocking_text]               [XML]           NULL,
    [start_time]                  [DATETIME]      NULL,
    [login_name]                  [NVARCHAR](256) NULL,
    [program_name]                [NVARCHAR](128) NULL,
    [login_time]                  [DATETIME]      NULL,
    [last_request_start_time]     [DATETIME]      NULL,
    [last_request_end_time]       [DATETIME]      NULL,
    [transaction_id]              [BIGINT]        NULL,
    [transaction_isolation_level] [SMALLINT]      NULL,
    [open_transaction_count]      [INT]           NULL,
    [totalReads]                  [BIGINT]        NULL,
    [totalWrites]                 [BIGINT]        NULL,
    [totalCPU]                    [INT]           NULL,
    [writes_in_tempdb]            [BIGINT]        NULL,
    [sql_plan]                    [XML]           NULL
) ON [PRIMARY];

CREATE CLUSTERED INDEX [IDX1]
    ON [dbo].[session_capture] (
    [date_captured] ASC,
    [session_id] ASC
)   ;

CREATE NONCLUSTERED INDEX [IDX2]
    ON [dbo].[session_capture] (
    [date_captured] ASC,
    [wait_time] ASC,
    [blocking_session_id] ASC
)   ;

CREATE NONCLUSTERED INDEX [IDX3]
    ON [dbo].[session_capture] (
    [database_id] ASC,
    [wait_time] ASC,
    [wait_type] ASC,
    [host_name] ASC
)   ;

GO

--3. Create the following 2 Stored Procedures in your utility DB:-
CREATE PROC [dbo].[SessionCapture]
    @TargetSizeMB BIGINT       = 4000,  -- Purge oldest 20% of data if SessionCapture table is larger than this size (MB)
    @Threshold    INT          = 15000, -- Alert on blocking that has wait-time greater than threshold (millisecs)
    @Recipients   VARCHAR(500) = NULL,  -- Who will receive blocking alert emails. Separate email addresses with ; Set to NULL to disable alerting
    @MailInterval INT          = 60     -- Minimum interval between alert emails (secs)

AS
    SET NOCOUNT ON;

    DECLARE @mailsubject VARCHAR(50),
            @tableHTML   NVARCHAR(MAX),
            @LastEmail   DATETIME;

    SET @LastEmail = GETDATE();

    -- Loop indefinitely every 10 seconds

    WHILE 1 = 1
    BEGIN

        BEGIN TRY

            INSERT DBA.dbo.session_capture
            SELECT GETDATE(),
                   x.session_id,
                   x.database_id,
                   x.host_name,
                   x.command,
                   (
                       SELECT text AS [text()]
                       FROM sys.dm_exec_sql_text(x.sql_handle)
                       FOR XML PATH(''), TYPE
                   ) AS sql_text,
                   x.wait_type,
                   x.wait_time,
                   x.wait_resource,
                   x.last_wait_type,
                   x.total_elapsed_time,
                   COALESCE(x.blocking_session_id, 0) AS blocking_session_id,
                   (
                       SELECT p.text
                       FROM (
                           SELECT MIN(sql_handle) AS sql_handle
                           FROM sys.dm_exec_requests r2
                           WHERE r2.session_id = x.blocking_session_id
                       ) AS r_blocking
                       CROSS APPLY (
                           SELECT text AS [text()]
                           FROM sys.dm_exec_sql_text(r_blocking.sql_handle)
                           FOR XML PATH(''), TYPE
                       ) p(text)
                   ) AS blocking_text,
                   x.start_time,
                   x.login_name,
                   x.program_name,
                   x.login_time,
                   x.last_request_start_time,
                   x.last_request_end_time,
                   x.transaction_id,
                   x.transaction_isolation_level,
                   x.open_transaction_count,
                   x.totalReads,
                   x.totalWrites,
                   x.totalCPU,
                   x.writes_in_tempdb,
                   (
                       SELECT query_plan FROM sys.dm_exec_query_plan(x.plan_handle)
                   ) AS sql_plan
            FROM (
                SELECT r.session_id,
                       r.database_id,
                       s.host_name,
                       s.login_name,
                       s.program_name,
                       s.login_time,
                       r.start_time,
                       r.sql_handle,
                       r.plan_handle,
                       r.blocking_session_id,
                       r.wait_type,
                       r.wait_resource,
                       r.wait_time,
                       r.last_wait_type,
                       r.total_elapsed_time,
                       r.transaction_id,
                       r.transaction_isolation_level,
                       r.open_transaction_count,
                       r.command,
                       s.last_request_start_time,
                       s.last_request_end_time,
                       SUM(r.reads) AS totalReads,
                       SUM(r.writes) AS totalWrites,
                       SUM(r.cpu_time) AS totalCPU,
                       SUM(tsu.user_objects_alloc_page_count + tsu.internal_objects_alloc_page_count) AS writes_in_tempdb
                FROM sys.dm_exec_requests r
                JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
                JOIN sys.dm_db_task_space_usage tsu ON s.session_id = tsu.session_id
                                                       AND r.request_id = tsu.request_id
                WHERE r.status IN ( 'running', 'runnable', 'suspended' )
                      AND r.session_id <> @@spid
                      AND r.session_id > 50
                GROUP BY r.session_id,
                         r.database_id,
                         s.host_name,
                         s.login_name,
                         s.login_time,
                         s.program_name,
                         r.start_time,
                         r.sql_handle,
                         r.plan_handle,
                         r.blocking_session_id,
                         r.wait_type,
                         r.wait_resource,
                         r.wait_time,
                         r.last_wait_type,
                         r.total_elapsed_time,
                         r.transaction_id,
                         r.transaction_isolation_level,
                         r.open_transaction_count,
                         r.command,
                         s.last_request_start_time,
                         s.last_request_end_time
            ) x;

            -- If email recipients set and blocking above threshold then email blocking alert
            -- But don’t send another email within @MailInterval
            IF @Recipients IS NOT NULL
               AND DATEDIFF(ss, @LastEmail, GETDATE()) > @MailInterval
            BEGIN

                IF EXISTS (
                    SELECT 1
                    FROM session_capture sc
                    WHERE sc.date_captured = (
                        SELECT MAX(date_captured) FROM session_capture
                    )
                          AND wait_time > @Threshold
                          AND blocking_session_id <> 0
                )
                BEGIN

                    SELECT @mailsubject = 'Prod Blocking Alert';

                    SET @tableHTML
                        = N'<H5 style="font-family:verdana"> Blocking and blocked sessions</H5>'
                          + N'<table width = 1300 border="1" style="font-family:verdana;font-size:60%">'
                          + N'<tr><th width = 100>Session_ID</th><th width = 100>Blocking_Session</th><th width = 100>Wait_Time</th><th width = 100>Hostname</th>'
                          + N'<th width = 100>NT_Username</th><th width = 100>DB_Name</th><th width = 500>Text</th>'
                          + N'<th width = 100>Current_Command</th><th width = 100>Sequence</th></tr>'
                          +

                    -- Query blocked and lead blocker session data

                    CAST((
                        SELECT DISTINCT
                               td = sp.spid,
                               '     ',
                               td = sp.blocked,
                               '     ',
                               td = sp.waittime,
                               '     ',
                               td = sp.hostname,
                               '     ',
                               td = sp.nt_username + ' ',
                               '     ',
                               td = sd.name,
                               '     ',
                               td = CAST(st.text AS NVARCHAR(500)),
                               '     ',
                               td = CASE
                                        WHEN sp.stmt_start > 0 THEN
                                            CASE
                                                WHEN sp.stmt_end > sp.stmt_start THEN
                                                    SUBSTRING(
                                                        st2.text,
                                                        1 + sp.stmt_start / 2,
                                                        1 + (sp.stmt_end / 2) - (sp.stmt_start / 2)
                                                    )
                                                ELSE
                                                    SUBSTRING(st2.text, 1 + sp.stmt_start / 2, LEN(st2.text))
                                            END
                                        ELSE
                                            ''
                                    END,
                               '     ',
                               td = CASE sp.waittime
                                        WHEN 0 THEN
                                            999999
                                        ELSE
                                            sp.waittime
                                    END,
                               '     '
                        FROM sys.sysprocesses (NOLOCK) sp
                        LEFT OUTER JOIN sys.sysprocesses (NOLOCK) s2 ON sp.spid = s2.blocked
                        INNER JOIN sys.sysdatabases (NOLOCK) sd ON sp.dbid = sd.dbid
                        LEFT OUTER JOIN sys.dm_exec_requests er ON sp.spid = er.session_id
                        CROSS APPLY (
                            SELECT text AS [text()]
                            FROM sys.dm_exec_sql_text(sp.sql_handle)
                        ) st(text)
                        CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) st2
                        WHERE (
                            (
                                  s2.spid IS NOT NULL
                                  AND sp.blocked = 0
                              )
                            OR sp.blocked <> 0
                        )
                              AND sp.spid > 50
                              AND (
                                  s2.ecid IS NULL
                                  OR s2.ecid = 0
                              )
                        ORDER BY CASE sp.waittime
                                     WHEN 0 THEN
                                         999999
                                     ELSE
                                         sp.waittime
                                 END DESC
                        FOR XML PATH('tr'), TYPE
                    ) AS NVARCHAR(MAX)) + N'</table>';

                    EXEC msdb.dbo.sp_send_dbmail @recipients = @Recipients,
                                                 @subject = @mailsubject,
                                                 @body = @tableHTML,
                                                 @body_format = 'HTML';

                    SET @LastEmail = GETDATE();

                END;

            END;

            -- Check table size, if > @TargetSizeMB then purge old data
            IF (
                SELECT SUM(reserved_page_count)
                FROM sys.dm_db_partition_stats
                WHERE object_id = OBJECT_ID('session_capture')
            ) > @TargetSizeMB * 1024 * 1024 / 8192
            BEGIN

                -- shrink table size to 80% of @TargetSizeMB

                DECLARE @totalrows  BIGINT,
                        @totalpages BIGINT;

                SELECT @totalpages = SUM(reserved_page_count),
                       @totalrows = SUM(CASE
                                            WHEN (index_id < 2) THEN
                                                row_count
                                            ELSE
                                                0
                                        END
                                    )
                FROM sys.dm_db_partition_stats ps
                WHERE object_id = OBJECT_ID('session_capture');

                -- Calculate how many rows to delete to be left with 80% of TargetSize
                SELECT @totalrows = @totalrows - (@totalrows * @TargetSizeMB * 1024 * 1024 / 8192 * 0.8 / @totalpages);

                DELETE sc
                FROM (
                    SELECT TOP (@totalrows)
                           *
                    FROM session_capture
                    ORDER BY date_captured
                ) sc;

            END;

            WAITFOR DELAY '00:00:10';

        END TRY
        BEGIN CATCH

            WAITFOR DELAY '00:00:10';

        END CATCH;

    END;

GO


CREATE PROC [dbo].[SessionCapturePurge] @RetentionDays INT = 14
AS
    DELETE FROM dbo.session_capture
    WHERE date_captured < DATEADD(dd, -@RetentionDays, GETDATE());

GO


USE [master];
GO

CREATE PROCEDURE [dbo].[SessionCapture]
AS
    EXEC DBA.dbo.SessionCapture @TargetSizeMB = 4000,
                                @Threshold = 20000,
                                @Recipients = 'mboomaars@gmail.com',
                                @MailInterval = 900;

GO


-- 4. Mark the master.dbo.SessionCapture as a startup proc, by executing the following 2 SPs:-
EXEC sp_configure 'scan for startup procs', 1;
RECONFIGURE WITH OVERRIDE;

EXEC sp_procoption 'SessionCapture', 'startup', 1;