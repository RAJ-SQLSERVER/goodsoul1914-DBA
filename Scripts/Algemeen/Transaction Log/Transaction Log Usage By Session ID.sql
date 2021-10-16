-- Transaction Log Usage By Session ID
-- ------------------------------------------------------------------------------------------------

SELECT DB_NAME (tdt.database_id) AS "DatabaseName",
       d.recovery_model_desc AS "RecoveryModel",
       d.log_reuse_wait_desc AS "LogReuseWait",
       es.original_login_name AS "OriginalLoginName",
       es.program_name AS "ProgramName",
       es.session_id AS "SessionID",
       er.blocking_session_id AS "BlockingSessionId",
       er.wait_type AS "WaitType",
       er.last_wait_type AS "LastWaitType",
       er.status AS "status",
       tat.transaction_id AS "TransactionID",
       tat.transaction_begin_time AS "TransactionBeginTime",
       tdt.database_transaction_begin_time AS "DatabaseTransactionBeginTime",
       tst.open_transaction_count AS "OpenTransactionCount",
       CASE tdt.database_transaction_state
           WHEN 1 THEN 'The transaction has not been initialized.'
           WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
           WHEN 4 THEN 'The transaction has generated log records.'
           WHEN 5 THEN 'The transaction has been prepared.'
           WHEN 10 THEN 'The transaction has been committed.'
           WHEN 11 THEN 'The transaction has been rolled back.'
           WHEN 12 THEN
               'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
           ELSE NULL --http://msdn.microsoft.com/en-us/library/ms186957.aspx 
       END AS "DatabaseTransactionStateDesc",
       est.text AS "StatementText",
       tdt.database_transaction_log_record_count AS "DatabaseTransactionLogRecordCount",
       tdt.database_transaction_log_bytes_used AS "DatabaseTransactionLogBytesUsed",
       tdt.database_transaction_log_bytes_reserved AS "DatabaseTransactionLogBytesReserved",
       tdt.database_transaction_log_bytes_used_system AS "DatabaseTransactionLogBytesUsedSystem",
       tdt.database_transaction_log_bytes_reserved_system AS "DatabaseTransactionLogBytesReservedSystem",
       tdt.database_transaction_begin_lsn AS "DatabaseTransactionBeginLsn",
       tdt.database_transaction_last_lsn AS "DatabaseTransactionLastLsn"
FROM sys.dm_exec_sessions AS es
INNER JOIN sys.dm_tran_session_transactions AS tst
    ON es.session_id = tst.session_id
INNER JOIN sys.dm_tran_database_transactions AS tdt
    ON tst.transaction_id = tdt.transaction_id
INNER JOIN sys.dm_tran_active_transactions AS tat
    ON tat.transaction_id = tdt.transaction_id
INNER JOIN sys.databases AS d
    ON d.database_id = tdt.database_id
LEFT OUTER JOIN sys.dm_exec_requests AS er
    ON es.session_id = er.session_id
LEFT OUTER JOIN sys.dm_exec_connections AS ec
    ON ec.session_id = es.session_id
--AND   ec.[most_recent_sql_handle] <> 0x 
OUTER APPLY sys.dm_exec_sql_text (ec.most_recent_sql_handle) AS est
--WHERE tdt.[database_transaction_state] >= 4 
ORDER BY tdt.database_transaction_begin_lsn;
GO