DECLARE @percentThreshold INT = 70;

SELECT t.name AS [table],
       c.name AS [column],
       ty.name AS [type],
       IDENT_CURRENT(t.name) AS [identity],
       100 * IDENT_CURRENT(t.name) / 2147483647 AS [percent full]
FROM sys.tables t
    JOIN sys.columns c
        ON c.object_id = t.object_id
    JOIN sys.types ty
        ON ty.system_type_id = c.system_type_id
WHERE c.is_identity = 1
      AND ty.name = 'int'
      AND 100 * IDENT_CURRENT(t.name) / 2147483647 > @percentThreshold
ORDER BY t.name;