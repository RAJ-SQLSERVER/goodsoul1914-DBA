DECLARE @max_rows AS INT = 0;
DECLARE @max_rows_per_job AS INT = 0;

EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	,N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent'
	,N'JobHistoryMaxRows'
	,@max_rows OUTPUT
	,N'no_output';

EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	,N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent'
	,N'JobHistoryMaxRowsPerJob'
	,@max_rows_per_job OUTPUT
	,N'no_output';

SELECT @max_rows AS MaxRows
	,@max_rows_per_job AS MaxPerJob;

-- Change them
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows = 10000
	,@jobhistory_max_rows_per_job = 1000

