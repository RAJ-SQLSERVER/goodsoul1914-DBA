IF OBJECTPROPERTY(OBJECT_ID('usp_ShowDataFileGrowth'), 'IsProcedure') = 1
    DROP PROCEDURE dbo.usp_ShowDataFileGrowth;
GO

CREATE PROC dbo.usp_ShowDataFileGrowth (
    @StartDate DATETIME2 = NULL
)
AS
BEGIN
	IF @StartDate IS NULL
		SET @StartDate = DATEADD(MONTH, -30, GETDATE());

    DECLARE @columns NVARCHAR(MAX) = N'',
            @sql     NVARCHAR(MAX) = N'';

    SELECT   @columns += QUOTENAME(CollectionTime) + N','
    FROM     (
        SELECT DISTINCT
               CONVERT(VARCHAR(10), CollectionTime, 105) AS CollectionTime
        FROM   dbo.DatabaseInfo
		WHERE CollectionTime >= @StartDate
    ) AS tbl
    ORDER BY CollectionTime;

    SET @columns = LEFT(@columns, LEN(@columns) - 1);
    --PRINT @columns;

    SET @sql
        = N'
		SELECT *
		FROM   (
			SELECT convert(varchar, CollectionTime, 105) AS CollectionTime, DatabaseName, DataSpaceUtilMB
			FROM dbo.DatabaseInfo dbi
		) tbl
		PIVOT (
			AVG(DataSpaceUtilMB) FOR CollectionTime IN (' + @columns + N')
		) AS pvt';

    EXECUTE sp_executesql @sql;
END;
GO
