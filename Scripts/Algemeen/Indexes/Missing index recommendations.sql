/******************************************************************************

 About Missing index recommendations

 * They’re not going to consider columns outside of the WHERE clause to be in 
   the key of the index
 * If your where clause doesn’t have an equality predicate, it’s a lot harder 
   to get missing index requests
 * Columns that would be helpful to have in index order won’t end up in the key 
   if they’re not in the WHERE
 * Even the order of columns suggested for being in the key of the index isn’t 
   scientific

******************************************************************************/


USE StackOverflow2013;
GO

dbo.DropIndexes
GO


/* Inequality predicate */
SELECT c.CreationDate,
       c.PostId,
       c.Score,
       c.Text,
       c.UserId
FROM dbo.Comments AS c
WHERE c.Score >= 1270 -- Hello I'm here
      AND c.CreationDate >= '20110101'
      AND c.CreationDate < '20120101'
ORDER BY c.CreationDate DESC;

/* Equality predicate */
SELECT c.CreationDate,
       c.PostId,
       c.Score,
       c.Text,
       c.UserId
FROM dbo.Comments AS c
WHERE c.Score = 1270 -- Hello I'm here
      AND c.CreationDate >= '20110101'
      AND c.CreationDate < '20120101'
ORDER BY c.CreationDate DESC;


CREATE NONCLUSTERED INDEX Score_CreationDate_Inc
ON [dbo].[Comments] ([Score],[CreationDate])
INCLUDE ([PostId],[Text],[UserId])