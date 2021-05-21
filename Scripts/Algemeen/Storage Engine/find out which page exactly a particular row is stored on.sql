-- Find out which page a particular row is stored on
USE BabbyNames
GO
SELECT sys.fn_PhysLocFormatter(%%physloc%%) as [File:Page:Slot], *
FROM ref.FirstName WITH (INDEX(ix_FirstName_FirstName)) 
GO





USE StackOverflow2013
GO
SELECT sys.fn_PhysLocFormatter(%%physloc%%) as [File:Page:Slot], *
FROM dbo.Users WITH (INDEX(PK_Users_Id)) 
GO
