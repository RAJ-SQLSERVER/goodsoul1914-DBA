
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBLogDetailsCurrent' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[CheckDBLogDetailsCurrent];
END
GO
CREATE VIEW [Minion].[CheckDBLogDetailsCurrent]
AS
       SELECT   *
       FROM     Minion.CheckDBLogDetails
       WHERE    ExecutionDateTime IN ( SELECT   MAX(ExecutionDateTime)
                                       FROM     Minion.CheckDBLogDetails );
GO

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBLogDetailsLatest' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[CheckDBLogDetailsLatest];
END
GO
CREATE VIEW [Minion].[CheckDBLogDetailsLatest]
AS
--Gets the latest checkdb run for each DB. This is different from the Current view
--in that the Current view gets the latest run regardless of what was in it.
--Here we're interested in the last time a DB was run.
       SELECT   *
       FROM     Minion.CheckDBLogDetails CLD1
       WHERE    ExecutionDateTime IN ( SELECT   MAX(CLD2.ExecutionDateTime)
                                       FROM     Minion.CheckDBLogDetails CLD2 WHERE CLD1.DBName = CLD2.DBName AND UPPER(CLD2.OpName) = 'CHECKDB' AND STATUS LIKE 'Complete%');




GO

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckTableLogDetailsLatest' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP VIEW [Minion].[CheckTableLogDetailsLatest];
END
GO
CREATE VIEW [Minion].[CheckTableLogDetailsLatest]
AS
--Gets the latest checkdb run for each DB. This is different from the Current view
--in that the Current view gets the latest run regardless of what was in it.
--Here we're interested in the last time a DB was run.
       SELECT   *
       FROM     Minion.CheckDBLogDetails CLD1
       WHERE    ExecutionDateTime IN ( SELECT   MAX(CLD2.ExecutionDateTime)
                                       FROM     Minion.CheckDBLogDetails CLD2 WHERE CLD1.DBName = CLD2.DBName AND UPPER(CLD2.OpName) = 'CHECKTABLE' AND STATUS LIKE 'Complete%');





GO


