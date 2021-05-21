
SELECT 
	LEFT(EmpExternalId, 12) AS Persnr, 
    LEFT(EmpEmailAddress, 64) AS Email,
	EmpDateInLabour AS InDienst,
	EmpDateOutLabour AS UitDienst
FROM 
	Ultimo.dba.Employee
WHERE 
	(EmpDateOutLabour IS NULL OR EmpDateOutLabour >= GETDATE()) 
	AND (EmpDateInLabour IS NOT NULL AND EmpDateInLabour <= GETDATE())
	AND (LEFT(EmpEmailAddress, 64) IS NOT NULL) 
	AND (LEFT(EmpEmailAddress, 64) != '')
	--AND LEFT(EmpExternalId, 12) = '246230'
ORDER BY
	LEFT(EmpExternalId, 12) ASC