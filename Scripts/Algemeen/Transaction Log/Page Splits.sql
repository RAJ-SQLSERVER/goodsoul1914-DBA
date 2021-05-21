-- Get how many times page splits occur
-- ------------------------------------------------------------------------------------------------

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
where [Transaction Name] = 'SplitPage'; 
go

-- Get all steps SQL Server performs during a single page split occurrence
-- ------------------------------------------------------------------------------------------------

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
where [Transaction ID] = '0000:0000e825';  
go