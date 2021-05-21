

select	datum, [VM], [GWO FAT], [GWO Gen09], [GWO Gen10], [PC Lievensb]
from (
	select	CONVERT(date, INDATUM) as datum, omgeving, count(*)/20 as [aantal runs]
	from	[Performance].[dbo].[PERF_RESULTATEN]
	where	name = 'Protocolleren'
	group	by CONVERT(date, INDATUM), omgeving 
) as s
pivot	(SUM([aantal runs]) for omgeving in ([VM], [GWO FAT], [GWO Gen09], [GWO Gen10], [PC Lievensb])) as p
order by datum desc

