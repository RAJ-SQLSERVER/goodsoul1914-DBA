/*	
    Controle op goed lopen van de HIX Taken
	Dit script verzend via database-mail een mail met de informatie over de afloop van de laatste Afspraak herinnering-job.	
	
	20170815, MBL - ULTIMO melding 17036044 - initiele versie
    20170816, MBL - ULTIMO melding 17036044 - definitieve versie met aanpassingen mail adres en informatie voor afhandeling
	20171031, MBL - ULTIMO melding 17048313 - Toevoegen nieuwe taak binnen HIX waardoor flexibel opvragen is gemaakt
	                                          Door aantal in de declares te gebruiken kan maximale check worden gebruikt
	                                          bij aanpassing aantal check hoeft dit aantal aan gepast te worden indien 
	                                          de taak op Taak server begint met 'E-Mail' 
    20171205, MBL status job toegevoegd 
    20171218, MBL Job voor meerdere taken gemaakt om zo de taken op 1 manier te controleren
    20171219, MBL Aanpassingen gemaakt om de melding goed te vullen waren leeg bij errors
    20180115, MBL Aanpassingen gemaakt om Screeningstaak mee te nemen in de controle
    20180425, MBL Aanpassingen gemaakt om fout herkenning en mailen wat niet altijd juist ging
	20180907, MBL Aanpassing om Jobs waarin meerdere stappen staan af te vangen
    
*/

-- Ontvangers van de Mail

--DECLARE @RecipientsMail    NVARCHAR(MAX) = 'Ultimo_meld@bravis.nl, ma.blom@bravis.nl'    
DECLARE @RecipientsMail    NVARCHAR(MAX) = 'm.boomaars@bravis.nl'

-- Parameter settings

DECLARE @HTML1             NVARCHAR(MAX) = N'<H1>Voor Technisch Applicatiebeheer</H1>'
DECLARE @HTML2  		   NVARCHAR(MAX) = ''
DECLARE @HTML3  		   NVARCHAR(MAX) = ''
DECLARE @HTMLBericht       NVARCHAR(MAX) = ''
DECLARE @OmschrijvingMail  NVARCHAR(MAX) = '[HIXtaak] Taakverwerking'
DECLARE @STARTMINUUT       INT           =  71 -- MINUTEN
DECLARE @STOPMINUUT        INT           =  10 -- MINUTEN
DECLARE @STARTTIJD		   DATETIME		 =  ( SELECT DATEADD( MINUTE, -@STARTMINUUT, getdate() ) )
DECLARE @STOPTIJD		   DATETIME		 =  ( SELECT DATEADD( MINUTE, -@STOPMINUUT, getdate() ) )

DECLARE @VERWERKT          NVARCHAR(MAX) = ( SELECT COUNT(*)
FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK]
WHERE [STATUS] IN ( 'U', 'E', 'V' )
    AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
    AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() ) )

DECLARE @AANTAL            NVARCHAR(MAX) = ( SELECT COUNT(*)
FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK]
WHERE [DATUM] + [TIJD] >= DATEADD(MINUTE, -@STARTMINUUT, getdate())
    AND [DATUM] + [TIJD] <= DATEADD(MINUTE, -@STOPMINUUT, getdate())
    AND [TYPTRIGGER] NOT LIKE 'P' )

DECLARE @TEST             NVARCHAR(MAX) = ( SELECT 'FOUT'
WHERE @AANTAL <> @VERWERKT  )

PRINT '@@INFORMATIE@@   Er is in de verwerkings verschil van ' + @TEST + ' taken geconstateerd '
PRINT '@@INFORMATIE@@   Geplande aantal taken >>> ' + @AANTAL + ' vs afgehandelde taken >>> ' + @VERWERKT
PRINT '@@INFORMATIE@@   START CHECK >> ' +  CONVERT(VARCHAR(20),@STARTTIJD ) + ' << STOP CHECK >> ' + CONVERT(VARCHAR(20), @STOPTIJD )

-- Start controle van de HIX Taken


