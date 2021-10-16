-- Last Log Truncation Time
--------------------------------------------------------------------------------------------------
SELECT [Checkpoint Begin]
FROM sys.fn_dblog (NULL, NULL)
WHERE Operation = 'LOP_BEGIN_CKPT';
GO