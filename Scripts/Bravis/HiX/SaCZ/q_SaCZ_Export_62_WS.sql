/*
  SaCZ Compare HiX performance deelnemende ziekenhuizen - Aanleveren LOGPERF data ## 6.2 versie ##
  v.6.1_01 Maart 2018, ADRZ - Dani�l Pairoux, LUMC - Jos van Hoek
  v.6.2_01 Juli 2019, LLZ - Michiel van den Boogaard
  v.6.2.02 Juli 2019, WorkstationName indeling lokaal en SaCZ voor HiX 6.2
  v.6.2.03 Augustus 2019, ADRZ - Dani�l Pairoux - Duration toegevoegd, IsSubAction en IsFirstTime gebruikt 
  v.6.2.04 December 2019, punt-komma uit context verwijderen ivm aanlevering als .csv
*/

USE HiX_Prod_Uxiplog;
GO

DECLARE @organisatienaam VARCHAR(20)   = 'BVS',																	-- Aanpassen naam organisatie 
        @omgevingsnaam   NVARCHAR(100) = N'BPHIXLS01.zkh.local.HiX_Acc',										-- Aanpassen naam omgeving (EnvironmentID)
        @startjaarmaand  VARCHAR(6)    = (SELECT CONVERT (VARCHAR(6), DATEADD (MONTH, -1, GETDATE ()), 112));
-- Aanpassen periode -> Standaard -1 dus vorige maand, -3 voor afgelopen drie maanden

DECLARE @startdatum DATETIME = (SELECT CONVERT (DATETIME, @startjaarmaand + '01')),
        @einddatum  DATETIME = (SELECT DATEFROMPARTS (YEAR (GETDATE ()), MONTH (GETDATE ()), 1));

SELECT @organisatienaam AS organisatie,
    CONVERT (VARCHAR(6), L2.jaarmaand, 112) AS jaarmaand,
    L2.versie AS versie,
    L2.soortwerkstation AS soortwerkstation,
    L2.typewerkstation AS typewerkstation,
    L2.isclient AS isclient,
    REPLACE (L2.Context, ';', '') AS context,
    L2.iseerstekeer AS iseerstekeer,
    REPLACE (LTRIM (STR (ROUND (AVG (L2.duur * 1.0) / 1000.0, 6), 100, 6)), '.', ',') AS duurgemiddeld,
    REPLACE (LTRIM (STR (ROUND (SUM (L2.duur) / 1000.000, 3), 100, 3)), '.', ',') AS duurtotaal,
    COUNT (*) AS aantal
FROM (
    SELECT CAST(L1.MeasureTimestamp AS DATE) AS jaarmaand,
        L1.FrontendVersion AS versie,
        L1.WorkstationName,
        CASE
               /* Exact match */
               WHEN L1.WorkstationName = 'PC00883' THEN 'FAT (PACS)'                                             -- BoZ PACS
               /* Partial match */
               WHEN L1.WorkstationName LIKE 'VD%' THEN 'VDI'                                                     -- Rsd
               WHEN L1.WorkstationName LIKE 'WOVD%' THEN 'VDI (POD' + SUBSTRING (L1.WorkstationName, 5, 2) + ')' -- GWO
               WHEN L1.WorkstationName LIKE 'PC%F' THEN 'FAT'                                                    -- GWO
               WHEN L1.WorkstationName LIKE 'PC-%' THEN 'FAT'                                                    -- BoZ
               WHEN L1.WorkstationName LIKE 'BP%' THEN 'SRV-F'                                                   -- GWO
               WHEN L1.WorkstationName LIKE '%HIXAS%' THEN 'SRV (HAS)'                                           -- GWO
               WHEN L1.WorkstationName LIKE '%HIXCOMEZ%' THEN 'SRV (COMEZ)'                                      -- GWO
               WHEN L1.WorkstationName LIKE '%HIXDWH%' THEN 'SRV (DWH)'                                          -- GWO
               WHEN L1.WorkstationName LIKE '%HIXMETING%' THEN 'SRV (METING)'                                    -- GWO
               WHEN L1.WorkstationName LIKE '%HIXTS%' THEN 'SRV (TS)'                                            -- GWO
               WHEN LEFT(L1.WorkstationName, 2) IN ( 'GA', 'GP' ) THEN 'SRV'                                     -- GWO
               ELSE 'PC'
           END AS soortwerkstation,
        CASE
               WHEN LEFT(L1.WorkstationName, 2) = 'VD' THEN 'VDI'
               WHEN LEFT(L1.WorkstationName, 4) = 'WOVD' THEN 'VDI'
               WHEN LEFT(L1.WorkstationName, 2) IN ( 'BP', 'GA', 'GP' ) THEN 'SRV'
               ELSE 'PC'
           END AS typewerkstation,
        CASE
               WHEN LEFT(L1.WorkstationName, 2) IN ( 'BP', 'GA', 'GP' ) THEN 0
               ELSE 1
           END AS isclient,
        L1.Context,
        L1.Duration AS duur,
        L1.IsFirstTime AS iseerstekeer
    FROM dbo.PERFLOG_ACTION AS L1 WITH (NOLOCK)
    -- Let op: PERFLOG_ACTION is een VIEW
    WHERE L1.MeasureTimestamp >= @startdatum
        AND L1.MeasureTimestamp < @einddatum
        AND L1.EnvironmentId = @omgevingsnaam
        AND L1.IsSubAction = 0
) AS L2
GROUP BY CONVERT (VARCHAR(6), L2.jaarmaand, 112),
         L2.versie,
         L2.soortwerkstation,
         L2.typewerkstation,
         L2.isclient,
         L2.Context,
         L2.iseerstekeer;
