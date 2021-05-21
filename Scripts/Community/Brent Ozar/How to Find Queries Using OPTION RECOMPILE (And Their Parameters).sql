/*

Run a sp_HumanEvents trace in another query window:

EXEC dbo.sp_HumanEvents @event_type = 'compilations', @seconds_sample = 30;

or

EXEC dbo.sp_HumanEvents @event_type = 'recompilations', @seconds_sample = 30;

*/
DropIndexes;
GO

CREATE INDEX Location ON dbo.Users (location);
CREATE INDEX CreationDate ON dbo.Comments (CreationDate);
GO

CREATE OR ALTER PROC dbo.usp_SearchUsers @Location  NVARCHAR(100),
                                         @StartDate DATETIME,
                                         @EndDate   DATETIME
AS
    BEGIN
        SELECT TOP (1000) *
        FROM dbo.Users AS u
        INNER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
        WHERE u.Location = @Location
              AND c.CreationDate >= @StartDate
              AND c.CreationDate <= @EndDate
        ORDER BY c.Score DESC
        OPTION (RECOMPILE);
    END;
GO

EXEC usp_SearchUsers @Location = 'London, United Kingdom',
                     @StartDate = '2010-01-01',
                     @EndDate = '2010-01-02';
GO 50

EXEC usp_SearchUsers @Location = 'Near Stonehenge',
                     @StartDate = '2010-01-01',
                     @EndDate = '2010-12-31';
GO 50

GO


CREATE OR ALTER PROC dbo.usp_SearchUsers_Encrypted @Location  NVARCHAR(100),
                                                   @StartDate DATETIME,
                                                   @EndDate   DATETIME
WITH ENCRYPTION
AS
    BEGIN
        SELECT TOP (1000) *
        FROM dbo.Users AS u
        INNER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
        WHERE u.Location = @Location
              AND c.CreationDate >= @StartDate
              AND c.CreationDate <= @EndDate
        ORDER BY c.Score DESC
        OPTION (RECOMPILE);
    END;
GO

EXEC usp_SearchUsers_Encrypted @Location = 'London, United Kingdom',
                               @StartDate = '2010-01-01',
                               @EndDate = '2010-01-02';
GO 50

EXEC usp_SearchUsers_Encrypted @Location = 'Near Stonehenge',
                               @StartDate = '2010-01-01',
                               @EndDate = '2010-12-31';
GO 50

GO



CREATE OR ALTER PROC dbo.usp_SearchUsers_Stable @Location  NVARCHAR(100),
                                                @StartDate DATETIME,
                                                @EndDate   DATETIME
AS
    BEGIN
        SELECT TOP (1000) *
        FROM dbo.Users AS u
        INNER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
        WHERE u.Location = @Location
              AND c.CreationDate >= @StartDate
              AND c.CreationDate <= @EndDate
        ORDER BY c.Score DESC;
    END;
GO

EXEC usp_SearchUsers_Stable @Location = 'London, United Kingdom',
                            @StartDate = '2010-01-01',
                            @EndDate = '2010-01-02';
GO 10

ALTER TABLE dbo.Users REBUILD;
GO

EXEC usp_SearchUsers_Stable @Location = 'London, United Kingdom',
                            @StartDate = '2010-01-01',
                            @EndDate = '2010-01-02';
GO 10
GO
