--Undercover Catalogue
--David Fowler
--Version 0.4.3 - 04 May 2020
--Module: Tables
--Script: Update



BEGIN

--update tables where they are known to the catalogue
UPDATE Catalogue.Tables 
SET		ServerName = Tables_Stage.ServerName
		,DatabaseName = Tables_Stage.DatabaseName
		,SchemaName = Tables_Stage.SchemaName
		,TableName = Tables_Stage.TableName
		,Columns = Tables_Stage.Columns
		,LastRecorded = GETDATE()
		,Rows = Tables_Stage.Rows
		,TotalSizeMB = Tables_Stage.TotalSizeMB
		,UsedSizeMB = Tables_Stage.UsedSizeMB
FROM	Catalogue.Tables_Stage
WHERE	Tables.ServerName = Tables_Stage.ServerName
		AND Tables.SchemaName = Tables_Stage.SchemaName
		AND Tables.TableName = Tables_Stage.TableName
		AND Tables.DatabaseName = Tables_Stage.DatabaseName



--insert tables that are unknown to the catlogue
INSERT INTO Catalogue.Tables
(ServerName,DatabaseName,SchemaName,TableName,Columns,FirstRecorded,LastRecorded, Rows, TotalSizeMB, UsedSizeMB)
SELECT ServerName,
		DatabaseName,
		SchemaName,
		TableName,
		Columns,
		GETDATE(),
		GETDATE()
		,Rows
		,TotalSizeMB
		,UsedSizeMB
FROM Catalogue.Tables_Stage
WHERE NOT EXISTS 
(SELECT 1 FROM Catalogue.Tables
WHERE	Tables.ServerName = Tables_Stage.ServerName
		AND Tables.SchemaName = Tables_Stage.SchemaName
		AND Tables.TableName = Tables_Stage.TableName
		AND Tables.DatabaseName = Tables_Stage.DatabaseName)

END


