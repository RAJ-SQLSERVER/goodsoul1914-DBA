-- Top n longest running procedures
-- ------------------------------------------------------------------------------------------------

SELECT TOP 10 t.text AS "ProcedureName",
              s.execution_count AS "ExecutionCount",
              ISNULL (s.total_elapsed_time / s.execution_count, 0) AS "AvgExecutionTime",
              s.total_worker_time / s.execution_count AS "AvgWorkerTime",
              s.total_worker_time AS "TotalWorkerTime",
              s.max_logical_reads AS "MaxLogicalReads",
              s.max_logical_writes AS "MaxLogicalWrites",
              s.creation_time AS "CreationDateTime",
              ISNULL (s.execution_count / DATEDIFF (SECOND, s.creation_time, GETDATE ()), 0) AS "CallsPerSecond"
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text (s.sql_handle) AS t
ORDER BY s.total_elapsed_time DESC;
GO

-- Long running queries
---------------------------------------------------------------------------------------------------

DECLARE @xml NVARCHAR(MAX);

DECLARE @body NVARCHAR(MAX);
-- specify long running query duration threshold

DECLARE @longrunningthreshold INT;

SET @longrunningthreshold = 2;
-- step 1: collect long running query details.

WITH cte AS
(
    SELECT spid AS "Session_id",
           (SELECT start_time FROM sys.dm_exec_requests WHERE spid = session_id) AS "Session_start_time",
           LTRIM (RTRIM (status)) AS "Session_status",
           DATEDIFF (mi, (SELECT start_time FROM sys.dm_exec_requests WHERE spid = session_id), GETDATE ()) AS "Session_duration",
           SUBSTRING (st.text,
                      qs.stmt_start / 2 + 1,
                      (CASE qs.stmt_end
                           WHEN -1 THEN DATALENGTH (st.text)
                           ELSE qs.stmt_end
                       END - qs.stmt_start
                      ) / 2 + 1
           ) AS "Session_query"
    FROM sys.sysprocesses AS qs
    CROSS APPLY sys.dm_exec_sql_text (sql_handle) AS st
    WHERE st.text <> 'WAITFOR(RECEIVE conversation_handle, service_contract_name, message_type_name, message_body FROM ExternalMailQueue INTO @msgs), TIMEOUT @rec_timeout -- Check if there was some error in reading from queue'
)
-- step 2: generate html table 
SELECT @xml = CAST((
        SELECT Session_id AS "td",
               '',
               Session_duration AS "td",
               '',
               Session_status AS "td",
               '',
               Session_query AS "td"
        FROM cte
        WHERE Session_duration >= @longrunningthreshold
        FOR XML PATH ('tr'), ELEMENTS
    ) AS NVARCHAR(MAX));

-- step 3: do rest of html formatting

SET @body = N'<html><body><H2>Long Running Queries ( Limit > 2 Minute )</H2><table border=1 BORDERCOLOR="Black"><tr><th align="centre">Session_id</th><th>Session_Duration(Minute)</th><th>Session_status</th><th>Session_query</th></tr>';

SET @body = @body + @xml + N'</table></body></html>';

SELECT @xml;

-- step 4: send email if a long running query is found.

IF @xml IS NOT NULL
BEGIN
    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'GPHIXSQL01',
                                 @body = @body,
                                 @body_format = 'html',
                                 @recipients = 'r.meijer@bravis.nl;m.boomaars@bravis.nl',
                                 @subject = 'ALERT: Long Running Queries';
END;