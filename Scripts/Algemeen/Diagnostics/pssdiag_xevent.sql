IF EXISTS
(
    SELECT *
    FROM sys.server_event_sessions
    WHERE name = 'PSSDiag_XEvent'
)
    DROP EVENT SESSION [PSSDiag_XEvent] ON SERVER;
GO
CREATE EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.cursor_implicit_conversion
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    )
WITH
(
    MAX_MEMORY = 200800KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 10 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = PER_CPU,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
);

GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.databases_log_growth
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.databases_log_shrink
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.additional_memory_grant
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.attention
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.background_job_error
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.batch_hash_table_build_bailout
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.blocked_process_report
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.cpu_threshold_exceeded
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.database_suspect_data_page
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.error_reported
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.exchange_spill
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.execution_warning
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.filestream_file_io_failure
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.hash_warning
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.missing_column_statistics
    (SET collect_column_list = (1)
     ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.missing_join_predicate
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sort_warning
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.auto_stats
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.plan_guide_successful
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.plan_guide_unsuccessful
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.query_post_execution_showplan
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (SET collect_data_stream = (1)
     ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.rpc_starting
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sp_cache_remove
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sp_statement_completed
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sp_statement_starting
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_batch_completed
    (SET collect_batch_text = (1)
     ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_batch_starting
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_statement_recompile
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_statement_starting
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.lock_deadlock
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.lock_escalation
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.lock_timeout
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.server_memory_change
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlos.wait_info
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.existing_connection
    (SET collect_database_name = (1)
     ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.login
    (SET collect_options_text = (1)
     ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.logout
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.dtc_transaction
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
GO
ALTER EVENT SESSION [PSSDiag_XEvent]
ON SERVER
    ADD EVENT sqlserver.sql_transaction
    (ACTION
     (
         package0.event_sequence,
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.client_pid,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.is_system,
         sqlserver.nt_username,
         sqlserver.query_hash,
         sqlserver.request_id,
         sqlserver.server_principal_name,
         sqlserver.session_server_principal_name,
         sqlserver.session_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text,
         sqlserver.transaction_id,
         sqlserver.username
     )
    );
