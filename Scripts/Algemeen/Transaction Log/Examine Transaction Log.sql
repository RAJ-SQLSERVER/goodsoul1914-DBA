-- Examine transaction log
--------------------------------------------------------------------------------------------------
select [Current LSN], 
	   [Transaction ID], 
	   Operation, 
	   [Transaction Name], 
	   CONTEXT, 
	   AllocUnitName, 
	   [Page ID], 
	   [Slot ID], 
	   [Begin Time], 
	   [End Time], 
	   [Number of Locks], 
	   [Lock Information]
from sys.fn_dblog (null, null)
where Operation in ('LOP_INSERT_ROWS', 'LOP_MODIFY_ROW', 'LOP_DELETE_ROWS', 'LOP_BEGIN_XACT', 'LOP_COMMIT_XACT');
go