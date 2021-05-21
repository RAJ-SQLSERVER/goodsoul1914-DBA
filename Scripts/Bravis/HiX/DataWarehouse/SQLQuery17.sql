
SELECT	vl.VERVERSING, OMSCHRIJVING, STARTDATE, STARTTIME, ENDDATE, ENDTIME, STATUS, TOTALDURATION, MODEL, ACTION, SUBJECT, 
		vr.CHOSENMODELS, vr.DWHVersie, vr.EzisVersie, vr.EzisHotfix, vr.ErrorCode, vr.MailSend, vr.ZHOmgeving
FROM [CSDW_Acceptatie].[dbo].[DWHHlpVerversingslog] vl
JOIN [CSDW_Acceptatie].[dbo].[DWHHlpVerversingsResultaat] vr ON vr.Verversing = vl.VERVERSING
WHERE ACTION = 'Totaal' AND SUBJECT = 'Loading' --AND vl.VERVERSING = 769


SELECT *
FROM	[CSDW_Acceptatie].[dbo].[DWHHlpVerversingsResultaat]
WHERE	Datum >= GETDATE() - 7 AND EindDatum IS NOT NULL --AND Verversing >= 804;
