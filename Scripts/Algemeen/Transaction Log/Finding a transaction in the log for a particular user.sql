/* Finding a transaction in the log for a particular user */

SELECT SUSER_SID ('DT-RSD-01\mboom') AS "SID";
GO -- 0x0105000000000005150000009ADDE4C64D08E6689D6E3E14E9030000


SELECT [Current LSN],
       Operation,
       [Transaction ID],
       [Begin Time],
       LEFT(Description, 40) AS "Description"
FROM fn_dblog (NULL, NULL)
WHERE [Transaction SID] = SUSER_SID ('DT-RSD-01\mboom');
GO


SELECT [Current LSN],
       Operation,
       [Transaction ID],
       [Begin Time],
       LEFT(Description, 40) AS "Description"
FROM fn_dblog (NULL, NULL)
WHERE [Transaction SID] = SUSER_SID ('DT-RSD-01\mboom')
      AND (
          [Begin Time] > '2021/09/13 11:18:15'
          AND [Begin Time] < '2021/10/11 11:18:25'
      );
GO