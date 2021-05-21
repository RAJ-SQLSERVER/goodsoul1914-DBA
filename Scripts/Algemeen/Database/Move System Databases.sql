--1.) Run the following Transact SQL to change location of the model, msdb and tempdb.
ALTER DATABASE model modify FILE (
	name = modeldev,
	filename = 'Type_New_Location_Here\model.mdf'
	);
GO

ALTER DATABASE model modify FILE (
	name = modellog,
	filename = 'Type_New_Location_Here\modellog.ldf'
	);
GO

ALTER DATABASE msdb modify FILE (
	name = MSDBData,
	filename = 'Type_New_Location_Here\MSDBData.mdf'
	);
GO

ALTER DATABASE msdb modify FILE (
	name = MSDBLog,
	filename = 'Type_New_Location_Here\MSDBLog.ldf'
	);
GO

ALTER DATABASE tempdb modify FILE (
	name = tempdev,
	filename = 'Type_New_Location_Here\tempdb.mdf'
	);
GO

ALTER DATABASE tempdb modify FILE (
	name = templog,
	filename = 'Type_New_Location_Here\templog.ldf'
	);
GO

--2.) Stop SQL Service
--3.) Copy Physical Files to new location, no need to copy TempDB files as these are recreated when SQL Server is started.
--4.) Start SQL Service
