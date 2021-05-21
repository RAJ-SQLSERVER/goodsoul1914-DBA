DECLARE @Duration VARCHAR(10) = '00:00:10';
DECLARE @FileSize VARCHAR(10) = '5'; -- in megabytes

-- create session
DECLARE @CreateSessionSQL NVARCHAR(MAX) = N'
    CREATE EVENT SESSION query_writes ON SERVER 
    ADD EVENT sqlserver.sp_statement_completed ( 
        SET collect_statement=(0)
        ACTION(sqlserver.transaction_id, sqlserver.database_name)
        WHERE sqlserver.transaction_id > 0
          AND sqlserver.database_name = ''' + DB_NAME ()
                                          + N''')
    ADD TARGET package0.asynchronous_file_target(
      SET filename = N''query_writes.xel'',
          max_file_size = ' + @FileSize + N',
          max_rollover_files = 1)
    WITH (
        STARTUP_STATE=ON,
        EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
        TRACK_CAUSALITY=OFF)';
EXEC sp_executesql @CreateSessionSQL;

ALTER EVENT SESSION query_writes ON SERVER STATE = START;

-- get the latest lsn for current DB
DECLARE @xact_seqno BINARY(10);
DECLARE @xact_seqno_string_begin VARCHAR(50);

EXEC sp_replincrementlsn @xact_seqno OUTPUT;

SET @xact_seqno_string_begin = '0x' + CONVERT (VARCHAR(50), @xact_seqno, 2);
SET @xact_seqno_string_begin = STUFF (@xact_seqno_string_begin, 11, 0, ':');
SET @xact_seqno_string_begin = STUFF (@xact_seqno_string_begin, 20, 0, ':');

-- wait a minute
WAITFOR DELAY @Duration;

-- get the latest lsn for current DB
DECLARE @xact_seqno_string_end VARCHAR(50);

EXEC sp_replincrementlsn @xact_seqno OUTPUT;

SET @xact_seqno_string_end = '0x' + CONVERT (VARCHAR(50), @xact_seqno, 2);
SET @xact_seqno_string_end = STUFF (@xact_seqno_string_end, 11, 0, ':');
SET @xact_seqno_string_end = STUFF (@xact_seqno_string_end, 20, 0, ':');

-- Stop the session
ALTER EVENT SESSION query_writes ON SERVER STATE = STOP;

-- read from transaction log
SELECT MAX ([Xact ID]) AS "transactionId",
       MAX ([Transaction Name]) AS "transactionName",
       SUM ([Log Record Length]) AS "logSize",
       COUNT (*) AS "logRowCount"
INTO #TLOGS
FROM fn_dblog (@xact_seqno_string_begin, @xact_seqno_string_end) AS f
GROUP BY [Transaction ID];

-- read from session data
CREATE TABLE #SessionData (id INT IDENTITY PRIMARY KEY, XEXml XML NOT NULL);

INSERT #SessionData (XEXml)
SELECT CAST(fileData.event_data AS XML)
FROM sys.fn_xe_file_target_read_file ('query_writes*xel', NULL, NULL, NULL) AS fileData;

-- find minimum transactionId captured by xes 
-- (almost always the first one, depending on luck here)
DECLARE @minTXFromSession BIGINT;

SELECT TOP (1) @minTXFromSession = S.XEXml.value ('(/event/action[(@name=''transaction_id'')]/value)[1]', 'bigint')
FROM #SessionData AS S;

WITH SD AS
(
    SELECT S.XEXml.value ('(/event/action[(@name=''transaction_id'')]/value)[1]', 'bigint') AS "transactionId",
           S.XEXml.value ('(/event/data[(@name=''object_id'')]/value)[1]', 'bigint') AS "objectId"
    FROM #SessionData AS S
)
SELECT ISNULL (T.transactionName, 'Unknown') AS "transactionTypeName",
       OBJECT_NAME (S.objectId) AS "ObjectName",
       SUM (T.logSize) AS "totalLogSizeBytes",
       SUM (T.logRowCount) AS "totalLogRowCount",
       COUNT (*) AS "executions"
FROM #TLOGS AS T
LEFT JOIN (SELECT DISTINCT * FROM SD) AS S
    ON T.transactionId = S.transactionId
WHERE T.transactionId >= @minTXFromSession
GROUP BY T.transactionName,
         S.objectId
ORDER BY SUM (T.logSize) DESC;

-- clean up
DROP EVENT SESSION query_writes ON SERVER;
DROP TABLE #TLOGS;
DROP TABLE #SessionData;