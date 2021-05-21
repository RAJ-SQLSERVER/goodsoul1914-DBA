USE AdventureWorks2014
GO

-- If the object is not in the dbo schema, you will need to include the 
-- schema and include single quotes like below.
sp_helptext @objname = 'Sales.SalesOrderDetail';
GO

-- If the object is in the dbo scheme it will look like this, single quotes not needed
sp_helptext @objname = uspGetBillOfMaterials;
GO

-- I really like to use sp_helptext when I have multiple objects that I need script. 
-- However, there is a bit of a catch.  If you try to run it without the GO keyword 
-- between you will receive this error.
sp_helptext @objname = uspGetBillOfMaterials;
sp_helptext @objname = uspUpdateEmployeeHireInfo;
GO

-- The second parameter only works on calculated columns
sp_helptext @objname = N'Sales.SalesOrderHeader',
            @columnname = salesordernumber;
GO

-- This code will return the definition of the uAddress trigger
SELECT OBJECT_DEFINITION (OBJECT_ID(N'Person.uAddress')) AS [Trigger Definition];
GO

