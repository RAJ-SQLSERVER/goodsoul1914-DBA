
--This is best left for the end to help with upgrades.
--Anything else that gets changed could cause these to need a refresh.
EXEC sp_refreshview 'Minion.CheckDBLogDetailsCurrent';
GO

EXEC sp_refreshview 'Minion.CheckDBLogDetailsLatest';
GO

EXEC sp_refreshview 'Minion.CheckTableLogDetailsLatest';
GO

