-- Log Growth Rate
--------------------------------------------------------------------------------------------------
with logs
	 as (select DB.name as DatabaseName, 
				MAX(DB.recovery_model_desc) as RecoveryModel, 
				SUM(size * 8) as TotalSizeKB, 
				SUM(case
						when MF.is_percent_growth = 0 then MF.growth
						else MF.size * MF.growth / 100
					end * 8) as TotalGrowthKB
		 from sys.master_files as MF
			  inner join sys.databases as DB on MF.database_id = DB.database_id
		 where MF.type = 1
		 group by DB.name),
	 total
	 as (select OPC.cntr_value as TotalCounter
		 from sys.dm_os_performance_counters as OPC
		 where OPC.object_name like N'%SQL%:Databases%'
			   and OPC.counter_name = N'Log Growths'
			   and OPC.instance_name = N'_Total'),
	 growth
	 as (select OPC.instance_name as DatabaseName, 
				OPC.cntr_value as Growths
		 from sys.dm_os_performance_counters as OPC
		 where OPC.object_name like N'%SQL%:Databases%'
			   and OPC.counter_name = N'Log Growths'
			   and OPC.instance_name <> N'_Total'),
	 shrinks
	 as (select OPC.instance_name as DatabaseName, 
				OPC.cntr_value as Shrinks
		 from sys.dm_os_performance_counters as OPC
		 where OPC.object_name like N'%SQL%:Databases%'
			   and OPC.counter_name = N'Log Shrinks'
			   and OPC.instance_name <> N'_Total')
	 select logs.DatabaseName, 
			logs.RecoveryModel, 
			logs.TotalSizeKB, 
			logs.TotalGrowthKB, 
			shrinks.Shrinks, 
			growth.Growths, 
			CONVERT(decimal(38, 2),
								 case
									 when total.TotalCounter = 0 then 0.0
									 else 100.0 * growth.Growths / total.TotalCounter
								 end) as [GrowthRate %]
	 from logs
		  inner join growth on logs.DatabaseName = growth.DatabaseName
		  inner join shrinks on logs.DatabaseName = shrinks.DatabaseName
		  cross join total
	 order by [GrowthRate %] desc, 
			  logs.DatabaseName asc;
go