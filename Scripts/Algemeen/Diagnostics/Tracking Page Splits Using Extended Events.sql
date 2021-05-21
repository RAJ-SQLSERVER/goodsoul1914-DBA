
SET NOCOUNT ON
USE tempdb
GO

-- create table T1
-- drop table t1

CREATE TABLE dbo.T1
(
	c1_c1 UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
	c1_testdata CHAR(1950) NOT NULL DEFAULT('sqlservergeeks.com')
)
GO

CREATE UNIQUE CLUSTERED INDEX idx_c1_c1 ON dbo.T1(c1_c1)
GO



-- Setup extended event session
CREATE EVENT SESSION [page_splits]
ON SERVER
    ADD EVENT sqlserver.page_split
    (ACTION
     (
         sqlserver.session_id,
         sqlserver.sql_text
     )
    )
    ADD TARGET package0.ring_buffer
WITH
(
    STARTUP_STATE = OFF
);
GO



-- Insert rows (run for a few seconds then stop)
SET NOCOUNT OFF
USE tempdb

TRUNCATE TABLE dbo.T1;

DECLARE @count AS INT
SET @count = 0;

WHILE @count <= 1000000
BEGIN
	INSERT INTO dbo.T1 DEFAULT VALUES
	SET @count = @count + 1
END
