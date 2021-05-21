USE master;
GO

/*************************************************************
    Allow Dedicated Admin Connection (DAC)
      
    0 = Allow Local Connection, 
    1 = Allow Remote Connections
*************************************************************/
sp_configure 'remote admin connections',
	1;
GO

RECONFIGURE;
GO


