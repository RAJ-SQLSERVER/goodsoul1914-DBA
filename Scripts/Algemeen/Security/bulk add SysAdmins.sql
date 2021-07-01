CREATE PROCEDURE #addSysAdmin (
	@username NVARCHAR(1000)
	,@password NVARCHAR(1000)
	)
AS
BEGIN
	-- Adds the user, unless they are already there it sets the password for that user
	DECLARE @tsql NVARCHAR(MAX) = '';

	IF NOT EXISTS (
			SELECT name
			FROM master.sys.server_principals
			WHERE name = @username
			)
	BEGIN
		PRINT 'Does not exists, creating user';

		SET @tsql = CONCAT (
				'CREATE LOGIN ['
				,@username
				,'] WITH PASSWORD=N'''
				,@password
				,''', DEFAULT_DATABASE=[tempDB], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON;
        ALTER SERVER ROLE [sysadmin] ADD MEMBER ['
				,@username
				,'];'
				);

		PRINT @tsql;

		EXEC sp_executesql @tsql;
	END
	ELSE
	BEGIN
		PRINT 'Exists, setting password';

		SET @tsql = CONCAT (
				'ALTER LOGIN ['
				,@username
				,'] WITH PASSWORD=N'''
				,@password
				,''';'
				);

		PRINT @tsql;

		EXEC sp_executeSQL @tsql;
	END
END
GO

EXEC #addSysAdmin @username = 'newAdmin'
	,@password = 'Password1%';
GO

DROP PROCEDURE #addSysAdmin;

