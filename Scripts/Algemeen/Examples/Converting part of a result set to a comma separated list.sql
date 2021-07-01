USE adventureworks2019;
GO

-- first query showing columns
SELECT c.firstname + ' ' + c.lastname
FROM [HumanResources].[Employee] e
INNER JOIN [Person].Person c ON c.BusinessEntityID = e.BusinessEntityID
ORDER BY c.lastname;
GO

-- second query as csv
SELECT Substring((
			SELECT ', ' + c.firstname + ' ' + c.lastname
			FROM [HumanResources].[Employee] e
			INNER JOIN [Person].[Person] c ON c.BusinessEntityID = e.BusinessEntityID
			ORDER BY c.lastname
			FOR XML PATH('')
			), 3, 10000000) AS list;

-- first query showing columns
SELECT e.JobTitle
	,c.firstname + ' ' + c.lastname
FROM [HumanResources].[Employee] e
INNER JOIN [Person].[Person] c ON c.BusinessEntityID = e.BusinessEntityID
ORDER BY e.JobTitle;

-- Now with the grouping by title, and a csv list for each title
SELECT e.JobTitle
	,(
		SELECT Substring((
					SELECT ', ' + c1.firstname + ' ' + c1.lastname
					FROM [HumanResources].[Employee] e1
					INNER JOIN [Person].[Person] c1 ON c1.BusinessEntityID = e1.BusinessEntityID
					WHERE e1.JobTitle = e.JobTitle
					ORDER BY c1.lastname
					FOR XML PATH('')
					), 3, 10000000) AS list
		) AS employeelist
FROM [HumanResources].[Employee] e
GROUP BY e.JobTitle;

