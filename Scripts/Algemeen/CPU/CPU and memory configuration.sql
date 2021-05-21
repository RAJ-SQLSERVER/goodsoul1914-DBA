SELECT cpu_count AS [Logical CPU Count],
       scheduler_count,
       hyperthread_ratio AS [Hyperthread Ratio],
       cpu_count / hyperthread_ratio AS [Physical CPU Count],
       physical_memory_kb / 1024 AS [Physical Memory (MB)],
       committed_target_kb / 1024 AS [Committed Target Memory (MB)],
       max_workers_count AS [Max Workers Count],
       affinity_type_desc AS [Affinity Type],
       softnuma_configuration_desc AS [Soft NUMA Configuration],
       sql_memory_model_desc -- New in SQL Server 2016 SP1
FROM sys.dm_os_sys_info WITH (NOLOCK)
OPTION (RECOMPILE);