IF EXISTS ( SELECT 'FOUT'
WHERE @AANTAL > @VERWERKT  )                            
BEGIN
    SET @HTML2  =  N'<H4>E-Mail: Taak zijn niet allemaal gestart volgens planning</H4>' + 
                    N'<table border="1">' +  
                    N'<tr><th>Taak Machine</th><th>RunID / Taak Naam</th><th>Plan Datum/Tijd</th><th>Status</th></tr>' +  
                     CAST ( ( SELECT td = [MACHINE] , '',
        td = RIGHT( [RUNID] , 3 ) + ' / ' + [OMSCHRIJV] , '' ,
        td = CONVERT(VARCHAR(23), [DATUM] + ( CASE TYPTRIGGER  WHEN 'T' THEN TIJD 
																					        WHEN 'P' THEN ( CASE STATUS WHEN 'U' THEN CONVERT(VARCHAR(8), (CONVERT(TIME, TIJD)))
																													    ELSE ( SELECT B.TIJD
        FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK] B
        WHERE TAAKPADID = B.TAAKPADID
            AND B.TYPTRIGGER LIKE 'T'
            AND B.[DATUM] + B.[TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
            AND B.[DATUM] + B.[TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )  ) END )
																							ELSE 'XX:XX' END )  , 120), '' ,
        td = CASE STATUS  WHEN 'U' THEN 'Klaar' 
                                                       WHEN 'W' THEN 'Wachtend' 
                                                       WHEN 'L' THEN 'Uitgepland' 
                                                       WHEN 'E' THEN 'Gestart' 
                                                       WHEN 'F' THEN 'VerwerkingsFOUT'
                                                       WHEN 'V' THEN 'Klaar zie LOG'
			                                           WHEN 'A' THEN 'Klaar met FOUT'
                                                       ELSE 'Onbekend' END  , ''
    FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK]
    WHERE [OMSCHRIJV] NOT LIKE 'Verversen%'
        AND [STATUS] NOT IN ( 'U', 'E', 'V' )
        AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
        AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )
    ORDER BY [DATUM] DESC
    FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) + 
                               N'</table>'
END

-- Zoeken of bij fouten ook resultaten zijn gemeld

IF EXISTS ( SELECT COUNT(*)
FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK]
WHERE [STATUS] NOT IN ( 'U' , 'W', 'E', 'L', 'V' )
    AND [DATUM] + [TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
    AND [DATUM] + [TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() ) )                         
BEGIN
    SET @HTML3 =  N'<table border="1">' +  
                   N'<tr><th>HIX Runid / TaakNaam</th><th>Fout Melding</th></tr>' +  
                   CAST ( ( SELECT td = RIGHT( A.[RUNID] , 3 ) + ' / ' + A.[OMSCHRIJV] , '' ,
        td = B.[RESULT] , ''
    FROM [HIX_ACCEPTATIE].[dbo].[TAAK_TAAK] A,
        [HIX_ACCEPTATIE].[dbo].[TAAK_TAAKLOG] B
    WHERE A.[ID] = B.[TAAKID]
        AND A.[STATUS] NOT IN ( 'U' , 'W', 'E', 'L', 'V' )
        AND B.[ERRCODE] not in (000 ,004)
        AND A.[DATUM] + A.[TIJD] >= DATEADD( MINUTE, -@STARTMINUUT, getdate() )
        AND A.[DATUM] + A.[TIJD] <= DATEADD( MINUTE, -@STOPMINUUT, getdate() )
    ORDER BY A.[DATUM] DESC
    FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) + 
                   N'</table>'
END

-- Mailtje versturen met resultaten

IF @HTML2 <> ''
BEGIN
    SET @HTMLBericht = @HTML1 + @HTML2
END

IF @HTML3 <> ''
BEGIN
    SET @HTMLBericht = @HTML1 + @HTML2 + @HTML3
END

IF @HTMLBericht <> '' 
BEGIN
    EXEC msdb.dbo.sp_send_dbmail  
          @profile_name                =  "GAHIXSQL01" ,  
          @subject                     =  @OmschrijvingMail ,
          @recipients                  =  @RecipientsMail ,   
          @body                        =  @HTMLBericht,  
          @body_format                 = 'HTML'
END	