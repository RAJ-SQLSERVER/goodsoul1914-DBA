use master;
go

-- EXEC sp_VerifyDatabase @DBName = 'DemoDB'

create procedure sp_VerifyDatabase
(
	@DBName as varchar(100)) 
as
begin
	declare @SQLString      nvarchar(500), 
			@BackupFileName as nvarchar(500);
	declare @ParmDefinition nvarchar(500);
	declare @Restore_DBName as varchar(100) = @DBName;
	declare @DataFileSpaceTaken_GB as int, 
			@FreeDriveSpace_GB as     int;
	declare @OriginalDataFileName as varchar(500), 
			@OriginalLogFileName as  varchar(500);-- just in case

	print '-- 0. CHECK THAT BOTH DATABASE AND BACKUP EXIST --';
	if exists
	(
		select database_id
		from sys.databases as ses
			 inner join msdb.dbo.backupfile as ile on ile.logical_name = ses.name
		where ses.name = @DBName
	) 
	begin
		print '-- 1. GET LATEST BACKUP FILE FOR A DATABASE--';
		select top 1 @BackupFileName = bakfams.Physical_Device_Name, --bakfams.Physical_Device_Name 
					 @DataFileSpaceTaken_GB = masfiles.size / 1024 / 1024 / 1024, 
					 @FreeDriveSpace_GB = osvols.available_bytes / 1024 / 1024 / 1024, 
					 @OriginalDataFileName = masfiles.physical_name, 
					 @OriginalLogFileName = masfiles2.physical_name
		from sys.databases as dats
			 inner join msdb.dbo.backupset as baks on baks.database_name = dats.name
			 inner join msdb.dbo.backupmediafamily as bakfams on baks.media_set_id = bakfams.media_set_id
			 inner join sys.master_files as masfiles on masfiles.database_id = dats.database_id
														and masfiles.type_desc = 'ROWS'
			 cross apply sys.dm_os_volume_stats(masfiles.database_id, masfiles.file_id) as osvols
			 left outer join sys.master_files as masfiles2 on masfiles2.database_id = dats.database_id
															  and masfiles2.type_desc = 'LOG'
		where 1 = 1
			  and dats.name = @DBName
			  and baks.type = 'D'
		order by baks.backup_finish_date desc;
		print @BackupFileName;

		print '-- 2. CREATE DATABASE NAME TO RESTORE --';
		set @Restore_DBName = @Restore_DBName + '_' + DATENAME(MONTH, GETDATE());
		set @Restore_DBName = @Restore_DBName + CONVERT(varchar(2), DAY(GETDATE()));
		set @Restore_DBName = @Restore_DBName + CONVERT(varchar(4), YEAR(GETDATE()));
		print @Restore_DBName;

		print '-- 3. CHECK FREE DISKSPACE TO RESTORE THE DATABASE --';
		print @DataFileSpaceTaken_GB;
		print @FreeDriveSpace_GB;
		if @FreeDriveSpace_GB < @DataFileSpaceTaken_GB * 2
		begin
			print '-- not enough space --';
			return;
		end;

		print '-- 4. RESTORE DB--';
		set @SQLString = 'RESTORE DATABASE [' + @Restore_DBName + ']';
		set @SQLString = @SQLString + ' FROM DISK = N''' + @BackupFileName + '''';
		set @SQLString = @SQLString + ' WITH FILE = 1,';
		set @SQLString = @SQLString + ' MOVE N''' + @DBName + '''';
		set @SQLString = @SQLString + ' TO N''' + REPLACE(@OriginalDataFileName, @DBName, @Restore_DBName) + '''';
		set @SQLString = @SQLString + ', MOVE N''' + @DBName + '_log''';
		set @SQLString = @SQLString + ' TO N''' + REPLACE(@OriginalLogFileName, @DBName, @Restore_DBName) + '''';
		set @SQLString = @SQLString + ', NOUNLOAD, REPLACE, STATS = 10';

		print @SQLString;
		execute sp_executesql @SQLString;
		--RETURN

		print '-- 5. CHECK RESTORED DATABASE--';
		set @SQLString = 'DBCC CHECKDB (' + @Restore_DBName + ')';
		set @SQLString = @SQLString + ' WITH NO_INFOMSGS '; -- WITH TABLERESULTS
		execute sp_executesql @SQLString;

		print '-- 6. DROP RESTORED DATABASE--';
		set @SQLString = 'DROP DATABASE ' + @Restore_DBName;
		execute sp_executesql @SQLString;

		print '—-7. CREATE TEMP winlog TABLE --';
		if OBJECT_ID('tempdb..#winlog') != 0
			drop table #winlog;
		create table #winlog
		(
			rowID       int identity(1, 1), 
			LogDate     datetime, 
			ProcessInfo varchar(50), 
			textRow     varchar(4000));

		print '-- 8. STORE DBCC CHECKDB RESULTS --';
		insert into #winlog (LogDate, 
							 ProcessInfo, 
							 textRow) 
		exec master.dbo.xp_readerrorlog;

		print '-- 9. LOCATE LAST/FIRST ROWID —-';
		declare @textRow  nvarchar(500), 
				@1stRowID as int           = 0;
		set @SQLString = 'SELECT TOP 1 @x1stRowID = rowID';
		set @SQLString = @SQLString + ' FROM #winlog';
		set @SQLString = @SQLString + ' WHERE textRow = ''Starting up database ''''' + @Restore_DBName + '''''.''';
		set @SQLString = @SQLString + ' ORDER BY rowID DESC';
		set @ParmDefinition = N'@x1stRowID AS INT OUTPUT';
		execute sp_executesql @SQLString, @ParmDefinition, @x1stRowID = @1stRowID output;
		set @SQLString = 'SELECT *';
		set @SQLString = @SQLString + ' FROM #winlog';
		set @SQLString = @SQLString + ' WHERE RowID >= @xRowID';
		set @SQLString = @SQLString + ' ORDER BY rowID DESC';
		print 'SELECT FROM WINLOG: ' + @SQLString;

		print '-- 10. DISPLAY RESULTS--';
		set @ParmDefinition = N'@xRowID INT';
		execute sp_executesql @SQLString, @ParmDefinition, @xRowID = @1stRowID;
		drop table #winlog;
	end;
	else
	begin
		print '-- DATABASE IS NOT AVAILABLE OR HAS NO BACKUP! --';
	end;
end;