SELECT instance_name AS Deprecated_feature,
       cntr_value AS Usage_Count
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Deprecated Features'
      AND cntr_value > 0
ORDER BY cntr_value DESC;