-------------------------------------------------------------------------------
-- Alle entries in de CPURingBuffers met SQLUtilization >80%
-------------------------------------------------------------------------------
SELECT SqlInstance,
       RecordId,
       EventTime,
       SQLProcessUtilization,
       OtherProcessUtilization,
       SystemIdle
FROM DBA.dbo.vwHighCPUUtilization
ORDER BY EventTime DESC;
GO

-------------------------------------------------------------------------------
-- Gegroepeerde entries in de CPURingBuffers met SQLUtilization >80%
-------------------------------------------------------------------------------
SELECT SqlInstance,
       COUNT (*) AS HighCount,
       MIN (SQLProcessUtilization) AS MinCPU,
       MAX (SQLProcessUtilization) AS MaxCPU
FROM DBA.dbo.vwHighCPUUtilization
WHERE EventTime > DATEADD(W, -1, GETDATE())
GROUP BY SqlInstance
ORDER BY HighCount DESC;
GO
