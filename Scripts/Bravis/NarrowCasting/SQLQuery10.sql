-- WACHTTIJD IN MIN. = (TIJDSTIP LAATSTE OPROEP + DUUR IN MIN.) - HUIDIGE TIJDSTIP ?
-- Nee, want pauzes worden dan niet meegerekend
-- 

WITH cteRowNum AS																		-- Alle afspraken waarvoor geldt:
(
    SELECT	A.AGENDA, A.SUBAGENDA, ZLA.PREZIES, UITVOERDER, VOORLETTER, PONSNAAM, REKCODE, LOCOMSCH, TIJD, OPROEP, CONSTYPE, DUUR
			, DENSE_RANK() OVER(PARTITION BY A.AGENDA, A.SUBAGENDA ORDER BY TIJD DESC) AS RowNum
    FROM	AGENDA_AFSPRAAK A 
	JOIN	CSZISLIB_ARTS ZLA ON ZLA.ARTSCODE = A.UITVOERDER
	JOIN	AGENDA_SUBAGEND S ON S.SUBAGENDA = A.SUBAGENDA
	JOIN	CSZISLIB_LOCCODE LC ON LC.CODE = A.LOKATIE
    WHERE	DATUM = CONVERT(CHAR(10), GETDATE(), 126)									-- Datum is vandaag
			AND A.PATIENTNR <> ''														-- Patientnummer is niet leeg		
			AND A.CONSTYPE IN ('E', 'H', 'V')											-- Consulttype is E, H of V (is soms *, wat dan?)
			--AND CAST(DATEADD(MI, A.DUUR, A.TIJD) AS TIME) < CAST(GETDATE() AS TIME)	-- Tijdstip einde afspraak/consult < huidige tijd
			AND CAST(A.TIJD AS TIME) < CAST(GETDATE() AS TIME)							-- Tijdstip afspraak/consult < huidige tijd
			AND A.UITVOERDER LIKE 'I%'													-- Uitvoerder code begint met I*
			AND EXISTS (															 
				SELECT	1																-- Uitvoerder heeft deze dag nog meer afspraken op deze agenda/subagenda combinatie
				FROM	AGENDA_AFSPRAAK a
				WHERE	DATUM = A.DATUM 
						AND TIJD > CONVERT(VARCHAR(5), GETDATE(), 108) 
						AND UITVOERDER = A.UITVOERDER 
						AND AGENDA = A.AGENDA 
						AND SUBAGENDA = A.SUBAGENDA
			)
)
SELECT	DISTINCT AGENDA																	-- Hoe kan dit dubbele afspraken opleveren?
		, SUBAGENDA 
		, UITVOERDER 
		, VOORLETTER 
		, PONSNAAM 
		, REKCODE																		-- Wat te doen al REKCODE leeg is?
		, LOCOMSCH 
		, DATUM = CONVERT(CHAR(10), GETDATE(), 126)
		, TIJD
		, DUUR
		, OPROEP	
		, CASE 
			WHEN DATEDIFF(MI, TIJD, OPROEP) < 0 THEN 0
			ELSE ROUND(DATEDIFF(MI, TIJD, OPROEP), -1)
		END AS WACHTTIJD
		, RowNum																		
		, CONSTYPE
FROM	cteRowNum 
--WHERE	RowNum = 1																	-- Laatste afspraak op AGENDA/SUBAGENDA combinatie, waarom?
