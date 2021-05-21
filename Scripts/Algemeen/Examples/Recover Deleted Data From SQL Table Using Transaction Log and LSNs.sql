use Playground;
go

-- Take the transaction log backup of the database using the query given below:
backup database Playground 
to disk = N'D:\SQLBackup\Playground.bak' 
with 
	noformat, 
	noinit, 
	name = N'Playground-Backup', 
	skip, 
	norewind, 
	nounload, 
	stats = 10;
go

delete 
from FragTest
where PKCol > 32000 and PKCol <= 32100
go

-- Check the number of rows present in the table
select *
from FragTest;
go

-- Take the transaction log backup of the database using the query given below:
backup LOG Playground 
to disk = N'D:\SQLBackup\Playground.trn' 
with 
	noformat, 
	noinit, 
	name = N'Playground-Transaction Log Backup', 
	skip, 
	norewind, 
	nounload, 
	stats = 10;
go

-- In order to recover deleted data from SQL Server Table, we need to collect some information about the deleted rows. 
-- Run the query given below to achieve this purpose
select [Transaction ID], 
	   [Current LSN], 
	   [Previous LSN], 
	   Operation, 
	   Context, 
	   AllocUnitName, 
	   [RowLog Contents 0]
from fn_dblog(null, null)
where Operation = 'LOP_DELETE_ROWS';
go

-- find the specific time at which rows were deleted using the Transaction ID
select [Current LSN], 
	   Operation, 
	   [Transaction ID], 
	   [Begin Time], 
	   [Transaction Name], 
	   [Transaction SID]
from fn_dblog(null, null)
where [Transaction ID] = '0001:00077483'
	  and Operation = 'LOP_BEGIN_XACT';
go

-- start the restore process to recover deleted data from SQL Server Table rows that was lost.
restore database Playground_Copy
from disk = 'D:\SQLBackup\Playground.bak' 
with 
	move 'Playground' to 'C:\Temp\Playground.mdf', 
	move 'Playground_log' to 'C:\Temp\Playground_log.ldf', 
	REPLACE, 
	norecovery;
go

-- apply transaction log to restore deleted rows by using LSN
restore LOG Playground_Copy 
from disk = N'D:\SQLBackup\Playground.trn' 
with stopbeforemark = 'lsn:0x00001010:00000031:0003';
go

--
RESTORE DATABASE Playground_Copy WITH RECOVERY
GO

-- process to recover deleted records from SQL table
use Playground_Copy; 
go 

select *
from FragTest;
go


alter database Platground set 