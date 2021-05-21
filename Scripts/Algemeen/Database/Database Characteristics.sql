-- Database characteristics
-- ----------------------------------------------------------------------------
SELECT d.name,
	F.name,
	LOWER(F.type_desc),
	physical_name AS [Physical File Name],
	size / 64 AS [Database Size (Mb)],
	CASE 
		WHEN growth = 0
			THEN 'fixed size'
		WHEN is_percent_growth = 0
			THEN CONVERT(VARCHAR(10), growth / 64)
		ELSE CONVERT(VARCHAR(10), (size * growth / 100) / 64)
		END AS [Growth (Mb)],
	CASE 
		WHEN max_size = 0
			THEN 'No growth allowed'
		WHEN max_size = - 1
			THEN 'unlimited Growth'
		WHEN max_size = 268435456
			THEN '2 TB'
		ELSE CONVERT(VARCHAR(10), max_size / 64) + 'Mb'
		END AS [Max Size],
	CASE 
		WHEN growth = 0
			THEN 'no autogrowth'
		WHEN is_percent_growth = 0
			THEN 'fixed increment'
		ELSE 'percentage'
		END AS [Database Autogrowth Setting]
FROM master.sys.databases AS d
INNER JOIN master.sys.master_files AS F ON F.database_id = d.database_id
ORDER BY F.name,
	F.file_id;
GO

--	Check if compatibility Model of databases are up to date
SELECT dbName = d.name,
	d.create_date,
	d.collation_name,
	model_compatibility_level = (
		SELECT d1.compatibility_level
		FROM sys.databases AS d1
		WHERE d1.name = 'model'
		),
	d.compatibility_level,
	d.user_access_desc,
	d.is_read_only,
	d.is_auto_close_on,
	d.is_auto_shrink_on,
	d.state_desc,
	d.is_in_standby,
	d.snapshot_isolation_state_desc,
	d.recovery_model_desc,
	d.is_auto_create_stats_on,
	d.is_auto_update_stats_on,
	d.is_auto_update_stats_async_on,
	d.log_reuse_wait_desc
FROM sys.databases AS d
WHERE d.compatibility_level NOT IN (
		SELECT d1.compatibility_level
		FROM sys.databases AS d1
		WHERE d1.name = 'model'
		);
