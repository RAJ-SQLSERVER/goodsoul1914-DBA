--EXEC tempdb..[usp_AnalyzeSpaceCapacity] @getLogInfo = 1 ,@verbose = 1

/********************************************************************************
	Created By:		Ajay Dwivedi
	Purpose:		Get Space Utilization of All DB Files along with Free space on Drives.
					This considers even non-accessible DBs
********************************************************************************/

declare @output table
(
	line varchar(2000));
declare @_powershellCMD varchar(400);
declare @mountPointVolumes table
(
	Volume          varchar(200), 
	Label           varchar(100) null, 
	[capacity(MB)]  decimal(20, 2), 
	[freespace(MB)] decimal(20, 2), 
	VolumeName      varchar(50), 
	[capacity(GB)]  decimal(20, 2), 
	[freespace(GB)] decimal(20, 2), 
	[freespace(%)]  decimal(20, 2));

--	Begin: Get Data & Log Mount Point Volumes
set @_powershellCMD = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@@servername, '''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,Label,capacity,freespace | foreach{$_.name+''|''+$_.Label+''|''+$_.capacity/1048576+''|''+$_.freespace/1048576}"';

--inserting disk name, Label, total space and free space value in to temporary table
insert into @output
exec xp_cmdshell @_powershellCMD;

with t_RawData
	 as (select ID = 1, 
				line, 
				expression = LEFT(line, CHARINDEX('|', line) - 1), 
				searchExpression = SUBSTRING(line, CHARINDEX('|', line) + 1, LEN(line) + 1), 
				delimitorPosition = CHARINDEX('|', SUBSTRING(line, CHARINDEX('|', line) + 1, LEN(line) + 1))
		 from @output
		 where line like '[A-Z][:]%'
		 --line like 'C:\%'
		 -- 
		 union all
		 --
		 select ID = ID + 1, 
				line, 
				expression = case
								 when delimitorPosition = 0 then searchExpression
							 else LEFT(searchExpression, delimitorPosition - 1)
							 end, 
				searchExpression = case
									   when delimitorPosition = 0 then null
								   else SUBSTRING(searchExpression, delimitorPosition + 1, LEN(searchExpression) + 1)
								   end, 
				delimitorPosition = case
										when delimitorPosition = 0 then -1
									else CHARINDEX('|', SUBSTRING(searchExpression, delimitorPosition + 1, LEN(searchExpression) + 1))
									end
		 from t_RawData
		 where delimitorPosition >= 0),
	 T_Volumes
	 as (select line, 
				Volume, 
				Label, 
				[capacity(MB)], 
				[freespace(MB)]
		 from (select line, 
					  [Column] = case ID
									 when 1 then 'Volume'
									 when 2 then 'Label'
									 when 3 then 'capacity(MB)'
									 when 4 then 'freespace(MB)'
								 else null
								 end, 
					  [Value] = expression
			   from t_RawData) as up pivot(MAX([Value]) for [Column] in(Volume, 
																		Label, 
																		[capacity(MB)], 
																		[freespace(MB)])) as pvt
	 --ORDER BY LINE
	 )
	 insert into @mountPointVolumes (Volume, 
									 Label, 
									 [capacity(MB)], 
									 [freespace(MB)], 
									 VolumeName, 
									 [capacity(GB)], 
									 [freespace(GB)], 
									 [freespace(%)]) 
	 select Volume, 
			Label, 
			[capacity(MB)] = CAST([capacity(MB)] as numeric(20, 2)), 
			[freespace(MB)] = CAST([freespace(MB)] as numeric(20, 2)), 
			Label as VolumeName, 
			CAST(CAST([capacity(MB)] as numeric(20, 2)) / 1024.0 as decimal(20, 2)) as [capacity(GB)], 
			CAST(CAST([freespace(MB)] as numeric(20, 2)) / 1024.0 as decimal(20, 2)) as [freespace(GB)], 
			CAST(( CAST([freespace(MB)] as numeric(20, 2)) * 100.0 ) / [capacity(MB)] as decimal(20, 2)) as [freespace(%)]
	 from T_Volumes as v
	 where v.Volume like '[A-Z]:\Data\'
		   or v.Volume like '[A-Z]:\Data[0-9]\'
		   or v.Volume like '[A-Z]:\Data[0-9][0-9]\'
		   or v.Volume like '[A-Z]:\Logs\'
		   or v.Volume like '[A-Z]:\Logs[0-9]\'
		   or v.Volume like '[A-Z]:\Logs[0-9][0-9]\'
		   or v.Volume like '[A-Z]:\tempdb\'
		   or v.Volume like '[A-Z]:\tempdb[0-9]\'
		   or v.Volume like '[A-Z]:\tempdb[0-9][0-9]\'
		   or exists (select *
					  from sys.master_files as mf
					  where mf.physical_name like Volume + '%');

select *
from @mountPointVolumes;