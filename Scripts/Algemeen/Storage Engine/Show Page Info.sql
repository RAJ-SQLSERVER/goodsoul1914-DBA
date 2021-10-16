-- Non-clustered indexes
-- ------------------------------------------------------------------------------------------------
SELECT *
FROM sys.dm_db_index_physical_stats (DB_ID ('StackOverflow2010'), OBJECT_ID ('Users'), NULL, NULL, 'DETAILED');
GO

-- Create a helper table
CREATE TABLE sp_table_pages (
    PageFID         TINYINT,
    PagePID         INT,
    IAMFID          TINYINT,
    IAMPID          INT,
    ObjectID        INT,
    IndexID         TINYINT,
    PartitionNumber TINYINT,
    PartitionID     BIGINT,
    IAM_ChainType   VARCHAR(30),
    PageType        TINYINT,
    IndexLevel      TINYINT,
    NextPageFID     TINYINT,
    NextPagePID     INT,
    PrevPageFID     TINYINT,
    PrevPagePID     INT,
    PRIMARY KEY (PageFID, PagePID)
);
GO

INSERT INTO sp_table_pages
EXEC ('DBCC IND(StackOverflow2010, Users, 3)'); -- DB_ID(), Table, Index ID
GO

SELECT *
FROM sp_table_pages
WHERE IndexLevel = 2;
GO

-- get the PagePID
DBCC TRACEON(3604);
GO

-- Dump out the root index page
DBCC PAGE('StackOverflow2010', 1, 1104520, 3); -- DB, FileNo, PageNo, Opt
GO

-- Dump out the intermediate level index page
DBCC PAGE('StackOverflow2010', 1, 1104976, 3);
GO

-- Dump out the leaf-level index page
DBCC PAGE('StackOverflow2010', 1, 1104848, 3);
GO

DROP TABLE sp_table_pages;
GO


