
SELECT top 10000 *
FROM [Performance].[dbo].[PERF_RESULTATEN]
WHERE OMGEVING = 'GWO Gen10'
--WHERE OMGEVING = 'GWO Gen9'
--WHERE OMGEVING = 'PC Lievensb'
--WHERE OMGEVING = 'GWO FAT'
--WHERE OMGEVING = 'VM'
ORDER BY Date DESC, Time DESC;


select omgeving, convert(date, INDATUM) as datum, count(*)/20 as [aantal metingen]
from [Performance].[dbo].[PERF_RESULTATEN]
where name = 'Protocolleren'
group by omgeving, convert(date, INDATUM)
order by convert(date, INDATUM) desc




