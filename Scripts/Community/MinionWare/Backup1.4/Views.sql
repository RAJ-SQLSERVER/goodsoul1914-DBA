
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupFilesCurrent' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[BackupFilesCurrent];
END
GO
CREATE VIEW [Minion].[BackupFilesCurrent]
AS
       SELECT   *
       FROM     Minion.BackupFiles
       WHERE    ExecutionDateTime IN ( SELECT   MAX(ExecutionDateTime)
                                       FROM     Minion.BackupFiles);
GO

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupLogCurrent' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[BackupLogCurrent];
END
GO
CREATE VIEW [Minion].[BackupLogCurrent]
AS
       SELECT   *
       FROM     Minion.BackupLog
       WHERE    ExecutionDateTime IN ( SELECT   MAX(ExecutionDateTime)
                                       FROM     Minion.BackupLog);

GO

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupLogDetailsCurrent' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[BackupLogDetailsCurrent];
END
GO
CREATE VIEW [Minion].[BackupLogDetailsCurrent]
AS
       SELECT   *
       FROM     Minion.BackupLogDetails
       WHERE    ExecutionDateTime IN ( SELECT   MAX(ExecutionDateTime)
                                       FROM     Minion.BackupLogDetails );

GO


