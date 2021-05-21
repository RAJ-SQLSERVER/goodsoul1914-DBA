--Query to find what's is running on server
-------------------------------------------------------------------------------

SELECT      s.session_id,
            DB_NAME(r.database_id) AS "DBName",
            r.percent_complete,
            s.status AS "session_status",
            r.status AS "request_status",
            r.command AS "running_command",
            r.wait_type AS "request_wait_type",
            wait_resource AS "request_wait_resource",
            r.start_time AS "request_start_time",
            CAST(DATEDIFF(s, r.start_time, GETDATE()) / 3600 AS VARCHAR) + ' hour(s), '
            + CAST((DATEDIFF(s, r.start_time, GETDATE()) % 3600) / 60 AS VARCHAR) + 'min, '
            + CAST(DATEDIFF(s, r.start_time, GETDATE()) % 60 AS VARCHAR) + ' sec' AS "request_running_time",
            CAST(r.estimated_completion_time / 3600000 AS VARCHAR) + ' hour(s), '
            + CAST((r.estimated_completion_time % 3600000) / 60000 AS VARCHAR) + 'min, '
            + CAST((r.estimated_completion_time % 60000) / 1000 AS VARCHAR) + ' sec' AS "est_time_to_go",
            DATEADD(SECOND, r.estimated_completion_time / 1000, GETDATE()) AS "est_completion_time",
            r.blocking_session_id AS "blocked by",
            SUBSTRING(   st.text,
                         r.statement_start_offset / 2 + 1,
                         (CASE r.statement_end_offset
                              WHEN -1 THEN
                                  DATALENGTH(st.text)
                              ELSE
                                  r.statement_end_offset
                          END - r.statement_start_offset
                         ) / 2 + 1
                     ) AS "statement_text",
            st.text AS "Batch_Text",
            r.wait_time / 1000.0 AS "WaitTime(S)",
            r.total_elapsed_time / 1000.0 AS "total_elapsed_time(S)",
            s.login_time,
            s.host_name,
            s.host_process_id,
            s.client_interface_name,
            s.login_name,
            s.memory_usage,
            s.writes AS "session_writes",
            r.writes AS "request_writes",
            s.logical_reads AS "session_logical_reads",
            r.logical_reads AS "request_logical_reads",
            s.is_user_process,
            s.row_count AS "session_row_count",
            r.row_count AS "request_row_count",
            r.sql_handle,
            r.plan_handle,
            r.open_transaction_count,
            r.cpu_time AS "request_cpu_time",
            CASE
                WHEN (CAST(r.granted_query_memory AS NUMERIC(20, 2)) * 8) / 1024 / 1024 >= 1.0 THEN
                    CAST((CAST(r.granted_query_memory AS NUMERIC(20, 2)) * 8) / 1024 / 1024 AS VARCHAR(23)) + ' GB'
                WHEN (CAST(r.granted_query_memory AS NUMERIC(20, 2)) * 8) / 1024 >= 1.0 THEN
                    CAST((CAST(r.granted_query_memory AS NUMERIC(20, 2)) * 8) / 1024 AS VARCHAR(23)) + ' MB'
                ELSE
                    CAST(CAST(r.granted_query_memory AS NUMERIC(20, 2)) * 8 AS VARCHAR(23)) + ' KB'
            END AS "granted_query_memory",
            r.query_hash,
            r.query_plan_hash,
            bqp.query_plan AS "BatchQueryPlan",
            CAST(sqp.query_plan AS XML) AS "SqlQueryPlan",
            CASE
                WHEN s.program_name LIKE 'SQLAgent - TSQL JobStep %' THEN
                (
                    SELECT     TOP 1
                               'SQL Job = ' + j.name
                    FROM       msdb.dbo.sysjobs (NOLOCK) AS j
                    INNER JOIN msdb.dbo.sysjobsteps (NOLOCK) AS js
                        ON j.job_id = js.job_id
                    WHERE      RIGHT(CAST(js.job_id AS NVARCHAR(50)), 10) = RIGHT(SUBSTRING(s.program_name, 30, 34), 10)
                )
                ELSE
                    s.program_name
            END AS "program_name",
            CASE
                WHEN s.program_name LIKE 'SQLAgent - TSQL JobStep %' THEN
                    1
                ELSE
                    2
            END AS "IsSqlJob"
