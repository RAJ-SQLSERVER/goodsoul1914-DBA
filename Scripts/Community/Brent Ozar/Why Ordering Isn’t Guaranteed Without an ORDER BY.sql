USE StackOverflow2010;
GO

SELECT Id,
       DisplayName,
       Location
FROM dbo.Users;
GO
-- PK_Users_Id

CREATE INDEX IX_DisplayName_Location ON dbo.Users (DisplayName, location);
GO

SELECT Id,
       DisplayName,
       Location
FROM dbo.Users;
GO
-- IX_DisplayName_Location (more narrow than the clustered index (The Table))

sp_BlitzIndex @TableName = 'Users';
GO
--dbo.Users.IX_DisplayName_Location (3)		299,398 rows; 13.1MB
--dbo.Users.PK_Users_Id (1)					299,398 rows; 58.1MB

SELECT *
FROM dbo.Users
WHERE DisplayName LIKE 'Brent%';
GO
-- Results come back in DisplayName order

SELECT *
FROM dbo.Users
WHERE DisplayName LIKE 'Alex%';
GO
-- PK_Users_Id -> so not in order of DisplayName


-- One way to be sure: use ORDER BY
SELECT *
FROM dbo.Users
WHERE DisplayName LIKE 'Alex%'
ORDER BY DisplayName,
         Location;