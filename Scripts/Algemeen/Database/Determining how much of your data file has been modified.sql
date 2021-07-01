SELECT df.name
	,df.physical_name
	,total_page_count
	,allocated_extent_page_count
	,modified_extent_page_count
	,100.0 * modified_extent_page_count / allocated_extent_page_count AS PercentChanged
FROM sys.dm_db_file_space_usage fsu
INNER JOIN sys.database_files df ON df.file_id = fsu.file_id;

-- Now based on the Percent Changed column we can make some assumptions on the 
-- size of the differential backup, and decide if we want to do a differential 
-- backup or a full backup.
DECLARE @percentChanged AS DECIMAL(10, 2) = 0;

-- only works if you have a single data file.  Need to modify if you have multiple data files.
SELECT @percentChanged = 100.0 * modified_extent_page_count / allocated_extent_page_count
FROM sys.dm_db_file_space_usage;

SELECT @percentChanged;

DECLARE @backupFilename AS NVARCHAR(256) = 'C:\BackupDemo\BackupDemo' + REPLACE(convert(NVARCHAR(20), GetDate(), 120), ':', '-');

IF @percentChanged > 75
BEGIN
	SET @backupFilename = @backupFilename + '_FULL.bak';

	BACKUP DATABASE BackupDemo TO DISK = @backupFilename
	WITH FORMAT
		,COMPRESSION
		,NAME = 'Full Backup';
END
ELSE
BEGIN
	SET @backupFilename = @backupFilename + '_DIFF.bak';

	BACKUP DATABASE BackupDemo TO DISK = @backupFilename
	WITH DIFFERENTIAL
		,FORMAT
		,COMPRESSION
		,NAME = 'Differential Backup';
END

