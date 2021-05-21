/****************************************************************************/
/*                       Pro SQL Server Internals                           */
/*      APress. 2nd Edition. ISBN-13: 978-1484219638 ISBN-10:1484219635     */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                      http://aboutsqlserver.com                           */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*             Chapter 04. Special Indexng and Storage Feautes              */
/*   Estimating Compression space Savings For All Tables in the Database    */
/****************************************************************************/
SET NOCOUNT ON;
GO

USE [SqlServerInternals];
GO

IF OBJECT_ID(N'tempdb..#CompressionData') IS NOT NULL
	DROP TABLE #CompressionData;

IF OBJECT_ID(N'tempdb..#CompressionResults') IS NOT NULL
	DROP TABLE #CompressionResults;
GO

CREATE TABLE #CompressionResults (
	object_name SYSNAME NOT NULL,
	schema_name SYSNAME NOT NULL,
	index_id INT NOT NULL,
	partition_number INT NOT NULL,
	[size_with_current_compressions_setting(KB)] BIGINT NOT NULL,
	[size_with_requested_compressions_setting(KB)] BIGINT NOT NULL,
	[sample_size_with_current_compressions_setting(KB)] BIGINT NOT NULL,
	[sample_size_with_requested_compressions_setting(KB)] BIGINT NOT NULL,
	PRIMARY KEY (
		schema_name,
		object_name,
		index_id,
		partition_number
		)
	);

CREATE TABLE #CompressionData (
	ObjectId INT NOT NULL,
	IndexId INT NOT NULL,
	PartitionNum INT NOT NULL,
	TableName SYSNAME NOT NULL,
	IndexName SYSNAME NULL,
	IndexType SYSNAME NOT NULL,
	CurrentCompression CHAR(5) NOT NULL,
	CurrentSizeMB DECIMAL(12, 3) NOT NULL,
	EstimatedSizeNoneMB DECIMAL(12, 3) NOT NULL,
	EstimatedSizeRowMB DECIMAL(12, 3) NOT NULL,
	EstimatedSizePageMB DECIMAL(12, 3) NOT NULL,
	PRIMARY KEY (
		TableName,
		IndexId,
		PartitionNum
		)
	);

DECLARE @object_id INT = - 1,
	@Table SYSNAME,
	@Index INT,
	@Schema SYSNAME;

WHILE 1 = 1
BEGIN
	SELECT TOP 1 @object_id = t.object_id,
		@Schema = s.name,
		@Table = t.name
	FROM sys.tables AS t WITH (NOLOCK)
	JOIN sys.schemas AS s WITH (NOLOCK) ON t.schema_id = s.schema_id
	WHERE t.object_id > @object_id
		AND t.is_ms_shipped = 0 -- and t.is_memory_optimized = 0 
	ORDER BY t.object_id;

	IF @@rowcount = 0
		BREAK;

	RAISERROR (
			'Table %s.%s.',
			0,
			1,
			@Schema,
			@Table
			)
	WITH NOWAIT;

	TRUNCATE TABLE #CompressionResults;

	INSERT INTO #CompressionResults
	EXEC sp_estimate_data_compression_savings @schema_name = @Schema,
		@object_name = @Table,
		@index_id = NULL,
		@partition_number = NULL,
		@data_compression = 'none';

	INSERT INTO #CompressionData (
		ObjectId,
		IndexId,
		PartitionNum,
		TableName,
		IndexName,
		IndexType,
		CurrentCompression,
		CurrentSizeMB,
		EstimatedSizeNoneMB,
		EstimatedSizeRowMB,
		EstimatedSizePageMB
		)
	SELECT @object_id,
		r.index_id,
		r.partition_number,
		@Schema + '.' + @Table,
		i.name,
		i.type_desc,
		p.data_compression_desc,
		[size_with_current_compressions_setting(KB)] / 1024.0,
		[size_with_requested_compressions_setting(KB)] / 1024.,
		0,
		0
	FROM #CompressionResults AS r
	LEFT JOIN sys.indexes AS i WITH (NOLOCK) ON i.object_id = @object_id
		AND r.index_id = i.index_id
	JOIN sys.partitions AS p WITH (NOLOCK) ON p.object_id = @object_id
		AND r.index_id = p.index_id
		AND r.partition_number = p.partition_number
	WHERE i.type IN (0, 1, 2)
		AND i.is_disabled = 0;

	TRUNCATE TABLE #CompressionResults;

	INSERT INTO #CompressionResults
	EXEC sp_estimate_data_compression_savings @schema_name = @Schema,
		@object_name = @Table,
		@index_id = NULL,
		@partition_number = NULL,
		@data_compression = 'row';

	UPDATE t
	SET t.EstimatedSizeRowMB = r.[size_with_requested_compressions_setting(KB)] / 1024.0
	FROM #CompressionData t
	JOIN #CompressionResults r ON t.ObjectId = @object_id
		AND t.IndexId = r.index_id
		AND t.PartitionNum = r.partition_number;

	TRUNCATE TABLE #CompressionResults;

	INSERT INTO #CompressionResults
	EXEC sp_estimate_data_compression_savings @schema_name = @Schema,
		@object_name = @Table,
		@index_id = NULL,
		@partition_number = NULL,
		@data_compression = 'page';

	UPDATE t
	SET t.EstimatedSizePageMB = r.[size_with_requested_compressions_setting(KB)] / 1024.0
	FROM #CompressionData t
	JOIN #CompressionResults r ON t.ObjectId = @object_id
		AND t.IndexId = r.index_id
		AND t.PartitionNum = r.partition_number;
END;

-- Raw data
SELECT *
FROM #CompressionData;

-- On per-index basis. Always take volatility of the data into consideration
WITH Data
AS (
	SELECT IndexId,
		TableName,
		IndexName,
		IndexType,
		SUM(CurrentSizeMB) AS [Current Size MB],
		SUM(EstimatedSizeNoneMB) AS [Estimated Size No Compression MB],
		SUM(EstimatedSizeRowMB) AS [Estimated Size Row Compression MB],
		SUM(EstimatedSizePAgeMB) AS [Estimated Size Page Compression MB]
	FROM #CompressionData
	GROUP BY IndexId,
		TableName,
		IndexName,
		IndexType
	)
SELECT *
FROM Data
WHERE [Current Size MB] > 0
ORDER BY [Current Size MB] / CASE 
		WHEN [Estimated Size Row Compression MB] = 0
			THEN [Current Size MB]
		ELSE [Estimated Size Row Compression MB]
		END DESC;
