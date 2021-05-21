-- https://sqlhints.com/tag/how-to-get-index-root-page/
--

create function dbo.udf_GetPagesOfBPlusTreeLevel
(
	@DBName         varchar(100), 
	@TableName      varchar(100) = null, 
	@IndexName      varchar(100) = null, 
	@PartionId      int          = null, 
	@MODE           varchar(20), 
	@BPlusTreeLevel varchar(20)) 
returns @IndexPageInformation table
(
	[DataBase]       varchar(100), 
	[Table]          varchar(100), 
	[Index]          varchar(100), 
	partition_id     int, 
	file_id          int, 
	page_id          int, 
	page_type_desc   varchar(100), 
	page_level       int, 
	previous_page_id int, 
	next_page_id     int) 
as
	begin
		declare @MinPageLevelId int = 0, 
				@MaxPageLevelId int = 0, 
				@IndexId        int = null;

		select @IndexId = index_id
		from sys.indexes
		where OBJECT_NAME(object_id) = @TableName
			  and name = @IndexName;

		if @IndexId is null
			return;

		if @BPlusTreeLevel in('Root', 'Intermediate')
		begin
			select @MaxPageLevelId = case
										 when @BPlusTreeLevel = 'Intermediate' then MAX(page_level) - 1
									 else MAX(page_level)
									 end, 
				   @MinPageLevelId = case
										 when @BPlusTreeLevel = 'Intermediate' then 1
									 else MAX(page_level)
									 end
			from sys.dm_db_database_page_allocations(DB_ID(@DBName), OBJECT_ID(@TableName), @IndexId, @PartionId, 'DETAILED') as PA
				 left outer join sys.indexes as SI on SI.object_id = PA.object_id
													  and SI.index_id = PA.index_id
			where is_allocated = 1
				  and page_type in (1, 2); -- INDEX_PAGE and DATA_PAGE Only

			if @MaxPageLevelId is null
			   or @MaxPageLevelId = 0
				return;
		end;

		insert into @IndexPageInformation
		select DB_NAME(PA.database_id) as [DataBase], 
			   OBJECT_NAME(PA.object_id) as [Table], 
			   SI.Name as [Index], 
			   partition_id, 
			   allocated_page_file_id as file_id, 
			   allocated_page_page_id as page_id, 
			   page_type_desc, 
			   page_level, 
			   previous_page_page_id as previous_page_id, 
			   next_page_page_id as next_page_id
		from sys.dm_db_database_page_allocations(DB_ID(@DBName), OBJECT_ID(@TableName), @IndexId, @PartionId, 'DETAILED') as PA
			 left outer join sys.indexes as SI on SI.object_id = PA.object_id
												  and SI.index_id = PA.index_id
		where is_allocated = 1
			  and page_type in (1, 2) -- INDEX_PAGE and DATA_PAGE Only   
			  and page_level between @MinPageLevelId and @MaxPageLevelId
		order by page_level desc, 
				 previous_page_page_id;

		return;
	end;
go

SELECT 'Root', *
FROM dbo.udf_GetPagesOfBPlusTreeLevel('Playground', 'CustomersTable', 'idx_c1', NULL, 'DETAILED', 'Root')

SELECT 'Intermediate', *
FROM dbo.udf_GetPagesOfBPlusTreeLevel('Playground', 'CustomersTable', 'idx_c1' , NULL, 'DETAILED', 'Intermediate')

SELECT 'Leaf', *
FROM dbo.udf_GetPagesOfBPlusTreeLevel('Playground', 'CustomersTable', 'idx_c1', NULL, 'DETAILED', 'Leaf')


DBCC TRACEON(3604)
DBCC PAGE('Playground', 1, 69017, 2) WITH TABLERESULTS
GO