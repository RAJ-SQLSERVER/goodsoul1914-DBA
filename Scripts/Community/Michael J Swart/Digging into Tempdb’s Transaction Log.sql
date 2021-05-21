USE tempdb;
SELECT *
FROM fn_dblog (NULL, NULL);

-- Collect tempdb log activity
USE tempdb;

-- get the latest lsn for tempdb
DECLARE @xact_seqno BINARY(10);
DECLARE @xact_seqno_string VARCHAR(50);

EXEC sp_replincrementlsn @xact_seqno OUTPUT;
SET @xact_seqno_string = '0x' + CONVERT (VARCHAR(50), @xact_seqno, 2);
SET @xact_seqno_string = STUFF (@xact_seqno_string, 11, 0, ':');
SET @xact_seqno_string = STUFF (@xact_seqno_string, 20, 0, ':');

-- wait for five seconds of activity:
WAITFOR DELAY '00:00:05';

SELECT TOP 10000 *
FROM fn_dblog (@xact_seqno_string, NULL);

-- What activity is there against PFS or GAM pages?
SELECT *
FROM fn_dblog (@xact_seqno_string, NULL)
WHERE Context IN ( 'LCX_PFS', 'LCX_GAM', 'LCX_SGAM' );

SELECT COUNT (*),
       Context
FROM fn_dblog (@xact_seqno_string, NULL)
WHERE Context IN ( 'LCX_PFS', 'LCX_GAM', 'LCX_SGAM' )
GROUP BY Context
ORDER BY COUNT (*) DESC;

-- What kinds of tempdb transactions are there?
SELECT COUNT (*),
       [Transaction Name]
FROM fn_dblog (@xact_seqno_string, NULL)
WHERE Operation = 'LOP_BEGIN_XACT'
GROUP BY [Transaction Name]
ORDER BY COUNT (*) DESC;

-- PFS or GAM activity by tempdb transaction type
WITH recentTempdbLogs AS (SELECT TOP 10000 * FROM fn_dblog (@xact_seqno_string, NULL) ),
     TransactionNames AS
(
    SELECT [Transaction ID],
           [Transaction Name]
    FROM recentTempdbLogs
    WHERE Operation = 'LOP_BEGIN_XACT'
)
SELECT tn.[Transaction Name],
       rtl.Context,
       COUNT (*) AS "Operations"
FROM recentTempdbLogs AS rtl
JOIN TransactionNames AS tn
    ON tn.[Transaction ID] = rtl.[Transaction ID]
WHERE Context IN ( 'LCX_PFS', 'LCX_GAM', 'LCX_SGAM' )
GROUP BY tn.[Transaction Name],
         Context
ORDER BY COUNT (*) DESC;