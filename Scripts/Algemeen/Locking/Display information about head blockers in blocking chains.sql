/*========================================================================================================================

Description:	Display information about head blockers in blocking chains
Scope:			Instance
Author:			Guy Glantser
Created:		02/09/2020
Last Updated:	02/09/2020
Notes:			Displays information about the head blocker at the task level.

=========================================================================================================================*/

WITH BlockingChains (SessionId, TaskAddress, WaitTime_Milliseconds, ChainLevel, HeadBlockerSessionId,
                     HeadBlockerTaskAddress
) AS
(
    SELECT Sessions.session_id AS "SessionId",
           Tasks.task_address AS "TaskAddress",
           CAST(NULL AS BIGINT) AS "WaitTime_Milliseconds",
           CAST(0 AS INT) AS "ChainLevel",
           Sessions.session_id AS "HeadBlockerSessionId",
           Tasks.task_address AS "HeadBlockerTaskAddress"
    FROM sys.dm_exec_sessions AS Sessions
    LEFT OUTER JOIN sys.dm_exec_requests AS Requests
        ON Sessions.session_id = Requests.session_id
    LEFT OUTER JOIN sys.dm_os_tasks AS Tasks
        ON Requests.session_id = Tasks.session_id
    WHERE Requests.blocking_session_id IS NULL
          OR Requests.blocking_session_id = 0
    UNION ALL
    SELECT BlockedTasks.session_id AS "SessionId",
           BlockedTasks.waiting_task_address AS "TaskAddress",
           BlockedTasks.wait_duration_ms AS "WaitTime_Milliseconds",
           BlockingChains.ChainLevel + 1 AS "ChainLevel",
           BlockingChains.HeadBlockerSessionId AS "HeadBlockerSessionId",
           BlockingChains.HeadBlockerTaskAddress AS "HeadBlockerTaskAddress"
    FROM BlockingChains
    INNER JOIN sys.dm_os_waiting_tasks AS BlockedTasks
        ON BlockingChains.SessionId = BlockedTasks.blocking_session_id
           AND (
               BlockingChains.TaskAddress = BlockedTasks.blocking_task_address
               OR BlockingChains.TaskAddress IS NULL
                  AND BlockedTasks.blocking_task_address IS NULL
           )
),
     HeadBlockers (HeadBlockerSessionId, HeadBlockerTaskAddress, BlockingChainLength, NumberOfBlockedTasks,
                   NumberOfBlockedSessions, TotalBlockedTasksWaitTime_Milliseconds
) AS
(
    SELECT HeadBlockerSessionId AS "HeadBlockerSessionId",
           HeadBlockerTaskAddress AS "HeadBlockerTaskAddress",
           MAX (ChainLevel) + 1 AS "BlockingChainLength",
           COUNT (*) - 1 AS "NumberOfBlockedTasks",
           COUNT (DISTINCT CASE
                               WHEN SessionId = HeadBlockerSessionId THEN NULL
                               ELSE SessionId
                           END
           ) AS "NumberOfBlockedSessions",
           SUM (WaitTime_Milliseconds) AS "TotalBlockedTasksWaitTime_Milliseconds"
    FROM BlockingChains
    GROUP BY HeadBlockerSessionId,
             HeadBlockerTaskAddress
    HAVING MAX (ChainLevel) > 0
)
SELECT HeadBlockers.HeadBlockerSessionId AS "HeadBlockerSessionId",
       HeadBlockers.HeadBlockerTaskAddress AS "HeadBlockerTaskAddress",
       HeadBlockers.BlockingChainLength AS "BlockingChainLength",
       HeadBlockers.NumberOfBlockedTasks AS "NumberOfBlockedTasks",
       HeadBlockers.NumberOfBlockedSessions AS "NumberOfBlockedSessions",
       HeadBlockers.TotalBlockedTasksWaitTime_Milliseconds AS "TotalBlockedTasksWaitTime_Milliseconds",
       Sessions.login_time AS "LoginDateTime",
       Sessions.host_name AS "HostName",
       Sessions.program_name AS "ProgramName",
       Sessions.login_name AS "LoginName",
       Sessions.status AS "SessionStatus",
       Sessions.last_request_start_time AS "LastRequestStartDateTime",
       CASE
           WHEN Requests.session_id IS NULL THEN Sessions.last_request_end_time
           ELSE NULL
       END AS "LastRequestEndDateTime",
       CASE
           WHEN Sessions.database_id = 0 THEN N'N/A'
           ELSE DB_NAME (Sessions.database_id)
       END AS "DatabaseName",
       Sessions.open_transaction_count AS "OpenTransactionCount",
       MostRecentBatchTexts.text AS "MostRecentBatchText",
       Requests.request_id AS "ActiveRequestId",
       Requests.status AS "ActiveRequestStatus",
       Requests.command AS "ActiveRequestCommand",
       SUBSTRING (
           RequestBatchTexts.text,
           Requests.statement_start_offset / 2 + 1,
           ((CASE
                 WHEN Requests.statement_end_offset = -1 THEN DATALENGTH (RequestBatchTexts.text)
                 ELSE Requests.statement_end_offset
             END - Requests.statement_start_offset
            ) / 2
           ) + 1
       ) AS "ActiveRequestStatementText",
       CAST(RequestStatementPlans.query_plan AS XML) AS "ActiveRequestStatementPlan",
       Requests.wait_type AS "ActiveRequestWaitType",
       Requests.wait_time AS "ActiveRequestWaitTime_Milliseconds",
       Requests.last_wait_type AS "ActiveRequestLastWaitType",
       Requests.percent_complete AS "ActiveRequestPercentComplete",
       Requests.cpu_time AS "ActiveRequestCPUTime_Milliseconds",
       Requests.total_elapsed_time AS "ActiveRequestElapsedTime_Milliseconds",
       Requests.reads AS "ActiveRequestReads",
       Requests.writes AS "ActiveRequestWrites",
       Requests.logical_reads AS "ActiveRequestLogicalReads",
       Requests.dop AS "ActiveRequestDegreeOfParallelism", -- supported only in SQL2016 and newer. remove if using an older version.
       ActiveTransactions.name AS "ActiveTransactionName",
       ActiveTransactions.transaction_begin_time AS "ActiveTransactionBeginDateTime"
FROM HeadBlockers
INNER JOIN sys.dm_exec_sessions AS Sessions
    ON HeadBlockers.HeadBlockerSessionId = Sessions.session_id
LEFT OUTER JOIN sys.dm_exec_connections AS Connections
    ON Sessions.session_id = Connections.session_id
OUTER APPLY sys.dm_exec_sql_text (Connections.most_recent_sql_handle) AS MostRecentBatchTexts
LEFT OUTER JOIN sys.dm_exec_requests AS Requests
    ON Sessions.session_id = Requests.session_id
OUTER APPLY sys.dm_exec_sql_text (Requests.sql_handle) AS RequestBatchTexts
OUTER APPLY sys.dm_exec_text_query_plan (
                Requests.plan_handle, Requests.statement_start_offset, Requests.statement_end_offset
            ) AS RequestStatementPlans
LEFT OUTER JOIN sys.dm_tran_active_transactions AS ActiveTransactions
    ON Requests.transaction_id = ActiveTransactions.transaction_id
ORDER BY TotalBlockedTasksWaitTime_Milliseconds DESC,
         HeadBlockerSessionId ASC,
         HeadBlockerTaskAddress ASC;
GO
