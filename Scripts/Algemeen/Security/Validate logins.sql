IF (OBJECT_ID('tempdb..#invalidlogins') IS NOT NULL)
BEGIN
    DROP TABLE #invalidlogins;
END;

CREATE TABLE #invalidlogins
(
    ACCTSID VARBINARY(85) NOT NULL,
    NTLOGIN sysname NOT NULL
);

INSERT INTO #invalidlogins
EXEC sys.sp_validatelogins;

SELECT NTLOGIN
FROM #invalidlogins
ORDER BY 1;