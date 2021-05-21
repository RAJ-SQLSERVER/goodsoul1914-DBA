/****** Script for SelectTopNRows command from SSMS  ******/
SELECT dtn.Guid
      , dtv.StringValue
      --, [SeriesTypeGuid]
	  --, st.Name as SeriesTypeName
      ,[ExamTypeGuid]
	  , et.Name as ExamTypeName
      ,[Parent]
      ,[AnatomyClassificationBodyPart]
  FROM DdpTypeNode dtn
  --JOIN SeriesType st ON dtn.SeriesTypeGuid = st.Guid
  JOIN DdpTypeValue dtv on dtn.Guid = dtv.NodeGuid
  JOIN ExamType et ON et.Guid = dtn.ExamTypeGuid
  ORDER BY StringValue