/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [MV_FZR_ARCHIVE].[dbo].[Parameters]
  WHERE ParameterID = 6624

SELECT *
  FROM [MV_FZR].[dbo].[Parameters]
  WHERE ParameterID = 6624

SELECT * 
  FROM [MV_FZR_ARCHIVE].[dbo].[DatabaseSettings]
  WHERE ID = 1

SELECT * 
  FROM [MV_FZR].[dbo].[DatabaseSettings]
  WHERE ID = 1


UPDATE [MV_FZR_ARCHIVE].[dbo].[Parameters]
  SET SingleValue = 1
  WHERE ParameterID = 6624

UPDATE [MV_FZR].[dbo].[Parameters]
  SET SingleValue = 1
  WHERE ParameterID = 6624

UPDATE [MV_FZR_ARCHIVE].[dbo].[DatabaseSettings]
  SET [EMPIServerName] = '13-024-0042'
  WHERE ID = 1

UPDATE [MV_FZR].[dbo].[DatabaseSettings]
  SET [EMPIServerName] = '13-024-0042'
  WHERE ID = 1


