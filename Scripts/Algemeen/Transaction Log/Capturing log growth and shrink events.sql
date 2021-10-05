DECLARE @object_name sysname;
SET @object_name = CASE
                       WHEN @@servicename = 'MSSQLSERVER' THEN 'SQLServer'
                       ELSE 'MSSQL$' + @@serviceName
                   END + ':Databases';

DECLARE @PERF_COUNTER_LARGE_RAWCOUNT INT;
SELECT @PERF_COUNTER_LARGE_RAWCOUNT = 65792;

SELECT object_name,
       counter_name,
       instance_name,
       cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type = @PERF_COUNTER_LARGE_RAWCOUNT
      AND object_name = @object_name
      AND counter_name IN ( 'Log Growths', 'Log Shrinks' )
      AND cntr_value > 0
ORDER BY object_name,
         counter_name,
         instance_name;