FROM        sys.dm_exec_sessions AS s
LEFT JOIN   sys.dm_exec_requests AS r
    ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS bqp
OUTER APPLY sys.dm_exec_text_query_plan(r.plan_handle, r.statement_start_offset, r.statement_end_offset) AS sqp
WHERE       CASE
                WHEN s.session_id != @@SPID
                     AND
                     (
                         s.session_id > 50
                         AND
                         (
                             r.session_id IS NOT NULL -- either some part of session has active request
                             OR ISNULL(open_resultset_count, 0) > 0 -- some result is open
                         )
                         OR s.session_id IN
                            (
                                SELECT ri.blocking_session_id FROM sys.dm_exec_requests AS ri
                            )
                     ) -- either take user sid, or system sid blocking user sid
    THEN
                    1
                WHEN NOT (
                             s.session_id != @@SPID
                             AND
                             (
                                 s.session_id > 50
                                 AND
                                 (
                                     r.session_id IS NOT NULL -- either some part of session has active request
                                     OR ISNULL(open_resultset_count, 0) > 0 -- some result is open
                                 )
                                 OR s.session_id IN
                                    (
                                        SELECT ri.blocking_session_id FROM sys.dm_exec_requests AS ri
                                    )
                             )
                         ) THEN
                    0
                ELSE
                    NULL
            END = 1
ORDER BY    IsSqlJob,
            session_id;


--set ansi_nulls on;
--go
--set quoted_identifier on;
--go
--create table dbo.WhatIsRunning
--(
--	session_id              smallint not null, 
--	DBName                  nvarchar(128) null, 
--	percent_complete        real null, 
--	session_status          nvarchar(30) not null, 
--	request_status          nvarchar(30) null, 
--	running_command         nvarchar(16) null, 
--	request_wait_type       nvarchar(60) null, 
--	request_wait_resource   nvarchar(256) null, 
--	request_start_time      datetime null, 
--	request_running_time    varchar(109) null, 
--	est_time_to_go          varchar(109) null, 
--	est_completion_time     datetime null, 
--	[blocked by]            smallint null, 
--	statement_text          nvarchar(max) null, 
--	Batch_Text              nvarchar(max) null, 
--	[WaitTime(S)]           numeric(17, 6) null, 
--	[total_elapsed_time(S)] numeric(17, 6) null, 
--	login_time              datetime not null, 
--	host_name               nvarchar(128) null, 
--	host_process_id         int null, 
--	client_interface_name   nvarchar(32) null, 
--	login_name              nvarchar(128) not null, 
--	memory_usage            int not null, 
--	session_writes          bigint not null, 
--	request_writes          bigint null, 
--	session_logical_reads   bigint not null, 
--	request_logical_reads   bigint null, 
--	is_user_process         bit not null, 
--	session_row_count       bigint not null, 
--	request_row_count       bigint null, 
--	sql_handle              varbinary(64) null, 
--	plan_handle             varbinary(64) null, 
--	open_transaction_count  int null, 
--	request_cpu_time        int null, 
--	granted_query_memory    varchar(26) null, 
--	query_hash              binary(8) null, 
--	query_plan_hash         binary(8) null, 
--	BatchQueryPlan          xml null, 
--	SqlQueryPlan            xml null, 
--	program_name            nvarchar(138) null, 
--	IsSqlJob                int not null, 
--	Source                  varchar(100) null, 
--	CollectionTime          datetime not null) 
--on [PRIMARY] textimage_on [PRIMARY];
--go