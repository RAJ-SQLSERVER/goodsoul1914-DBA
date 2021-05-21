-- Verrichtingen Bravis
---------------------------------------------------------------------------------------------------

USE ODSProductie
GO

DECLARE @StartDatum			AS DATE			-- Startmoment
DECLARE @Peildatum			AS DATE			-- Eindmoment / Peildatum
DECLARE @AGBCode			AS VARCHAR(8)	-- AGBCode
DECLARE @DetailOverzicht	AS BIT			-- Detailoverzicht tonen?

SET @StartDatum =			'2017-01-01'	-- Afhankelijk van jaarcontroles
SET @Peildatum  =			'2020-05-31'	-- Laatste dag van de maand voor de laatst afgesloten maand
SET @AGBCode    =			'06011036'		-- Bravis Ziekenhuis
SET @DetailOverzicht =		0				-- 0 = Toon gegroepeerde resulaten / 1 = Toon detailoverzicht

IF @DetailOverzicht = 0
	BEGIN
		SELECT	GETDATE(), FORMAT (DATUM, 'yyyy') as jaar, COUNT(*)
		FROM	D001_FAKTUUR_VERRICHT_VERRSEC F
		LEFT OUTER JOIN 
				D001_EPISODE_DBCPER E ON F.CASENR = E.DBCNUMMER	
		WHERE	F.IsActueel = 1									-- alle actuele verrichtingen					
				AND F.DATUM >= @StartDatum 
				AND F.DATUM <= @Peildatum						-- waarvan verrichtingsdatum tussen @StartDatum en @PeilDatum
				--AND F.AantalWerkelijkZorginstelling <> 0.000	-- waarvan het werkelijk aantal boven de 0 ligt
				 
				AND COALESCE(E.LOCATIE, F.LOCATIE) IN (
					SELECT	CODE 
					FROM	D001_CSZISLIB_LOCCODE 
					WHERE	LOCCODE = @AGBCode
				)												-- DBC locatie is leidend, als die null is (geen koppeling naar DBC) dan verrichting locatie
				AND F.PATIENTNR IN (
					SELECT	PATIENTNR 
					FROM	D001_PATIENT_PATIENT 
					WHERE	IsTestPatient = 0
				)												-- die geen testpatienten betreffen
				AND F.STROOM <> 'R'		
				AND (F.VERZEKERIN LIKE 'V%' OR F.VERZEKERIN IS NULL OR F.VERZEKERIN = '')
				--AND F.TYPE_CODE <> 'N'						-- waarvan type code ongelijk is aan N
				AND F.AFDELING NOT IN ('DBC', '015')			-- waarvan de afdeling ongelijk is aan DBC of 015
		GROUP BY FORMAT (F.DATUM, 'yyyy')
		ORDER BY 2
	END
ELSE
	BEGIN
		SELECT 
			F.PATIENTNR,
			F.ID,
			F.DATUM,
			F.EINDDATUM,
			F.AFDELING,
			F.UITVOERDER,
			F.AANVRAGER,
			F.REFNUMMER,
			F.OPNAMENR,
			F.FAKTUURDAT,
			F.ORGNUMMER,
			F.BRON,
			F.INVOERDAT,
			F.CASENR,
			F.BOEKPER,
			F.FAKTUURNUM,
			F.SECID,
			F.CODE,
			F.VERRTIJD,
			F.EINDTIJD,
			F.BEDRAGZIEK,
			F.BEDRAGSPEC,
			F.KOSTPLAATS,
			F.KOSTPLTHON,
			F.OPBRENGSTSPECIALISM,
			F.UITVOERDERSPECIALISM,
			F.REKKOST,
			F.REKHON,
			F.AantalWerkelijkZorginstelling,
			F.AantalOpbrengstZorginstelling,
			F.AantalWerkelijkZorgverlener,
			F.AantalOpbrengstZorgverlener,
			F.IsActueel,
			F.BRONSTATUS,
			F.SOORT_BEH,
			F.TYPE_CODE,
			F.VERZEKERIN as VERR_VERZEKERIN,

			D.BEGINDAT,
			D.EINDDAT,
			D.DBCNUMMER,
			D.HOOFDDBC,
			D.EPISODE,
			D.SPECIALISM,
			D.ZORGTYPE,
			D.ZORGVRAAG,
			D.HOOFDDIAG,
			D.BEHCODE,
			D.INGBEH,
			D.LOCATIE,
			D.AFSLUIT,
			D.MEDIND,
			D.DECLCODE,
			D.ZORGPROD,
			D.VERWZORGPR,
			D.VERZEKERIN,
			D.DBCTypering,
			D.AFSLREG,
			D.ICD10,
			D.STATUS,
			D.VERVALLEN,
			D.STROOM
		INTO	Bravis_Verrichtingen_20200101_20200430
		FROM	D001_FAKTUUR_VERRICHT_VERRSEC F
		LEFT OUTER JOIN 
				D001_EPISODE_DBCPER D ON F.CASENR = D.DBCNUMMER
		WHERE	F.IsActueel = 1
				AND F.DATUM >= @StartDatum 
				AND F.DATUM <= @Peildatum						-- waarvan verrichtingsdatum tussen @StartDatum en @PeilDatum
				--AND	F.AantalWerkelijkZorginstelling <> 0.000
				AND COALESCE(D.LOCATIE, F.LOCATIE) IN (
					SELECT	CODE 
					FROM	D001_CSZISLIB_LOCCODE 
					WHERE	LOCCODE = @AGBCode					-- DBC locatie is leidend, als die null is (geen koppeling naar DBC) dan verrichting locatie
				)
				AND F.PATIENTNR IN (
					SELECT	PATIENTNR 
					FROM	D001_PATIENT_PATIENT 
					WHERE	IsTestPatient = 0
				)
				AND F.STROOM <> 'R' 
				--AND F.TYPE_CODE <> 'N'
				AND (F.VERZEKERIN LIKE 'V%' OR F.VERZEKERIN IS NULL OR F.VERZEKERIN = '')
				AND F.AFDELING NOT IN ('DBC', '015')
		ORDER BY 3, 2
	END
GO
