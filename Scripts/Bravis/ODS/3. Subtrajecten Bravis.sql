-- Subtrajecten Bravis
---------------------------------------------------------------------------------------------------

/*
R = Reguliere DBC (cijfercode 11). Een patiënt met een nieuwe zorgvraag krijgt een eerste DBC geopend. 
	De typering hiervan is dus R, een reguliere DBC.
L = Langdurige zorg (cijfercode 21). De eerste DBC van de patiënt is afgesloten en er wordt een vervolg DBC geopend.
I = Intercollegiaal consult (cijfercode 13). Als een patiënt voor specialisme A is opgenomen en specialisme B 
	wordt in consult erbij gevraagd dan opent het tweede specialisme een DBC met zorgtype I. Ter info: als de patiënt 
	uiteindelijk door specialisme B daadwerkelijk in behandeling wordt genomen wordt de DBC met zorgtype I (13) omgezet naar een zorgtype R (11).
*/

USE ODSProductie
GO

DECLARE @StartDatum			AS DATE			-- Startmoment
DECLARE @PeilDatum			AS DATE			-- Eindmoment / Peildatum
DECLARE @AGBCode			AS VARCHAR(8)	-- AGBCode
DECLARE @DetailOverzicht	AS BIT

SET @StartDatum =			'2017-01-01' 
SET @PeilDatum  =			'2020-05-31' 
SET @AGBCode    =			'06011036'		-- Bravis Ziekenhuis
SET @DetailOverzicht =		0				-- 0 = Toon gegroepeerde resulaten / 1 = Toon detailoverzicht

IF @DetailOverzicht = 0
	BEGIN
		SELECT GETDATE(), FORMAT (BEGINDAT, 'yyyy') as jaar, COUNT(*)
		FROM D001_EPISODE_DBCPER D						
		WHERE 
			D.VERVALLEN <> 1							-- die niet vervallen zijn
			AND D.BEGINDAT >= @StartDatum			
			AND D.BEGINDAT <= @PeilDatum				-- waarvan de begindatum tussen de @StartDatum en @PeilDatum ligt
			AND D.LOCATIE IN (
				SELECT	L.CODE 
				FROM	D001_CSZISLIB_LOCCODE L
				WHERE	L.LOCCODE = @AGBCode
			)											-- die gelden voor Bravis Ziekenhuis
			AND D.STATUS <> 'X'							-- de status ongelijk is aan X
			AND D.EPISODE IN (
				SELECT	A.EPISODE
				FROM	D001_EPISODE_EPISODE A, D001_PATIENT_PATIENT B 
				WHERE	A.PATIENTNR = B.PATIENTNR 
						AND B.IsTestPatient = 0)		-- die geen testpatienten betreffen
			AND D.STROOM <> 'R'							-- die niet REVALIDATIE betreffen
			AND D.DBCNUMMER IN (
				SELECT	V.CASENR 
				FROM	D001_FAKTUUR_VERRICHT_VERRSEC V
				WHERE	V.DATUM >= @StartDatum 
						AND V.DATUM <= @PeilDatum
						AND (V.VERZEKERIN LIKE 'V%' OR V.VERZEKERIN IS NULL OR V.VERZEKERIN = '')
			)											-- waarvan de verrichtingsdatum tussen @StartDatum en @PeilDatum ligt
			AND D.ZORGTYPE IN ('L', 'R', 'I')			-- waarvan zorgtype is L, R of I
		GROUP BY FORMAT (D.BEGINDAT, 'yyyy')
		ORDER BY 2
	END
ELSE
	BEGIN
		SELECT	D.BEGINDAT,
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
		INTO    dbo.Bravis_Subtrajecten_20200101_20200430
		FROM	D001_EPISODE_DBCPER D
		WHERE	D.VERVALLEN <> 1
				AND D.BEGINDAT >= @StartDatum
				AND D.BEGINDAT <= @PeilDatum
				AND D.LOCATIE IN (
					SELECT	L.CODE 
					FROM	D001_CSZISLIB_LOCCODE L
					WHERE	L.LOCCODE = @AGBCode
				)
				AND D.STATUS <> 'X'
				AND D.EPISODE IN (
					SELECT	A.EPISODE 
					FROM	D001_EPISODE_EPISODE A, D001_PATIENT_PATIENT B 
					WHERE	A.PATIENTNR = B.PATIENTNR 
							AND B.IsTestPatient = 0
				)
				AND D.STROOM <> 'R'
				AND D.DBCNUMMER IN (
					SELECT	V.CASENR 
					FROM	D001_FAKTUUR_VERRICHT_VERRSEC V
					WHERE	V.DATUM >= @StartDatum 
							AND V.DATUM <= @PeilDatum
							AND (V.VERZEKERIN LIKE 'V%' OR V.VERZEKERIN IS NULL OR V.VERZEKERIN = '')
				)
				AND D.ZORGTYPE IN ('L', 'R', 'I')
		ORDER BY 1, 4
	END
GO
