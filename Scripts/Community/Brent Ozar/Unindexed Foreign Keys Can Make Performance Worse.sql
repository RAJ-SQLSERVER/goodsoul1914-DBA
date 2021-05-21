USE StackOverflow2013;
GO
dbo.DropIndexes;
GO

/* Implement foreign keys: */

ALTER TABLE dbo.Badges WITH NOCHECK
ADD CONSTRAINT fk_badges_users_id
    FOREIGN KEY (UserId)
    REFERENCES dbo.Users (Id);
GO

ALTER TABLE dbo.Comments WITH NOCHECK
ADD CONSTRAINT fk_comments_users_id
    FOREIGN KEY (UserId)
    REFERENCES dbo.Users (Id);
GO

ALTER TABLE dbo.Posts WITH NOCHECK
ADD CONSTRAINT fk_posts_users_id
    FOREIGN KEY (OwnerUserId)
    REFERENCES dbo.Users (Id);
GO

ALTER TABLE dbo.Votes WITH NOCHECK
ADD CONSTRAINT fk_votes_users_id
    FOREIGN KEY (UserId)
    REFERENCES dbo.Users (Id);
GO


/* 
 Delete a specific user 

 TURN ON ACTUAL EXECUTION PLANS !!!
*/

SET STATISTICS IO, TIME ON;
GO

DELETE dbo.Users
WHERE Id = 26837;
GO

SET STATISTICS IO, TIME OFF;
GO


/* Create indexes on all foreign key columns */

CREATE INDEX UserId ON dbo.Badges (UserId);
CREATE INDEX UserId ON dbo.Comments (UserId);
CREATE INDEX OwnerUserId ON dbo.Posts (OwnerUserId);
CREATE INDEX UserId ON dbo.Votes (UserId);
GO


