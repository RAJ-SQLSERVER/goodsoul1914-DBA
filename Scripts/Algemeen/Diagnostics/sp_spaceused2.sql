-- www.qdpma.com/SQL/SqlScripts.html
-- comment 2018-10-04 
-- if the intent is to call this procedure frequently with any of the three optional parameters 
-- then consider replacing the first CTE with a temp table or table variable 
-- and using a statement level recompile to insert into the temp table: OPTION (RECOMPILE) 
-- 
-- update 2018-02-24 
-- update 2018-10-11: now using table variables in place of CTEs 
use master; -- skip this on Azure
go 
if exists (select *
		   from sys.procedures
		   where object_id = OBJECT_ID('sp_spaceused2')) 
	drop procedure dbo.sp_spaceused2; 
go 
create procedure dbo.sp_spaceused2 
	@objname nvarchar(776) = null, 
	@psid    int           = null, 
	@minrow  int           = 0
as
begin
	set nocount on;
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

	declare @ClK table
	(
		object_id int
		primary key, 
		ClKey     varchar(4000));
	with j1
		 as (select j.object_id, 
					j.index_id, 
					j.key_ordinal, 
					c.column_id, 
					c.name, 
					is_descending_key
			 from sys.index_columns as j
				  inner join sys.columns as c on c.object_id = j.object_id
												 and c.column_id = j.column_id)
		 insert into @ClK
		 select c.object_id, 
				ISNULL(STUFF( (select ', ' + name + case is_descending_key
														when 1 then '-'
													else ''
													end
							   from j1
							   where j1.object_id = c.object_id
									 and j1.index_id = 1
									 and j1.key_ordinal > 0
							   order by j1.key_ordinal for xml path(''), type, root) .value('root[1]', 'nvarchar(max)'), 1, 1, ''), '') as ClKey
		 from sys.indexes as c
		 where c.index_id = 1;

	declare @c table
	(
		otype         varchar(2), 
		object_id     int, 
		Ord           int, 
		data_space_id int, 
		Rows          bigint, 
		Reserved      bigint, 
		Used          bigint, 
		Data          bigint, 
		index2        bigint, 
		index3        bigint, 
		in_row_data   bigint, 
		lob           bigint, 
		ovrflw        bigint, 
		Cmpr          int, 
		Part          int, 
		Pop           int, 
		Ppz           int, 
		Cnt           int, 
		Clus          int, 
		IxCt          int, 
		XmlC          int, 
		SpaC          int, 
		CoSC          int, 
		ncs           int, 
		Uniq          int, 
		disa          int, 
		hypo          int, 
		filt          int,
		primary key(object_id, data_space_id));
	with a
		 as (select case
						when o.schema_id = 4 then case
													  when o.type = 'S' then 1
													  when o.type = 'IT' then 2
												  else 3
												  end
					else o.object_id
					end as object_id, 
					o.type as otype, 
					d.index_id, 
					i.data_space_id, 
					d.reserved_page_count, 
					d.used_page_count, 
					d.in_row_data_page_count, 
					d.lob_used_page_count, 
					d.row_overflow_used_page_count, 
					d.row_count, 
					r.data_compression, 
					r.partition_number, 
					i.type as itype, 
					i.is_unique, 
					i.fill_factor, 
					i.is_disabled, 
					i.is_hypothetical, 
					i.has_filter
			 from sys.objects as o with(nolock)
				  inner join sys.indexes as i with(nolock) on i.object_id = o.object_id
				  left join sys.partitions as r with(nolock) on r.object_id = i.object_id
																and r.index_id = i.index_id
				  left join sys.dm_db_partition_stats as d with(nolock) on d.partition_id = r.partition_id 
			 --AND r.object_id = d.object_id AND r.index_id = d.index_id AND r.partition_number = d.partition_number 
			 where o.type <> 'TF'
				   and o.type <> 'IT'
				   and ( @objid is null
						 or o.object_id = @objid
					   )
				   and ( @psid is null
						 or i.data_space_id = @psid
					   )
				   and ( @minrow = 0
						 or row_count > @minrow
					   )),
		 b
		 as (select object_id, 
					index_id, 
					otype, 
					itype, 
					data_space_id
					, -- MAX(CASE WHEN index_id <= 1 THEN data_space_id ELSE 0 END) data_space_id 
					case
						when COUNT(*) > 1 then 1
					else 0
					end as Part, 
					COUNT(*) as Cnt, 
					reserved = 8 * SUM(reserved_page_count), 
					used = 8 * SUM(used_page_count), 
					in_row_data = 8 * SUM(in_row_data_page_count), 
					lob_used = 8 * SUM(lob_used_page_count), 
					row_overflow_used = 8 * SUM(row_overflow_used_page_count), 
					row_count = SUM(row_count), 
					compressed = SUM(data_compression)
					, -- change to 0 for SQL Server 2005  
					Pop = SUM(case
								  when row_count = 0
									   or index_id > 1 then 0
							  else 1
							  end), 
					Ppz = SUM(case
								  when row_count = 0
									   and index_id <= 1 then 1
							  else 0
							  end), 
					Clus = MAX(case a.index_id
								   when 1 then 1
							   else 0
							   end), 
					IxCt = MAX(case itype
								   when 2 then 1
							   else 0
							   end), 
					XmlC = MAX(case itype
								   when 3 then 1
							   else 0
							   end), 
					SpaC = MAX(case itype
								   when 4 then 1
							   else 0
							   end), 
					CoSC = MAX(case itype
								   when 5 then 1
							   else 0
							   end), 
					ncs = MAX(case itype
								  when 6 then -1
							  else 0
							  end), 
					MO = MAX(case itype
								 when 7 then 1
							 else 0
							 end), 
					Uniq = MAX(case is_unique
								   when 1 then 1
							   else 0
							   end), 
					disa = MAX(case is_disabled
								   when 1 then 1
							   else 0
							   end), 
					hypo = MAX(case is_hypothetical
								   when 1 then 1
							   else 0
							   end), 
					filt = MAX(case has_filter
								   when 1 then 1
							   else 0
							   end)
			 from a
			 group by object_id, 
					  index_id, 
					  otype, 
					  itype, 
					  data_space_id)
		 insert into @c
		 select case
					when otype is null then 'A'
				else otype
				end as otype,
				case
					when b.object_id is null then 0
					   else b.object_id
				end as object_id,
				case
					when b.object_id is null then 0
					when b.object_id in(1, 2) then b.object_id
					   else 3
				end as Ord
				, --, data_space_id  
				MAX(case
						when index_id <= 1 then data_space_id
					else 0
					end) as data_space_id, 
				Rows = SUM(case
							   when b.index_id < 2 then b.row_count
						   else 0
						   end), 
				Reserved = SUM(b.reserved), 
				Used = SUM(b.used), 
				Data = SUM(case
							   when b.index_id < 2 then b.in_row_data + b.lob_used + b.row_overflow_used
						   else b.lob_used + b.row_overflow_used
						   end), 
				index2 = SUM(case
								 when b.index_id > 1
									  and itype = 2 then b.in_row_data
							 else 0
							 end), 
				index3 = SUM(case
								 when b.index_id > 1
									  and itype > 2 then b.used
							 else 0
							 end), 
				in_row_data = SUM(in_row_data), 
				lob = SUM(lob_used), 
				ovrflw = SUM(row_overflow_used), 
				SUM(case compressed
						when 0 then 0
					else 1
					end) as Cmpr, 
				SUM(case
						when b.object_id > 10
							 and Part > 0 then 1
					else 0
					end) as Part, 
				SUM(Pop) as Pop, 
				SUM(Ppz) as Ppz, 
				MAX(case
						when b.object_id < 10
							 and disa = 0 then Cnt
					else 0
					end) as Cnt, 
				SUM(Clus) as Clus, 
				SUM(IxCt) as IxCt, 
				SUM(XmlC) as XmlC, 
				SUM(SpaC) as SpaC, 
				SUM(CoSC) as CoSC, 
				SUM(ncs) as ncs, 
				SUM(Uniq) as Uniq, 
				SUM(disa) as disa, 
				SUM(hypo) as hypo, 
				SUM(filt) as filt --, SUM(MO) MO 
		 from b
		 group by b.object_id, 
				  otype -- , data_space_id 
		 with rollup
		 having b.object_id is not null
				and otype is not null
				or b.object_id is null;

	declare @l table
	(
		object_id int
		primary key, 
		CIxSk     bigint, 
		IxSk      bigint, 
		Scans     bigint, 
		lkup      bigint, 
		upd       bigint, 
		ZrIx      int);
	insert into @l
	select object_id, 
		   SUM(case index_id
				   when 1 then user_seeks
			   else 0
			   end) as CIxSk, 
		   SUM(case
				   when index_id < 2 then 0
			   else user_seeks
			   end) as IxSk, 
		   SUM(case
				   when index_id < 2 then user_scans
			   else 0
			   end) as Scans, 
		   SUM(case
				   when index_id < 2 then 0
			   else user_lookups
			   end) as lkup, 
		   SUM(case
				   when index_id < 2 then 0
			   else user_updates
			   end) as upd, 
		   SUM(case
				   when index_id > 1
						and user_seeks = 0 then 1
			   else user_updates
			   end) as ZrIx
	from sys.dm_db_index_usage_stats with(nolock)
	where database_id = DB_ID()
	group by object_id;

	select otype,
		   case
			   when t.schema_id is null then ''
		   else t.name
		   end as [Schema],
		   case c.object_id
			   when 0 then '_Total'
			   when 1 then '_sys'
			   when 2 then '_IT'
				  else o.name
		   end as [Table], 
		   ClKey, 

