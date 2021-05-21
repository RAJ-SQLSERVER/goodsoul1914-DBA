/*
 DBCC SQLPERF(logspace) - Only one database, or with conditions.
*/

-- optional parameters
DECLARE @dbname VARCHAR(155) = NULL,
        @SpaceUsed FLOAT = 70;

DECLARE @LOGSPACE TABLE
(
    dbName VARCHAR(155),
    LogSizeMB FLOAT,
    [LogSpaceUsed%] FLOAT,
    [Status] INT
);

INSERT @LOGSPACE
EXEC ('DBCC SQLPERF(''logspace'')');

-- Now pull it back for review
-- if your optional parms are null, you return log usage for all databases

SELECT dbName,
       LogSizeMB,
       [LogSpaceUsed%],
       [Status]
FROM @LOGSPACE
WHERE (
          dbName = @dbname
          OR @dbname IS NULL
      )
      AND
      (
          [LogSpaceUsed%] >= @SpaceUsed
          OR @SpaceUsed IS NULL
      );
GO
