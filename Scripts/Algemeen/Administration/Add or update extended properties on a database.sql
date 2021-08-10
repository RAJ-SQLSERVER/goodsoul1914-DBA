USE [master]
GO

/* Create extended properties on a database */
EXEC [EMS].sys.sp_addextendedproperty @name=N'Contact', @value=N'' 
EXEC [EMS].sys.sp_addextendedproperty @name=N'Description', @value=N''
EXEC [EMS].sys.sp_addextendedproperty @name=N'Owner', @value=N''
EXEC [EMS].sys.sp_addextendedproperty @name=N'Supplier', @value=N''
EXEC [EMS].sys.sp_addextendedproperty @name=N'Telephone', @value=N''
GO

/* Update extended properties on a database */
EXEC [EMS].sys.sp_updateextendedproperty @name=N'Contact', @value=N'Test' 
EXEC [EMS].sys.sp_updateextendedproperty @name=N'Description', @value=N'Test' 
EXEC [EMS].sys.sp_updateextendedproperty @name=N'Owner', @value=N'Test' 
EXEC [EMS].sys.sp_updateextendedproperty @name=N'Supplier', @value=N'Test' 
EXEC [EMS].sys.sp_updateextendedproperty @name=N'Telephone', @value=N'Test' 
GO


