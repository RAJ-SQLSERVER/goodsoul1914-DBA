CREATE DATABASE DBA CONTAINMENT = NONE ON PRIMARY (
	NAME = N'DBA',
	FILENAME = N'D:\MSSQL\Data\DBA.mdf',
	SIZE = 1048576KB,
	FILEGROWTH = 262144KB
) LOG ON (
	NAME = N'DBA_log',
	FILENAME = N'D:\MSSQL\Logs\DBA_log.ldf',
	SIZE = 262144KB,
	FILEGROWTH = 65536KB
);

GO
