/*****************************
 Reading Transaction Log file 
*****************************/

select 
    [Current LSN], 
    Operation, 
    [Transaction ID], 
    SPID, 
    [Begin Time], 
    [Transaction Name], 
    SUSER_SNAME([Transaction SID]) as Login, 
    [Xact ID], 
    [Lock Information], 
    Description
from fn_dblog (null, null)
where Operation = 'LOP_BEGIN_XACT'
      and [Transaction Name] not in ('AutoCreateQPStats', 'SplitPage')
order by 
    [Current LSN] asc;

/*******************************************
 Getting details about a single transaction 
*******************************************/

select 
    [Current LSN], 
    Operation, 
    [Transaction ID], 
    SPID, 
    [Begin Time], 
    [Transaction Name], 
    SUSER_SNAME([Transaction SID]) as Login, 
    [Xact ID], 
    [End Time], 
    [Lock Information], 
    Description, 
    CAST(SUBSTRING([RowLog Contents 0], 33, LEN([RowLog Contents 0])) as varchar(8000)) as Definition
from fn_dblog (null, null)
where [Transaction ID] = '0001:000240ab'
order by 
    [Current LSN] asc;

/*******************************************************
 Finding a transaction in a transaction log backup file 

	- The first is a starting log sequence number (LSN) we want to read from. 
	  If you specify NULL, it returns everything from the start of the backup file.
	- The second is an ending log sequence number (LSN) we want to read to. 
	  If you specify NULL, it returns everything to the end of the backup file.
	- The third is a type of file (can be DISK or TAPE).
	- The fourth one is a backup number in the backup file.
	- The fifth is a path to the backup file
*******************************************************/

select 
    [Current LSN], 
    Operation, 
    [Transaction ID], 
    SPID, 
    [Begin Time], 
    [Transaction Name], 
    SUSER_SNAME([Transaction SID]) as Login, 
    [Xact ID], 
    [End Time], 
    [Lock Information], 
    Description
from fn_dump_dblog (null, null, N'DISK', 1, N'D:\SQLBackup\LT-RSD-01\StackOverflow2010\LOG\LT-RSD-01_StackOverflow2010_LOG_20200613_021507.trn', default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default, default)
where Operation = 'LOP_BEGIN_XACT'
      and [Transaction Name] not in ('AutoCreateQPStats', 'SplitPage')
order by 
    [Current LSN] asc;