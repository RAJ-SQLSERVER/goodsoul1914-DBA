-------------------------------------------------------------------------------
-- Show all SQL-related services
-------------------------------------------------------------------------------

DECLARE @WindowsSvc TABLE (results VARCHAR(MAX) NULL)

INSERT INTO @WindowsSvc
EXEC xp_cmdshell 'net start';

SELECT results
FROM @WindowsSvc
WHERE results LIKE '%SQL%';
