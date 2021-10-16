/*
	Stored Procedure to Get Server Storage Information in Server

	The SP expects 2 parameters:
		@﻿persistData: ‘Y’ if the DBA desires to save the output in a target table, 
					  and ‘N’ if the DBA only wants to see the output directly
		@driveDetail: Although optional, if you pass a drive letter, then the 
					  @persistData parameter will have no effect whatsoever

	Fields Presented and Their meaning:
﻿		drive: the drive letter that contains data files for the current instance.
		total_space: the size of the drive, in GBs.
		free_space: the amount of GBs left in the drive.
		used_space: the amount of GBs occupied by all the databases in the instance.
		data_collection_timestamp: visible only if ‘Y’ is passed to the @persistData parameter, 
					and it is used to know when the SP was executed and the information was 
					successfully saved in the DBA_Storage table.

	EXEC GetStorageData @persistData = 'N'
	EXEC GetStorageData @persistData = 'N', @driveDetail = 'C'

	SELECT * FROM DBA_Storage WHERE drive = 'C:\';
	SELECT * FROM DBA_Storage ORDER BY free_space;
	SELECT * FROM DBA_Storage ORDER BY used_space DESC;

*/
CREATE OR ALTER PROCEDURE dbo.GetStorageData @persistData CHAR(1) = 'Y',
                                             @driveDetail CHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @command NVARCHAR(MAX);

    DECLARE @Tmp_StorageInformation TABLE (
        drive       CHAR(3)        NOT NULL,
        total_space DECIMAL(10, 3) NOT NULL,
        free_space  DECIMAL(10, 3) NOT NULL,
        used_space  DECIMAL(10, 3) NOT NULL
    );

    IF NOT EXISTS (
        SELECT *
        FROM dbo.sysobjects
        WHERE id = OBJECT_ID (N'DBA_Storage')
              AND OBJECTPROPERTY (id, N'IsTable') = 1
    )
    BEGIN
        CREATE TABLE DBA_Storage (
            drive                     CHAR(3)        NOT NULL,
            total_space               DECIMAL(10, 3) NOT NULL,
            free_space                DECIMAL(10, 3) NOT NULL,
            used_space                DECIMAL(10, 3) NOT NULL,
            data_collection_timestamp DATETIME       NOT NULL
        );
    END;

    IF (@driveDetail IS NOT NULL)
    BEGIN
        SELECT DB_NAME (mf.database_id) AS "database",
               CONVERT (DECIMAL(10, 3), SUM (size * 8) / 1024.0 / 1024.0) AS "total space"
        FROM sys.master_files AS mf
        WHERE SUBSTRING (mf.physical_name, 0, 4) = CONCAT (@driveDetail, ':\')
        GROUP BY mf.database_id;

        RETURN;
    END;

    INSERT INTO @Tmp_StorageInformation
    SELECT drives.drive,
           drives.total_space,
           drives.free_space,
           (
               SELECT CONVERT (DECIMAL(10, 3), SUM (size * 8) / 1024.0 / 1024)
               FROM sys.master_files
               WHERE SUBSTRING (physical_name, 0, 4) = drives.drive
           ) AS "used_space"
    FROM (
        SELECT DISTINCT vs.volume_mount_point AS "drive",
                        CONVERT (DECIMAL(10, 3), (vs.available_bytes / 1048576) / 1024.0) AS "free_space",
                        CONVERT (DECIMAL(10, 3), (vs.total_bytes / 1048576) / 1024.0) AS "total_space"
        FROM sys.master_files AS mf
        CROSS APPLY sys.dm_os_volume_stats (mf.database_id, mf.file_id) AS vs
    ) AS drives;

    IF @persistData = 'N' 
		SELECT * FROM @Tmp_StorageInformation;
    ELSE
    BEGIN
        TRUNCATE TABLE DBA_Storage;

        INSERT INTO DBA_Storage
        SELECT *,
               GETDATE ()
        FROM @Tmp_StorageInformation
        ORDER BY drive;
    END;
END;