/********************************************************************
CASE is_memory_optimized WHEN 1 THEN x2.rows_returned ELSE [Rows] END
********************************************************************/

		   Rows, 

/***********************************************************************************
CASE is_memory_optimized WHEN 1 THEN memory_allocated_for_table_kb ELSE Reserved END
***********************************************************************************/

		   Reserved, 

/***************************************************************************
CASE is_memory_optimized WHEN 1 THEN memory_used_by_table_kb ELSE [Data] END
***************************************************************************/

		   Data, 
		   lob
		   , --, ovrflw  
/******************************************************************
CASE is_memory_optimized WHEN 1 THEN memory_used_by_indexes_kb ELSE
******************************************************************/

		   index2 as 

/**
END
**/

		   [Index]
		   , --, newIx = index3  
/*********************************************************************************************************************************************************
CASE is_memory_optimized WHEN 1 THEN memory_allocated_for_table_kb+memory_allocated_for_indexes_kb-memory_used_by_table_kb -memory_used_by_indexes_kb ELSE
*********************************************************************************************************************************************************/

		   Reserved - Used as 

/**
END
**/

		   Unused, 
		   AvBR = case Rows
					  when 0 then 0
				  else 1024 * Data / Rows
				  end,
		   case
			   when c.object_id in(1, 2, 3) then Cnt
				  else Clus
		   end as Clus, 
		   IxCt, 
		   Uniq, 
		   XmlC as Xm, 
		   SpaC as Sp, 
		   CoSC + ncs as cs, 

