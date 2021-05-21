/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [NAAM]
      ,[OWNER]
      ,[INSTTYPE]
      ,[SPECCODE]
      ,[VALUE],
	  cast(replace(cast(VALUE as nvarchar(max)),'0.80','0.83') as ntext)
      ,[ETD_STATUS]
  FROM [HIX_PRODUCTIE].[dbo].[CONFIG_INSTVARS]
  WHERE NAAM LIKE 'ZC_HFCHECK' AND OWNER = 'CHIPSOFT'
  
  
  UPDATE [HIX_PRODUCTIE].[dbo].[CONFIG_INSTVARS]
  SET VALUE = cast(replace(cast(VALUE as nvarchar(max)),'0.80','0.83') as ntext)
  WHERE NAAM LIKE 'ZC_HFCHECK' AND OWNER = 'CHIPSOFT'