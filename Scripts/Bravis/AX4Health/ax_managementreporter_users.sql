/****** Script for SelectTopNRows command from SSMS  ******/
SELECT SU.WindowsSecurityIdentifier, SP.Name, SP.ID, SU.UserName, SP.IsDeleted
  FROM [SecurityUser] AS SU 
  RIGHT JOIN [SecurityPrincipal] AS SP
  ON SU.[UserID] = SP.ID
  WHERE SP.IsGroup = 0 AND SP.Name != 'Management Reporter'
  ORDER BY SP.Name ASC