-- Transact-SQL script to analyse the database size growth using backup history. 

declare @endDate datetime, 
		@months  smallint;

set @endDate = GETDATE();-- Include in the statistic all backups from today 

set @months = 6;-- back to the last 6 months. 

with HIST
	 as (select BS.database_name as DatabaseName, 
				YEAR(BS.backup_start_date) * 100 + MONTH(BS.backup_start_date) as YearMonth, 
				CONVERT(numeric(10, 1), MIN(BF.file_size / 1048576.0)) as MinSizeMB, 
				CONVERT(numeric(10, 1), MAX(BF.file_size / 1048576.0)) as MaxSizeMB, 
				CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) as AvgSizeMB
		 from msdb.dbo.backupset as BS
			  inner join msdb.dbo.backupfile as BF on BS.backup_set_id = BF.backup_set_id
		 where not BS.database_name in ('master', 'msdb', 'model', 'tempdb')
			   and BF.file_type = 'D'
			   and BS.backup_start_date between DATEADD(mm, -@months, @endDate) and @endDate
		 group by BS.database_name, 
				  YEAR(BS.backup_start_date), 
				  MONTH(BS.backup_start_date))
	 select MAIN.DatabaseName, 
			MAIN.YearMonth, 
			MAIN.MinSizeMB, 
			MAIN.MaxSizeMB, 
			MAIN.AvgSizeMB, 
			MAIN.AvgSizeMB -
	 (
		 select top 1 SUB.AvgSizeMB
		 from HIST as SUB
		 where SUB.DatabaseName = MAIN.DatabaseName
			   and SUB.YearMonth < MAIN.YearMonth
		 order by SUB.YearMonth desc
	 ) as GrowthMB
	 from HIST as MAIN
	 order by MAIN.DatabaseName, 
			  MAIN.YearMonth;