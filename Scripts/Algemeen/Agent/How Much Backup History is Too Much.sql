DECLARE @startDate AS DATETIME;

SET @startDate = NULL;

SELECT @startDate = min(backup_start_date)
FROM msdb.dbo.backupset WITH (NOLOCK);

SET @startDate = dateadd(d, 5, @startDate);

IF @startDate < getdate() - 20
BEGIN
	EXEC msdb.dbo.sp_delete_backuphistory @startDate;
END

