-- File, Page and Slot info
---------------------------------------------------------------------------------------------------
USE [SQLServerInternals];

SELECT OrderId,
	'Location(File:Page:Slot)' = sys.fn_PhysLocFormatter(% % physloc % %),
	KeyHashValue = % % lockres % %
FROM dbo.Orders WITH (INDEX = IDX_Orders_CustomerId);
