SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		M. Boomaars
-- Create date: 2020-02-10
-- Description:	DataWarehouse reload
-- =============================================
ALTER PROCEDURE sp_dwh_reload
	@do_count BIT = 1	-- Voer HiX Telling uit (0 = Nee, 1 = Ja)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @dwh_server_name NVARCHAR(100)	= 'GAHIXDWH02',
			@hix_server_name NVARCHAR(100)	= 'GAHIXSQL01',
			@db_name NVARCHAR(100)			= 'CSDW_Acceptatie',
			@days_ago INT					= 26, -- Hoeveel dagen terug kijken we?
			@first_id INT					= 0, -- ID eerste run
			@reload_status INT				= 0, -- Status van de verversing (0-1 = niet afgerond, 2 = afgerond)
			@reload_result INT				= 0, -- Resultaat van de verversing (0 = succesvol, >1 = fout)
			@reload_error NVARCHAR(MAX)		= NULL,			
			@sql NVARCHAR(MAX)				= NULL,
			@Body NVARCHAR(MAX)				= NULL,
			@Subject NVARCHAR(100)			= NULL,
			@ls_jobname NVARCHAR(100)		= 'LSRestore_GAHIXSQL02_HIX_ACCEPTATIE';
	
	-- Schakel logship restore job uit
	EXEC msdb.dbo.sp_update_job @job_name = @ls_jobname, @enabled = 0;
	RAISERROR('Logship restore job uitgeschakeld.', 10, 1) WITH NOWAIT;

	-- Haal de ID op van de eerste run van de verversing
	SET @sql = 'SELECT @FirstRunIdOut = MAX(Verversing) - 1 FROM [' + @db_name + '].[dbo].[DWHHlpVerversingsResultaat];' 
	EXEC sp_executesql @sql, N'@FirstRunIdOut INT OUTPUT', @FirstRunIdOut = @first_id OUTPUT
	RAISERROR('ID eerste run bepaald.', 10, 1) WITH NOWAIT;

	-- Is de verversing in zijn geheel afgerond?
	SELECT	@reload_status = COUNT (*) 
	FROM	CSDW_Acceptatie.dbo.DWHHlpVerversingsResultaat
	WHERE	Verversing >= @first_id AND Datum >= GETDATE() - @days_ago AND EindDatum IS NOT NULL;	-- @TODO dynamiseren

	-- Indien afgerond zijn er 2 nieuwe rijen in de tabel DWHHlpVerversingslog waarvan de einddatum gevuld is
	IF @reload_status = 2	
		BEGIN
			RAISERROR('Verversing is afgerond.', 10, 1) WITH NOWAIT; 
			
			-- Zijn er fouten opgetreden bij de verversing?
			SELECT	@reload_result = COUNT(*) 
			FROM	CSDW_Acceptatie.dbo.DWHHlpVerversingslog	 
			WHERE	Verversing >= @first_id AND STATUS like 'Error';	-- @TODO dynamiseren

			-- Indien er fouten zijn opgetreden bevat de tabel DWHHlpVerversingslog één of meer rijen met details
			IF @reload_result >= 1
				BEGIN
					RAISERROR('Verversing is geheel of gedeeltelijk mislukt.', 10, 1) WITH NOWAIT;

					-- Bepaal de eerste foutmelding van de verversing
					SELECT	TOP 1 @reload_error = DETAILS
					FROM	CSDW_Acceptatie.dbo.DWHHlpVerversingslog		
					WHERE	Verversing >= @first_id AND STATUS like 'Error'	-- @TODO dynamiseren

					-- Onderwerp e-mail samenstellen
					SET @Subject = CASE 
						WHEN @reload_result = 1 THEN 'Fout opgetreden tijdens verversing Chipsoft DataWarehouse' 
						ELSE 'Meerdere fouten opgetreden tijdens verversing Chipsoft DataWarehouse' 
					END

					-- Body e-mail samenstellen (alleen de eerste foutmelding weergeven)
					SET @Body = CONCAT('<pre>', @reload_error, '</pre>');
					
					-- E-mail sturen naar Ultimo
					EXEC msdb.dbo.sp_send_dbmail  
						@profile_name	=  'GAHIXDWH02',  
						@subject        =  @Subject,
						@recipients     =  'm.boomaars@bravis.nl', -- 'Ultimo_Meld@bravis.nl'   
						@body           =  @Body,  
						@body_format    = 'HTML'; 

					RAISERROR('Mail gestuurd naar Ultimo.', 10, 1) WITH NOWAIT;
				END

			-- Body e-mail HiX Tellingen samenstellen
			IF @do_count = 1
			BEGIN
				DECLARE @ndVerversing INTEGER      
				DECLARE @ddControle4wStart DATETIME     
				DECLARE @ddControle4wEinde DATETIME     

				SET @ndVerversing = (
					SELECT	MAX(Verversing)     
					FROM	CSDW_Acceptatie.dbo.DWHHlpVerversingsResultaat   
					WHERE	CHOSENMODELS <> 'DDR');	-- Waarom < > DDR? te bepalen o.b.v. @first_id?

				SET @ddControle4wStart =  (
					SELECT	DATEADD(mm, DATEDIFF(mm, 0, Datum) - 1, 0)  
					FROM	CSDW_Acceptatie.dbo.DWHHlpVerversingsResultaat  
					WHERE	VERVERSING = @ndVerversing);  -- @TODO dynamiseren  
         
				SET @ddControle4wEinde  = GETDATE();  

				SET @Body = N'<H4>DBC Tellingen</H4>' +  
					N'<table border="1">' +  
					N'<tr><th>Module</th><th>Jaar</th><th>DBCNummer</th></tr>' +  
					CAST (( 
						SELECT	td = 'DBC', 
								'', 
								td = YEAR(BEGINDAT), 
								'',
								td = COUNT([DBCNummer]), 
								''                                                     
						FROM GAHIXSQL01.HIX_ACCEPTATIE.dbo.EPISODE_DBCPER                                                     
						WHERE Begindat>= '20140101'       
						GROUP BY YEAR(BEGINDAT)       
						ORDER BY YEAR(BEGINDAT)
						FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +  
					N'</table>' +
					N'<H4>VER Tellingen</H4>' +  
					N'<table border="1">' +  
					N'<tr><th>Module</th><th>Jaar</th><th>Aantal</th></tr>' +  
					CAST (( 
						SELECT	td = 'VER', 
								'',
								td = YEAR(DATUM), 
								'', 
								td = COUNT(ID), 
								''                                                     
						FROM GAHIXSQL01.HIX_ACCEPTATIE.dbo.FAKTUUR_VERRVIEW                                                    
						WHERE DATUM >= '20140101'       
						GROUP BY YEAR(DATUM)       
						ORDER BY YEAR(DATUM)  
						FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +
					N'</table>'  +
					N'<H4>DBC Begindatum</H4>' +  
					N'<table border="1">' +  
					N'<tr><th>Module</th><th>Begindatum</th><th>Aantal</th></tr>' +  
					CAST (( 
						SELECT	td = 'DBC', 
								'', 
								td = CONVERT(CHAR(10), BEGINDAT, 126), 
								'', 
								td = COUNT([DBCNummer]), 
								''                                                     
						FROM GAHIXSQL01.HIX_ACCEPTATIE.dbo.EPISODE_DBCPER                                                    
						WHERE Begindat >= @ddControle4wStart AND Begindat < @ddControle4wEinde  
						GROUP BY CONVERT(CHAR(10), BEGINDAT, 126)     
						ORDER BY CONVERT(CHAR(10), BEGINDAT, 126) DESC
						FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +
						N'</table>'  +
					N'<H4>DBC Begindatum</H4>' +  
					N'<table border="1">' +  
					N'<tr><th>Module</th><th>VERRdatum</th><th>Aantal</th></tr>' +  
					CAST (( 
						SELECT	td = 'VER', 
								'', 
								td = CONVERT(CHAR(10), datum, 126) , 
								'', 
								td = COUNT(ID), 
								''                                                     
						FROM [GAHIXSQL01].[HIX_ACCEPTATIE].[dbo].[FAKTUUR_VERRVIEW]                                                    
						WHERE DATUM >= @ddControle4wStart AND DATUM < @ddControle4wEinde  
						GROUP BY CONVERT(CHAR(10), datum, 126)      
						ORDER BY CONVERT(CHAR(10), datum, 126) DESC
						FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) +
					N'</table>';
			
				-- Stuur e-mail HiX Tellingen
				EXEC msdb.dbo.sp_send_dbmail  
					@profile_name	=  'GAHIXDWH02',  
					@subject        =  'HiX Tellingen',
					@recipients     =  'm.boomaars@bravis.nl', -- 'Ultimo_Meld@bravis.nl'   
					@body           =  @Body,  
					@body_format    = 'HTML'; 
			END

			-- Schakel logship restore job in
			EXEC msdb.dbo.sp_update_job @job_name = @ls_jobname, @enabled = 1;
			RAISERROR('Logship restore job ingeschakeld.', 10, 1) WITH NOWAIT;
		END

	-- Nee, de verversing is nog niet afgerond
	ELSE 
		BEGIN
			RAISERROR('Verversing niet afgerond.', 10, 1) WITH NOWAIT;

			-- Schakel logship restore job uit
			EXEC msdb.dbo.sp_update_job @job_name = @ls_jobname, @enabled = 0;
			RAISERROR('Logship restore job uitgeschakeld.', 10, 1) WITH NOWAIT;
		END

	-- Short circuit
	FINISH:
	RAISERROR('Procedure voltooid.', 10, 1) WITH NOWAIT

END
GO
