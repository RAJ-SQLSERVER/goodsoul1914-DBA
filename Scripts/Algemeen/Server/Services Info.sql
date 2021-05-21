select servicename, 
	   process_id, 
	   startup_type_desc, 
	   status_desc, 
	   last_startup_time, 
	   service_account, 
	   is_clustered, 
	   cluster_nodename, 
	   filename, 
	   instant_file_initialization_enabled
from sys.dm_server_services with(nolock) option(recompile);

-- https://www.brentozar.com/archive/2015/05/sql-server-version-detection/
SELECT	[version],
    common_version = SUBSTRING([version], 1, CHARINDEX('.', version) + 1 ),
    major = PARSENAME(CONVERT(VARCHAR(32), [version]), 4),
    minor = PARSENAME(CONVERT(VARCHAR(32), [version]), 3),
    build = PARSENAME(CONVERT(varchar(32), [version]), 2),
    revision = PARSENAME(CONVERT(VARCHAR(32), [version]), 1)
FROM (	SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)) AS [version] ) AS B

-- When was SQL Server Installed/Latest Instance Migration
select @@SERVERNAME as ServerName, 
	   create_date as [SQL Server Install Date]
from sys.server_principals with(nolock)
where name = N'NT AUTHORITY\SYSTEM'
	  or name = N'NT AUTHORITY\NETWORK SERVICE' option(recompile);
go

--	Check when was the system started
select @@servername as SvrName, 
	   GETDATE() as CurrentDate, 
	   create_date as ServiceStartDate, 
	   DATEDIFF(day, create_date, GETDATE()) as ServiceStartDays, 
	   DATEDIFF(hour, create_date, GETDATE()) as ServiceStartHours
from sys.databases as d
where d.name = 'tempdb';

-- Current RAM share of SQL Server
select m.total_physical_memory_kb / 1024 / 1024 as [Ram(GB)], 
	   system_memory_state_desc, 
	   m.available_physical_memory_kb / 1024 as [Available(MB)], 
	   CONVERT(numeric(20, 1), ( m.available_physical_memory_kb * 1.0 ) / 1024 / 1024) as [Available(GB)], 
	   CONVERT(numeric(20, 1), ( m.system_cache_kb * 1.0 ) / 1024 / 1024) as [Cache(GB)], 
	   CONVERT(numeric(20, 0), ( m.available_physical_memory_kb - m.system_cache_kb ) / 1024) as [Free(MB)]
from sys.dm_os_sys_memory as m;