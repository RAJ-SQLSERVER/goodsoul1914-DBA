-- SERVER-LEVEL SECURITY
sp_srvrolepermission 'sysadmin'

ALTER SERVER ROLE [sysadmin] ADD member [MyLogin]
GO

CREATE SERVER ROLE [SeansRole]

ALTER SERVER ROLE [SeansRole] ADD member [WINSRV1\Mark]
GO


