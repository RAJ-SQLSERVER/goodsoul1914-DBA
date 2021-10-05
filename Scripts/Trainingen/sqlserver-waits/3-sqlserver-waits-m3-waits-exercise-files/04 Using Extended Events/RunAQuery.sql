USE [Production];
GO

-- Drop all pages from memory
DBCC DROPCLEANBUFFERS;
GO

-- Get connection to put into XEvent
SELECT @@SPID;
GO

-- Execute to here first...

ALTER INDEX [test_CL] ON [test] REBUILD;
GO