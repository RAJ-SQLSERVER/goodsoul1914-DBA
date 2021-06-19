SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwHighCPUUtilizationLatestGrouped
as
SELECT        SqlInstance, COUNT(*) AS Count
FROM            dbo.CPURingBuffers
WHERE        (SQLProcessUtilization > 80) AND (EventTime >= DATEADD(D, - 1, GETDATE()))
GROUP BY SqlInstance
GO