/************************************************
CASE is_memory_optimized WHEN 1 THEN 1 ELSE 0 END
************************************************/

		   0 as MO, 
		   Stct, 
		   kct, 
		   Cmpr, 
		   Part, 
		   Pop, 
		   Ppz
		   , -- , Cnt  
		   CIxSk, 
		   IxSk, 
		   Scans, 
		   lkup, 
		   upd, 
		   cols, 
		   guids, 
		   ngu, 
		   c.data_space_id as dsid,
		   case y.lob_data_space_id
			   when 0 then null
							  else y.lob_data_space_id
		   end as lobds
		   ,  --, fif.ftct, fif.ftsz  
		   rkey, 
		   fkey, 
		   def, 
		   trg
		   , --, cols  
		   disa
		   , --, hypo  
		   filt, 
		   o.create_date
	from @c as c
		 left join @ClK as j on j.object_id = c.object_id
		 left join sys.objects as o with(nolock) on o.object_id = c.object_id
		 left join sys.tables as y with(nolock) on y.object_id = c.object_id
		 left join sys.schemas as t with(nolock) on t.schema_id = o.schema_id 
		 --LEFT JOIN sys.dm_db_xtp_table_memory_stats x ON x.object_id = y.object_id 
		 --LEFT JOIN sys.dm_db_xtp_index_stats x2 ON x2.object_id = y.object_id AND x2.index_id = 0 
		 left join (select case
							   when object_id is null then 0
						   else object_id
						   end as object_id, 
						   COUNT(*) as Stct
					from sys.stats with(nolock)
					where object_id > 3 

/****************
 skip low values 
****************/

					group by object_id with rollup
					having object_id is not null
						   or object_id is null) as s on s.object_id = c.object_id
		 left join (select table_id, 
						   SUM(data_size) / 1024 as ftsz, 
						   COUNT(*) as ftct
					from sys.fulltext_index_fragments with(nolock)
					where status = 4
					group by table_id) as fif on fif.table_id = c.object_id
		 left join (select object_id, 
						   COUNT(*) as kct
					from sys.index_columns with(nolock)
					where index_id = 1
					group by object_id) as k on k.object_id = c.object_id
		 left join (select case
							   when object_id is null then 0
						   else object_id
						   end as object_id, 
						   COUNT(*) as cols, 
						   SUM(case system_type_id
								   when 36 then 1
							   else 0
							   end) as guids, 
						   SUM(case
								   when system_type_id = 36
										and is_nullable = 1 then 1
							   else 0
							   end) as ngu
					from sys.columns with(nolock)
					group by object_id 
 
/************************************************************
WITH ROLLUP HAVING object_id IS NOT NULL OR object_id IS NULL
************************************************************/

				   ) as e on e.object_id = c.object_id
		 left join (select case
							   when referenced_object_id is null then 0
						   else referenced_object_id
						   end as referenced_object_id, 
						   COUNT(*) as rkey
					from sys.foreign_keys with(nolock)
					group by referenced_object_id 
 
/**********************************************************************************
WITH ROLLUP HAVING referenced_object_id IS NOT NULL OR referenced_object_id IS NULL
**********************************************************************************/

				   ) as r on r.referenced_object_id = c.object_id
		 left join (select case
							   when parent_object_id is null then 0
						   else parent_object_id
						   end as parent_object_id, 
						   COUNT(*) as fkey
					from sys.foreign_keys with(nolock)
					group by parent_object_id 
 
/****************************************************************************
 WITH ROLLUP HAVING parent_object_id IS NOT NULL OR parent_object_id IS NULL 
****************************************************************************/
 
				   ) as f on f.parent_object_id = c.object_id
		 left join (select case
							   when parent_object_id is null then 0
						   else parent_object_id
						   end as parent_object_id, 
						   COUNT(*) as def
					from sys.default_constraints with(nolock)
					group by parent_object_id 
 
/**************************************************************************
WITH ROLLUP HAVING parent_object_id IS NOT NULL OR parent_object_id IS NULL
**************************************************************************/
 
				   ) as d on d.parent_object_id = c.object_id
		 left join (select case
							   when parent_id is null then 0
						   else parent_id
						   end as parent_id, 
						   COUNT(*) as trg
					from sys.triggers with(nolock)
					where parent_id > 0
					group by parent_id 
 
/************************************************************
WITH ROLLUP HAVING parent_id IS NOT NULL OR parent_id IS NULL
************************************************************/
 
				   ) as g on g.parent_id = c.object_id
		 left join @l as l on l.object_id = c.object_id
	where --o.type IN ('U','V') AND 
	( c.object_id is not null 

/*************************
OR x.object_id IS NOT NULL
*************************/

	) 
	--WHERE (--t.name <>'dbo' AND o.name NOT LIKE 'Trace%') OR t.name IS NULL 
	order by Ord, 
			 Reserved desc 
	--, t.name, o.name 
	option(recompile);
end; 
go 
-- Then mark the procedure as a system procedure. 
exec sys.sp_MS_marksystemobject 'sp_spaceused2'; 
go 
select NAME, 
	   IS_MS_SHIPPED
from SYS.OBJECTS
where NAME like 'sp_spaceused2%'; 
go