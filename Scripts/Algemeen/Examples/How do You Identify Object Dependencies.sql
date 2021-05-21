SELECT ROUTINE_NAME,
       ROUTINE_TYPE
FROM   INFORMATION_SCHEMA.ROUTINES
WHERE  ROUTINE_DEFINITION LIKE '%Employee%';
GO


EXEC sp_depends @objname = N'HumanResources.Employee';
GO


SELECT     DISTINCT
           so.name
FROM       syscomments AS sc
INNER JOIN sysobjects AS so
    ON sc.id = so.id
WHERE      CHARINDEX('Employee', text) > 0;


-- Value 131527 shows objects that are dependent on the specified object
EXEC sp_MSdependencies @objname = N'HumanResources.[Employee]',
                       @objtype = NULL,
                       @flags = 1315327;
GO

-- Value 1053183 shows objects that the specified object is dependent on
EXEC sp_MSdependencies @objname = N'HumanResources.[Employee]',
                       @objtype = NULL,
                       @flags = 1053183;
GO
