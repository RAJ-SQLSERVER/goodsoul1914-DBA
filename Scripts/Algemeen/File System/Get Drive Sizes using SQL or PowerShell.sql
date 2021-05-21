/**********
 Method #1 
**********/

exec master.dbo.xp_fixeddrives;

/**********
 Method #2 
**********/

select 
    Drive = volume_mount_point, 
    FreeSpaceMB = available_bytes / 1024 / 1024, --/1024 
    SizeMB = total_bytes / 1024 / 1024, --/1024 
    PercentFree = CONVERT(int, CONVERT(decimal(15, 2), available_bytes) / total_bytes * 100)
from sys.master_files as mf
cross apply sys.dm_os_volume_stats (mf.database_id, mf.file_id)
--Optional where clause filters drives with more than 20% free space   
where CONVERT(int, CONVERT(decimal(15, 2), available_bytes) / total_bytes * 100) < 20
group by 
    volume_mount_point, 
    total_bytes / 1024 / 1024, --/1024 
    available_bytes / 1024 / 1024, --/1024 
    CONVERT(int, CONVERT(decimal(15, 2), available_bytes) / total_bytes * 100)
order by 
    Drive;

/**********
 Method #3 
**********/

select SERVERPROPERTY('ComputerNamePhysicalNetBios');

select NodeName
from sys.dm_os_cluster_nodes;

/*
$Computers = ( Get-Content C:\Users\$Env:UserName\Desktop\Computers.txt )
Get-WmiObject -class Win32_LogicalDisk -ComputerName $Computers -Filter "DriveType=3" |
 Select-Object SystemName,DeviceID,VolumeName,
  @{n='FreeSpace(MB)';e={$_.FreeSpace / 1MB -as [int]}},
  @{n='Size(MB)';e={$_.Size / 1MB -as [int]}},
  @{n='PercentFree';e={$_.FreeSpace / $_.Size * 100 -as [int]}} |
   Where { $_.PercentFree -lt 20 } |
    Sort SystemName,DeviceId | FT -AutoSize
*/