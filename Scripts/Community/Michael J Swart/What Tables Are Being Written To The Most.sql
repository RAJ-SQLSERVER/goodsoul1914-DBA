
-- get the latest lsn for current DB
DECLARE @xact_seqno BINARY(10);
DECLARE @xact_seqno_string_begin VARCHAR(50);

EXEC sys.sp_replincrementlsn @xact_seqno = @xact_seqno OUTPUT;

SET @xact_seqno_string_begin = '0x' + CONVERT (VARCHAR(50), @xact_seqno, 2);
SET @xact_seqno_string_begin = STUFF (@xact_seqno_string_begin, 11, 0, ':');
SET @xact_seqno_string_begin = STUFF (@xact_seqno_string_begin, 20, 0, ':');

-- wait a few seconds
WAITFOR DELAY '00:00:10';

-- get the latest lsn for current DB
DECLARE @xact_seqno_string_end VARCHAR(50);

EXEC sys.sp_replincrementlsn @xact_seqno = @xact_seqno OUTPUT;

SET @xact_seqno_string_end = '0x' + CONVERT (VARCHAR(50), @xact_seqno, 2);
SET @xact_seqno_string_end = STUFF (@xact_seqno_string_end, 11, 0, ':');
SET @xact_seqno_string_end = STUFF (@xact_seqno_string_end, 20, 0, ':');

WITH Log AS
(
    SELECT Category,
           SUM ([Log Record Length]) AS "Log Bytes"
    FROM fn_dblog (@xact_seqno_string_begin, @xact_seqno_string_end)
    CROSS APPLY (SELECT ISNULL (AllocUnitName, Operation)) AS C(Category)
    GROUP BY Category
)
SELECT Category,
       [Log Bytes],
       100.0 * [Log Bytes] / SUM ([Log Bytes]) OVER () AS "%"
FROM Log
ORDER BY [Log Bytes] DESC;