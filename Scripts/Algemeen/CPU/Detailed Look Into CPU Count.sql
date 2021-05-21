-- COUNT CPU
SELECT cpu_count,
       cpu_ticks,
       ms_ticks,
       hyperthread_ratio,
       physical_memory_kb,
       virtual_memory_kb,
       committed_kb,
       committed_target_kb,
       visible_target_kb,
       stack_size_in_bytes,
       os_quantum,
       os_error_mode,
       os_priority_class,
       max_workers_count,
       scheduler_count,
       scheduler_total_count,
       deadlock_monitor_serial_number,
       sqlserver_start_time_ms_ticks,
       sqlserver_start_time,
       affinity_type,
       affinity_type_desc,
       process_kernel_time_ms,
       process_user_time_ms,
       time_source,
       time_source_desc,
       virtual_machine_type,
       virtual_machine_type_desc,
       softnuma_configuration,
       softnuma_configuration_desc,
       process_physical_affinity,
       sql_memory_model,
       sql_memory_model_desc,
       socket_count,
       cores_per_socket,
       numa_node_count,
       container_type,
       container_type_desc
FROM sys.dm_os_sys_info;
GO

-- DETAILED LOOK INTO CPU COUNT
DECLARE @xp_msver TABLE
(
    idx INT NULL,
    c_name VARCHAR(100) NULL,
    int_val FLOAT NULL,
    c_val VARCHAR(128) NULL
);

INSERT INTO @xp_msver
EXEC ('[master]..[xp_msver]');

WITH [ProcessorInfo]
AS (SELECT cpu_count / hyperthread_ratio AS number_of_physical_cpus,
           CASE
               WHEN hyperthread_ratio = cpu_count THEN
                   cpu_count
               ELSE
           (cpu_count - hyperthread_ratio) / (cpu_count / hyperthread_ratio)
           END AS number_of_cores_per_cpu,
           CASE
               WHEN hyperthread_ratio = cpu_count THEN
                   cpu_count
               ELSE
           (cpu_count / hyperthread_ratio) * (cpu_count - hyperthread_ratio) / (cpu_count / hyperthread_ratio)
           END AS total_number_of_cores,
           cpu_count AS number_of_virtual_cpus,
           (
               SELECT c_val FROM @xp_msver WHERE c_name = 'Platform'
           ) AS cpu_category
    FROM sys.dm_os_sys_info)
SELECT number_of_physical_cpus,
       number_of_cores_per_cpu,
       total_number_of_cores,
       number_of_virtual_cpus,
       LTRIM(RIGHT(cpu_category, CHARINDEX('x', cpu_category) - 1)) AS cpu_category
FROM ProcessorInfo;
GO