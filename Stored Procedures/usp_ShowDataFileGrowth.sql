IF OBJECTPROPERTY(OBJECT_ID('usp_ShowDataFileGrowth'), 'IsProcedure') = 1
    DROP PROCEDURE dbo.usp_ShowDataFileGrowth;
GO

CREATE OR ALTER PROC dbo.usp_ShowDataFileGrowth (
    @StartDate DATETIME2 = NULL
)
AS
BEGIN
	IF @StartDate IS NULL
		SET @StartDate = DATEADD(WEEK, -1, GETDATE());

    DECLARE @columns NVARCHAR(MAX) = N'',
            @sql     NVARCHAR(MAX) = N'';

    SELECT   @columns += QUOTENAME(CheckDate) + N','
    FROM     (
        SELECT DISTINCT
               CONVERT(VARCHAR(10), CheckDate, 105) AS CheckDate
        FROM   dbo.DiskSpace
		WHERE CheckDate >= @StartDate
    ) AS tbl
    ORDER BY CheckDate;

    SET @columns = LEFT(@columns, LEN(@columns) - 1);
    PRINT @columns;

    SET @sql
        = N'
		SELECT *
		FROM   (
			SELECT convert(varchar, CheckDate, 105) AS CheckDate, ComputerName, Name, PercentFree
			FROM dbo.DiskSpace dbi
		) tbl
		PIVOT (
			AVG(PercentFree) FOR CheckDate IN (' + @columns + N')
		) AS pvt';

    EXECUTE sp_executesql @sql;
END;
GO
