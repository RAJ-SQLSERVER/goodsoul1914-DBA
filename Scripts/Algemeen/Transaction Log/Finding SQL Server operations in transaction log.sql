
-- Examine transaction log
SELECT
	[Current LSN],
	[Transaction ID],
	[Operation],
	[Transaction Name],
	[CONTEXT],
	[AllocUnitName],
	[Page ID],
	[Slot ID],
	[Begin Time],
	[End Time],
	[Number of Locks],
	[Lock Information]
FROM sys.fn_dblog(NULL, NULL)
WHERE Operation IN 
   ('LOP_INSERT_ROWS','LOP_MODIFY_ROW',
    'LOP_DELETE_ROWS','LOP_BEGIN_XACT','LOP_COMMIT_XACT')  

-- Get how many times page split occurs
SELECT 
	[Current LSN],
	[Transaction ID],
	[Operation],
	[Transaction Name],
	[CONTEXT],
	[AllocUnitName],
	[Page ID],
	[Slot ID],
	[Begin Time],
	[End Time],
	[Number of Locks],
	[Lock Information]
FROM sys.fn_dblog(NULL, NULL)
WHERE [Transaction Name]='SplitPage' 
GO

-- Get all steps SQL Server performs during a single page split occurrence
SELECT 
	[Current LSN],
	[Transaction ID],
	[Operation],
	[Transaction Name],
	[CONTEXT],
	[AllocUnitName],
	[Page ID],
	[Slot ID],
	[Begin Time],
	[End Time],
	[Number of Locks],
	[Lock Information]
FROM sys.fn_dblog(NULL, NULL)
WHERE [Transaction ID]='0000:000003e4'  