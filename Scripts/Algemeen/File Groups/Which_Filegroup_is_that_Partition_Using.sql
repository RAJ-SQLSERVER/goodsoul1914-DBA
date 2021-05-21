/*
Source link: https://www.littlekendra.com/2017/01/31/which-filegroup-is-that-partition-using-how-many-rows-does-it-have/
Author: Kendra Little
*/
SELECT sc.name + N'.' + so.name AS [Schema.Table],
       si.index_id AS [Index ID],
       si.type_desc AS [Structure],
       si.name AS [Index],
       stat.row_count AS [Rows],
       stat.in_row_reserved_page_count * 8. / 1024. / 1024. AS [In-Row GB],
       stat.lob_reserved_page_count * 8. / 1024. / 1024. AS [LOB GB],
       p.partition_number AS [Partition #],
       pf.name AS [Partition Function],
       CASE pf.boundary_value_on_right
           WHEN 1 THEN
               'Right / Lower'
           ELSE
               'Left / Upper'
       END AS [Boundary Type],
       prv.value AS [Boundary Point],
       fg.name AS [Filegroup]
FROM sys.partition_functions AS pf
    JOIN sys.partition_schemes AS ps
        ON ps.function_id = pf.function_id
    JOIN sys.indexes AS si
        ON si.data_space_id = ps.data_space_id
    JOIN sys.objects AS so
        ON si.object_id = so.object_id
    JOIN sys.schemas AS sc
        ON so.schema_id = sc.schema_id
    JOIN sys.partitions AS p
        ON si.object_id = p.object_id
           AND si.index_id = p.index_id
    LEFT JOIN sys.partition_range_values AS prv
        ON prv.function_id = pf.function_id
           AND p.partition_number = CASE pf.boundary_value_on_right
                                        WHEN 1 THEN
                                            prv.boundary_id + 1
                                        ELSE
                                            prv.boundary_id
                                    END
    /* For left-based functions, partition_number = boundary_id, 
           for right-based functions we need to add 1 */
    JOIN sys.dm_db_partition_stats AS stat
        ON stat.object_id = p.object_id
           AND stat.index_id = p.index_id
           AND stat.index_id = p.index_id
           AND stat.partition_id = p.partition_id
           AND stat.partition_number = p.partition_number
    JOIN sys.allocation_units AS au
        ON au.container_id = p.hobt_id
           AND au.type_desc = 'IN_ROW_DATA'
    /* Avoiding double rows for columnstore indexes. */
    /* We can pick up LOB page count from partition_stats */
    JOIN sys.filegroups AS fg
        ON fg.data_space_id = au.data_space_id
ORDER BY [Schema.Table],
         [Index ID],
         [Partition Function],
         [Partition #];
GO