USE [Credit];
GO

-- Create a new capture instance for the Category table
EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo',
	@source_name = N'category',
	@role_name = N'cdc_admin';
GO


-- Add a new filegroup to the database to isolate the change tables
ALTER DATABASE [Credit] 
ADD FILEGROUP [cdc_ChangeTables];
GO

-- Add a file to the filegroup 
ALTER DATABASE [Credit] 
ADD FILE (	NAME = N'cdc_ChangeTables', 
			FILENAME = N'E:\SQLData\Credit_cdc_ChangeTables.ndf', 
			SIZE = 1048576KB , 
			FILEGROWTH = 102400KB ) 
TO FILEGROUP [cdc_ChangeTables];
GO

-- Create a second capture instance for the Category table on the new filegroup
-- Note! Second capture instance requires the @capture_instance parameter
EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo',
	@source_name = N'category',
	@role_name = N'cdc_admin',
	@capture_instance = N'dbo_category_2',
	@filegroup_name = N'cdc_ChangeTables';
GO

-- View capture instance configuration
EXEC sys.sp_cdc_help_change_data_capture;
GO

-- Disable all capture instances on the Category table
EXEC sys.sp_cdc_disable_table
	@source_schema = N'dbo',
	@source_name = N'category',
	@capture_instance = N'all';
GO


-- Create a new capture instance for the charge table
EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo',
	@source_name = N'charge',
	@role_name = N'cdc_admin',
	@filegroup_name = 'cdc_ChangeTables',
	@supports_net_changes = 0;
GO

-- Enable a table with a subset of columns tracked
-- Note! This is a second capture instance on the table and requires explicitly naming the @capture_instance
EXEC sys.sp_cdc_enable_table 
	@source_schema = N'dbo',
	@source_name = N'charge',
	@role_name = N'cdc_admin',
	@filegroup_name = 'cdc_ChangeTables',
	@supports_net_changes = 1,
	@capture_instance = N'dbo_charge_2',
	@captured_column_list = 'charge_no, charge_amt, charge_code';
GO

-- View capture instance configuration
EXEC sys.sp_cdc_help_change_data_capture;
GO