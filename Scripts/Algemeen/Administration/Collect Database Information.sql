/*========================================================================================================================

Description:	Display information about all the databases in the instance to be used for establishing a database maintenance plan
Scope:			Instance
Author:			Guy Glantser
Created:		09/09/2020
Last Updated:	15/02/2021
Notes:			Use this information to plan a maintenance plan for the databases in the instance

=========================================================================================================================*/

SELECT SERVERPROPERTY ('ServerName') AS ServerName,
       database_id AS DatabaseId,
       name AS DatabaseName,
       user_access_desc AS UserAccessMode,
       state_desc AS DatabaseState,
       recovery_model_desc AS RecoveryModel,
       page_verify_option_desc AS PageVerifyOption,
       compatibility_level AS CompatibilityLevel,
       dbfiles.Data_MB AS Data_Size_MB,
       dbfiles.Data_Files AS Data_Files,
       dbfiles.Log_MB AS Log_Size_MB,
       dbfiles.Log_Files AS Log_Files,
       is_auto_shrink_on AS IsAutoShrinkOn,
       is_auto_create_stats_on AS IsAutoCreateStatsOn,
       is_auto_create_stats_incremental_on AS IsAutoCreateStatsIncrementalOn, -- Applies to: SQL Server (starting with SQL Server 2014 (12.x))
       is_auto_update_stats_on AS IsAutoUpdateStatsOn,
       is_auto_update_stats_async_on AS IsAutoUpdateStatsAsyncOn,
       is_published AS IsPublishedInReplication,
       log_reuse_wait_desc AS LogReuseWait,
       is_cdc_enabled AS IsCdcEnabled,
       CASE
           WHEN group_database_id IS NULL -- Applies to: SQL Server (starting with SQL Server 2012 (11.x)) and Azure SQL Database
       THEN    0
           ELSE 1
       END AS IsPartOfAvailabilityGroup,
       is_accelerated_database_recovery_on AS IsAcceleratedDatabaseRecoveryOn -- Applies to: SQL Server (starting with SQL Server 2019 (15.x)) and Azure SQL Database
FROM sys.databases
CROSS APPLY (
    SELECT COUNT (CASE WHEN type <> 1 THEN type END) AS Data_Files,
           COUNT (CASE WHEN type = 1 THEN type END) AS Log_Files,
           CONVERT (FLOAT, SUM (CASE WHEN type <> 1 THEN size END) / 128.0) AS Data_MB,
           CONVERT (FLOAT, SUM (CASE WHEN type = 1 THEN size END) / 128.0) AS Log_MB
    FROM sys.master_files
    WHERE master_files.database_id = databases.database_id
) AS dbfiles
WHERE source_database_id IS NULL
      AND is_read_only = 0
ORDER BY DatabaseId ASC;
GO