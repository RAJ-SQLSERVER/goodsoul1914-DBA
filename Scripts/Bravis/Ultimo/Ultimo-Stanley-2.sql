SELECT        
   LEFT(a.EmpFirstName, 64) AS FirstName, LEFT(a._EmpBirthSurName, 64) AS LastName, LEFT(a._EmpBirthMiddleName, 32) AS MiddleName1, LEFT(a.EmpExternalId, 12) AS EmployeeNumber, 
   LEFT(CASE WHEN ISNUMERIC(a.EmpExternalid) = 1 THEN 'Permanent' ELSE 'Tijdelijk' END, 64) AS PersonType, LEFT(b.DepDescr, 64) AS Department, LEFT(ISNULL(a.EmpAddressLine1, N'') 
   + ', ' + ISNULL(a.EmpZipCode, N'') + ' ' + ISNULL(a.EmpCity, N''), 64) AS Address1, REPLACE(CONVERT(varchar, a.EmpBirthDate, 111), '/', '-') AS UserField6, REPLACE(CONVERT(varchar, a.EmpDateInLabour, 
   111), '/', '-') AS UserField11, REPLACE(CONVERT(varchar, a.EmpDateOutLabour, 111), '/', '-') AS UserField12, 
   ISNULL(CASE a._EmpStand WHEN 'Bergen op Zoom' THEN 'BOZ' WHEN 'Roosendaal' THEN 'RSD' ELSE UPPER(LEFT(a._EmpStand, 3)) END, N'ONB') AS UserField19_, LEFT(c._ObjconFunction, 64) 
   AS UserField13, LEFT(LEFT(REPLACE(a.EmpInitials, '.', ''), 1) + '. ' + '(' + a.EmpFirstName + ') ' + a._EmpFormatSurName, 64) AS UserField2, LEFT(c._ObjconFunction, 64) AS UserField3, CONVERT(varchar, 
   GETDATE(), 120) AS UserField4, LEFT(REPLACE(a.EmpInitials, '.', ''), 3) AS Initials, CONVERT(varchar, a.EmpRecCreateDate, 120) AS UserField5, LEFT(a.EmpEmailAddress, 64) AS UserField17, 
   LEFT(CASE EmpGdrId WHEN '0001' THEN 'Man' WHEN '0002' THEN 'Vrouw' ELSE 'O' END, 64) AS UserField14_, LEFT(c._ObjConLabRelation, 64) AS UserField17_, c.ObjconId, c.ObjconEmpId, c._ObjconValidFrom, c._ObjconValidTill
FROM            
   Ultimo.dba.Employee AS a LEFT OUTER JOIN
   Ultimo.dba.ObjectContact AS c ON a.EmpId = c.ObjconEmpId LEFT OUTER JOIN
   Ultimo.dba.Department AS b ON c._ObjconDepId = b.DepId INNER JOIN
   Ultimo.dba.Profession AS d ON c._ObjconFunctionId = d.ProfId
WHERE
	(a.EmpRecStatus >= 0) AND 
	(a.EmpContext = 1) AND 
	(d._ProfDoNotExport = 0) AND 
	(c.ObjconRecStatus >= 0) AND 
	LEFT(a.EmpExternalId, 12) = '41480' AND 
	(c.ObjconId = --'0493244')
      (SELECT TOP (1) ObjconId
       FROM Ultimo.dba.ObjectContact
       WHERE (ObjconEmpId = c.ObjconEmpId) AND (_ObjconValidFrom <= DATEADD(d, 30, GETDATE()) OR _ObjconValidFrom IS NULL) AND (_ObjconValidTill >= GETDATE() OR _ObjconValidTill IS NULL)
       ORDER BY _ObjconLabourPart DESC, ObjconCreateDate DESC))


SELECT TOP (10) *,ObjconRecStatus
FROM Ultimo.dba.ObjectContact
WHERE (ObjconEmpId = '048992') AND (_ObjconValidFrom <= DATEADD(d, 30, GETDATE()) OR _ObjconValidFrom IS NULL) AND (_ObjconValidTill >= GETDATE() OR _ObjconValidTill IS NULL)
ORDER BY _ObjconLabourPart DESC, ObjconCreateDate DESC