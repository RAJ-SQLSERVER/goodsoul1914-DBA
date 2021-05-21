
SELECT INDATUM, avg(cast(SessieDuur as bigint)) as Totaal
FROM [dbo].[PERF_RESULTATEN]
where winstat LIKE 'wovd01%' and DATEDIFF (DAY, INDATUM, GETDATE()) <= 90
group by INDATUM
order by INDATUM

SELECT INDATUM, avg(cast(SessieDuur as bigint)) as Totaal
FROM [dbo].[PERF_RESULTATEN]
where winstat LIKE 'wovd02%' and DATEDIFF (DAY, INDATUM, GETDATE()) <= 90
group by INDATUM
order by INDATUM

SELECT INDATUM, avg(cast(SessieDuur as bigint)) as Totaal
FROM [dbo].[PERF_RESULTATEN]
where winstat LIKE 'wovd03%' and DATEDIFF (DAY, INDATUM, GETDATE()) <= 90
group by INDATUM
order by INDATUM

SELECT INDATUM, avg(cast(SessieDuur as bigint)) as Totaal
FROM [dbo].[PERF_RESULTATEN]
where winstat LIKE 'wovd04%' and DATEDIFF (DAY, INDATUM, GETDATE()) <= 90
group by INDATUM
order by INDATUM
