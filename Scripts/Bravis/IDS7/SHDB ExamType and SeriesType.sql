/****** Script for SelectTopNRows command from SSMS  ******/
SELECT st2et.[Guid]
      --,[ExamTypeGuid]
	  , et.Name as ExamTypeName
      --,[SeriesTypeGuid]
	  , st.Name as SeriesTypeName
	  , st.Notes
      ,[SeriesTypeOrder]
FROM SeriesTypeToExamType st2et
JOIN SeriesType st on st.Guid = st2et.SeriesTypeGuid
JOIN ExamType et on et.Guid = st2et.ExamTypeGuid
ORDER BY et.Name, SeriesTypeOrder