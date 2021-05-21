use [msdb];
with [BackupSize]
	 as (select bs.database_name as Name, 
				DATEDIFF(DD, DATEADD(DD, -45, GETDATE()), bs.backup_start_date) as [Date], 
				SUM(bs.backup_size) / 1024 / 1024 / 1024 as Size
		 from backupmediafamily as bmf
			  inner join backupset as bs on bmf.media_set_id = bs.media_set_id
		 where bs.backup_start_date >= DATEADD(DD, -45, GETDATE())
			   and bs.type = 'D'
		 group by bs.database_name, 
				  DATEDIFF(DD, DATEADD(DD, -45, GETDATE()), bs.backup_start_date))
	 select Name, 
			[Date], 
			Size, 
			PERCENTILE_CONT(0.25) within group(order by Size) over(partition by Name) as Q1, 
			PERCENTILE_CONT(0.5) within group(order by Size) over(partition by Name) as Q2, 
			PERCENTILE_CONT(0.75) within group(order by Size) over(partition by Name) as Q3
	 into #Info
	 from BackupSize;
update #Info
set Size = Q2
where Size < 2 * Q1 - Q3
	  or Size > 2 * Q3 - Q1;
with [slope]
	 as (select Name, 
				MAX(DateAvg) as DateAvg, 
				MAX(SizeAvg) as SizeAvg,
				case
					when SUM(( [Date] - DateAvg ) * ( [Date] - DateAvg )) = 0 then 0
								else SUM(( [Date] - DateAvg ) * ( Size - SizeAvg )) / SUM(( [Date] - DateAvg ) * ( [Date] - DateAvg ))
				end as m
		 from (select Name, 
					  [Date], 
					  AVG([Date]) over(partition by Name) as DateAvg, 
					  Size, 
					  AVG(Size) over(partition by Name) as SizeAvg
			   from #Info) as x
		 group by Name),
	 [lr]
	 as (select Name, 
				m, 
				SizeAvg - DateAvg * m as b
		 from slope)
	 select Name, 
			GEOMETRY::STGeomFromText('LINESTRING(0 ' + CAST(b as varchar(53)) + ',90 ' + CAST(m * 90 + b as varchar(53)) + ')', 0) as Geom
	 from lr
	 group by Name, 
			  m, 
			  b
	 union all
	 select Name, 
			GEOMETRY::STGeomFromText('LINESTRING(' + string_agg(CONCAT([Date], ' ', Size), ',') within group(order by [Date]) + ')', 0)
	 from #Info
	 group by Name;
drop table #Info;