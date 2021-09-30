-- Clear the waits in WaitStats1.sql
-- Clear the buffer pool
DBCC DROPCLEANBUFFERS;
GO

DBCC CHECKDB (N'master') WITH NO_INFOMSGS;
GO

-- Examine waits in WaitStats1.sql