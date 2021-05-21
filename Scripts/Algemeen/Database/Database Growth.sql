-- The sample scripts are not supported under any Microsoft standard support 
-- program or service. The sample scripts are provided AS IS without warranty  
-- of any kind. Microsoft further disclaims all implied warranties including,  
-- without limitation, any implied warranties of merchantability or of fitness for 
-- a particular purpose. The entire risk arising out of the use or performance of  
-- the sample scripts and documentation remains with you. In no event shall 
-- Microsoft, its authors, or anyone else involved in the creation, production, or 
-- delivery of the scripts be liable for any damages whatsoever (including, 
-- without limitation, damages for loss of business profits, business interruption, 
-- loss of business information, or other pecuniary loss) arising out of the use 
-- of or inability to use the sample scripts or documentation, even if Microsoft 
-- has been advised of the possibility of such damages. 
SELECT smf.name AS LogicalName,
	smf.file_id AS FileID,
	smf.physical_name AS FileName,
	CAST(CAST(sf.name AS VARBINARY(256)) AS SYSNAME) AS FileGroupName,
	CONVERT(VARCHAR(10), smf.size * 8) + ' KB' AS Size,
	CASE 
		WHEN smf.max_size = - 1
			THEN 'Unlimited'
		ELSE CONVERT(VARCHAR(10), CONVERT(BIGINT, smf.max_size) * 8) + ' KB'
		END AS MaxSize,
	CASE smf.is_percent_growth
		WHEN 1
			THEN CONVERT(VARCHAR(10), smf.growth) + '%'
		ELSE CONVERT(VARCHAR(10), smf.growth * 8) + ' KB'
		END AS Growth,
	CASE 
		WHEN smf.type = 0
			THEN 'Data Only'
		WHEN smf.type = 1
			THEN 'Log Only'
		WHEN smf.type = 2
			THEN 'FILESTREAM Only'
		WHEN smf.type = 3
			THEN 'Informational purposes Only'
		WHEN smf.type = 4
			THEN 'Full-text '
		END AS USAGE,
	DB_NAME(smf.database_id) AS DatabaseName
FROM sys.master_files AS smf
LEFT JOIN sys.filegroups AS sf ON (
		smf.type = 2
		OR smf.type = 0
		)
	AND smf.drop_lsn IS NULL
	AND smf.data_space_id = sf.data_space_id;
