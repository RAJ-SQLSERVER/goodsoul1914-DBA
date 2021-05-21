-- www.qdpma.com/SQL/SqlScripts.html
-- updates 2018-03-06 
-- 2018-04-08 sys.stats is_incremental 

if exists (select *
		   from sys.procedures
		   where object_id = OBJECT_ID('sp_helpindex2')) 
	drop procedure dbo.sp_helpindex2; 
go 

create procedure dbo.sp_helpindex2 
	@objname nvarchar(776)
as
begin
	declare @objid  int, 
			@dbname sysname; 
	-- Check to see that the object names are local to the current database. 
	select @dbname = PARSENAME(@objname, 3);
	if @dbname is null
		select @dbname = DB_NAME();
	else
		if @dbname <> DB_NAME()
		begin
			raiserror(15250, -1, -1);
			return 1;
		end; 
	-- Check to see the the table exists and initialize @objid. 
	select @objid = OBJECT_ID(@objname);
	if @objid is null
	begin
		raiserror(15009, -1, -1, @objname, @dbname);
		return 1;
	end;
	with b
		 as (select d.object_id, 
					d.index_id, 
					part = COUNT(*), 
					pop = SUM(case row_count
								  when 0 then 0
							  else 1
							  end), 
					reserved = 8 * SUM(d.reserved_page_count), 
					used = 8 * SUM(d.used_page_count), 
					in_row_data = 8 * SUM(d.in_row_data_page_count), 
					lob_used = 8 * SUM(d.lob_used_page_count), 
					overflow = 8 * SUM(d.row_overflow_used_page_count), 
					row_count = SUM(row_count), 
					notcompressed = SUM(case data_compression
											when 0 then 1
										else 0
										end), 
					compressed = SUM(case data_compression
										 when 0 then 0
									 else 1
									 end) -- change to 0 for SQL Server 2005 
			 from sys.dm_db_partition_stats as d with(nolock)
			 inner join sys.partitions as r with(nolock) on r.partition_id = d.partition_id
			 group by d.object_id, 
					  d.index_id),
		 j
		 as (select j.object_id, 
					j.index_id, 
					j.key_ordinal, 
					c.column_id, 
					c.name, 
					j.is_descending_key, 
					j.is_included_column, 
					j.partition_ordinal
			 from sys.index_columns as j
			 inner join sys.columns as c on c.object_id = j.object_id
											and c.column_id = j.column_id)
		 select ISNULL(i.name, '') as [index], 
				ISNULL(STUFF( (select ', ' + name + case is_descending_key
														when 1 then '-'
													else ''
													end + case partition_ordinal
															  when 1 then '*'
														  else ''
														  end
							   from j
							   where j.object_id = i.object_id
									 and j.index_id = i.index_id
									 and j.key_ordinal > 0
							   order by j.key_ordinal for xml path(''), type, root) .value('root[1]', 'nvarchar(max)'), 1, 1, ''), '') as Keys, 
				ISNULL(STUFF( (select ', ' + name + case partition_ordinal
														when 1 then '*'
													else ''
													end
							   from j
							   where j.object_id = i.object_id
									 and j.index_id = i.index_id
									 and ( j.is_included_column = 1
										   or j.key_ordinal = 0
										   and partition_ordinal = 1 )
							   order by j.column_id for xml path(''), type, root) .value('root[1]', 'nvarchar(max)'), 1, 1, ''), '') as Incl, 
				--, j.name AS ptky  
				i.index_id,
				case
					when i.is_primary_key = 1 then 'PK'
					when i.is_unique_constraint = 1 then 'UC'
					when i.is_unique = 1 then 'U'
					when i.type = 0 then 'heap'
					when i.type = 3 then 'X'
					when i.type = 4 then 'S'
				  else CONVERT(char, i.type)
				end as typ, 
				i.data_space_id as dsi, 
				b.row_count, 
				b.in_row_data as in_row, 
				b.overflow as ovf, 
				b.lob_used as lob, 
				b.reserved - b.in_row_data - b.overflow - b.lob_used as unu, 
				'ABR' = case row_count
							when 0 then 0
						else 1024 * used / row_count
						end, 
				y.user_seeks, 
				y.user_scans as u_scan, 
				y.user_lookups as u_look, 
				y.user_updates as u_upd, 
				b.notcompressed as ncm, 
				b.compressed as cmp, 
				b.pop, 
				b.part, 
				rw_delta = b.row_count - s.rows, 
				s.rows_sampled, --, s.unfiltered_rows  
				s.modification_counter as mod_ctr, 
				s.steps, 
				CONVERT(varchar, s.last_updated, 120) as updated, 
				i.is_disabled as dis, 
				i.is_hypothetical as hyp, 
				ISNULL(i.filter_definition, '') as filt, 
				t.no_recompute as no_rcp, 
				t.is_incremental as incr
		 from sys.objects as o
		 join sys.indexes as i on i.object_id = o.object_id
		 left join sys.stats as t on t.object_id = o.object_id
									 and t.stats_id = i.index_id
		 left join b on b.object_id = i.object_id
						and b.index_id = i.index_id
		 left join sys.dm_db_index_usage_stats as y on y.object_id = i.object_id
													   and y.index_id = i.index_id
													   and y.database_id = DB_ID()
		 outer apply sys.dm_db_stats_properties(i.object_id, i.index_id) as s 
		 --LEFT JOIN j ON j.object_id = i.object_id AND j.index_id = i.index_id AND j.partition_ordinal = 1 
		 where i.object_id = @objid;
end; 
go 

-- Then mark the procedure as a system procedure. 
exec sys.sp_MS_marksystemobject 'sp_helpindex2'; -- skip this for Azure 
go 

select NAME, 
	   IS_MS_SHIPPED
from SYS.OBJECTS
where NAME like 'sp_helpindex%'; 
go 
