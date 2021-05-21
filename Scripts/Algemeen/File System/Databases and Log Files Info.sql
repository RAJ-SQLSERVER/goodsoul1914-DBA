-- Database and Logfile info 
--------------------------------------------------------------------------------------------------

set nocount on;

-- Variabele declaraties

declare @HostName nvarchar(128);

declare @CurrentDB nvarchar(128);

-- Verwijder tabel #tblServerDatabases als deze bestaat

if OBJECT_ID('tempdb..#tblServerDatabases', 'U') is not null
	drop table #tblServerDatabases;

-- Maak tabel #tblServerDatabases

create table #tblServerDatabases
(
	DBName nvarchar(128));

-- Verwijder tabel #tblDBFilesExtendedInfo als deze bestaat

if OBJECT_ID('tempdb..#tblDBFilesExtendedInfo', 'U') is not null
	drop table #tblDBFilesExtendedInfo;

-- Maak tabel #tblDBFilesExtendedInfo

create table #tblDBFilesExtendedInfo
(
	Idx                 int identity(1, 1), 
	ScanDate            datetime, 
	HostName            nvarchar(128), 
	FileID              int, 
	FileGroupID         int, 
	TotalExtents        bigint, 
	UsedExtents         bigint, 
	DBFileName          nvarchar(128), 
	DBFilePath          nvarchar(1024), 
	DBFileType          varchar(16), 
	DBName              nvarchar(128), 
	[TotalFileSize(MB)] money, 
	[TotalUsed(MB)]     money, 
	[TotalFree(MB)]     money, 
	[SpaceUsed(%)]      money, 
	status              int);

-- Verwijder tabel #tblDBFilesBasicInfo als deze bestaat

if OBJECT_ID('tempdb..#tblDBFilesBasicInfo', 'U') is not null
	drop table #tblDBFilesBasicInfo;

-- Maak tabel #tblDBFilesBasicInfo

create table #tblDBFilesBasicInfo
(
	DBName        nvarchar(128), 
	DBFileName    nvarchar(128), 
	FileID        int, 
	FilePath      nvarchar(1024), 
	FileGroupDesc nvarchar(128), 
	FileSizeKB    nvarchar(64), 
	MaxSizeDesc   nvarchar(64), 
	Growth        nvarchar(64), 
	Usage         nvarchar(64));

-- Bepaal de hostname

select @HostName = @@servername;

-- Voeg alle databasenamen toe aan tabel #tblServerDatabases

insert into #tblServerDatabases (DBName) 
select name
from sys.databases;

-- Neem de eerste database uit de tabel 

select @CurrentDB = MIN(DBName)
from #tblServerDatabases;

-- Zo lang er een database is...

while @CurrentDB is not null
begin   -- Start database loop
	-- Voeg gegevens omtrent de MDF toe aan tabel #tblDBFilesExtendedInfo
	insert into #tblDBFilesExtendedInfo (FileID, 
										 FileGroupID, 
										 TotalExtents, 
										 UsedExtents, 
										 DBFileName, 
										 DBFilePath) 
	exec ('USE ['+@CurrentDB+'] DBCC SHOWFILESTATS');

	-- Werk overige velden bij 
	update #tblDBFilesExtendedInfo
	set ScanDate = GETDATE(), HostName = @HostName, DBName = @CurrentDB, DBFileType = 'Data File'
	where DBName is null;

	-- Voeg gegevens omtrent LDF en MDF toe aan tabel #tblDBFilesBasicInfo
	insert into #tblDBFilesBasicInfo (DBFileName, 
									  FileID, 
									  FilePath, 
									  FileGroupDesc, 
									  FileSizeKB, 
									  MaxSizeDesc, 
									  Growth, 
									  Usage) 
	exec ('EXEC ['+@HostName+'].['+@CurrentDB+'].dbo.sp_helpfile '); -- Host.DB Syntax werkt hier wel
	-- Werk overige velden bij
	update #tblDBFilesBasicInfo
	set DBName = @CurrentDB
	where DBName is null;

	-- Bepaal de volgende database in de tijdelijke tabel
	select @CurrentDB = MIN(DBName)
	from #tblServerDatabases with(nolock)
	where DBName > @CurrentDB;
end; -- Einde database loop
-- Bereken op basis van TotalExtents en UsedExtents de schijfruimte gegevens

update #tblDBFilesExtendedInfo
set DBFileName = RIGHT(DBFilePath, CHARINDEX('\', REVERSE(DBFilePath)) - 1), [TotalFileSize(MB)] = CAST(( TotalExtents * 64 ) / 1024.00 as money), [TotalUsed(MB)] = CAST(( UsedExtents * 64 ) / 1024.00 as money), [TotalFree(MB)] = CAST(( TotalExtents * 64 ) / 1024.00 as money) - CAST(( UsedExtents * 64 ) / 1024.00 as money), [SpaceUsed(%)] = case
																																																																																						   when CAST(( TotalExtents * 64 ) / 1024.00 as money) = 0.0 then 0.0
																																																																																						   else( CAST(( UsedExtents * 64 ) / 1024.00 as money) * 100 ) / CAST(( TotalExtents * 64 ) / 1024.00 as money)
																																																																																					   end;

-- Voeg gegevens omtrent de LDF toe aan tabel #tblDBFilesExtendedInfo 

insert into #tblDBFilesExtendedInfo (DBName, 
									 [TotalFileSize(MB)], 
									 [SpaceUsed(%)], 
									 status) 
exec ('DBCC SQLPERF(LOGSPACE)');

-- Werk de overige velden van #tblDBFilesExtendedInfo bij

update a
set Scandate = GETDATE(), HostName = @HostName, [TotalUsed(MB)] = ( a.[SpaceUsed(%)] / 100.00 ) * a.[TotalFileSize(MB)], [TotalFree(MB)] = ( 1.0 - a.[SpaceUsed(%)] / 100.00 ) * a.[TotalFileSize(MB)], DBFileType = 'Log file', DBFilePath = b.FilePath, DBFileName = RIGHT(b.FilePath, CHARINDEX('\', REVERSE(b.FilePath)) - 1)
from #tblDBFilesExtendedInfo a
	 inner join #tblDBFilesBasicInfo b on a.DBName = b.DBName
where a.DBFileType is null
	  and b.Usage = 'log only';

set nocount off;

select *
from #tblDBFilesExtendedInfo
order by DBFileName;

-- verwijder tijdelijke tabellen

if OBJECT_ID('tempdb..#tblServerDatabases', 'U') is not null
	drop table #tblServerDatabases;

if OBJECT_ID('tempdb..#tblDBFilesExtendedInfo', 'U') is not null
	drop table #tblDBFilesExtendedInfo;

if OBJECT_ID('tempdb..#tblDBFilesBasicInfo', 'U') is not null
	drop table #tblDBFilesBasicInfo;
go