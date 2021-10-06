USE [master];
GO
IF DB_ID('LockEscalations') IS NOT NULL
BEGIN
	ALTER DATABASE [LockEscalations] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [LockEscalations];
END
GO

CREATE DATABASE [LockEscalations];
GO
-- Set file growth values
USE [master]
GO
ALTER DATABASE [LockEscalations] MODIFY FILE ( NAME = N'LockEscalations', FILEGROWTH = 262144KB )
GO
ALTER DATABASE [LockEscalations] MODIFY FILE ( NAME = N'LockEscalations_log', FILEGROWTH = 262144KB )
GO

-- Change database
USE [LockEscalations];
GO

-- Create the QueueItems table
CREATE TABLE dbo.QueueItems
(	QueueItemID int NOT NULL IDENTITY (1, 1),
	QueueID int NOT NULL,
	DateEntered datetime NOT NULL,
	IsProcessing bit NOT NULL,
	DataPacket xml NOT NULL);
GO
ALTER TABLE dbo.QueueItems 
ADD CONSTRAINT DF_QueueItems_DateEntered DEFAULT getdate() 
FOR DateEntered;
GO
ALTER TABLE dbo.QueueItems 
ADD CONSTRAINT DF_QueueItems_IsProcessing DEFAULT 0 
FOR IsProcessing;
GO
ALTER TABLE dbo.QueueItems 
ADD CONSTRAINT PK_QueueItems PRIMARY KEY CLUSTERED 
(QueueItemID);
GO

INSERT INTO dbo.QueueItems (QueueID, DateEntered, IsProcessing, DataPacket)
SELECT
	a.number%4 AS QueueID, 
	DATEADD(dd, -1*a.number, DATEADD(mi, -1*b.number, DATEADD(ss, b.number, DATEADD(ms, a.number, GETDATE())))) AS EventTime,
	1 AS IsProcessing,
	'<DataPacket />'
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b
WHERE a.type=N'P'
	AND b.type=N'P';
GO 5

CREATE PROCEDURE dbo.InsertNewEvents
AS
BEGIN
	WHILE 1=1
	BEGIN
		INSERT INTO dbo.QueueItems (QueueID, DataPacket)
		SELECT
			a.number%4 AS QueueID, 
			'<DataPacket />'
		FROM master.dbo.spt_values AS a
		WHERE a.type=N'P'
			AND a.number < 5;
		WAITFOR DELAY '00:00:00.500';  -- 1/2 second delay between loops
	END
END
GO

CREATE PROCEDURE dbo.PruneEvents
AS
BEGIN
	DECLARE @OldestEventDate DATETIME = DATEADD(dd, -30, GETDATE());
	DECLARE @RowsDeleted INT = 50000;

	WHILE @RowsDeleted > 0
	BEGIN
		BEGIN TRANSACTION
		DELETE TOP(50000)
		FROM dbo.QueueItems
		WHERE DateEntered < @OldestEventDate;

		SET @RowsDeleted = @@ROWCOUNT;

		-- Wait to hold locks open
		WAITFOR DELAY '00:00:05.000';

		ROLLBACK TRANSACTION
	END

END