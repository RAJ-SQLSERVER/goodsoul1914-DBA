-------------------------------------------------------------------------------
-- Create 100's of Sample Databases
-------------------------------------------------------------------------------

-- Create Variables
DECLARE @DataFilePath VARCHAR(100);
DECLARE @LogFilePath VARCHAR(100);
DECLARE @SubPartDBName VARCHAR(100);
DECLARE @StartCnt INT;
DECLARE @MaxDBCnt INT;

-- Set the Variable Values, @MaxDBCnt is Number of Databases you want to Create
SET @StartCnt = 1;
SET @MaxDBCnt = 101;

-- Provide the Data File Path And Log File Path
SET @DataFilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL01\MSSQL\DATA\';
SET @LogFilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL01\MSSQL\DATA\';
-- Chose the First part of your DB name, Let's say TEST is chosen then Databae will be created Test1,Test2....Test100
SET @SubPartDBName = 'Test';


-- Create Databases
WHILE (@StartCnt < @MaxDBCnt)
BEGIN

    PRINT CAST(@StartCnt AS VARCHAR(100));
    DECLARE @DBFullName VARCHAR(500) = @SubPartDBName + CAST(@StartCnt AS VARCHAR(10));
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL
        = N'CREATE DATABASE [' + @DBFullName + N']

 ON 
( NAME = N'''  + @DBFullName + N''', FILENAME = N''' + @DataFilePath + @DBFullName
          + N'.mdf'' ,
 SIZE = 4096KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'''  + @DBFullName + N'_log'', FILENAME = N''' + @LogFilePath + @DBFullName
          + N'_log.ldf'' ,
 SIZE = 1024KB , FILEGROWTH = 10%)';
    SET @StartCnt = @StartCnt + 1;
    PRINT @SQL;
    EXECUTE (@SQL);
END;