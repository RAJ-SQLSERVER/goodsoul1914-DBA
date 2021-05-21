USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwTopWaits]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY WaitType ORDER BY CollectionTime) AS CollectionNumber,
       WaitType,
       WaitPercentage,
       AvgWaitSec,
       AvgResSec,
       AvgSigSec,
       WaitSec,
       ResourceSec,
       SignalSec,
       WaitCount,
       HelpInfoURL
FROM DBA.dbo.TopWaits;     
GO
